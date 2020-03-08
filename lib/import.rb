require 'pry'
require 'roo'
require 'creek'

class Import
  attr_reader :file_path, :records
  attr_accessor :counter
  def initialize()
    @file_path = '/home/terminator/sample.xlsx';
    @records = []
    @counter = 1
  end

  BATCH_IMPORT_SIZE = 10

  def call
    rows.each do |row|
    	self.counter += 1
    	if self.counter > 2
	      records << build_new_record(row)
	      import_records if reached_batch_import_size? || reached_end_of_file?
	    end
    end
  end

  private


  def book
    @book ||= Creek::Book.new(file_path)
  end

  # in this example, we assume that the
  # content is in the first Excel sheet
  def rows
    @rows ||= book.sheets.first.rows
  end

  def increment_counter
    self.counter += 1
  end

  def row_count
    @row_count ||= rows.count
  end

  def build_new_record(row)
    # only build a new record without saving it
    User.new(user_params row)
  end

  def import_records
    # save multiple records using activerecord-import gem
    User.import(records)

    # clear records array
    records.clear
  end

  def user_params row
		[:first_name, :last_name, :email].zip(row).to_h
	end

  def reached_batch_import_size?
    (counter % BATCH_IMPORT_SIZE).zero?
  end

  def reached_end_of_file?
    counter == row_count
  end
end

Import.new.call
# COUNTER = 2
# BATCH_IMPORT_SIZE = 10

# def build_record row
# 	User.new(user_params row)
# end

# def import_records records
# 	User.import(records)

# end

# def user_params row
# 	[:first_name, :last_name, :email].zip(row).to_h
# end

# def reached_batch_import_size?
#   (COUNTER % BATCH_IMPORT_SIZE).zero?
# end

# begin
# 	# binding.pry
# 	file_path = '/home/terminator/sample.xlsx'

# # raise I18n.t('unknown_file_type', file: file.original_filename) unless [".xls", ".xlsx"].include?(file_ext)
#   spreadsheet = Roo::Excelx.new(file_path)
#   row_count = spreadsheet.last_row
#   @users = []
#   header = spreadsheet.row(1)
#   (2..row_count).map do |i|
#   	COUNTER = COUNTER+1
#     # row = Hash[[header.map!(&:downcase), spreadsheet.row(i).map{|x| x.strip unless x.nil? }].transpose]
#     @users << build_record(spreadsheet.row(i))

#     import_records(@users) if reached_batch_import_size? || (COUNTER == row_count)
#   end

# rescue StandardError => e
# 	puts e
# end

