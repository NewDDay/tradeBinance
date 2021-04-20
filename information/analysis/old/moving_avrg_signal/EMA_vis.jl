# Программа написана для визуализации EMA
# Вывод - с Бинансом не совпадает, но следует проверить прибыльность

using LibPQ, DataFrames, Plots
include("/home/rosenrot/tradeBinance/robots/source/binanceAPI.jl")
include("/home/rosenrot/tradeBinance/robots/source/source.jl")

LibPQ.Connection(src.data()["connPG"]) do conn
        global df = execute(conn, """SELECT * FROM "kline_BTCUSDT_1m" ORDER BY start DESC LIMIT 200;""") |> DataFrame
        α = 2/7
        β = 2/3
        global EMA_long = []
        global EMA_short = []
        push!(EMA_short, df[200, 4])
        push!(EMA_long, df[200, 4])
        for i in 199:-1:1
                push!(EMA_short, df[i, 4]*β + EMA_short[200-i] * (1-β))
                push!(EMA_long, df[i, 4]*α + EMA_long[200-i] * (1-α))
        end
        time = df[1, 1]
        while true
                df = execute(conn, """SELECT * FROM "kline_BTCUSDT_1m" ORDER BY start DESC LIMIT 2;""") |> DataFrame
                if df[1, 1] > time
                        popfirst!(EMA_short)
                        popfirst!(EMA_long)
                        push!(EMA_short, df[1, 4]*β + EMA_short[199] * (1-β))
                        push!(EMA_long, df[1, 4]*α + EMA_long[199] * (1-α))
                        time = df[1, 1]
                else
                        # pop!(EMA_short)
                        # pop!(EMA_long)
                        EMA_long[end] = df[1, 4]*α + EMA_long[199] * (1-α)
                        EMA_short[end] = df[1, 4]*β + EMA_short[199] * (1-β)
                end

                plt = plot(EMA_short, leg = false)
                plot!(EMA_long, leg = false)
                display(plt)
        end
end
