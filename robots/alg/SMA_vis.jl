println("Подключение к библиотекам")
using LibPQ, DataFrames, Dates, Plots
cd("/home/rosenrot/tradeBinance")
include("/home/rosenrot/tradeBinance/robots/source/binanceAPI.jl")
include("/home/rosenrot/tradeBinance/robots/source/source.jl")
include("/home/rosenrot/tradeBinance/robots/source/analysis.jl")
# unicodeplots()
plotly()

println("Запрос к БД")
df = LibPQ.Connection(src.data()["connPG"]) do conn
    execute(conn, """SELECT * FROM "kline_BTCUSDT_1m" WHERE start > '$(now(UTC) - Minute(2000))' ORDER BY start;""") |> DataFrame
end

println("Вычисление")
sma_short = an.sma(df[1:end, 4], 540)
sma_long = an.sma(df[1:end, 4], 1260)
prices = df[1:end, 4]
println("Визуализация")
plot(prices,
    size = (800, 400),
    width = 2,
    color = :black,
    smarker = (:dots,1),
    label = "Цена")
plot!(sma_short,
    width = 1.5,
    color = :red,
    label = "Короткая",
    smarker = (:dots,1))
plot!(sma_long,
    width = 1.5,
    color = :blue,
    label = "Средняя",
    smarker = (:dots,1))
savefig("./robots/alg/SMA.png")

# while true
#     println("Запрос БД")
#     df = LibPQ.Connection(src.data()["connPG"]) do conn
#         execute(conn, """SELECT * FROM "kline_BTCUSDT_1m" ORDER BY start DESC LIMIT 3000;""") |> DataFrame
#     end
#     println("Вычисление")
#     sma_short = an.sma(df[1:end, 4], 540)
#     sma_long = an.sma(df[1:end, 4], 1260)
#     prices = df[1:end, 4]
#
#     println("Визуализация")
#     plt = plot(prices,
#         size = (1000, 500),
#         width = 2,
#         color = :black,
#         smarker = (:dots,1),
#         label = "Цена")
#     plot!(sma_short,
#         width = 1.5,
#         color = :red,
#         label = "Короткая",
#         smarker = (:dots,1))
#     plot!(sma_long,
#         width = 1.5,
#         color = :blue,
#         label = "Средняя",
#         smarker = (:dots,1))
#     display(plt)
#         sleep(5)
# end
