require 'json'

module OsLib_Reporting

  # setup - get model, sql, and setup web assets path
  def self.setup(runner)
    results = {}

    # get the last model
    model = runner.lastOpenStudioModel
    if model.empty?
      runner.registerError('Cannot find last model.')
      return false
    end
    model = model.get

    # get the last idf
    workspace = runner.lastEnergyPlusWorkspace
    if workspace.empty?
      runner.registerError('Cannot find last idf file.')
      return false
    end
    workspace = workspace.get

    # get the last sql file
    sqlFile = runner.lastEnergyPlusSqlFile
    if sqlFile.empty?
      runner.registerError('Cannot find last sql file.')
      return false
    end
    sqlFile = sqlFile.get
    model.setSqlFile(sqlFile)

    # populate hash to pass to measure
    results[:model] = model
    # results[:workspace] = workspace
    results[:sqlFile] = sqlFile
    results[:web_asset_path] = OpenStudio.getSharedResourcesPath / OpenStudio::Path.new('web_assets')

    return results
  end

# -----------------------------------------------------------------------------------------------
# LEED Report start

# define each section

  def self.general_information_section(model, sqlFile, runner, name_only = false)
    # array to hold tables
    tables = []

    # gather data for section
    @geninfo_sect = {}
    @geninfo_sect[:title] = 'General Information Tab'
    @geninfo_sect[:tables] = tables

    # stop here if only name is requested this is used to populate display name for arguments
    if name_only == true
      return @geninfo_sect
    end

    # using helper method that generates table for second example
    tables << OsLib_Reporting.general_information_general_table(model, sqlFile, runner)
    tables << OsLib_Reporting.general_information_energyModelInfo_table(model, sqlFile, runner)

    return @geninfo_sect
  end

  def self.schedules_section(model, sqlFile, runner, name_only = false)
    # array to hold tables
    tables = []

    # gather data for section
    @schedules_sect = {}
    @schedules_sect[:title] = 'Schedules Tab'
    @schedules_sect[:tables] = tables

    # stop here if only name is requested this is used to populate display name for arguments
    if name_only == true
      return @schedules_sect
    end

    # using helper method that generates table for second example
    tables << OsLib_Reporting.schedules_EFLH_table(model, sqlFile, runner)
    tables << OsLib_Reporting.schedules_SetPts_table(model, sqlFile, runner)

    return @schedules_sect
  end


  def self.eflh_section(model, sqlFile, runner, name_only = false)
    # array to hold tables
    tables = []

    # gather data for section
    @eflh_sect = {}
    @eflh_sect[:title] = 'EFLH Calculator Tab'
    @eflh_sect[:tables] = tables

    # stop here if only name is requested this is used to populate display name for arguments
    if name_only == true
      return @eflh_sect
    end

    # using helper method that generates table for second example
    tables << OsLib_Reporting.experiment1_table(model, sqlFile, runner)

    return @eflh_sect
  end

  def self.opaque_section(model, sqlFile, runner, name_only = false)
    # array to hold tables
    tables = []

    # gather data for section
    @opaque_sect = {}
    @opaque_sect[:title] = 'Opaque Assemblies Tab'
    @opaque_sect[:tables] = tables

    # stop here if only name is requested this is used to populate display name for arguments
    if name_only == true
      return @opaque_sect
    end

    # using helper method that generates table for second example
    tables << OsLib_Reporting.opaque_assemblies_table(model, sqlFile, runner)

    return @opaque_sect
  end

  def self.fene_section(model, sqlFile, runner, name_only = false)
    # array to hold tables
    tables = []

    # gather data for section
    @fene_sect = {}
    @fene_sect[:title] = 'Shading and Fenestration Tab'
    @fene_sect[:tables] = tables

    # stop here if only name is requested this is used to populate display name for arguments
    if name_only == true
      return @fene_sect
    end

    # using helper method that generates table for second example
    tables << OsLib_Reporting.fene_wallGlazeArea_table(model, sqlFile, runner)
    tables << OsLib_Reporting.fene_roofSkyliteArea_table(model, sqlFile, runner)

    return @fene_sect
  end

  def self.lighting_section(model, sqlFile, runner, name_only = false)
    # array to hold tables
    tables = []

    # gather data for section
    @lite_sect = {}
    @lite_sect[:title] = 'Lighting Tab'
    @lite_sect[:tables] = tables

    # stop here if only name is requested this is used to populate display name for arguments
    if name_only == true
      return @lite_sect
    end

    # using helper method that generates table for second example
    tables << OsLib_Reporting.lighting_intLite_table(model, sqlFile, runner)
    tables << OsLib_Reporting.lighting_extLite_table(model, sqlFile, runner)

    return @lite_sect
  end

  def self.process_section(model, sqlFile, runner, name_only = false)
    # array to hold tables
    tables = []

    # gather data for section
    @proc_sect = {}
    @proc_sect[:title] = 'Process Loads Tab'
    @proc_sect[:tables] = tables

    # stop here if only name is requested this is used to populate display name for arguments
    if name_only == true
      return @proc_sect
    end

    # using helper method that generates table for second example
    tables << OsLib_Reporting.process_plugPower_table(model, sqlFile, runner)
    tables << OsLib_Reporting.process_non_receptacle_gas_table(model, sqlFile, runner)
    tables << OsLib_Reporting.process_non_receptacle_hotwater_table(model, sqlFile, runner)
    tables << OsLib_Reporting.process_non_receptacle_steam_table(model, sqlFile, runner)

    return @proc_sect
  end

  def self.swh_section(model, sqlFile, runner, name_only = false)
    # array to hold tables
    tables = []

    # gather data for section
    @swh_sect = {}
    @swh_sect[:title] = 'Service Water Heating Tab'
    @swh_sect[:tables] = tables

    # stop here if only name is requested this is used to populate display name for arguments
    if name_only == true
      return @swh_sect
    end

    # using helper method that generates table for second example
    tables << OsLib_Reporting.service_water_heaters_table(model, sqlFile, runner)

    return @swh_sect
  end

  def self.airside_section(model, sqlFile, runner, name_only = false)
    # array to hold tables
    tables = []

    # gather data for section
    @airside_sect = {}
    @airside_sect[:title] = 'Air-Side HVAC Tab'
    @airside_sect[:tables] = tables

    # stop here if only name is requested this is used to populate display name for arguments
    if name_only == true
      return @airside_sect
    end

    # using helper method that generates table for second example
    tables << OsLib_Reporting.air_side_hvac_unitary_cooling_coils(model, sqlFile, runner)
    tables << OsLib_Reporting.air_side_hvac_unitary_heating_coils(model, sqlFile, runner)
    tables << OsLib_Reporting.air_side_hvac_fans(model, sqlFile, runner)

    return @airside_sect
  end

  def self.waterside_section(model, sqlFile, runner, name_only = false)
    # array to hold tables
    tables = []

    # gather data for section
    @waterside_sect = {}
    @waterside_sect[:title] = 'Water-Side HVAC Tab'
    @waterside_sect[:tables] = tables

    # stop here if only name is requested this is used to populate display name for arguments
    if name_only == true
      return @waterside_sect
    end

    # using helper method that generates table for second example
    tables << OsLib_Reporting.water_side_hvac_central_plant(model, sqlFile, runner)
    tables << OsLib_Reporting.water_side_hvac_pumps(model, sqlFile, runner)

    return @waterside_sect
  end

  def self.perf_out_section(model, sqlFile, runner, name_only = false)
    # array to hold tables
    tables = []

    # gather data for section
    @perf_sect = {}
    @perf_sect[:title] = 'Performance Outputs 1 Tab'
    @perf_sect[:tables] = tables

    # stop here if only name is requested this is used to populate display name for arguments
    if name_only == true
      return @perf_sect
    end

    # using helper method that generates table for second example
    tables << OsLib_Reporting.experiment1_table(model, sqlFile, runner)

    return @perf_sect
  end


# define each table

  # create template section
  def self.experiment1_table(model, sqlFile, runner)
    # create a second table
    template_table = {}
    template_table[:title] = 'Experiment Table Title'
    template_table[:header] = ['Type', 'Based on', 'Toppings', 'Value']
    template_table[:units] = ['', '', '', 'scoop']
    template_table[:data] = []

    # add rows to table
    template_table[:data] << ['Vanilla', 'Vanilla', 'NA', 1.5]
    template_table[:data] << ['Rocky Road', 'Vanilla', 'Nuts', 1.5]
    template_table[:data] << ['Mint Chip', 'Mint', 'Chocolate Chips', 1.5]


    # total building area
    query = 'SELECT Value FROM tabulardatawithstrings WHERE '
    query << "ReportName='AnnualBuildingUtilityPerformanceSummary' and "
    query << "ReportForString='Entire Facility' and "
    query << "TableName='End Uses' and "
    query << "RowName='Cooling' and "
    query << "ColumnName='Electricity' and "
    query << "Units='GJ';"
    query_results = sqlFile.execAndReturnFirstDouble(query)
    if query_results.empty?
      runner.registerWarning('Did not find value for total building area.')
      return false
    else
      display = 'Heating Electricity'
      source_units = 'GJ'
      target_units = 'kBtu'
      template_table[:data] << [display, query_results.get, source_units,"from SQL"]
      value = OpenStudio.convert(query_results.get, source_units, target_units).get
      value_neat = OpenStudio.toNeatString(value, 0, true)
      template_table[:data] << [display, value_neat, target_units,"from SQL"]
      runner.registerValue(display.downcase.gsub(" ","_"), value, target_units)
    end
    return template_table
  end

  def self.experiment1_Sect11A_table(model, sqlFile, runner)
    # create a second table
    template_table = {}
    template_table[:title] = 'Section 1.1 A General Information'
    template_table[:header] = ['Information', 'Value', 'Units']
    template_table[:data] = []

    # add rows to table

    # weather file
    query = 'SELECT Value FROM tabulardatawithstrings WHERE '
    query << "ReportName='LEEDsummary' and "
    query << "ReportForString='Entire Facility' and "
    query << "TableName='Sec1.1A-General Information' and "
    query << "RowName='Weather File' and "
    query << "ColumnName='Data' and "
    query << "Units='';"
    query_results = sqlFile.execAndReturnFirstString(query)
    if query_results.empty?
      runner.registerWarning('Did not find value for weather file.')
      return false
    else
      display = 'Weather File'
      value = query_results.get
      template_table[:data] << [display, value, ""]
      runner.registerValue(display.downcase.gsub(" ","_"), value, "")
    end

    # Total gross floor area
    query = 'SELECT Value FROM tabulardatawithstrings WHERE '
    query << "ReportName='LEEDsummary' and "
    query << "ReportForString='Entire Facility' and "
    query << "TableName='Sec1.1A-General Information' and "
    query << "RowName='Total gross floor area' and "
    query << "ColumnName='Data' and "
    query << "Units='m2';"
    query_results = sqlFile.execAndReturnFirstDouble(query)
    if query_results.empty?
      runner.registerWarning('Did not find value for Total gross floor area.')
      return false
    else
      display = 'Total gross floor area'
      source_units = 'm^2'
      target_units = 'ft^2'
      value = OpenStudio.convert(query_results.get, source_units, target_units).get
      value_neat = OpenStudio.toNeatString(value, 0, true)
      template_table[:data] << [display, value_neat, target_units]
      runner.registerValue(display.downcase.gsub(" ","_"), value, target_units)
    end

    # Principal Heating Source
    query = 'SELECT Value FROM tabulardatawithstrings WHERE '
    query << "ReportName='LEEDsummary' and "
    query << "ReportForString='Entire Facility' and "
    query << "TableName='Sec1.1A-General Information' and "
    query << "RowName='Principal Heating Source' and "
    query << "ColumnName='Data' and "
    query << "Units='';"
    query_results = sqlFile.execAndReturnFirstString(query)
    if query_results.empty?
      runner.registerWarning('Did not find value for Principal Heating Source.')
      return false
    else
      display = 'Principal Heating Source'
      value = query_results.get
      template_table[:data] << [display, value, ""]
      runner.registerValue(display.downcase.gsub(" ","_"), value, "")
    end
 

    return template_table
  end


  def self.general_information_general_table(model, sqlFile, runner)
    # create a second table
    template_table = {}
    template_table[:title] = 'General Information - General'
    template_table[:header] = ['Information', 'Value', 'Units']
    template_table[:data] = []

    # add rows to table


    # Conditioned building  area
    display = 'Conditioned building  area'
    source_units = 'm^2'
    target_units = 'ft^2'
    value = OpenStudio.convert(model.getBuilding.conditionedFloorArea.get(), source_units, target_units).get
    value_neat = OpenStudio.toNeatString(value, 0, true)
    template_table[:data] << [display, value_neat, target_units]
    runner.registerValue(display.downcase.gsub(" ","_"), value, target_units)

    # Unconditioned building  area
    display = 'Unconditioned building  area'
    value = OpenStudio.convert(model.getBuilding.floorArea - model.getBuilding.conditionedFloorArea.get(), source_units, target_units).get
    value_neat = OpenStudio.toNeatString(value, 0, true)
    template_table[:data] << [display, value_neat, target_units]
    runner.registerValue(display.downcase.gsub(" ","_"), value, target_units)

    # Total building  area
    display = 'Total building  area'
    value = OpenStudio.convert(model.getBuilding.floorArea, source_units, target_units).get
    value_neat = OpenStudio.toNeatString(value, 0, true)
    template_table[:data] << [display, value_neat, target_units]
    runner.registerValue(display.downcase.gsub(" ","_"), value, target_units)


    # Principal Heating Source
    query = 'SELECT Value FROM tabulardatawithstrings WHERE '
    query << "ReportName='LEEDsummary' and "
    query << "ReportForString='Entire Facility' and "
    query << "TableName='Sec1.1A-General Information' and "
    query << "RowName='Principal Heating Source' and "
    query << "ColumnName='Data' and "
    query << "Units='';"
    query_results = sqlFile.execAndReturnFirstString(query)
    if query_results.empty?
      runner.registerWarning('Did not find value for Principal Heating Source.')
      return false
    else
      display = 'Principal Heating Source'
      value = query_results.get
      template_table[:data] << [display, value, ""]
      runner.registerValue(display.downcase.gsub(" ","_"), value, "")
    end
 

    return template_table
  end

  def self.general_information_energyModelInfo_table(model, sqlFile, runner)
    # create a second table
    template_table = {}
    template_table[:title] = 'General Information - Energy Model Information'
    template_table[:header] = ['Information', 'Value', 'Units']
    template_table[:data] = []

    # add rows to table

    # Cooling Degree Days
    display = 'Cooling Degree Days'
    template_table[:data] << [display, "TO DO", ""]

    # Heating Degree Days
    display = 'Heating Degree Days'
    template_table[:data] << [display, "TO DO", ""]

    # HDD and CDD data source
    display = 'HDD and CDD data source'
    template_table[:data] << [display, "TO DO", ""]

    # Climate Zone
    display = 'Climate Zone'
    template_table[:data] << [display, "TO DO", ""]

    # weather file
    query = 'SELECT Value FROM tabulardatawithstrings WHERE '
    query << "ReportName='LEEDsummary' and "
    query << "ReportForString='Entire Facility' and "
    query << "TableName='Sec1.1A-General Information' and "
    query << "RowName='Weather File' and "
    query << "ColumnName='Data' and "
    query << "Units='';"
    query_results = sqlFile.execAndReturnFirstString(query)
    if query_results.empty?
      runner.registerWarning('Did not find value for weather file.')
      return false
    else
      display = 'Weather File'
      value = query_results.get
      template_table[:data] << [display, value, ""]
      runner.registerValue(display.downcase.gsub(" ","_"), value, "")
    end

    return template_table
  end

  def self.schedules_EFLH_table(model, sqlFile, runner)
    # create a second table
    template_table = {}
    template_table[:title] = 'Schedules-EFLH (Schedule Type=Fraction)'
    template_table[:header] = ['Schedule Name', 'First Object Used', 'Equivalent Full Load Hours of Operation Per Year']
    template_table[:data] = []

    # add rows to table

    template_table[:data] << ["TO DO", "TO DO", "TO DO"]

    return template_table
  end

  def self.schedules_SetPts_table(model, sqlFile, runner)

    # data for query
    report_name = 'LEEDsummary'
    table_name = 'Schedules-SetPoints (Schedule Type=Temperature)'
    columns = ['', 'First Object Used', 'Month Assumed', '11am First Wednesday', 'Days with Same 11am Value', '11pm First Wednesday', 'Days with Same 11pm Value']
    columns_query = ['', 'First Object Used', 'Month Assumed', '11am First Wednesday', 'Days with Same 11am Value', '11pm First Wednesday', 'Days with Same 11pm Value']

    # populate dynamic rows
    rows_name_query = "SELECT DISTINCT  RowName FROM tabulardatawithstrings WHERE ReportName='#{report_name}' and TableName='#{table_name}'"
    rows = sqlFile.execAndReturnVectorOfString(rows_name_query).get

    # create table
    template_table = {}
    template_table[:title] = 'Schedules-SetPoints'
    template_table[:header] = columns
    template_table[:data] = []

    # run query and populate table
    rows.each do |row|
      row_data = [row]
      column_counter = -1
      columns_query.each do |header|
        column_counter += 1
        next if header == ''
        query = "SELECT Value FROM tabulardatawithstrings WHERE ReportName='#{report_name}' and TableName='#{table_name}' and RowName= '#{row}' and ColumnName= '#{header}'"
        results = sqlFile.execAndReturnFirstString(query)
        row_data << results
      end
      template_table[:data] << row_data
    end

		return template_table

  end

  def self.opaque_assemblies_table(model, sqlFile, runner)

    # data for query
    report_name = 'EnvelopeSummary'
    table_name = 'Opaque Exterior'
    columns = ['', 'Construction', 'Assembly U-Factor with Film', 'Reflectance']
    columns_query = ['','Construction', 'U-Factor with Film', 'Reflectance']

    # populate dynamic rows
    rows_name_query = "SELECT DISTINCT  RowName FROM tabulardatawithstrings WHERE ReportName='#{report_name}' and TableName='#{table_name}'"
    rows = sqlFile.execAndReturnVectorOfString(rows_name_query).get

    # create table
    template_table = {}
    template_table[:title] = 'Opaque Assemblies'
    template_table[:header] = columns
    source_units_ufact = 'W/m^2*K'
    target_units_ufact = 'Btu/ft^2*h*R' 

    template_table[:source_units] = ['', '', source_units_ufact, ''] # used for conversation, not needed for rendering.
    template_table[:units] = ['', '', target_units_ufact, '']
    template_table[:data] = []

		uniqueRowCons = []
    # run query and populate table
    rows.each do |row|
      row_data = [row]
      column_counter = -1
      columns_query.each do |header|
        column_counter += 1
        next if header == ''
        query = "SELECT Value FROM tabulardatawithstrings WHERE ReportName='#{report_name}' and TableName='#{table_name}' and RowName= '#{row}' and ColumnName= '#{header}'"
        if not template_table[:source_units][column_counter] == ''
          results = sqlFile.execAndReturnFirstDouble(query)
          row_data_ip = OpenStudio.convert(results.to_f, template_table[:source_units][column_counter], template_table[:units][column_counter]).get
          row_data << row_data_ip.round(2)
        else
          results = sqlFile.execAndReturnFirstString(query)
          row_data << results
        end
      end
			if not (uniqueRowCons.include? row_data[2])
        template_table[:data] << row_data
        uniqueRowCons << row_data[2]
      end
    end

		return template_table

  end


  def self.fene_wallGlazeArea_table(model, sqlFile, runner)

    #note that column and row are transposed from the original so the variable names can seem a little messed up

    # data for query
    report_name = 'InputVerificationandResultsSummary'
    table_name = 'Window-Wall Ratio'
    columns = ['', 'Above Ground Wall Area', 'Vertical Glazing Area', 'Above Ground Window-Wall Ratio']
    columns_query = ['','Above Ground Wall Area', 'Window Opening Area', 'Above Ground Window-Wall Ratio']

		rows = ['North (315 to 45 deg)','East (45 to 135 deg)','South (135 to 225 deg)','West (225 to 315 deg)','Total']

    # create table
    template_table = {}
    template_table[:title] = 'Shading and Fenestration - Above Grade Wall and Vertical Glazing Area'
    template_table[:header] = columns

    template_table[:source_units] = ['', 'm^2', 'm^2', ''] # used for conversation, not needed for rendering.
    template_table[:units] = ['', 'ft^2', 'ft^2', '']
    template_table[:data] = []

		uniqueRowCons = []
    # run query and populate table
    rows.each do |row|
      row_data = [row]
      column_counter = -1
      columns_query.each do |header|
        column_counter += 1
        next if header == ''
        query = "SELECT Value FROM tabulardatawithstrings WHERE ReportName='#{report_name}' and TableName='#{table_name}' and RowName= '#{header}' and ColumnName= '#{row}'"
        if not template_table[:source_units][column_counter] == ''
          results = sqlFile.execAndReturnFirstDouble(query)
          row_data_ip = OpenStudio.convert(results.to_f, template_table[:source_units][column_counter], template_table[:units][column_counter]).get
          row_data << row_data_ip.round(2)
        else
          results = sqlFile.execAndReturnFirstString(query)
          row_data << results
        end
      end
      template_table[:data] << row_data
    end

		return template_table

  end

  def self.fene_roofSkyliteArea_table(model, sqlFile, runner)

    #note that column and row are transposed from the original so the variable names can seem a little messed up

    # data for query
    report_name = 'InputVerificationandResultsSummary'
    table_name = 'Skylight-Roof Ratio'
    columns = ['', 'Roof Area', 'Skylight Area', 'Skylight-Roof Ratio']
    columns_query = ['','Gross Roof Area', 'Skylight Area', 'Skylight-Roof Ratio']

		rows = ['Total']

    # create table
    template_table = {}
    template_table[:title] = 'Shading and Fenestration - Roof and Skylight Area'
    template_table[:header] = columns

    template_table[:source_units] = ['', 'm^2', 'm^2', ''] # used for conversation, not needed for rendering.
    template_table[:units] = ['', 'ft^2', 'ft^2', '']
    template_table[:data] = []

		uniqueRowCons = []
    # run query and populate table
    rows.each do |row|
      row_data = [row]
      column_counter = -1
      columns_query.each do |header|
        column_counter += 1
        next if header == ''
        query = "SELECT Value FROM tabulardatawithstrings WHERE ReportName='#{report_name}' and TableName='#{table_name}' and RowName= '#{header}' and ColumnName= '#{row}'"
        if not template_table[:source_units][column_counter] == ''
          results = sqlFile.execAndReturnFirstDouble(query)
          row_data_ip = OpenStudio.convert(results.to_f, template_table[:source_units][column_counter], template_table[:units][column_counter]).get
          row_data << row_data_ip.round(2)
        else
          results = sqlFile.execAndReturnFirstString(query)
          row_data << results
        end
      end
      template_table[:data] << row_data
    end

		return template_table

  end


  def self.lighting_intLite_table(model, sqlFile, runner)
    # data for query
    report_name = 'LightingSummary'
    table_name = 'Interior Lighting'
    columns = ['', 'Zone', 'Lighting Power Density', 'Zone Area','Total Power', 'End Use Subcategory','Schedule Name', 'Scheduled Hours/Week', 'Actual Load Hours/Week','Hours/Week > 1%','Full Load Hours/Week','Return Air Fraction','Conditioned (Y/N)','Consumption']
    columns_query = ['', 'Zone', 'Lighting Power Density', 'Zone Area','Total Power', 'End Use Subcategory','Schedule Name', 'Scheduled Hours/Week', 'Full Load Hours/Week','Hours/Week > 1%','Full Load Hours/Week','Return Air Fraction','Conditioned (Y/N)','Consumption']

    # populate dynamic rows
    rows_name_query = "SELECT DISTINCT  RowName FROM tabulardatawithstrings WHERE ReportName='#{report_name}' and TableName='#{table_name}'"
    row_names = sqlFile.execAndReturnVectorOfString(rows_name_query).get
    rows = []
    row_names.each do |row_name|
      next if row_name == 'Interior Lighting Total' # skipping this on purpose, may give odd results in some instances
      rows << row_name
    end

    # create table
    template_table = {}
    template_table[:title] = 'Lighting - Interior'
    template_table[:header] = columns
    source_units_lpd = 'W/m^2'
    target_units_lpd = 'W/ft^2'
    template_table[:source_units] = ['', '', source_units_lpd, 'm^2', 'W', '', '','hr', 'hr', 'hr', 'hr','','','GJ'] # used for conversation, not needed for rendering.
    template_table[:units] = ['', '', target_units_lpd, 'ft^2','W', '', '','hr', 'hr', 'hr', 'hr','','','kWh']
    template_table[:data] = []

    # run query and populate table
    rows.each do |row|
      row_data = [row]
      column_counter = -1
      columns_query.each do |header|
        column_counter += 1
        next if header == ''
        query = "SELECT Value FROM tabulardatawithstrings WHERE ReportName='#{report_name}' and TableName='#{table_name}' and RowName= '#{row}' and ColumnName= '#{header}'"
        if not template_table[:source_units][column_counter] == ''
          results = sqlFile.execAndReturnFirstDouble(query)
          row_data_ip = OpenStudio.convert(results.to_f, template_table[:source_units][column_counter], template_table[:units][column_counter]).get
          row_data << row_data_ip.round(2)
        else
          results = sqlFile.execAndReturnFirstString(query)
          row_data << results
        end
      end
      template_table[:data] << row_data
    end
	return template_table
  end

  def self.lighting_extLite_table(model, sqlFile, runner)

    # data for query
    report_name = 'LightingSummary'
    table_name = 'Exterior Lighting'
    columns = ['', 'Total Watts', 'Astronomical Clock/Schedule', 'Schedule Name', 'Scheduled Hours/Week', 'Hours/Week > 1%','Consumption']
    columns_query = ['', 'Total Watts', 'Astronomical Clock/Schedule', 'Schedule Name', 'Scheduled Hours/Week', 'Hours/Week > 1%','Consumption']

    # populate dynamic rows
    rows_name_query = "SELECT DISTINCT  RowName FROM tabulardatawithstrings WHERE ReportName='#{report_name}' and TableName='#{table_name}'"
    row_names = sqlFile.execAndReturnVectorOfString(rows_name_query).get
    rows = []
    row_names.each do |row_name|
      next if row_name == 'Exterior Lighting Total' # skipping this on purpose, may give odd results in some instances
      rows << row_name
    end
 
    # create table
    template_table = {}
    template_table[:title] = 'Lighting - Exterior'
    template_table[:header] = columns
    source_units_lpd = 'W/m^2'
    target_units_lpd = 'W/ft^2'
    template_table[:source_units] = ['', 'W', '', '', 'hr', 'hr','GJ'] # used for conversation, not needed for rendering.
    template_table[:units] = ['', 'W', '', '', 'hr', 'hr','kWh']
    template_table[:data] = []

    # run query and populate table
    rows.each do |row|
      row_data = [row]
      column_counter = -1
      columns_query.each do |header|
        column_counter += 1
        next if header == ''
        query = "SELECT Value FROM tabulardatawithstrings WHERE ReportName='#{report_name}' and TableName='#{table_name}' and RowName= '#{row}' and ColumnName= '#{header}'"
        if not template_table[:source_units][column_counter] == ''
          results = sqlFile.execAndReturnFirstDouble(query)
          row_data_ip = OpenStudio.convert(results.to_f, template_table[:source_units][column_counter], template_table[:units][column_counter]).get
          row_data << row_data_ip.round(2)
        else
          results = sqlFile.execAndReturnFirstString(query)
          row_data << results
        end
      end

      template_table[:data] << row_data
    end
	return template_table
  end

  def self.process_plugPower_table(model, sqlFile, runner)
    # data for query
    report_name = 'Initialization Summary'
    table_name = 'ElectricEquipment Internal Gains Nominal'
    columns = ['', 'Name', 'Schedule Name', 'Zone Name','Zone Floor Area', '# Zone Occupants','Equipment Level', 'Equipment/Floor Area', 'Equipment per person','End-Use SubCategory']
    columns_query = ['', 'Name', 'Schedule Name', 'Zone Name','Zone Floor Area {m2}', '# Zone Occupants','Equipment Level {W}', 'Equipment/Floor Area {W/m2}', 'Equipment per person {W/person}','End-Use SubCategory']

    # populate dynamic rows
    rows_name_query = "SELECT DISTINCT  RowName FROM tabulardatawithstrings WHERE ReportName='#{report_name}' and TableName='#{table_name}'"
    row_names = sqlFile.execAndReturnVectorOfString(rows_name_query).get
    rows = []
    row_names.each do |row_name|
      next if row_name == 'Interior Lighting Total' # skipping this on purpose, may give odd results in some instances
      rows << row_name
    end

    # create table
    template_table = {}
    template_table[:title] = 'Process Loads - Summary'
    template_table[:header] = columns
    source_units_lpd = 'W/m^2'
    target_units_lpd = 'W/ft^2'
    template_table[:source_units] = ['', '', '', '', 'm^2', '', 'W', 'W/m^2', 'W', ''] # used for conversation, not needed for rendering.
    template_table[:units] =        ['', '', '', '', 'ft^2','', 'W', 'W/ft^2', 'W', '']
    template_table[:data] = []

    # run query and populate table
    rows.each do |row|
      row_data = [row]
      column_counter = -1
      columns_query.each do |header|
        column_counter += 1
        next if header == ''
        query = "SELECT Value FROM tabulardatawithstrings WHERE ReportName='#{report_name}' and TableName='#{table_name}' and RowName= '#{row}' and ColumnName= '#{header}'"
        if not template_table[:source_units][column_counter] == ''
          results = sqlFile.execAndReturnFirstDouble(query)
          row_data_ip = OpenStudio.convert(results.to_f, template_table[:source_units][column_counter], template_table[:units][column_counter]).get
          row_data << row_data_ip.round(2)
        else
          results = sqlFile.execAndReturnFirstString(query)
          row_data << results
        end
      end
      template_table[:data] << row_data
    end
	return template_table
  end

  def self.process_non_receptacle_gas_table(model, sqlFile, runner)
    # data for query
    report_name = 'Initialization Summary'
    table_name = 'GasEquipment Internal Gains Nominal'
    columns = ['', 'Name', 'Schedule Name', 'Zone Name','Zone Floor Area', '# Zone Occupants','Equipment Level', 'Equipment/Floor Area', 'Equipment per person','End-Use SubCategory']
    columns_query = ['', 'Name', 'Schedule Name', 'Zone Name','Zone Floor Area {m2}', '# Zone Occupants','Equipment Level {W}', 'Equipment/Floor Area {W/m2}', 'Equipment per person {W/person}','End-Use SubCategory']

    # populate dynamic rows
    rows_name_query = "SELECT DISTINCT  RowName FROM tabulardatawithstrings WHERE ReportName='#{report_name}' and TableName='#{table_name}'"
    rows = sqlFile.execAndReturnVectorOfString(rows_name_query).get

    # create table
    template_table = {}
    template_table[:title] = 'Process Loads - Non Receptacle Process Equipment - Gas'
    template_table[:header] = columns
    template_table[:source_units] = ['', '', '', '', 'm^2', '', 'W', 'W/m^2', 'W', ''] # used for conversation, not needed for rendering.
    template_table[:units] =        ['', '', '', '', 'ft^2','', 'W', 'W/ft^2', 'W', '']
    template_table[:data] = []

    # run query and populate table
    rows.each do |row|
      row_data = [row]
      column_counter = -1
      columns_query.each do |header|
        column_counter += 1
        next if header == ''
        query = "SELECT Value FROM tabulardatawithstrings WHERE ReportName='#{report_name}' and TableName='#{table_name}' and RowName= '#{row}' and ColumnName= '#{header}'"
        if not template_table[:source_units][column_counter] == ''
          results = sqlFile.execAndReturnFirstDouble(query)
          row_data_ip = OpenStudio.convert(results.to_f, template_table[:source_units][column_counter], template_table[:units][column_counter]).get
          row_data << row_data_ip.round(2)
        else
          results = sqlFile.execAndReturnFirstString(query)
          row_data << results
        end
      end
      template_table[:data] << row_data
    end
	return template_table
  end

  def self.process_non_receptacle_hotwater_table(model, sqlFile, runner)
    # data for query
    report_name = 'Initialization Summary'
    table_name = 'HotWatersEquipment Internal Gains Nominal'
    columns = ['', 'Name', 'Schedule Name', 'Zone Name','Zone Floor Area', '# Zone Occupants','Equipment Level', 'Equipment/Floor Area', 'Equipment per person','End-Use SubCategory']
    columns_query = ['', 'Name', 'Schedule Name', 'Zone Name','Zone Floor Area {m2}', '# Zone Occupants','Equipment Level {W}', 'Equipment/Floor Area {W/m2}', 'Equipment per person {W/person}','End-Use SubCategory']

    # populate dynamic rows
    rows_name_query = "SELECT DISTINCT  RowName FROM tabulardatawithstrings WHERE ReportName='#{report_name}' and TableName='#{table_name}'"
    rows = sqlFile.execAndReturnVectorOfString(rows_name_query).get

    # create table
    template_table = {}
    template_table[:title] = 'Process Loads - Non Receptacle Process Equipment - Hot Water'
    template_table[:header] = columns
    template_table[:source_units] = ['', '', '', '', 'm^2', '', 'W', 'W/m^2', 'W', ''] # used for conversation, not needed for rendering.
    template_table[:units] =        ['', '', '', '', 'ft^2','', 'W', 'W/ft^2', 'W', '']
    template_table[:data] = []

    # run query and populate table
    rows.each do |row|
      row_data = [row]
      column_counter = -1
      columns_query.each do |header|
        column_counter += 1
        next if header == ''
        query = "SELECT Value FROM tabulardatawithstrings WHERE ReportName='#{report_name}' and TableName='#{table_name}' and RowName= '#{row}' and ColumnName= '#{header}'"
        if not template_table[:source_units][column_counter] == ''
          results = sqlFile.execAndReturnFirstDouble(query)
          row_data_ip = OpenStudio.convert(results.to_f, template_table[:source_units][column_counter], template_table[:units][column_counter]).get
          row_data << row_data_ip.round(2)
        else
          results = sqlFile.execAndReturnFirstString(query)
          row_data << results
        end
      end
      template_table[:data] << row_data
    end
	return template_table
  end

  def self.process_non_receptacle_steam_table(model, sqlFile, runner)
    # data for query
    report_name = 'Initialization Summary'
    table_name = 'SteamEquipment Internal Gains Nominal'
    columns = ['', 'Name', 'Schedule Name', 'Zone Name','Zone Floor Area', '# Zone Occupants','Equipment Level', 'Equipment/Floor Area', 'Equipment per person','End-Use SubCategory']
    columns_query = ['', 'Name', 'Schedule Name', 'Zone Name','Zone Floor Area {m2}', '# Zone Occupants','Equipment Level {W}', 'Equipment/Floor Area {W/m2}', 'Equipment per person {W/person}','End-Use SubCategory']

    # populate dynamic rows
    rows_name_query = "SELECT DISTINCT  RowName FROM tabulardatawithstrings WHERE ReportName='#{report_name}' and TableName='#{table_name}'"
    rows = sqlFile.execAndReturnVectorOfString(rows_name_query).get

    # create table
    template_table = {}
    template_table[:title] = 'Process Loads - Non Receptacle Process Equipment - Steam'
    template_table[:header] = columns
    template_table[:source_units] = ['', '', '', '', 'm^2', '', 'W', 'W/m^2', 'W', ''] # used for conversation, not needed for rendering.
    template_table[:units] =        ['', '', '', '', 'ft^2','', 'W', 'W/ft^2', 'W', '']
    template_table[:data] = []

    # run query and populate table
    rows.each do |row|
      row_data = [row]
      column_counter = -1
      columns_query.each do |header|
        column_counter += 1
        next if header == ''
        query = "SELECT Value FROM tabulardatawithstrings WHERE ReportName='#{report_name}' and TableName='#{table_name}' and RowName= '#{row}' and ColumnName= '#{header}'"
        if not template_table[:source_units][column_counter] == ''
          results = sqlFile.execAndReturnFirstDouble(query)
          row_data_ip = OpenStudio.convert(results.to_f, template_table[:source_units][column_counter], template_table[:units][column_counter]).get
          row_data << row_data_ip.round(2)
        else
          results = sqlFile.execAndReturnFirstString(query)
          row_data << results
        end
      end
      template_table[:data] << row_data
    end
	return template_table
  end

  def self.service_water_heaters_table(model, sqlFile, runner)
    # data for query
    report_name = 'EquipmentSummary'
    table_name = 'Service Water Heating'
    columns = ['', 'Type', 'Storage Volume', 'Input','Thermal Efficiency', 'Recovery Efficiency','Energy Factor']
    columns_query = ['', 'Type', 'Storage Volume', 'Input','Thermal Efficiency', 'Recovery Efficiency','Energy Factor']

    # populate dynamic rows
    rows_name_query = "SELECT DISTINCT  RowName FROM tabulardatawithstrings WHERE ReportName='#{report_name}' and TableName='#{table_name}'"
    rows = sqlFile.execAndReturnVectorOfString(rows_name_query).get

    # create table
    template_table = {}
    template_table[:title] = 'Service Water Heating - Water Heaters'
    template_table[:header] = columns
    template_table[:source_units] = ['', '', 'm^3',  'W',     '', '', ''] # used for conversation, not needed for rendering.
    template_table[:units] =        ['', '', 'ft^3', 'Btu/h', '', '', '']
    template_table[:data] = []

    # run query and populate table
    rows.each do |row|
      row_data = [row]
      column_counter = -1
      columns_query.each do |header|
        column_counter += 1
        next if header == ''
        query = "SELECT Value FROM tabulardatawithstrings WHERE ReportName='#{report_name}' and TableName='#{table_name}' and RowName= '#{row}' and ColumnName= '#{header}'"
        if not template_table[:source_units][column_counter] == ''
          results = sqlFile.execAndReturnFirstDouble(query)
          row_data_ip = OpenStudio.convert(results.to_f, template_table[:source_units][column_counter], template_table[:units][column_counter]).get
          row_data << row_data_ip.round(2)
        else
          results = sqlFile.execAndReturnFirstString(query)
          row_data << results
        end
      end
      template_table[:data] << row_data
    end
	return template_table
  end

  def self.air_side_hvac_unitary_cooling_coils(model, sqlFile, runner)
    # data for query
    report_name = 'EquipmentSummary'
    table_name = 'DX Cooling Coils'
    columns = ['', 'Standard Rated Net Cooling Capacity', 'Standard Rated Net COP', 'EER','SEER', 'IEER']
    columns_query = ['', 'Standard Rated Net Cooling Capacity', 'Standard Rated Net COP', 'EER','SEER', 'IEER']

    # populate dynamic rows
    rows_name_query = "SELECT DISTINCT  RowName FROM tabulardatawithstrings WHERE ReportName='#{report_name}' and TableName='#{table_name}'"
    rows = sqlFile.execAndReturnVectorOfString(rows_name_query).get

    # create table
    template_table = {}
    template_table[:title] = 'Unitary Cooling Coils'
    template_table[:header] = columns
    template_table[:source_units] = ['', 'W',     '', 'Btu/W-h',  'Btu/W-h', 'Btu/W-h'] # used for conversation, not needed for rendering.
    template_table[:units] =        ['', 'Btu/h', '', 'Btu/W-h',  'Btu/W-h', 'Btu/W-h']
    template_table[:data] = []

    # run query and populate table
    rows.each do |row|
      row_data = [row]
      column_counter = -1
      columns_query.each do |header|
        column_counter += 1
        next if header == ''
        query = "SELECT Value FROM tabulardatawithstrings WHERE ReportName='#{report_name}' and TableName='#{table_name}' and RowName= '#{row}' and ColumnName= '#{header}'"
        if not template_table[:source_units][column_counter] == ''
          results = sqlFile.execAndReturnFirstDouble(query)
          row_data_ip = OpenStudio.convert(results.to_f, template_table[:source_units][column_counter], template_table[:units][column_counter]).get
          row_data << row_data_ip.round(2)
        else
          results = sqlFile.execAndReturnFirstString(query)
          row_data << results
        end
      end
      template_table[:data] << row_data
    end
	return template_table
  end

  def self.air_side_hvac_unitary_heating_coils(model, sqlFile, runner)
    report_name = 'EquipmentSummary'
    table_name = 'DX Heating Coils'
    columns = ['', 'High Temperature Heating (net) Rating Capacity', 'Low Temperature Heating (net) Rating Capacity', 'HSPF','Region Number']
    columns_query = ['', 'High Temperature Heating (net) Rating Capacity', 'Low Temperature Heating (net) Rating Capacity', 'HSPF','Region Number']

    # populate dynamic rows
    rows_name_query = "SELECT DISTINCT  RowName FROM tabulardatawithstrings WHERE ReportName='#{report_name}' and TableName='#{table_name}'"
    rows = sqlFile.execAndReturnVectorOfString(rows_name_query).get

    # create table
    template_table = {}
    template_table[:title] = 'Unitary Heating Coils'
    template_table[:header] = columns
    template_table[:source_units] = ['', 'W',     'W',     'Btu/W-h',  ''] # used for conversation, not needed for rendering.
    template_table[:units] =        ['', 'Btu/h', 'Btu/h', 'Btu/W-h',  '']
    template_table[:data] = []

    # run query and populate table
    rows.each do |row|
      row_data = [row]
      column_counter = -1
      columns_query.each do |header|
        column_counter += 1
        next if header == ''
        query = "SELECT Value FROM tabulardatawithstrings WHERE ReportName='#{report_name}' and TableName='#{table_name}' and RowName= '#{row}' and ColumnName= '#{header}'"
        if not template_table[:source_units][column_counter] == ''
          results = sqlFile.execAndReturnFirstDouble(query)
          row_data_ip = OpenStudio.convert(results.to_f, template_table[:source_units][column_counter], template_table[:units][column_counter]).get
          row_data << row_data_ip.round(2)
        else
          results = sqlFile.execAndReturnFirstString(query)
          row_data << results
        end
      end
      template_table[:data] << row_data
    end
	return template_table
  end

  def self.air_side_hvac_fans(model, sqlFile, runner)
    # data for query
    report_name = 'EquipmentSummary'
    table_name = 'Fans'
    columns =       ['', 'Type', 'Total Efficiency', 'Delta Pressure','Max Air Flow Rate', 'Rated Electric Power','Rated Power Per Max Air Flow Rate','Motor Heat In Air Fraction','End Use']
    columns_query = ['', 'Type', 'Total Efficiency', 'Delta Pressure','Max Air Flow Rate', 'Rated Electric Power','Rated Power Per Max Air Flow Rate','Motor Heat In Air Fraction','End Use']

    # populate dynamic rows
    rows_name_query = "SELECT DISTINCT  RowName FROM tabulardatawithstrings WHERE ReportName='#{report_name}' and TableName='#{table_name}'"
    rows = sqlFile.execAndReturnVectorOfString(rows_name_query).get

    # create table
    template_table = {}
    template_table[:title] = 'Fans'
    template_table[:header] = columns
    template_table[:source_units] = ['', '', '', 'Pa',       'm^3/s',    'W',     'W-s/m^3',    '', ''] # used for conversation, not needed for rendering.
    template_table[:units] =        ['', '', '', 'inH_{2}O', 'ft^3/min', 'Btu/h', 'W-s/m^3',    '', '']

#    template_table[:source_units] = ['', '', '', 'Pa',       'm^3/s',    'W',     'W-s/m^3',    '', ''] # used for conversation, not needed for rendering.
#    template_table[:units] =        ['', '', '', 'inH_{2}O', 'ft^3/min', 'Btu/h', 'W-min/ft^3', '', '']


    template_table[:data] = []

    # run query and populate table
    rows.each do |row|
      row_data = [row]
      column_counter = -1
      columns_query.each do |header|
        column_counter += 1
        next if header == ''
        query = "SELECT Value FROM tabulardatawithstrings WHERE ReportName='#{report_name}' and TableName='#{table_name}' and RowName= '#{row}' and ColumnName= '#{header}'"
        if not template_table[:source_units][column_counter] == ''
          results = sqlFile.execAndReturnFirstDouble(query)
          row_data_ip = OpenStudio.convert(results.to_f, template_table[:source_units][column_counter], template_table[:units][column_counter]).get
          row_data << row_data_ip.round(2)
        else
          results = sqlFile.execAndReturnFirstString(query)
          row_data << results
        end
      end
      template_table[:data] << row_data
    end
	return template_table
  end

  def self.water_side_hvac_central_plant(model, sqlFile, runner)
    report_name = 'EquipmentSummary'
    table_name = 'Central Plant'
    columns =       ['', 'Type', 'Nominal Capacity', 'Nominal Efficiency','IPLV in SI Units','IPLV in IP Units']
    columns_query = ['', 'Type', 'Nominal Capacity', 'Nominal Efficiency','IPLV in SI Units','IPLV in IP Units']

    # populate dynamic rows
    rows_name_query = "SELECT DISTINCT  RowName FROM tabulardatawithstrings WHERE ReportName='#{report_name}' and TableName='#{table_name}'"
    rows = sqlFile.execAndReturnVectorOfString(rows_name_query).get

    # create table
    template_table = {}
    template_table[:title] = 'Central Plant'
    template_table[:header] = columns
    template_table[:source_units] = ['', '','W',     'W/W', 'W/W', 'Btu/W-h'] # used for conversation, not needed for rendering.
    template_table[:units] =        ['', '','Btu/h', 'W/W', 'W/W', 'Btu/W-h']
    template_table[:data] = []

    # run query and populate table
    rows.each do |row|
      row_data = [row]
      column_counter = -1
      columns_query.each do |header|
        column_counter += 1
        next if header == ''
        query = "SELECT Value FROM tabulardatawithstrings WHERE ReportName='#{report_name}' and TableName='#{table_name}' and RowName= '#{row}' and ColumnName= '#{header}'"
        if not template_table[:source_units][column_counter] == ''
          results = sqlFile.execAndReturnFirstDouble(query)
          row_data_ip = OpenStudio.convert(results.to_f, template_table[:source_units][column_counter], template_table[:units][column_counter]).get
          row_data << row_data_ip.round(2)
        else
          results = sqlFile.execAndReturnFirstString(query)
          row_data << results
        end
      end
      template_table[:data] << row_data
    end
	return template_table
  end

  def self.water_side_hvac_pumps(model, sqlFile, runner)
    report_name = 'EquipmentSummary'
    table_name = 'Pumps'
    columns =       ['', 'Type', 'Control', 'Head','Water Flow','Electric Power','Power Per Water Flow Rate','Motor Efficiency']
    columns_query = ['', 'Type', 'Control', 'Head','Water Flow','Electric Power','Power Per Water Flow Rate','Motor Efficiency']

    # populate dynamic rows
    rows_name_query = "SELECT DISTINCT  RowName FROM tabulardatawithstrings WHERE ReportName='#{report_name}' and TableName='#{table_name}'"
    rows = sqlFile.execAndReturnVectorOfString(rows_name_query).get

    # create table
    template_table = {}
    template_table[:title] = 'Pumps'
    template_table[:header] = columns
    template_table[:source_units] = ['', '', '', 'Pa',       'm^3/s',   'W',  'W-s/m3', 'W/W'] # used for conversation, not needed for rendering.
    template_table[:units] =        ['', '', '', 'ftH_{2}O', 'gal/min', 'W',  'W-s/m3', 'W/W']
    template_table[:data] = []

    # run query and populate table
    rows.each do |row|
      row_data = [row]
      column_counter = -1
      columns_query.each do |header|
        column_counter += 1
        next if header == ''
        query = "SELECT Value FROM tabulardatawithstrings WHERE ReportName='#{report_name}' and TableName='#{table_name}' and RowName= '#{row}' and ColumnName= '#{header}'"
        if not template_table[:source_units][column_counter] == ''
          results = sqlFile.execAndReturnFirstDouble(query)
          row_data_ip = OpenStudio.convert(results.to_f, template_table[:source_units][column_counter], template_table[:units][column_counter]).get
          row_data << row_data_ip.round(2)
        else
          results = sqlFile.execAndReturnFirstString(query)
          row_data << results
        end
      end
      template_table[:data] << row_data
    end
	return template_table
  end


end #module

