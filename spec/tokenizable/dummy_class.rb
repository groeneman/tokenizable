class Dummy
  include Mongoid::Document
  include Tokenizable::Base

  tokenize
end