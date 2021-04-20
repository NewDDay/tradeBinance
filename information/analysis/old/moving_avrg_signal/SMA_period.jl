# Цель программы: найти оптимальные периоды для SMA

using LibPQ, DataFrames, Plots, Dates
include("/home/rosenrot/tradeBinance/robots/source/binanceAPI.jl")
include("/home/rosenrot/tradeBinance/robots/source/source.jl")
plotly()

df = LibPQ.Connection(src.data()["connPG"]) do conn
                execute(conn, """SELECT * FROM "kline_BTCUSDT_1m" ORDER BY start;""")
end |> DataFrame

function ma(i, l)
        sum(df[i-l+1:i, 4])/l
end

for l in 2:10
        for L in 2*l:5*l
                s = 0
                buf = 0
                flag = 0

                for i in L+1:size(df)[1]
                        if (ma(i, l) > ma(i, L)) && (ma(i-1, l) < ma(i-1, L))
                                flag = 1
                                buf = i
                        elseif (ma(i, l) < ma(i, L)) && (ma(i-1, l) > ma(i-1, L)) && flag == 1
                                s += df[i, 4] - df[buf, 4]
                                flag = 0
                                # println("""{$(df[buf, 4]);$(df[buf, 1])} -> {$(df[i, 4]);$(df[i, 1])}  = $(df[i, 4] - df[buf, 3]) ~ $s""")
                        end
                end
                if s > 1500 println("$l and $L - $s") end
        end
end

# Проанализировав котировки за трое суток, я нашёл оптимальные длины
# средних скользящих. Это 2 и 6.
