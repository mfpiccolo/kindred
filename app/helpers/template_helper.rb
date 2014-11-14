module TemplateHelper

  def bind(collection:, container: nil, &block)
    if container.present?
      open_and_close_elem = {open: "<tbody data-collection='purchase_orders'>", close: "</tbody>"}
    end

    js(
      js_class: "PurchaseOrdersController",
      function: "index",
      args: {
        template: capture(&block),
        purchase_orders: collection.to_json,
      },
      container: open_and_close_elem,
      rendered: true
    )
  end

  def data_attr_for(class_name, attribute)
    if class_name.is_a? Symbol
      "data-id=''  data-class=#{class_name.to_s.classify} data-attr=#{attribute}"
    # elsif class_name is AR object
      # add id class name and attr
    # end
    end
  end

end
