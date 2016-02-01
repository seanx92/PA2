require './movie_test'

##
# MovieData class

class MovieData

    ##
    # Constructor for class MovieData. Its arguments has two options:
    #
    # z = MovieData.new("ml-100k")
    #
    # will read it all of the data in the 100,000 lines in “u.data” as the training set and will have an empty test set;
    #
    # z = MovieData.new('ml-100k',:u1)
    #
    # will read in the 80,000 lines in “u1.base” as the training set and the 20,000 lines in “u1.test” as the test set.

    def initialize(*args)
        if args.size < 1 || args.size > 2
            puts 'Wrong arguments'
        else
            @dict_mid = Hash.new
            @dict_uid = Hash.new
            @test_list = Array.new
            @count = 0
            if args.size == 2
                filename = args[0] + '/' + args[1].to_s + '.base'
                test_filename = args[0] + '/' + args[1].to_s + '.test'
                load_data(filename, 80000)
                load_test(test_filename, 20000)
            else
                filename = args[0] + '/u.data'
                load_data(filename, 100000)
            end
        end
    end

    ##
    # Read in the max_line_num lines in "filename" as the test set.

    def load_test(filename, max_line_num)
        File.foreach(filename).with_index do |line, i|
            break if i >= max_line_num
            user_id, movie_id, rating, timestamp = line.split(' ')
            @test_list.push([user_id, movie_id, rating, timestamp])
        end
    end

    ##
    # Read in the max_line_num lines in "filename" as the training set.

    def load_data(filename, max_line_num)
        File.foreach(filename).with_index do |line, i|
            break if i >= max_line_num
            user_id, movie_id, rating, timestamp = line.split(' ')
            @dict_mid[movie_id] = Hash.new if !(@dict_mid.has_key?(movie_id))
            @dict_mid[movie_id][user_id] = [rating, timestamp]
            @dict_uid[user_id] = Hash.new if !(@dict_uid.has_key?(user_id))
            @dict_uid[user_id][movie_id] = [rating, timestamp]
            @count += 1
        end
    end

    ##
    # Runs the predict method on the first k ratings in the test set and returns a MovieTest object containing the results.
    #
    # The parameter k is optional and if omitted, all of the tests will be run.

    def run_test(*args)
        if args.size > 1
            puts 'Wrong arguments'
        else
            array = @test_list if args.size == 0
            array = @test_list.first(args[0]) if args.size == 1
            result = Array.new
            array.each do |user_id, movie_id, rating, _|
                result.push([user_id, movie_id, rating.to_i, predict(user_id, movie_id)])
            end
            test = MovieTest.new(result)
            print 'Average predication error: ', test.mean, "\n"
            print 'Standard deviation of error: ', test.stddev, "\n"
            print 'Root mean square error:', test.rms, "\n"
            pred_array = test.to_a
            pred_array.each do |u, m, r, p|
                print "user_id: ", u, "\tmovie_id: ", m, "\treal rating: ", r, "\tpredict rating: ", p, "\n"
            end
        end
    end

    ##
    # Returns a floating point number between 1.0 and 5.0 as an estimate of what user user_id would rate movie movie_id.

    def predict(user_id, movie_id)
        sampling_ratio = 0.2
        u_rating = rating(user_id, movie_id)  
        return Float(u_rating) if u_rating > 0
        user_list = viewers(movie_id).sort_by {|iter_user_id| -similarity(user_id, iter_user_id)}
        return 3.0 if user_list.size == 0
        sum = 0.0
        sample_num = (user_list.size * sampling_ratio).round
        sample_num += 1 if sample_num == 0
        user_list[0..sample_num].each do |iter_user_id|
            sum += rating(iter_user_id, movie_id)
        end
        return sum / sample_num
    end

    ##
    # Returns the rating that user user_id gave movie movie_id in the training set, and 0 if user user_id did not rate movie movie_id.

    def rating(user_id, movie_id)
        if @dict_uid.has_key?(user_id)
            user_hash = @dict_uid[user_id]
            return user_hash[movie_id][0].to_i if user_hash.has_key?(movie_id)
        end
        return 0
    end

    ##
    # Returns the array of movies that user user_id has watched.

    def movies(user_id)
        return @dict_uid[user_id].keys if @dict_uid.has_key?(user_id)
    end

    ##
    # Returns the array of users that have seen movie movie_id.

    def viewers(movie_id)
        return @dict_mid[movie_id].keys if @dict_mid.has_key?(movie_id)
    end

    ##
    # Returns a number that indicates the popularity of movie movie_id (higher numbers are more popular).

    def popularity(movie_id)
        return @dict_mid[movie_id].size() / @count
    end

    def popularity_list()
        ret = Array.new
        temp = @dict_mid.sort_by {|_, array| array.size()}.reverse
        temp.each do |movie_id, _|
            ret.push(movie_id)
        end
        return ret
    end

    ##
    # Returns a floating point number between 0 and 1.0 as the similarity in movie preference between user1 and user2, 
    # where higher numbers indicate greater similarity.

    def similarity(user1, user2)
        user1_hash = @dict_uid[user1]
        user2_hash = @dict_uid[user2]
        dividend = 0
        user2_hash.each do |user2_movie_id, user2_tuple|
            if user1_hash.has_key?(user2_movie_id)
                dividend += 1.0 / ((user1_hash[user2_movie_id][0].to_i - user2_tuple[0].to_i).abs + 1)
            end
        end
        return dividend / [user1_hash.size(), user2_hash.size()].min
    end

    ##
    # Returns a list of users whose tastes are most similar to the tastes of user u

    def most_similar(u)
        t_max = -1
        ret = Array.new
        @dict_uid.keys.each do |user_id|
            next if u == user_id
            score = similarity(u, user_id)
            if score > t_max
                t_max = score
                ret = [user_id]
            elsif score == t_max
                ret.push(user_id)
            end
        end
        return ret
    end

end

movie_data = MovieData.new('ml-100k', :u1)

movie_data.run_test(5000)
