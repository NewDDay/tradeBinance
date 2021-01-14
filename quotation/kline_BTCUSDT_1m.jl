# Проверить работу скрипта на BNBUSDT возможно будет работать лучше
# Посмотреть, может ли он обновлять интервалы корректно?
# Построить среднюю скользящую, и сравнить с бинансом (сначала залогировать, потом сохранить)
# Заработало, надо тестануть

using LibPQ, HTTP,  JSON, Dates
include("/home/rosenrot/tradeBinance/robots/source/binanceAPI.jl")
include("/home/rosenrot/tradeBinance/robots/source/source.jl")

while true
    try
        LibPQ.Connection(src.data()["connPG"]) do conn
            function inDB(kline::Dict{String,Any})
                execute(conn, """INSERT INTO "kline_BTCUSDT_1m"
                                (start, stop, open, close, max, min, volume)
                                VALUES
                                ('$(unix2datetime(kline["k"]["t"]/1000))', '$(unix2datetime(kline["k"]["T"]/1000))',
                                '$(kline["k"]["o"])', '$(kline["k"]["c"])', '$(kline["k"]["h"])', '$(kline["k"]["l"])',
                                '$(kline["k"]["v"])')
                                ON CONFLICT (start) DO UPDATE SET
                                "open"= $(kline["k"]["o"]), "close"= $(kline["k"]["c"]),
                                "max"= $(kline["k"]["h"]), "min"= $(kline["k"]["l"]),
                                "volume" = $(kline["k"]["v"]);""")
            end

            HTTP.WebSockets.open(string(BN.BINANCE_API_WS, lowercase("BTCUSDT"), string("@kline_", "1m")); verbose=false) do io
                while !eof(io)
                    try
                        kline = JSON.parse(String(readavailable(io)))
                        @async inDB(kline)
                    catch
                    end
                end
            end
        end
    catch
    end
end
