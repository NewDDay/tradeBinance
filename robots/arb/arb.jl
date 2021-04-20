# Цены из БД логарифмируются и задача поиска арбитражной позиции сводится
# к задаче поиска отрицательного цикла в системе взвешенных направленных графов.
# Применён алгоритм Беллмана-Форда

using LibPQ, DataFrames
include("/home/rosenrot/tradeBinance/robots/source/binanceAPI.jl")
include("/home/rosenrot/tradeBinance/robots/source/source.jl")

a = [zeros(9), zeros(9)]
ways = [[2, 3, 5], [1, 3, 4, 5, 6, 7, 8, 9], [1, 2, 4, 5, 6, 7, 8, 9],
    [2, 3], [1, 2, 3, 6, 8], [2, 3, 5], [2, 3], [2, 3, 5], [2, 3]]

function next(i)
    push!(c, i)
    if (i != 0.0) && !in(a[2][Int64(i)], c)
        return next(a[2][Int64(i)])
    end
    push!(c, a[2][Int64(i)])
    return c
end

# while true
#     try
#         LibPQ.Connection(src.data()["connPG"]) do conn
#             global ways
#             global a
#
#                 global df = execute(conn, """select -log("AAVE") as "AAVE", -log("BNB") as "BNB", -log("BTC") as "BTC", -log("CTK") as "CTK", -log("ETH") as "ETH", -log("LTC") as "LTC", -log("SOL") as "SOL", -log("TRX") as "TRX", -log("YFI") as "YFI" from prices where name != 'CAKE' AND name != 'BURGER' order by name;""") |> DataFrame
#                 # df = convert(Matrix, df)
#
#             try
#                 for x in 1:9
#                     buf = copy(a[1])
#                     buf_ways = copy(a[2])
#                     for f in 1:9
#                         for s in ways[f]
#                             if (a[1][f] + df[f, s]) < buf[s]
#                                 buf[s] = a[1][f] + df[f, s]
#                                 buf_ways[s] = f
#                             end
#                         end
#                     end
#                     # if buf_ways == a[2]
#                     #     # println(x)
#                     #     break
#                     # end
#                     a[2] = copy(buf_ways)
#                     a[1] = copy(buf)
#                     # x |> print
#                     # println(round.(a[1]; digits=2), "\n", a[2])
#                 end
#             catch
#                 src.logging("arb_errors.log", 0, "Ошибка алгоритма Беллмана-Форда")
#             end
#
#             for i in 1.0:1.0:9.0
#                 try
#                     global c = []
#                     src.logging("arb.log", 3, "$(next(i))\n($df)")
#                     # println(next(i))
#                 catch
#                     src.logging("arb_errors.log", 0, "Ошибка поиска цикла")
#                 end
#             end
#         end
#     catch
#         src.logging("arb_errors.log", 0, "Ошибка программы")
#     end
# end


LibPQ.Connection(src.data()["connPG"]) do conn
    global ways
    global a

        global df = execute(conn, """select -log("AAVE") as "AAVE", -log("BNB") as "BNB", -log("BTC") as "BTC", -log("CTK") as "CTK", -log("ETH") as "ETH", -log("LTC") as "LTC", -log("SOL") as "SOL", -log("TRX") as "TRX", -log("YFI") as "YFI" from prices where name != 'CAKE' AND name != 'BURGER' order by name;""") |> DataFrame
        # df = convert(Matrix, df)
end

for x in 1:9
    buf = copy(a[1])
    buf_ways = copy(a[2])
    for f in 1:9
        for s in ways[f]
            if (a[1][f] + df[f, s]) < buf[s]
                buf[s] = a[1][f] + df[f, s]
                buf_ways[s] = f
            end
        end
    end

    # if buf_ways == a[2]
    #     # println(x)
    #     break
    # end
    a[2] = copy(buf_ways)
    a[1] = copy(buf)
    # x |> print
    # println(round.(a[1]; digits=2), "\n", a[2])
end

a

df

for i in 1.0:1.0:9.0
    global c = []
    next(i)
    # src.logging("arb.log", 3, "$(next(i))\n($df)")
    # println(next(i))
end


a = [zeros(9).+100, zeros(9)]
b = [collect(1:9), collect(1:9)]

for x in 1:2
    for f in b[2]
        for s in ways[f]
            # println("$x\t$f -> $s")
            if (df[f, s] + a[2][s] < a[1][s])
                a[1][s] = df[f, s] + a[2][s]
                b[1][s] = f
                # println(a[1][s])
            end
        end
    end
    println(a[1])
    println(b[1])
    a[2] = copy(a[1])
    b[2] = copy(b[1])
end


df |> println
