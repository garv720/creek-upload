class ImportService
  attr_reader :file_path, :records
  attr_accessor :counter, :failed, :sheet_failed, :success_count, :total_row_count

  def initialize(file_path)
    @file_path = file_path
    @records = []
    @sheet_failed = []
    @failed = []
    @counter = 0
    @success_count = 0
    @total_row_count = 0
  end

  # Limit after which users will be saved
  BATCH_IMPORT_SIZE = 500

  def call
    book.sheets.each do |sheet|
      rows(sheet).each do |row|
      	self.counter += 1
      	if self.counter >= 2
          data = row["cells"].values
  	      records << build_new_record(build_data(data, row["r"]))
  	      import_records if reached_batch_import_size? || reached_end_of_sheet?(sheet)
  	    end
      end
      failed << sheet_failed
      self.total_row_count += row_count(sheet)
      self.counter = 0
      self.sheet_failed = []
    end
    return [failed, success_count, total_row_count, book.sheets.count]
  end

  private

  # Opening the file with Creek gem
  def book
    Creek::Book.new(file_path)
  end

  # Collecting all rows from the first sheet.
  def rows(sheet)
    sheet.simple_rows_with_meta_data
  end

  # Total row count
  def row_count(sheet)
    rows(sheet).count
  end

  def build_data data, r
    case data.size
    when 0
      data = ["", "", "", r]
    when 1
      data << ["", "", r]
    when 2
      data << ["", r]
    when 3
      data << r
    end
    data.flatten
  end

  # Build a new record
  def build_new_record(row)
    User.new(user_params row)
  end

  # save multiple records using activerecord-import gem
  def import_records
    result = User.import(records)
    self.success_count = self.success_count + result.ids.count
    result.failed_instances.map do |user|
      sheet_failed << user
    end

    records.clear # Clearing the older records after imporing a batch
  end

  # Creating user hash for user
  def user_params row
		[:first_name, :last_name, :email, :row_number].zip(row).to_h
	end

  # Checking record size.
  def reached_batch_import_size?
    (counter % BATCH_IMPORT_SIZE).zero?
  end

  # Checking End Of File
  def reached_end_of_sheet? sheet
    counter == row_count(sheet)
  end
end
