class Player < Sequel::Model
  plugin :timestamps, update_on_create: true
end
