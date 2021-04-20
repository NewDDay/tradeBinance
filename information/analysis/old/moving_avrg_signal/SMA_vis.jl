using LibPQ, DataFrames, Plots
include("/home/rosenrot/tradeBinance/robots/source/binanceAPI.jl")
include("/home/rosenrot/tradeBinance/robots/source/source.jl")

LibPQ.Connection(src.data()["connPG"]) do conn
        df = execute(conn, """SELECT * FROM "kline_BTCUSDT_1m" ORDER BY start DESC LIMIT 12;""") |> DataFrame
        short = []
        long = []
        for i in 6:-1:1
                push!(short, sum(df[i:i+1, 4])/2)
                push!(long, sum(df[i:i+5, 4])/6)
        end
        plt = plot(short)
        plot!(long)
        display(plt)
end
