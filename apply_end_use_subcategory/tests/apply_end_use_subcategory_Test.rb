require 'openstudio'
require 'openstudio/ruleset/ShowRunnerOutput'
require 'minitest/autorun'

require_relative '../measure.rb'

require 'fileutils'

class ApplyEndUseSubcategory_Test < MiniTest::Unit::TestCase

  def is_openstudio_2?
    begin
      workflow = OpenStudio::WorkflowJSON.new
    rescue
      return false
    end
    return true
  end

  def model_in_path_default
    #return "#{File.dirname(__FILE__)}/EnvelopeAndLoadTestModel_01.osm"
    return "#{File.dirname(__FILE__)}/test5.osm"
  end

  def epw_path_default
    # make sure we have a weather data location
    epw = nil
    epw = OpenStudio::Path.new("#{File.dirname(__FILE__)}/USA_CO_Golden-NREL.724666_TMY3.epw")
    assert(File.exist?(epw.to_s))
    return epw.to_s
  end

  def run_dir(test_name)
    # always generate test output in specially named 'output' directory so result files are not made part of the measure
    "#{File.dirname(__FILE__)}/output/#{test_name}"
  end

  def model_out_path(test_name)
    "#{run_dir(test_name)}/TestOutput.osm"
  end

  def workspace_path(test_name)
    if is_openstudio_2?
      return "#{run_dir(test_name)}/run/in.idf"
    else
      return "#{run_dir(test_name)}/ModelToIdf/in.idf"
    end
  end

  def sql_path(test_name)
    if is_openstudio_2?
      return "#{run_dir(test_name)}/run/eplusout.sql"
    else
      return "#{run_dir(test_name)}/ModelToIdf/EnergyPlusPreProcess-0/EnergyPlus-0/eplusout.sql"
    end
  end

  def report_path(test_name)
    "#{run_dir(test_name)}/report.html"
  end

  # method for running the test simulation using OpenStudio 1.x API
  def setup_test_1(test_name, epw_path)

    co = OpenStudio::Runmanager::ConfigOptions.new(true)
    co.findTools(false, true, false, true)

    if !File.exist?(sql_path(test_name))
      puts "Running EnergyPlus"

      wf = OpenStudio::Runmanager::Workflow.new("modeltoidf->energypluspreprocess->energyplus")
      wf.add(co.getTools())
      job = wf.create(OpenStudio::Path.new(run_dir(test_name)), OpenStudio::Path.new(model_out_path(test_name)), OpenStudio::Path.new(epw_path))

      rm = OpenStudio::Runmanager::RunManager.new
      rm.enqueue(job, true)
      rm.waitForFinished
    end
  end

  # method for running the test simulation using OpenStudio 2.x API
  def setup_test_2(test_name, epw_path)
    if !File.exist?(sql_path(test_name))
      osw_path = File.join(run_dir(test_name), 'in.osw')
      osw_path = File.absolute_path(osw_path)

      workflow = OpenStudio::WorkflowJSON.new
      workflow.setSeedFile(File.absolute_path(model_out_path(test_name)))
      workflow.setWeatherFile(File.absolute_path(epw_path))
      workflow.saveAs(osw_path)

      cli_path = OpenStudio.getOpenStudioCLI
      cmd = "\"#{cli_path}\" run -w \"#{osw_path}\""
      puts cmd
      system(cmd)
    end
  end

  # create test files if they do not exist when the test first runs
  def setup_test(test_name, model_in_path = model_in_path_default, epw_path = epw_path_default)
    if !File.exist?(run_dir(test_name))
      FileUtils.mkdir_p(run_dir(test_name))
    end
    assert(File.exist?(run_dir(test_name)))

    if File.exist?(report_path(test_name))
      FileUtils.rm(report_path(test_name))
    end

    assert(File.exist?(model_in_path))

    if File.exist?(model_out_path(test_name))
      FileUtils.rm(model_out_path(test_name))
    end

    # convert output requests to OSM for testing, OS App and PAT will add these to the E+ Idf
    workspace = OpenStudio::Workspace.new("Draft".to_StrictnessLevel, "EnergyPlus".to_IddFileType)
    #workspace.addObjects(idf_output_requests)
    rt = OpenStudio::EnergyPlus::ReverseTranslator.new
    request_model = rt.translateWorkspace(workspace)

    translator = OpenStudio::OSVersion::VersionTranslator.new
    model = translator.loadModel(model_in_path)
    assert((not model.empty?))
    model = model.get
    model.addObjects(request_model.objects)
    model.save(model_out_path(test_name), true)

    if is_openstudio_2?
      setup_test_2(test_name, epw_path)
    else
      setup_test_1(test_name, epw_path)
    end
  end

  # assert that no section errors were thrown
  def section_errors(runner)

    test_string = 'Error prevented QAQC check from running'

    if is_openstudio_2?
      section_errors = []
      runner.result.stepWarnings.each do |warning|
        if warning.include?(test_string)
          section_errors << warning
        end
      end
      assert(section_errors.size == 0)
    else
      section_errors = []
      runner.result.warnings.each do |warning|
        if warning.logMessage.include?(test_string)
          section_errors << warning
        end
      end
      assert(section_errors.size == 0)
    end

    return section_errors

  end

  def test_good_argument_values_exteriorlights_wild
    test_name = 'test_good_argument_values_exteriorlights_wild'

    # create an instance of the measure
    measure = ApplyEndUseSubcategory.new

    # create an instance of a runner
    runner = OpenStudio::Ruleset::OSRunner.new

    # get model
    translator = OpenStudio::OSVersion::VersionTranslator.new
    model = translator.loadModel(model_in_path_default)
    assert((not model.empty?))
    model = model.get

    # get arguments
    arguments = measure.arguments(model)
    argument_map = OpenStudio::Ruleset.convertOSArgumentVectorToMap(arguments)
 
    # create hash of argument values
    args_hash = {}

    args_hash["end_use_subcategory"] = "Facade Lighting"
    args_hash["name_obj_choice_obj"] = "All Objects of Type - OS:Exterior:Lights"

    # populate argument with specified hash value if specified
    arguments.each do |arg|
      temp_arg_var = arg.clone
      if args_hash[arg.name]
        assert(temp_arg_var.setValue(args_hash[arg.name]))
      end
      argument_map[arg.name] = temp_arg_var
    end

    # mimic the process of running this measure in OS App or PAT
    epw_path = epw_path_default
    setup_test(test_name) # was setup_test(test_name,idf_output_requests)

    assert(File.exist?(model_out_path(test_name)))
    assert(File.exist?(sql_path(test_name)))
    assert(File.exist?(epw_path))

    # set up runner, this will happen automatically when measure is run in PAT or OpenStudio
    runner.setLastOpenStudioModelPath(OpenStudio::Path.new(model_out_path(test_name)))
    runner.setLastEnergyPlusWorkspacePath(OpenStudio::Path.new(workspace_path(test_name)))
    runner.setLastEpwFilePath(epw_path)
    runner.setLastEnergyPlusSqlFilePath(OpenStudio::Path.new(sql_path(test_name)))

    # delete the output if it exists
    if File.exist?(report_path(test_name))
      FileUtils.rm(report_path(test_name))
    end
    assert(!File.exist?(report_path(test_name)))

    # temporarily change directory to the run directory and run the measure
    start_dir = Dir.pwd
    begin
      Dir.chdir(run_dir(test_name))

      # run the measure
      measure.run(model, runner, argument_map)
      result = runner.result
      show_output(result)
      assert_equal('Success', result.value.valueName)
      
      objs_of_selected = model.getObjectsByType("OS:Exterior:Lights".to_IddObjectType)
      obj0 = objs_of_selected[0].to_ExteriorLights.get
      obj1 = objs_of_selected[1].to_ExteriorLights.get
      
      # test the names of the objects
      assert_equal(obj0.name.to_s,"NonDimming Exterior Lights Def")
      assert_equal(obj1.name.to_s,"Occ Sensing Exterior Lights Def")
      
      # test the end use subcategory
      assert_equal(obj0.endUseSubcategory, "Facade Lighting")
      assert_equal(obj1.endUseSubcategory, "Facade Lighting")

    ensure
      Dir.chdir(start_dir)
    end

  end

  def test_good_argument_values_lights
    test_name = 'test_good_argument_values_lights'

    # create an instance of the measure
    measure = ApplyEndUseSubcategory.new

    # create an instance of a runner
    runner = OpenStudio::Ruleset::OSRunner.new

    # get model
    translator = OpenStudio::OSVersion::VersionTranslator.new
    model = translator.loadModel(model_in_path_default)
    assert((not model.empty?))
    model = model.get

    # get arguments
    arguments = measure.arguments(model)
    argument_map = OpenStudio::Ruleset.convertOSArgumentVectorToMap(arguments)

    # create hash of argument values
    args_hash = {}

    args_hash["end_use_subcategory"] = "Interior lighting - process"
    args_hash["name_obj_choice_obj"] = "Office WholeBuilding - Sm Office Lights - OS:Lights"

    # populate argument with specified hash value if specified
    arguments.each do |arg|
      temp_arg_var = arg.clone
      if args_hash[arg.name]
        assert(temp_arg_var.setValue(args_hash[arg.name]))
      end
      argument_map[arg.name] = temp_arg_var
    end

    # mimic the process of running this measure in OS App or PAT
    epw_path = epw_path_default
    setup_test(test_name) # was setup_test(test_name,idf_output_requests)

    assert(File.exist?(model_out_path(test_name)))
    assert(File.exist?(sql_path(test_name)))
    assert(File.exist?(epw_path))

    # set up runner, this will happen automatically when measure is run in PAT or OpenStudio
    runner.setLastOpenStudioModelPath(OpenStudio::Path.new(model_out_path(test_name)))
    runner.setLastEnergyPlusWorkspacePath(OpenStudio::Path.new(workspace_path(test_name)))
    runner.setLastEpwFilePath(epw_path)
    runner.setLastEnergyPlusSqlFilePath(OpenStudio::Path.new(sql_path(test_name)))

    # delete the output if it exists
    if File.exist?(report_path(test_name))
      FileUtils.rm(report_path(test_name))
    end
    assert(!File.exist?(report_path(test_name)))

    # temporarily change directory to the run directory and run the measure
    start_dir = Dir.pwd
    begin
      Dir.chdir(run_dir(test_name))

      # run the measure
      measure.run(model, runner, argument_map)
      result = runner.result
      show_output(result)
      assert_equal('Success', result.value.valueName)
      
      objs_of_selected = model.getObjectsByType("OS:Lights".to_IddObjectType)
      obj0 = objs_of_selected[0].to_Lights.get
      
      # test the names of the objects
      assert_equal(obj0.name.to_s,"Office WholeBuilding - Sm Office Lights")
      
      # test the end use subcategory
      assert_equal(obj0.endUseSubcategory, "Interior lighting - process")

    ensure
      Dir.chdir(start_dir)
    end

  end

  def test_good_argument_values_elec_equip
    test_name = 'test_good_argument_values_elec_equip'

    # create an instance of the measure
    measure = ApplyEndUseSubcategory.new

    # create an instance of a runner
    runner = OpenStudio::Ruleset::OSRunner.new

    # get model
    translator = OpenStudio::OSVersion::VersionTranslator.new
    model = translator.loadModel(model_in_path_default)
    assert((not model.empty?))
    model = model.get

    # get arguments
    arguments = measure.arguments(model)
    argument_map = OpenStudio::Ruleset.convertOSArgumentVectorToMap(arguments)

    # create hash of argument values
    args_hash = {}

    args_hash["end_use_subcategory"] = "Elevators and escalators"
    args_hash["name_obj_choice_obj"] = "Office WholeBuilding - Sm Office Elec Equip - OS:ElectricEquipment"

    # populate argument with specified hash value if specified
    arguments.each do |arg|
      temp_arg_var = arg.clone
      if args_hash[arg.name]
        assert(temp_arg_var.setValue(args_hash[arg.name]))
      end
      argument_map[arg.name] = temp_arg_var
    end

    # mimic the process of running this measure in OS App or PAT
    epw_path = epw_path_default
    setup_test(test_name) # was setup_test(test_name,idf_output_requests)

    assert(File.exist?(model_out_path(test_name)))
    assert(File.exist?(sql_path(test_name)))
    assert(File.exist?(epw_path))

    # set up runner, this will happen automatically when measure is run in PAT or OpenStudio
    runner.setLastOpenStudioModelPath(OpenStudio::Path.new(model_out_path(test_name)))
    runner.setLastEnergyPlusWorkspacePath(OpenStudio::Path.new(workspace_path(test_name)))
    runner.setLastEpwFilePath(epw_path)
    runner.setLastEnergyPlusSqlFilePath(OpenStudio::Path.new(sql_path(test_name)))

    # delete the output if it exists
    if File.exist?(report_path(test_name))
      FileUtils.rm(report_path(test_name))
    end
    assert(!File.exist?(report_path(test_name)))

    # temporarily change directory to the run directory and run the measure
    start_dir = Dir.pwd
    begin
      Dir.chdir(run_dir(test_name))

      # run the measure
      measure.run(model, runner, argument_map)
      result = runner.result
      show_output(result)
      assert_equal('Success', result.value.valueName)
      
      objs_of_selected = model.getObjectsByType("OS:ElectricEquipment".to_IddObjectType)
      obj0 = objs_of_selected[0].to_ElectricEquipment.get
      
      # test the names of the objects
      assert_equal(obj0.name.to_s,"Office WholeBuilding - Sm Office Elec Equip")
      
      # test the end use subcategory
      assert_equal(obj0.endUseSubcategory, "Elevators and escalators")

    ensure
      Dir.chdir(start_dir)
    end

  end

  def test_good_argument_values_fans_wild
    test_name = 'test_good_argument_values_fans_wild'

    # create an instance of the measure
    measure = ApplyEndUseSubcategory.new

    # create an instance of a runner
    runner = OpenStudio::Ruleset::OSRunner.new

    # get model
    translator = OpenStudio::OSVersion::VersionTranslator.new
    model = translator.loadModel(model_in_path_default)
    assert((not model.empty?))
    model = model.get

    # get arguments
    arguments = measure.arguments(model)
    argument_map = OpenStudio::Ruleset.convertOSArgumentVectorToMap(arguments)
 
    # create hash of argument values
    args_hash = {}

    args_hash["end_use_subcategory"] = "Fans - Kitchen Ventilation"
    args_hash["name_obj_choice_obj"] = "All Objects of Type - OS:Fan:OnOff"

    # populate argument with specified hash value if specified
    arguments.each do |arg|
      temp_arg_var = arg.clone
      if args_hash[arg.name]
        assert(temp_arg_var.setValue(args_hash[arg.name]))
      end
      argument_map[arg.name] = temp_arg_var
    end

    # mimic the process of running this measure in OS App or PAT
    epw_path = epw_path_default
    setup_test(test_name) # was setup_test(test_name,idf_output_requests)

    assert(File.exist?(model_out_path(test_name)))
    assert(File.exist?(sql_path(test_name)))
    assert(File.exist?(epw_path))

    # set up runner, this will happen automatically when measure is run in PAT or OpenStudio
    runner.setLastOpenStudioModelPath(OpenStudio::Path.new(model_out_path(test_name)))
    runner.setLastEnergyPlusWorkspacePath(OpenStudio::Path.new(workspace_path(test_name)))
    runner.setLastEpwFilePath(epw_path)
    runner.setLastEnergyPlusSqlFilePath(OpenStudio::Path.new(sql_path(test_name)))

    # delete the output if it exists
    if File.exist?(report_path(test_name))
      FileUtils.rm(report_path(test_name))
    end
    assert(!File.exist?(report_path(test_name)))

    # temporarily change directory to the run directory and run the measure
    start_dir = Dir.pwd
    begin
      Dir.chdir(run_dir(test_name))

      # run the measure
      measure.run(model, runner, argument_map)
      result = runner.result
      show_output(result)
      assert_equal('Success', result.value.valueName)
      
      objs_of_selected = model.getObjectsByType("OS:Fan:OnOff".to_IddObjectType)
      obj0 = objs_of_selected[0].to_FanOnOff.get
      obj1 = objs_of_selected[1].to_FanOnOff.get
      obj2 = objs_of_selected[2].to_FanOnOff.get
      obj3 = objs_of_selected[3].to_FanOnOff.get
      obj4 = objs_of_selected[4].to_FanOnOff.get
      
      # test the names of the objects
      assert_equal(obj0.name.to_s,"Perimeter_ZN_1 ZN PSZ-AC-2 Fan")
      assert_equal(obj1.name.to_s,"Perimeter_ZN_2 ZN PSZ-AC-3 Fan")
      assert_equal(obj2.name.to_s,"Perimeter_ZN_3 ZN PSZ-AC-4 Fan")
      assert_equal(obj3.name.to_s,"Perimeter_ZN_4 ZN PSZ-AC-5 Fan")
      assert_equal(obj4.name.to_s,"Core_ZN ZN PSZ-AC-1 Fan")
      
      # test the end use subcategory
      assert_equal(obj0.endUseSubcategory, "Fans - Kitchen Ventilation")
      assert_equal(obj1.endUseSubcategory, "Fans - Kitchen Ventilation")
      assert_equal(obj2.endUseSubcategory, "Fans - Kitchen Ventilation")
      assert_equal(obj3.endUseSubcategory, "Fans - Kitchen Ventilation")
      assert_equal(obj4.endUseSubcategory, "Fans - Kitchen Ventilation")

    ensure
      Dir.chdir(start_dir)
    end

  end


end
