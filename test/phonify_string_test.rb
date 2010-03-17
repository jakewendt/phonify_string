require 'test/unit'
require 'rubygems'
require 'active_record'

$:.unshift "#{File.dirname(__FILE__)}/../lib"
require 'phonify_string'
ActiveRecord::Base.send(:extend, PhonifyString )

ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :database => ":memory:")

def setup_db
	ActiveRecord::Schema.define(:version => 1) do
		create_table :users do |t|
			t.string :name
			t.string :phone
			t.string :optional_phone
			t.timestamps
		end
		user = User.create({:name => "Jake", :phone_number => '1234567890'})
	end
end

def teardown_db
	ActiveRecord::Base.connection.tables.each do |table|
		ActiveRecord::Base.connection.drop_table(table)
	end
end

class User < ActiveRecord::Base
	phonify_string :phone, :required => true
	phonify_string :optional_phone, :required => false
end

class PhonifyStringTest < Test::Unit::TestCase

	def setup
		setup_db
	end

	def teardown
		teardown_db
	end

	def test_invalid_phone_1
		u = User.first
		u.update_attributes(:phone_number => "123")
		assert u.errors.on(:phone_number)
		assert u.changed?
		assert u.phone == "123"
		u = User.first
		assert u.reload.phone == "(123)456-7890"
	end

	def test_invalid_phone_2
		u = User.first
		u.update_attributes(:phone_number => "")
		assert u.errors.on(:phone_number)
		assert u.changed?
		assert u.reload.phone == "(123)456-7890"
	end

	def test_invalid_phone_3
		u = User.first
		u.update_attributes(:phone_number => "123 456 789")
		assert u.errors.on(:phone_number)
		assert u.changed?
		assert u.reload.phone == "(123)456-7890"
	end

	def test_valid_phone_1
		u = User.first
		u.update_attributes(:phone_number => "0987654321")
		assert !u.errors.on(:phone_number)
		assert u.reload.phone == "(098)765-4321"
	end

	def test_valid_phone_2
		u = User.create(:name => "Jakeb", :phone => "fakephone")	# nothing to stop straight access
		assert u.phone == "fakephone"
		assert !u.errors.on(:phone_number)
		assert !u.errors.on(:optional_phone_number)

		u.update_attributes(:phone_number => "0987654321")
		assert !u.errors.on(:phone_number)
		assert u.reload.phone == "(098)765-4321"
	end

	def test_valid_phone_3
		u = User.create(:name => "Jakeb", :phone => "fakephone")	# nothing to stop straight access
		assert u.phone == "fakephone"
		assert !u.errors.on(:phone_number)
		assert !u.errors.on(:optional_phone_number)

		u.update_attributes(:optional_phone_number => "")
		assert !u.errors.on(:optional_phone_number)
		assert u.reload.optional_phone == ""
	end

	def test_valid_phone_4
		u = User.create(:name => "Jakeb", :optional_phone_number => "fakephone")
		assert u.optional_phone == "fakephone"
		assert !u.errors.on(:phone_number)
		assert u.errors.on(:optional_phone_number)
	end

end
