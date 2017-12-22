require 'openstudio'
require 'openstudio/ruleset/ShowRunnerOutput'
require 'minitest/autorun'

require_relative '../measure.rb'

require 'fileutils'

class EnhancedLEEDSummaryReport_Test < MiniTest::Unit::TestCase

  def is_openstudio_2?
    begin
      workflow = OpenStudio::WorkflowJSON.new
    rescue
      return false
    end
    return true
  end

  def model_in_path_default
    return "#{File.dirname(__FILE__)}/ExampleModel.osm"
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
    puts "begin of setup_test_2"

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
    puts "end of setup_test_2"
  end

  # create test files if they do not exist when the test first runs
  def setup_test(test_name, idf_output_requests, model_in_path = model_in_path_default, epw_path = epw_path_default)
    puts "begin of setup_test"
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
    workspace.addObjects(idf_output_requests)

#    # add tariff to workspace for testing    
#    new_object_string = "
#      UtilityCost:Tariff,
#        Electricity Tariff,                     !- Name
#        ElectricityPurchased:Facility,          !- Output Meter Name
#        kWh,                                    !- Conversion Factor Choice
#        ,                                       !- Energy Conversion Factor
#        ,                                       !- Demand Conversion Factor
#        ,                                       !- Time of Use Period Schedule Name
#        ,                                       !- Season Schedule Name
#        ,                                       !- Month Schedule Name
#        Day,                                    !- Demand Window Length
#        0.0;                                    !- Monthly Charge or Variable Name
#        "
#    elec_tariff = workspace.addObject(OpenStudio::IdfObject::load(new_object_string).get).get
#
#    # make UtilityCost:Charge:Simple objects for electricity
#    new_object_string = "
#      UtilityCost:Charge:Simple,
#        ElectricityTariffEnergyCharge, !- Name
#        Electricity Tariff,                     !- Tariff Name
#        totalEnergy,                            !- Source Variable
#        Annual,                                 !- Season
#        EnergyCharges,                          !- Category Variable Name
#        0.12;                                   !- Cost per Unit Value or Variable Name
#        "
#    elec_utility_cost = workspace.addObject(OpenStudio::IdfObject::load(new_object_string).get).get
#    
#    puts "elec_tariff", elec_tariff
#    puts "elec_utility_cost", elec_utility_cost
#    puts "workspace", workspace
#    
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
    puts "end of setup_test"
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

  def test_good_argument_values
    puts "begin of test_good_argument_values"
    test_name = 'test_good_argument_values'

    # create an instance of the measure
    measure = EnhancedLEEDSummaryReport.new

    # create an instance of a runner
    runner = OpenStudio::Ruleset::OSRunner.new

    # get arguments
    arguments = measure.arguments
    argument_map = OpenStudio::Ruleset.convertOSArgumentVectorToMap(arguments)

    # create hash of argument values
    args_hash = {}

    # populate argument with specified hash value if specified
    arguments.each do |arg|
      temp_arg_var = arg.clone
      if args_hash[arg.name]
        assert(temp_arg_var.setValue(args_hash[arg.name]))
      end
      argument_map[arg.name] = temp_arg_var
    end

    # get the energyplus output requests, this will be done automatically by OS App and PAT
    idf_output_requests = measure.energyPlusOutputRequests(runner, argument_map)
    assert_equal(0, idf_output_requests.size)

    # mimic the process of running this measure in OS App or PAT
    epw_path = epw_path_default
    setup_test(test_name, idf_output_requests)

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
      measure.run(runner, argument_map)
      result = runner.result
      show_output(result)
      assert_equal('Success', result.value.valueName)

      # look for section_errors
      assert(section_errors(runner).size == 0)

    ensure
      Dir.chdir(start_dir)
    end

    # make sure the report file exists
    assert(File.exist?(report_path(test_name)))
    puts "end of test_good_argument_values"
  end
  
 def test_tariff      
    puts "begin test_tariff"
    test_name = 'tariff'
    model_in_path = "#{File.dirname(__FILE__)}/ExampleModel.osm"

    # create an instance of the measure
    measure = EnhancedLEEDSummaryReport.new

    # create an instance of a runner
    runner = OpenStudio::Ruleset::OSRunner.new

    # get arguments
    arguments = measure.arguments
    argument_map = OpenStudio::Ruleset.convertOSArgumentVectorToMap(arguments)

    # create hash of argument values
    args_hash = {}

    # populate argument with specified hash value if specified
    arguments.each do |arg|
      temp_arg_var = arg.clone
      if args_hash[arg.name]
        assert(temp_arg_var.setValue(args_hash[arg.name]))
      end
      argument_map[arg.name] = temp_arg_var
    end

    # get the energyplus output requests, this will be done automatically by OS App and PAT
    idf_output_requests = measure.energyPlusOutputRequests(OpenStudio::Measure::OSRunner.new(OpenStudio::WorkflowJSON.new), argument_map)
    assert_equal(0, idf_output_requests.size)

    # mimic the process of running this measure in OS App or PAT
    epw_path = epw_path_default

    # temporarily change directory to the run directory and run the measure
    start_dir = Dir.pwd
    begin
      if !File.exist?(run_dir(test_name))
        FileUtils.mkdir_p(run_dir(test_name))
      end
      assert(File.exist?(run_dir(test_name)))
      Dir.chdir(run_dir(test_name))

      # copy osw, osm, and epw to test directory and run from there.
      source_osw = '../../add_tariff.osw'
      target_osw = 'in.osw'
      FileUtils.cp(source_osw, target_osw)
      target_osm = 'TestOutput.osm'

      # convert output requests to OSM for testing, OS App and PAT will add these to the E+ Idf
      workspace = OpenStudio::Workspace.new("Draft".to_StrictnessLevel, "EnergyPlus".to_IddFileType)
      workspace.addObjects(idf_output_requests)
      rt = OpenStudio::EnergyPlus::ReverseTranslator.new
      request_model = rt.translateWorkspace(workspace)

      translator = OpenStudio::OSVersion::VersionTranslator.new
      model = translator.loadModel(model_in_path)
      assert((not model.empty?))
      model = model.get
      model.addObjects(request_model.objects)
      model.save(target_osm, true)

      # create osw that calls tariff measure. That measure needs to sit adjacent ot this one
      cli_path = OpenStudio.getOpenStudioCLI
      cmd = "\"#{cli_path}\" run -w \"in.osw\""
      system(cmd)

    ensure
      Dir.chdir(start_dir)
    end

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
      measure.run(runner, argument_map)
      result = runner.result
      show_output(result)
      assert_equal('Success', result.value.valueName)

      # look for section_errors
      assert(section_errors(runner).size == 0)

    ensure
      Dir.chdir(start_dir)
    end

    # make sure the report file exists
    assert(File.exist?(report_path(test_name)))
  end
  
  
end