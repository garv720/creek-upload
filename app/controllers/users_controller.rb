class UsersController < ApplicationController

	def index
	end

	def result
		file_path = params[:file].path
		result = ImportService.new(file_path).call
		@errors = result[0]
		@success = result[1]
		@total = result[2] - result.last
		@failed = @total - @success
	end

end