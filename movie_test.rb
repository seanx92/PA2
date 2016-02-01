##
# MovieTest class

class MovieTest

	##
	# Constructor for class MovieData. result_list is an array of tuples that have a format as below:
	#
	# [user_id, movie_id, real_rating, predict_rating]

	def initialize(result_list)
		@result_list = result_list
	end

	##
	# Returns an array of predication error.

	def error()
		ret = Array.new
		@result_list.each do |_user_id, _movie_id, real_rating, predict_rating|
			ret.push((real_rating - predict_rating).abs)
		end
		return ret
	end

	##
	# Returns the average predication error.

	def mean()
		array = error()
		array.inject(0) { |sum, x| sum += x } / array.size.to_f
	end

	##
	# Returns the standard deviation of the error.

	def stddev()
		array = error()
		m = mean()
		variance = array.inject(0) { |variance, x| variance += (x - m) ** 2 }
		Math.sqrt(variance / (array.size - 1))
	end

	##
	# Returns the root mean square error of the prediction.

	def rms()
		array = error()
		variance = array.inject(0) { |variance, x| variance += x ** 2 }
		Math.sqrt(variance / (array.size - 1))
	end

	##
	# Returns an array of the predictions in the form [user_id, movie_id, real_rating, predict_rating].

	def to_a()
		return @result_list
	end

end