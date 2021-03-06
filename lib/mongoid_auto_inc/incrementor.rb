# This is a modified version of the code found on this blog post:
#   http://ihswebdesign.com/blog/autoincrement-in-mongodb-with-ruby/
module MongoidAutoInc
  class Incrementor
    class Sequence
      def initialize(sequence, collection_name, seed)
        @sequence = sequence.to_s
        @collection = collection_name.to_s
        exists? || create(seed)
      end

      def inc
        update_number_with("$inc" => { "number" => 1 })
      end

      def set(number)
        update_number_with("$set" => { "number" => number })
      end

      private

      def exists?
        collection.find(query).count > 0
      end

      def create(number = 0)
        collection.insert(query.merge({ "number" => number }))
      end

      def collection
          Mongoid.default_session[@collection]
      end

      def query
        { "seq_name" => @sequence }
      end

      def current
          collection.find(query).one['number']
      end

      def update_number_with(mongo_func)
        opts = {
          "query"  => query,
          "update" => mongo_func,
          "new"    => true # return the modified document
        }
          collection.database.command({
            findandmodify: collection.name
          }.merge(opts))['value']['number']

      end
    end

    def initialize(options=nil)
      options ||= {}
      @collection = options[:collection] || "sequences"
      @seed = options[:seed].to_i
    end

    def [](sequence)
      Sequence.new(sequence, @collection, @seed)
    end

    def []=(sequence, number)
      Sequence.new(sequence, @collection, @seed).set(number)
    end
  end
end
