require 'mongoid'

module Mongoid
  module Likeable

    extend ActiveSupport::Concern

    included do
      field :likes, type: Integer, default: 0
      field :liker_ids, type: Array, default: []
    end

    def like(liker)
      id = liker_id(liker)
      return if liked? id
      push liker_ids: id
      update_likers
    end

    def unlike(liker)
      id = liker_id(liker)
      return unless liked? id
      pull liker_ids: id
      update_likers
    end

    def liked?(liker)
      id = liker_id(liker)
      liker_ids.include?(id)
    end
    
    def likers
      liker_ids.map{ |liker| User.find(liker) if liker.respond_to?(:_id) } || liker_ids
    end

    private
    def liker_id(liker)
      if liker.respond_to?(:_id)
        liker._id
      else
        liker
      end
    end

    def update_likers
      update_attribute :likes, liker_ids.size
    end
  end
end
