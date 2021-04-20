# Сравнение EMA с SMA показывает чуть ли не двойную разницу в пользу EMA

using LibPQ, DataFrames, Plots, Dates
include("/home/rosenrot/tradeBinance/robots/source/binanceAPI.jl")
include("/home/rosenrot/tradeBinance/robots/source/source.jl")

for β in 2:10
        β = 2//(β+1)
        for α in 2*β:5*β
                α = 2//(α+1)
                LibPQ.Connection(src.data()["connPG"]) do conn
                        global df = execute(conn, """SELECT * FROM "kline_BTCUSDT_1m" ORDER BY start DESC;""") |> DataFrame

                        global EMA_long = []
                        global EMA_short = []
                        push!(EMA_short, df[end, 4])
                        push!(EMA_long, df[end, 4])
                        for i in (size(df)[1]-1):-1:1
                                push!(EMA_short, df[i, 4]*β + EMA_short[size(df)[1]-i] * (1-β))
                                push!(EMA_long, df[i, 4]*α + EMA_long[size(df)[1]-i] * (1-α))
                        end
                end

                s = 0
                buf = 0
                flag = 0
                for i in 2:length(EMA_long)
                        if (EMA_short[i] > EMA_long[i]) && (EMA_short[i-1] < EMA_long[i-1])
                                flag = 1
                                global buf = i
                        elseif ((EMA_short[i] < EMA_long[i]) && (EMA_short[i-1] > EMA_long[i-1]) && (flag == 1))
                                global s += df[length(EMA_long)-i, 4] - df[length(EMA_long)-buf, 4]
                        end
                end
                if s > 000 println("$β and $α - $s") end
        end
end
