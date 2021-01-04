using LibPQ, DataFrames
include("/home/rosenrot/tradeBinance/robots/source/binanceAPI.jl")
include("/home/rosenrot/tradeBinance/robots/source/source.jl")

df[1, 2]
df[2, 1]
df
df
LibPQ.Connection(src.data()["connPG"]) do conn
    while true
        # Убрать глобал!
        global df = execute(conn, """select log("BNB") as "BNB", log("BTC") as "BTC", log("ETH") as "ETH", log("LTC") as "LTC" from prices order by name;""") |> DataFrame

        # name = names(df)
        # len = length(name)
        sleep(0.01)
        k = -0.0001
        a = df[1, 2] + df[2, 3] + df[3, 1]
        a < k ? src.logging("/test.log", 0, "$a") : false
        a = df[1, 2] + df[2, 4] + df[4, 1]
        a < k ? src.logging("/test.log", 0, "$a") : false
        a = df[1, 3] + df[3, 4] + df[4, 1]
        a < k ? src.logging("/test.log", 0, "$a") : false
        a = df[1, 4] + df[4, 3] + df[3, 1]
        a < k ? src.logging("/test.log", 0, "$a") : false
        a = df[1, 4] + df[4, 2] + df[2, 1]
        a < k ? src.logging("/test.log", 0, "$a") : false
        a = df[1, 3] + df[3, 2] + df[2, 1]
        a < k ? src.logging("/test.log", 0, "$a") : false

        a = df[2, 1] + df[1, 3] + df[3, 2]
        a < k ? src.logging("/test.log", 0, "$a") : false
        a = df[2, 1] + df[1, 4] + df[4, 2]
        a < k ? src.logging("/test.log", 0, "$a") : false
        a = df[2, 3] + df[3, 4] + df[4, 2]
        a < k ? src.logging("/test.log", 0, "$a") : false
        a = df[2, 4] + df[4, 3] + df[3, 2]
        a < k ? src.logging("/test.log", 0, "$a") : false
        a = df[2, 4] + df[4, 1] + df[1, 2]
        a < k ? src.logging("/test.log", 0, "$a") : false
        a = df[2, 3] + df[3, 1] + df[1, 2]
        a < k ? src.logging("/test.log", 0, "$a") : false

        a = df[3, 2] + df[2, 1] + df[1, 3]
        a < k ? src.logging("/test.log", 0, "$a") : false
        a = df[3, 2] + df[2, 4] + df[4, 3]
        a < k ? src.logging("/test.log", 0, "$a") : false
        a = df[3, 1] + df[1, 4] + df[4, 3]
        a < k ? src.logging("/test.log", 0, "$a") : false
        a = df[3, 4] + df[4, 1] + df[1, 3]
        a < k ? src.logging("/test.log", 0, "$a") : false
        a = df[3, 4] + df[4, 2] + df[2, 3]
        a < k ? src.logging("/test.log", 0, "$a") : false
        a = df[3, 1] + df[1, 2] + df[2, 3]
        a < k ? src.logging("/test.log", 0, "$a") : false

        a = df[4, 2] + df[2, 3] + df[3, 4]
        a < k ? src.logging("/test.log", 0, "$a") : false
        a = df[4, 2] + df[2, 1] + df[1, 4]
        a < k ? src.logging("/test.log", 0, "$a") : false
        a = df[4, 3] + df[3, 1] + df[1, 4]
        a < k ? src.logging("/test.log", 0, "$a") : false
        a = df[4, 1] + df[1, 3] + df[3, 4]
        a < k ? src.logging("/test.log", 0, "$a") : false
        a = df[4, 1] + df[1, 2] + df[2, 4]
        a < k ? src.logging("/test.log", 0, "$a") : false
        a = df[4, 3] + df[3, 2] + df[2, 4]
        a < k ? src.logging("/test.log", 0, "$a") : false
    end
end



#
# for x in 1:len
#     for y in 1:len
#         if x!=y
#             f = df[x, y]
#             # "f - $f" |> println
#             for z in 1:len
#                 if x!=z && y!=z
#                     s = f + df[y, z]
#                     # "s - $s" |> println
#                     t = s + df[z, x]
#                     # "t - $t" |> println
#                     t > 0.0001 ? src.logging("/test.log", 0, "$(name[x]) -> $(name[y]) -> $(name[z]) -> $(name[x]) - $(round(t, digits = 5))") : false
#                     for k in 1:len
#                         if x!=k && y!=k && z!=k
#                             a = s + df[z, k] + df[k, x]
#                             a > 0.0001 ? src.logging("/test.log", 0, "$(name[x]) -> $(name[y]) -> $(name[z]) -> $(name[k]) -> $(name[x]) - $(round(a, digits = 5))") : false
#                         end
#                     end
#                 end
#             end
#         end
#     end
# end
