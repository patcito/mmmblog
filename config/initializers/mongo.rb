require 'mm-paginate'

MongoMapper.connection = Mongo::Connection.new(nil, nil, :auto_reconnect => true)
MongoMapper.database = "mmmmblog-#{Rails.env}"
MongoMapper.ensure_indexes!
