using Plots, Dates

open("/home/rosenrot/tradeBinance/information/log/BTCtoETH.log", "r") do io
    global file = String(read(io))
end

times = DateTime[]
number = Float64[]
limit = Float64[]

rx_time = r".*\["
m = eachmatch(rx_time, file)
f = collect(m)
for x in f
    #x.match[2:end-2] |> println
    tt = DateTime(x.match[2:end-2])
    push!(times, tt)
end

rx_delay = r" .+ "
m = eachmatch(rx_delay, file)
f = collect(m)
for x in f
    num = parse(Float64, x.match[3:end-1])
    push!(number, num)
    push!(limit, 0.23)
end

times
number
limit

pl = plot(times, [number, limit], fmt = :png)

#savefig( "131233.pdf")
