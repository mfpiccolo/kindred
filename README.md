kindred
============
| Project                 |  Gem Release      |
|------------------------ | ----------------- |
| Gem name                |  kindred      |
| License                 |  [MIT](LICENSE.txt)   |
| Version                 |  [![Gem Version](https://badge.fury.io/rb/kindred.png)](http://badge.fury.io/rb/kindred) |
| Continuous Integration  |  [![Build Status](https://travis-ci.org/mfpiccolo/kindred.png?branch=master)](https://travis-ci.org/mfpiccolo/kindred)
| Test Coverage           |  [![Coverage Status](https://coveralls.io/repos/mfpiccolo/kindred/badge.png?branch=master)](https://coveralls.io/r/mfpiccolo/kindred?branch=coveralls)
| Grade                   |  [![Code Climate](https://codeclimate.com/github/mfpiccolo/kindred/badges/gpa.svg)](https://codeclimate.com/github/mfpiccolo/kindred)
| Dependencies            |  [![Dependency Status](https://gemnasium.com/mfpiccolo/kindred.png)](https://gemnasium.com/mfpiccolo/kindred)
| Homepage                |  [http://mfpiccolo.github.io/kindred][homepage] |
| Documentation           |  [http://rdoc.info/github/mfpiccolo/kindred/frames][documentation] |
| Issues                  |  [https://github.com/mfpiccolo/kindred/issues][issues] |

## Description
Kindred is an open source project that intends to optimize programmers happiness and productivity for client-heavy rails applications. Kindred aims to allow developers to create robust client side applications with minimal code while maintaining best practices and conventions.

## Installation

Add this line to your application's Gemfile:

```ruby
gem "kindred"
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install kindred

## Demo

If you would like to see kindred in action check out [kindred-demo](https://kindred-demo.herokuapp.com/dashboard).

## Features
###Templates
In a rails view you can pass html to your javascript by using the `#template` helper method.
The `#template` method takes the following keyword arguments:

`model:` String of the javascript model name

`collection:` Collection of json serializable ruby objects

`target:` String of the data-target attribute wrapper

`&block` In the block pass html that will be used for that model

```HTML
  <div data-target="line-item">
    <%= template(collection: @line_items, target: "line-item", model: "line_item") do %>
      <tr>
        <td><%= k_text_field_tag(:line_item, :description) %></td>
        <td><%= k_text_field_tag(:line_item, :qty) %></td>
        <td><%= k_text_field_tag(:line_item, :price_cents) %></td>
        <td><%= k_check_box_tag(:line_item, :complete) %></td>
      </tr>
    <% end %>
  </div>
 ```
Templates will be available in your javascript by accessing the `App.Template` class.  The `#template_info` property is an array of objects that contain both the collection and the template namespaced under the model that you passed.

If you passed a line_item you could access it with:

`li_info = App.Template.template_info["line_item"]`

You could then get access to the collection or the template by using those properties.

`li_info.template` would return the html you passed through

`li_info.collection` would return the json collection

###Controllers
In kindred, javascript controllers are a client side augmentation of your ruby controllers.  They are just client side code that gets run on page load.

```coffeescript
  class this.InvoicesController
    @edit: ->
       console.log "Run this on invoice edit view"
```

To ensure that this code is run on the client side call the js method from your view or controller:

```ruby
class InvoicesController < ApplicationController
  def edit
    @line_items = @invoice.line_items

    respond_to do |format|
      format.html { js }
    end
  end
end
```

###Models

A kindred model is an object that helps the interaction between the page and the rails api.

Here is an example model:

```coffeescript
class App.LineItem extends App.Base

  @route = "/line_items"
  @set_class_name("LineItem")
```

####Instance Functions

#####Page functions:

`append_to_page()` This function will put the values from the model instance that is called on the page.  If the element found is an input it will add it as a value.  If it is not an input it will insert the value into the tag.

`dirty_from_page()` This boolean function will check all the inputs that belong to the model instance that it is being called on and check if the value has changed since it was set on the page.  Returns true or false.

`assign_attributes_from_page()`  This will grab all the inputs that belong to a model instance and assign them to the attributes property as a javascript object.

`remove_errors_from_page()`  This function will remove all errors from the page belonging to the model instance.

#####Base functions:

`set(attr_name, val)` Assigns the value to the model instance attributes object using the attribute name as a key.

```coffeescript
li = new App.LineItem()
li.set("foo", "bar")
li.attributes # => Object {uuid: "some-uuid", foo: "bar"}
```

`get(attr_name)` Retrieves the value from the model instance attributes object using the attribute name.

```coffeescript
li = new App.LineItem({foo: "bar"})
li.get("foo") # => "bar"
```

`save()` ajax post request to the route specified in the model with the data from the model instance attributes object to either post or patch depending on the presence of the id.

```coffeescript
li = new App.LineItem({foo: "bar"})
li.save() # => sends request to POST or PATCH depending on presince of id
```

```
# Server log
Started POST "/line_items.json" for 127.0.0.1 at 2014-12-14 02:35:32 -0800
Processing by LineItemsController#create as JSON
  Parameters: {"line_item"=>{"uuid"=>"354f1fb8-a80a-449d-2320-e316bb02390c", "foo"=>"bar"}}
```

`destroy()` ajax delete request to the route specified in the model.

```coffeescript
li = new App.LineItem({id: 1})
li.destroy() # => Removes element from the page and sends delete request if id present
```

```
# Server log
Started DELETE "/line_items/1.json" for 127.0.0.1 at 2014-12-14 02:41:39 -0800
Processing by LineItemsController#destroy as JSON
  Parameters: {"id"=>"1"}
```

`assign_attributes(attrs)` Adds the attrs to the attributes object for the model instance.

```coffeescript
li = new App.LineItem({foo: "bar"})
li.assign_attributes({baz: qux, quux: "corge"})
li.attributes # => Object {uuid: "some-uuid", foo: "bar", baz: "qux", quux: "corge"}
```

#####Base Overridable Hooks:
These hooks have defalut functionality but you can override them in the model to do custom behavior.

`after_save`

`after_save_error`

`after_destroy`

`after_destroy_error`

Here is an example where you are removing relevant errors from the page after deleting a line item.

```coffeescript
class App.LineItem extends App.Base

  @route = "/line_items"
  @set_class_name("LineItem")

  # kindred override hook
  after_destroy: (data, textStatus, xhr) ->
    $("[data-error][data-k-uuid='" + @uuid + "']").parent().parent().remove()
```

####Class Functions

`set_template()` On page load, use this function to set the template for the model.
(i.e. `App.LineItem.set_template App.Template.template_info["line_item"]`)

`set_class_name()` Sets the class name for the model as well as dash_name and snake_name.

`collection_from_page()` Retrieves a collection of model objects from the page.

`save_all(opts)` Collects all the objects of this class from the page ajax posts the json to the save_all action.

###Listeners
Listeners in kindred should be namespaces and set in classes.

Below is an example of a listener that will both send a delete request to the server and remove the element from the page.

```coffeescript
# app/assets/javascripts/listeners/invoice_listeners.coffee
class App.InvoiceListeners extends App.Listener

  @set: ->
    $("#line-item-table").on "click.Listeners.LineItem.delete", ".delete", (evt) ->
      li = new App.LineItem({id: $(@).data("id"), uuid: $(@).data("k-uuid")})
      li.destroy()
      $(@).parent().parent().remove()
```

A bonus for namespacing the listener is that you can see all the listeners that kindred has registerd using the `App.Listeners` class.

`App.Listeners` will return an object which contains all the registered listeners and information about each listener.

### Error Logging

All jquery element not found errors are logged to `App.Logger`

`App.Logger.errors` will return an array of errors with information including stack traces.

### Naming and Directory Structure
Although this is really up to the individual developer, Kindred should really be set up with a similar naming and directory stucture as rails.

If you are adding code that is controller and action specific, then add a directory called controllers in your `app/assets/javascripts` directory.  If your controllers are namespaced then namespace them just like you do in your rails controllers.  Here is an example of a namespaced coffee class:

```coffeescript
# app/assets/javascripts/controllers/admin/special/orders_controller.coffee
@Admin ||= {};
@Admin.Special ||= {};

class @Admin.Special.OrdersController

  @index: (args) ->
    alert("Do some js stuff here...")
```

Put models in `app/assets/javascripts/models`

```coffeescript
# app/assets/javascripts/models/some_model.coffee
class App.SomeModel

  @route = "/some_models"
  @set_class_name("SomeModel")
```

Make note of the ||=.  This is to make sure that you don't overwrite the js object if it already exists.

Use this same naming and directory structure for all your js.  If you are creating service objects then put them in `app/assets/javascripts/services`

Remember to add your paths to the manifest so sprockets can load them:

```
//= require_tree ./controllers
//= require_tree ./services
```

Or require them explicitly:

`//= require controllers/admin/special/orders_controller`

## Donating
Support this project and [others by mfpiccolo][gittip-mfpiccolo] via [gittip][gittip-mfpiccolo].

[gittip-mfpiccolo]: https://www.gittip.com/mfpiccolo/

## Copyright

Copyright (c) 2014 Mike Piccolo

See [LICENSE.txt](LICENSE.txt) for details.

## Contributing

1. Fork it ( http://github.com/mfpiccolo/kindred/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

[![githalytics.com alpha](https://cruel-carlota.pagodabox.com/e1a155a07163d56ca0c4f246c7aa8766 "githalytics.com")](http://githalytics.com/mfpiccolo/kindred)

[license]: https://github.com/mfpiccolo/kindred/MIT-LICENSE
[homepage]: http://mfpiccolo.github.io/kindred
[documentation]: http://rdoc.info/github/mfpiccolo/kindred/frames
[issues]: https://github.com/mfpiccolo/kindred/issues

