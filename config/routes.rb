Rails.application.routes.prepend do
  # Dynamically create routes based on defined attachments
  begin ; Rails.application.eager_load! ; rescue ; end

  loaded_url_templates = []
  must_create_default_route = false

  Paperclip.classes_with_attachments.each do |class_name|
    klass = class_name.constantize

    klass.attachment_definitions.each do |attachment_name, definition|
      next if (not definition.has_key? :storage) or definition[:storage].to_s != 'database'
      must_create_default_route = true and next unless definition.has_key?(:url)
      next if loaded_url_templates.include?(definition[:url])

      loaded_url_templates << definition[:url]

      #ap [klass.name, attachment_name, definition]
      get definition[:url] => 'paperclip_database_storage/attachments#get_attachment'
    end
  end

  # Generate the default route, if necessary
  if must_create_default_route
    get Paperclip::Attachment.default_options[:url].gsub(/:id_partition/, '*id_partition').gsub(/:filename/, '*filename') => 'paperclip_database_storage/attachments#get_attachment', :as => :default_pds
  end
end