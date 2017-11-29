#start the measure
class ApplyEndUseSubcategory < OpenStudio::Ruleset::ModelUserScript

  #define the name that a user will see
  def name
    return "Apply End-Use Subcategory"
  end

  # human readable description
  def description
    return "zx To aid in applying end-use subcategories to various objects so that they appear correctly in the reports that show breakdowns by end-use subcategory including EnergyPlus ABUPS End Uses by Subcateogry report and the report produced by the enhanced LEED summary report measure. "
  end
  # human readable description of modeling approach
  def modeler_description
    return "zAllow users to apply specific end-use subcategories to various components in their OpenStudio model. Specific predefined end-use subcategory tags that correspond to LEED end-uses that have special treatment in the LEED spreadsheet will be used such as Fans-Parking Garage, Interior Lighting-Process, Fans-Kitchen Ventilation, Elevators and Escalators, etc. The end-use subcategories for the following: Lights, ElectricEquipment, GasEquipment, HotWaterEquipment, SteamEquipment, OtherEquipment, Exterior:Lights, Fan:ConstantVolume, Fan:VariableVolume, Fan:OnOff, Fan:ZoneExhaust, WaterHeater:Stratified, EnergyManagementSystem:MeteredOutputVariable, Refrigeration:Condenser:AirCooled, Refrigeration:Condenser:EvaporativeCooled, Refrigeration:Condenser:WaterCooled, Refrigeration:GasCooler:AirCooled, Refrigeration:Compressor, Refrigeration:System. Refrigeration:TranscriticalSystem, Refrigeration:SecondarySystem"
  end


  def list_of_idd_objects
    list = []
    list << "Lights"
    list << "ElectricEquipment" 
    list << "GasEquipment"
    list << "HotWaterEquipment"
    list << "SteamEquipment"
    list << "OtherEquipment"
    list << "Exterior:Lights"
    list << "Fan:ConstantVolume"
    list << "Fan:VariableVolume"
    list << "Fan:OnOff"
    list << "Fan:ZoneExhaust"
    list << "WaterHeater:Stratified"
    list << "EnergyManagementSystem:MeteredOutputVariable"
    list << "Refrigeration:Condenser:AirCooled"
    list << "Refrigeration:Condenser:EvaporativeCooled"
    list << "Refrigeration:Condenser:WaterCooled"
    list << "Refrigeration:GasCooler:AirCooled"
    list << "Refrigeration:Compressor"
    list << "Refrigeration:System"
    list << "Refrigeration:TranscriticalSystem"
    list << "Refrigeration:SecondarySystem"
    return list
  end

  #define the arguments that the user will input
  def arguments(model)
    args = OpenStudio::Ruleset::OSArgumentVector.new
    idd_objects =  list_of_idd_objects  
    name_obj_choice = OpenStudio::StringVector.new
    name_obj_choice_obj = OpenStudio::StringVector.new
    idd_objects.each do |idd_object|
      os_objs = model.getObjectsByType("OS:#{idd_object}".to_IddObjectType)
      os_objs.each do |os_obj|
        name_obj_choice << "#{os_obj.name.to_s} - OS:#{idd_object}"   
      end
      if os_objs.length >= 2
        name_obj_choice << "All Objects of Type - OS:#{idd_object}"   
      end
    end    
    name_obj_choice_obj = OpenStudio::Ruleset::OSArgument::makeChoiceArgument('Name of Object - Type of Object', name_obj_choice, true)
    args << name_obj_choice_obj
    
    end_use_choice = OpenStudio::StringVector.new
    end_use_choice << "Fans - interior ventilation"
    end_use_choice << "Fans - parking garage"
    end_use_choice << "IT Equipment"
    end_use_choice << "Interior lighting - process"
    end_use_choice << "Fans - Kitchen Ventilation"
    end_use_choice << "Industrial Process"
    end_use_choice << "Elevators and escalators"
    end_use_choice << "Heat Pump Supplementary"
    end_use_choice << "Misc Equipment"
    end_use_choice << "Auxiliary"
    end_use_choice << "----------------------"
    end_use_choice << "Lighting In Apartments"
    end_use_choice << "Cooking"
    end_use_choice << "IT Equipment CPU"
    end_use_choice << "IT Equipment Fans"
    end_use_choice << "IT Equipment UPS"
    end_use_choice << "Refrigeration Equipment Unregulated"
    end_use_choice << "Refrigeration Equipment Regulated"
    end_use_choice << "Building Transformers"
    end_use_choice << "Computers"
    end_use_choice << "Office Equipment"
    end_use_choice << "Grounds Lights"
    end_use_choice << "Facade Lighting"
    end_use_choice << "Parking Lighting"
    end_use_choice << "Accent Lighting"
    end_use_choice << "Task Lights"
    end_use_choice << "Clothes Washing"
    end_use_choice << "Clothes Drying"
    end_use_choice << "Zone Exhaust Fans"
    end_use_choice << "Fume Hoods"
    end_use_choice << "Bathrooms"
    end_use_choice << "Dishwashing"
    end_use_choice << "Showers"
    end_use_choice << "Bathroom Handwashing"
    end_use_choice << "Kitchen Sink"
    end_use_choice << "Light Food Prep"
    end_use_choice << "Rain and Well Water"
    end_use_choice << "Other 1"
    end_use_choice << "Other 2"
    end_use_choice << "Other 3"
    end_use_choice << "Other 4"
    end_use_choice << "Other 5"
    end_use_choice << "Other 6"
    end_use_choice << "Other 7"
    end_use_choice << "Other 8"
    end_use_choice << "Other 9"
    end_use_subcategory = OpenStudio::Ruleset::OSArgument::makeChoiceArgument('End Use Subcategory', end_use_choice, true)
    args << end_use_subcategory
    return args
  end #end the arguments method

  #define what happens when the measure is run
  def run(model, runner, user_arguments)
    super(model, runner, user_arguments)
    #use the built-in error checking
    if not runner.validateUserArguments(arguments(model), user_arguments)
      return false
    end
    
    #assign the user inputs to variables
    selected_name_obj = runner.getStringArgumentValue('Name of Object - Type of Object',user_arguments)
    name_of_obj, type_of_object = selected_name_obj.split(' - OS:')
    if selected_name_obj.empty?
      runner.registerError("No object was chosen.")
    else
      runner.registerInfo("The selected object name: '#{selected_name_obj}' with the name of the object: '#{name_of_obj}' and the type of object: '#{type_of_object}'")
    end

    selected_subcategory = runner.getStringArgumentValue('End Use Subcategory',user_arguments)
    if selected_subcategory.empty?
      runner.registerError("No end use subcategory was chosen.")
    else
      runner.registerInfo("The selected end use subcategory: #{selected_subcategory}")
    end

    objs_of_selected = model.getObjectsByType("OS:#{type_of_object}".to_IddObjectType)
    if name_of_obj == "All Objects of Type"
      runner.registerInitialCondition("The model includes #{objs_of_selected.size} objects of type 'OS:#{type_of_object}'.")
      objs_of_selected.each do |obj|
        obj.setEndUseSubcategory(selected_subcategory)
      end
      runner.registerFinalCondition("The end-use subcategory '#{selected_subcategory}' has been applied to #{objs_of_selected.size} objects of type 'OS:#{type_of_object}'.")
    else # single object
      found = false
      objs_of_selected.each do |obj|
        if name_of_obj == obj.name.to_s
          runner.registerInfo("An object of type 'OS:#{type_of_object}' named '#{obj.name.to_s}' was found.")
#          runner.registerInfo( obj.methods.join(","))
#          mod_obj = obj.to_ModelObject
#          runner.registerInfo( "===================================================")
#          runner.registerInfo( mod_obj.methods.join(","))
          found = true
          if obj.isEndUseSubcategoryDefaulted()
            runner.registerInitialCondition("The object '#{name_of_obj}' of type 'OS:#{type_of_object}' was initially defaulted.")
          else
            existing_string = obj.endUseSubcategory
            runner.registerInitialCondition("The object '#{name_of_obj}' of type 'OS:#{type_of_object}' was initially had the value of #{existing_string}.")
          end
          obj.setEndUseSubcategory(selected_subcategory)
          runner.registerFinalCondition("The end-use subcategory '#{selected_subcategory}' has been applied to an object of type 'OS:#{type_of_object}' named '#{name_of_obj}'.")
        end
      end  
      if not found
        runner.registerError("The object '#{name_of_obj}' of type 'OS:#{type_of_object}' was missing and the end-use subcategory of '#{selected_subcategory}' could not be applied.")
      end
    end # end if name_of_obj == "All Objects of Type"
  end #end the run method

end #end the measure

#this allows the measure to be used by the application
ApplyEndUseSubcategory.new.registerWithApplication