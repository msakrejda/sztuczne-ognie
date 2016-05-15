Sequel.migration do
  change do
    create_table(:games) do
      uuid         :id, default: Sequel.function(:uuid_generate_v4), primary_key: true
      timestamptz  :created_at, default: Sequel.function(:now), null: false
      timestamptz  :started_at
      timestamptz  :finished_at
      jsonb        :state, null: false
    end
  end
end
