Sequel.migration do
  up do
    create_table(:games_players) do
      foreign_key :game_id, :games, type: :uuid
      foreign_key :player_id, :players, type: :uuid
      timestamptz :joined_at, null: false
      timestamptz :left_at
    end
  end

  down do
    drop_table(:games_players)
  end
end
