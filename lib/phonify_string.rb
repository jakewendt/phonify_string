module PhonifyString

	def phonify_string(*names)
		configuration = {
			:required => false
		}.merge(names.extract_options!)

		names.each do |name|

			#	This, apparently, gives direct access to @#{name}_invalid
			#	which was unexpected.  Can use this in the validations below.
			self.send(:attr_accessor, "#{name}_invalid".intern )

			if self.accessible_attributes
				self.send(:attr_accessible, "#{name}_number".intern )
			end

			define_method "#{name}_number" do
				read_attribute(name) unless read_attribute(name).nil?
			end
			
			define_method "#{name}_number=" do |phone|
				if ( !phone.blank? )
					if phone =~ /\D*(\d?)\D*(\d{3})\D*(\d{3})\D*(\d{4})\D*/
						write_attribute(name, "#{$1}(#{$2})#{$3}-#{$4}")
						instance_variable_set("@#{name}_invalid", false)
					else
						write_attribute(name, phone)
						instance_variable_set("@#{name}_invalid", true)
					end
				else
					if configuration[:required]
						write_attribute(name,'')
						instance_variable_set("@#{name}_invalid", true)
					else
						write_attribute(name,'')
						instance_variable_set("@#{name}_invalid", false)
					end
				end
			end
			
			validates_each( name ) do |record,attr,value|
				record.errors.add("#{name}_number","is invalid.") if record.send("#{name}_invalid".intern)
			end

		end
	end
end
