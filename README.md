# stores_in_mongo
### Create virtual attributes of an ActiveRecord model that are stored in a Mongo database

Have you ever wanted to perform relational JOINs between your SQL tables and Mongo documents?

Have you ever abused ActiveRecord's `serialize` feature and stored way too much complex data in your SQL table that you know deep in your heart shuld be offloaded, perhaps to a Mongo document?

Now you can with ease!

This gem allows you to interact with fields that you define as if they were fields of your model, but actually store their data in a Mongo document. The class representing the Mongo document itself can be created dynamically by stores_in_mongo, or you can provide an existing class that includes `Mongoid::Document`.

An example use case is a Transcript model that you also wish to store in a relational database, for example to join to other resources (e.g. `:project` and `:user`):

```ruby
class Transcript < ActiveRecord::Base
  belongs_to: :project
  belongs_to: :user

  stores_in_mongo :words, Hash
end
```

This setup requires the `transcript` table to have a `String` column called `mongo_document_id`, which can be customized (see below).

You can then use `Transcript#words` as if it were a field of `Transcript`. This is functionally similar to defining a `has_one_document` association using a gem such as [active_mongoid](https://github.com/sportngin/active_mongoid), but this implementation allows developers to skip any fussing with a separate object, instead treating the data as a native field. Here, the `words` field is saved with the model, reloaded with the model, destroyed with the model, and deep_dup'd with the model. Data is loaded on-demand, meaning you don't have to worry about slow performance due to loading from an external Mongo database unless you're actually referencing the data.

You can specify multiple fields and additional options in a single model using block syntax:

```ruby
class Transcript < ActiveRecord::Base
  belongs_to: :project
  belongs_to: :user

  stores_in_mongo do
    field :words, Hash
    field :keywords, Array
  end
end
```


## What's new

v1.0.0
 - Block syntax, allowing multiple fields
 - Add options to specify existing class and foreign_key column name
 - Remove `dup` override in favor of more aggressive `deep_dup` implementation.
 - Change default document_id column from `document_id` to `mongo_document_id`
 - Rename private `document*` methods to safer, more explicit `mongo_document*` names

 NOTE: to upgrade to v2.0 from previous versions, you will either have to migrate your database to rename the `document_id` column to `mongo_document_id`, or else provide `foreign_key: "document_id"` as an argument to `stores_in_mongo`.

v0.3.0
 - Allow non-Hash data types

## Detailed spec

The basic use case is described in the example above, using the `stores_in_mongo` method with the provided block. There are some document-level options and field-level options available.

`StoresInMongo::Base` is included by default in `ActiveRecord::Base`. This defined the method `stores_in_mongo`, which you can use to attach Mongo-backed virtual-fields to your object. By default, calling `stores_in_mongo` will create a new class nested underneath your model called `MongoDocument` and its correspoding collection in your Mongo database (e.g. `Transcript::MongoDocument`, whose collection name will be `transcript_mongo_documents`)

There are two ways you can call `stores_in_mongo`:
 - Inline (quick) syntax, which allows only a single field
 `stores_in_mongo(field_name, data_type = nil, **options)`

 - Block syntax, which allows mutliple fields and additional options
 ```ruby
 stores_in_mongo(**options) do
  field field_name_1, data_type_1 = nil
  field field_name_2, data_type_2 = nil
  # ...etc
 end
 ```

### Args for `stores_in_mongo`
 - `field_name`: a `String` or `Symbol` namining the field. This argument can only be used with inline syntax.
 - `data_type` (default: `nil`): a data type (class), such as `Hash` or `Array`, that you could pass as `type` to a `Mongoid` class. This argument can only be used with inline syntax.
 - `:class_name` (default: `nil`): provide an existing Mongoid class instead of having `stores_in_mongo` define one on the fly. This class must already exist (or be auto-loadable) by the time this code executes.
 - `:foreign_key` (default: `class_name.foreign_key`): specify the column of the model that holds the id of the mongo document. This will be `mongo_document_id` by default if the `class_name` argument is also not specified. If `class_name` is specified to be, for example, `"Transcript"`, this will be `transcript_id` by default.
 - `:as`: `String` specifying a polymorphic association to the Mongoid class. E.g. `as: "document"` will tell `stores_in_mongo` to look for the columns `document_type` and `document_id` to fetch and persist the Mongo document associated with this record. You cannot use this option with `:class_name` or `:foreign_key` options.

### Inside the block
The block passed to `stores_in_mongo` currently accepts two methods:
- `field(name, data_type=nil)`: same as inline syntax, but you can call this multiple times to define multiple fields.
- `session do ... end`: define an inline method that determines which mongoid session to use for a given model. This is useful if you need to store sensitive documents in different locations depending on instance attributes (e.g. client), but don't want to have to define polymorphic active-mongoid associations to the document classes and carry around all that bookeeping. For example:

```ruby
stores_in_mongo do
  field :name
  field :interview
  session do
    self.protected_client? ? "secure" : "default"
  end
end
```

This setup uses the `secure` session in your mongoid.yml file if `self.protected_client?` returns `true` for a given record, and `default` otherwise. For more, see the Mongoid docs on [custom persistence](https://docs.mongodb.com/ruby-driver/master/tutorials/5.1.0/mongoid-persistence/#custom).

### Other details

Setting fields assigns them in memory, but you need to `save` your object before these are persisted to the Mongo database.

The mongo document is automatically saved when the model is saved and destroyed when the model is destroyed. There is no auto creation (for the reason specified above), but you can add it if you like! You can try
`after_initialize :find_or_initialize_mongo_document`
or
`after_initialize :find_or_initialize_mongo_document :if => :new_record?` to be slightly less aggressive.

Calling `reload` on your object will reload the Mongo fields as well (but only if the document has already been loaded, saving performance when this behavior is not needed)

Calling `deep_dup` on your object will load the document if not already loaded and `deep_dup` it.

Changing the document data will cause Rails to update the `updated_at` field on save, if appropriate. `stores_in_mongo` does this by overriding the `dirty` method to also check for possible changes to the mongo document. Currently, we do not have a good way for detecting in-place changes to the document, so your model will always be marked as dirty if the document has been loaded.

Methods defined by `stores_in_mongo` are owned by a dynamically created module `model::MongoDocumentMethods`, where `model` is the class that called `stores_in_mongo`. Thus you can override these in your model and still have access to `super` if you would like to hook into the document creation, loading, or saving.

### TODO

Figure out if we can safely hack into the `changes` data and any other ActiveRecord features that described changed or non-persisted data.

---

Enjoy! Feedback and feature requests welcome!
