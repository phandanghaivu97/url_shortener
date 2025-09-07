class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class

  def self.extract_unique_violation_attribute(message)
    match = message.match(/Key \((?<column_name>.*?)\)=\(.*\) already exists\./)
    match[:column_name] if match
  end
end
