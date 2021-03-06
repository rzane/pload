require 'active_record'
require 'pload/version'

module Pload
  class << self
    def raise_errors!
      ActiveRecord::Associations::SingularAssociation.prepend Pload::Association
      ActiveRecord::Associations::CollectionAssociation.prepend Pload::Association
    end
  end

  class AssociationNotLoadedError < StandardError
    def initialize(owner, reflection)
      super "N+1 query detected:\n  #{owner.class} => :#{reflection.name}"
    end
  end

  module Relation
    def pload(*args)
      extending(PloadedRelation).includes!(*args)
    end

    def pload?
      extending_values.include? PloadedRelation
    end
  end

  module PloadedRelation
    def first(*)
      super.try(:pload)
    end

    def last(*)
      super.try(:pload)
    end

    def each
      super do |record, *args|
        yield record.pload, *args
      end
    end

    def find_each
      super do |record, *args|
        yield record.pload, *args
      end
    end
  end

  module Base
    def self.prepended(base)
      base.singleton_class.delegate :pload, to: :all
    end

    def pload
      @pload = true
      self
    end

    def pload?
      @pload
    end
  end

  module Association
    def reader(*args, pload: true)
      return super(*args) unless pload && owner.pload?

      unless loaded?
        raise Pload::AssociationNotLoadedError.new(owner, reflection)
      end

      super(*args).try(:pload)
    end
  end
end

ActiveSupport.on_load :active_record do
  ActiveRecord::Base.prepend Pload::Base
  ActiveRecord::Relation.prepend Pload::Relation
end
