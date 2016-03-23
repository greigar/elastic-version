class Conversation < ActiveRecord::Base
  include Elasticsearch::Model
  include Elasticsearch::Model::Callbacks
  has_paper_trail

  def self.search(query)
    __elasticsearch__.search(
      {
        query: {
          multi_match: {
            query: query,
            fields: ['state^10', 'body']
          }
        },
        highlight: {
          pre_tags: ['<em>'],
          post_tags: ['</em>'],
          fields: {
            state: {},
            body:  {}
          }
        }
      }
    )
  end

  def self.search_string(query)
    __elasticsearch__.search(
      {
        query: {
          query_string: {
            fields: ['state^5', 'body'],
            query: query
          }
        },
        highlight: {
          pre_tags: ['<em>'],
          post_tags: ['</em>'],
          fields: {
            state: {},
            body:  {}
          }
        }
      }
    )
  end

  settings index: { number_of_shards: 1 } do
    mappings dynamic: 'false' do
      indexes :state, analyzer: 'english'
      indexes :body , analyzer: 'english', index_options: 'offsets'
    end
  end

  def show_versions
    c_previous = self

    while c_previous
      puts "#{c_previous.body} : #{c_previous.previous_version.try(:body)}"
      c_previous = c_previous.previous_version
    end
    versions.each do |v|
      puts "#{v.id} #{v.reify || 'na'}"
    end
  end
end

  # Delete the previous articles index in Elasticsearch
  # Conversation.__elasticsearch__.client.indices.delete index: Conversation.index_name rescue nil

  # Create the new index with the new mapping
  # Conversation.__elasticsearch__.client.indices.create index: Conversation.index_name,
        # body: { settings: Conversation.settings.to_hash, mappings: Conversation.mappings.to_hash }

  # Index all article records from the DB to Elasticsearch
  # Conversation.import
