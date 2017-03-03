class Listing
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name, type: String
  field :description, type: String

  field :url, type: String

  field :street, type: String
  field :city, type: String
  field :state, type: String
  field :zip, type: String
  field :country, type: String

  field :website, type: String
  field :email, type: String
  field :phone, type: String

  field :categories, type: Array, default: []
  field :brands, type: Array, default: []
end
