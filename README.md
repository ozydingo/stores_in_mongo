# stores_in_mongo
Seamlessly attach a Mongo document field to and ActiveRecord object 

## What's new

v1.3.1
 - Fix bug where the `reload` method was not accepting arguments (e.g. `lock: true`).

v1.3.0
 - Allow non-Hash data structures in mongo field

## IMPORTANT UPDATE

There is a bug in v1.0.0 with the directory structure of the gem. Please update to 1.2.0 or higher.

## Usage

In an ActiveRecord model, use

`stores_in_mongo :data`

Specify the type, e.g. Hash, using

`stores_in_mongo :data, Hash`

To create a pseudo-field called "data" on your model that is stored in a Mongo collection. You can now access this field using `model_instance.data` or `model_instance.data = some_data`. The mogno data itself is represented by a new class at model.class::MongoDocument (e.g. Post::MongoDocument`), which , via the `Mongoid` gem will create a collection called `"#{class_name}_mongo_dcouments"` in your mongo db. "data" is the default field name, but you can use anything, subject to the same namespace conflicts as any method name you'd create on your model.

The mongo document is automatically saved when the model is saved, and destroyed when the model is destroyed. There is no auto creation, but you can add it if you like! Use `before_create :find_or_initialize_document` in your model to do so.

The mongo data is only fetched when referenced, so intiailizing an instance of your model will not be slowed or gated by your connection to mongo unless you explicitly read the data.

The `dup` and `reload` methods are overridden on StoresInMongo::DocumentMethods, included into your model, to also dup or reload the associated document if it has already been read.

Enjoy! Feedback and feature requests welcome!