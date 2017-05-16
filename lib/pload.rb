require 'active_record'
require 'pload/version'

module Pload
  class << self
    def disable_errors!
      @enabled = false
    end

    def enabled?
      return true unless defined?(@enabled)
      @enabled
    end
  end

  class AssociationNotLoadedError < StandardError
    def initialize(owner, reflection)
      super "N+1 query detected:\n  #{owner.class} => :#{reflection.name}"
    end
  end

  module Relation
    def pload(*args)
      spawn.pload!.includes!(*args)
    end

    def pload!
      if Pload.enabled?
        extending! PloadedRelation
      else
        self
      end
    end

    def pload?
      extending_values.include? PloadedRelation
    end
  end

  module PloadedRelation
    def first(*)
      super.pload
    end

    def last(*)
      super.pload
    end

    def each
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
      @pload = Pload.enabled?
      self
    end

    def pload?
      @pload
    end
  end

  module Association
    def reader(pload: true)
      return super() unless pload && owner.pload?

      unless loaded?
        raise Pload::AssociationNotLoadedError.new(owner, reflection)
      end

      super().pload
    end
  end
end

ActiveRecord::Base.prepend Pload::Base
ActiveRecord::Relation.prepend Pload::Relation
ActiveRecord::Associations::SingularAssociation.prepend Pload::Association
ActiveRecord::Associations::CollectionAssociation.prepend Pload::Association
