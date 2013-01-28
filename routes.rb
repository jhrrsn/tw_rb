require 'sinatra'
require 'mongo'

###########################
# Connect to Mongo client #
###########################
include Mongo

client = MongoClient.new("localhost", 27017)
db = client.db("tw_rb")
$coll = db["tweets"]


########################
# Setup Sinatra routes #
########################

# When root page is accessed, return index.erb
get '/' do 
  erb :index
end


# When the form at index is submitted, this method will run and return results.erb 
post '/result' do

  # Use supplied keyword to query MongoDB
  input = params[:keyword].downcase
  results = $coll.find("keywords" => input).sort(:time).to_a

  
  # Set placeholder min/max time values from first result
  @min_time = results.first['time']
  @max_time = results.first['time']

  # Create empty array to hold tweets
  @tweets = []

  # Iterate through results to fill @tweets array
  results.each do |doc|
    ## Check if this tweet was published earliest/latest
    @min_time = doc['time'] if doc['time'] < @min_time
    @max_time = doc['time'] if doc['time'] > @max_time

    ## Add tweet content and metadata to the tweets array
    tweet = []
    tweet.push doc['coords']
    tweet.push doc['time']
    tweet.push doc['_id']
    tweet.push doc['name']
    @tweets.push tweet
  end

  # Return results.erb with variables keywords, results, min & max time.
  erb :results, locals: {
    keyword: input, 
    results: @tweets, 
    min_time: @min_time, 
    max_time: @max_time
  }
end