class MovieTest

	def initialize(result_list)
		@result_list = result_list
	end

	def error()
		ret = Array.new
		@result_list.each do |user_id, movie_id, real_rating, predict_rating|
			#print user_id, ' ', movie_id, ' ', real_rating, ' ', predict_rating, "\n"
			ret.push((real_rating - predict_rating).abs)
		end
		return ret
	end

	def mean()
		array = error()
		array.inject(0) { |sum, x| sum += x } / array.size.to_f
	end

	def stddev()
		array = error()
		m = mean()
		variance = array.inject(0) { |variance, x| variance += (x - m) ** 2 }
		Math.sqrt(variance / (array.size - 1))
	end

	def rms()
		array = error()
		variance = array.inject(0) { |variance, x| variance += x ** 2 }
		Math.sqrt(variance / (array.size - 1))
	end

	def to_a()
		return @result_list
	end

end