module Endpoints
  class Game < Base
    # N.B.: with this mechanism things break down if we scale to > 1 process;
    # add some Redis or something in that case
    set :sockets, []

    namespace '/game' do
      get do
        if !request.websocket?
          raise Pliny::Errors::MethodNotAllowed # ¯\_(ツ)_/¯
        else
          request.websocket do |ws|
            ws.onopen do
              # send info about pending games (created but not started
              # and under max players)

              # TODO: support re-joining games if you've joined a game
              # but got disconnected
              ws.send(JSON.generate({}))
              settings.sockets << ws
            end
            ws.onmessage do |msg|
              payload = JSON.parse(msg, symbolize_names: true)
              case payload[:type]
              when :new_game
                # create a new game
              when :join
                # join an existing game (player id, game id)
              when :start
                # start a game that you've created
              when :leave
                # leave a game you've joined
              when :move
                # make a move in an active game
              else
                # send error
              end
              # if any of the above fail, also send error
              EM.next_tick do
                settings.sockets.each {|s| s.send(msg) }
              end
            end
            ws.onclose do
              settings.sockets.delete(ws)
            end
          end
        end
      end
    end
  end
end
