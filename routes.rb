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
  @tweets = $coll.find("keywords" => input).sort(:time).to_a
  puts(@tweets)


  # Return results.erb with variables keywords, results, min & max time.
  erb :results, locals: {
    keyword: input, 
    results: @tweets
  }
end