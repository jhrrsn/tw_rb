require 'tweetstream'
require 'mongo'
require 'json'

###########################
# Connect to Mongo client #
###########################
include Mongo

client = MongoClient.new("localhost", 27017)
db = client.db("tw_rb")
$coll = db["tweets"]
$geo = db["geo"]


###############################################################
# Define method for cleaning and splitting tweet text content #
###############################################################

def clean_n_split (text)
  # Stopwords for NLP 
  stopwords = "a,able,about,across,after,all,almost,also,am,among,an,and,any,are,as,at,be,because,been,but,by,can,cannot,could,dear,did,do,does,either,else,ever,every,for,from,get,got,had,has,have,he,her,hers,him,his,how,however,i,if,in,into,is,it,its,just,least,let,like,likely,may,me,might,most,must,my,neither,no,nor,not,of,off,often,on,only,or,other,our,own,rather,said,say,says,she,should,since,so,some,than,that,the,their,them,then,there,these,they,this,tis,to,too,twas,us,wants,was,we,were,what,when,where,which,while,who,whom,why,will,with,would,yet,you,your,&amp;,rt, xd, ha, haha, now, i'd, u, can't, lol, :), i'm, omg, doesn't, don't, it's, i'll, that's, didn't, use, can't, yep, go, wtf"
  swd_array = stopwords.split(",")

  # Common punctuation
  punctuation = [".", ",", "#", "!", "?", "_", "-"]
  
  # Remove common punctuation, process this string into an array & ensure words are lowercase for matching.
  punctuation.each {|p| text.gsub!("#{p}", '')}
  word_array = text.split(" ")
  word_array.delete_if {|word| word.include?("@")} # Remove usernames from array.
  word_array.each {|word| word.downcase!}

   # Remove matched stopwords from array
  word_array.each do |word|
  swd_array.each { |sw|
    word_array.delete(sw)
  }
  end

  return word_array
end


###################################################
# Set up connection to Twitter streaming endpoint #
###################################################

# Load OAuth credentials from external .json file. These can be inputted directly, but are stored externally here due to public GitHub exposure.
def load_oauth_cred (filename) 
  JSON.parse(IO.read(filename))
end

# Configure connection credentials to Twitter Streaming API.
TweetStream.configure do |config|
  oauth = load_oauth_cred('oauth.json')
  config.consumer_key       = oauth['consumer_key']
  config.consumer_secret    = oauth['consumer_secret']
  config.oauth_token        = oauth['oauth_token']
  config.oauth_token_secret = oauth['oauth_token_secret']
  config.auth_method        = :oauth
end


#################################
# Setup method to call on tweet #
#################################

TweetStream::Client.new.locations(-7.9, 49.6, 2.2, 61.1) do |status|
  # Set tweet_text equal to the text of the Twitter status.
  original_text = status.text
  split_tweet = clean_n_split(status.text)
  gl_const = $geo.find_one({ 'geometry' => {'$geoIntersects' => {'$geometry' => {'type' => 'Point' , 'coordinates' => [status.geo.long, status.geo.lat] }}}})['properties']['UNIT_ID'] # Query MongoDB GeoJSON collection with tweet location (system dictates reversed lat/long) to return the Unit ID of the London Assembly constituency it is in.
  entry = {"_id" => status.id.to_i, "time" => Time.now.to_i, "coords" => [status.geo.lat, status.geo.long], "gl_const" => gl_const, "text" => original_text, "name" => status.from_user, "keywords" => split_tweet}
  $coll.insert(entry)
end