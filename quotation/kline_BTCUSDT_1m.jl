# Данна программа записывает котировку (макс и мин цены, цену открытия и закрытие, объём торгов) каждую минуту

using LibPQ, HTTP,  JSON, Dates
include("/home/rosenrot/tradeBinance/robots/source/binanceAPI.jl")
include("/home/rosenrot/tradeBinance/robots/source/source.jl")

src.logging("common.log", 0, "Start kline_BTCUSDT_1m.jl")

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
                    catch err
                        # src.logging("common.log", 4, "Поминутный вебсокет: $err\n")
                    end
                end
            end
        end
    catch err
        src.logging("common.log", 0, "Failed to run kline_BTCUSDT_1m.jl")
    end
end

# src.logging("common.log", 0, "Стоп поминутного вебсокета")
