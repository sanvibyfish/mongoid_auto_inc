require "mongoid"
require "mongoid_auto_inc/incrementor"

module MongoidAutoInc
  extend ActiveSupport::Concern

  module ClassMethods
    def auto_increment(name, options={})
      field name, :type => Integer
      seq_name = "#{self.name.downcase}_#{name}"
      incrementor = MongoidAutoInc::Incrementor.new(options) 

      unless self.type == 0
        before_create { self.send("#{name}=", incrementor[seq_name].inc) unless self[name.to_sym].present? } 
      end
    end
  end
end

module Mongoid
  module Document
    include MongoidAutoInc
  end
end
