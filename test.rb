require 'mongo'


####################################
# Connect to remote Mongo instance #
####################################
include Mongo

db = MongoClient.new("ds047217.mongolab.com", 47217)
auth = db.authenticate("jhrrsn", "orange45")