require 'tweetstream'
require 'mongo'

####################################
# Connect to remote Mongo instance #
####################################

# Stopwords for NLP 
stopwords = "a,able,about,across,after,all,almost,also,am,among,an,and,any,are,as,at,be,because,been,but,by,can,cannot,could,dear,did,do,does,either,else,ever,every,for,from,get,got,had,has,have,he,her,hers,him,his,how,however,i,if,in,into,is,it,its,just,least,let,like,likely,may,me,might,most,must,my,neither,no,nor,not,of,off,often,on,only,or,other,our,own,rather,said,say,says,she,should,since,so,some,than,that,the,their,them,then,there,these,they,this,tis,to,too,twas,us,wants,was,we,were,what,when,where,which,while,who,whom,why,will,with,would,yet,you,your,&amp;,rt, xd, ha, haha, now, i'd, u, can't, lol, :), i'm, omg, doesn't, don't, it's, i'll, that's, didn't, use, can't, yep, go, wtf"
swd_array = stopwords.split(",")

# Common punctuation
punctuation = [".", ",", "#", "!", "@", "?", "_", "-"]

# Setup auth
TweetStream.configure do |config|
  config.username = "PDEPrototyping"
  config.password = "PD3Pr0t0typ1ng"
  config.auth_method = :basic
end


# Setup method to call on tweet
TweetStream::Client.new.locations(-7.9, 49.6, 2.2, 61.1) do |status|
  # Set tweet_text equal to the text of the Twitter status.
  tweet_text = "#{status.text}"

  # Remove common punctuation, process this string into an array & ensure words are lowercase for matching.
  punctuation.each {|p| tweet_text.gsub!("#{p}", '')}
  word_array = tweet_text.split(" ")
  word_array.each {|word| word.downcase!}

   # Remove stopwords from array
  word_array.each do |word|
  swd_array.each { |sw|
    word_array.delete(sw)
  }
  end

  word_array.each {|word| print word + " | "}
  puts "---------------------------"
end


####################################################
# Structure & write tweet to remote Mongo instance #
####################################################