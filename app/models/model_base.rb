class ModelBase

  # generic attribute loader
  def load_parameter_attributes(attributes = {})
    if !attributes.nil?
      attributes.each do |name, value|
        setter = "#{name}="
        next unless respond_to?(setter)
        send(setter, value)
      end
    end
  end

end 