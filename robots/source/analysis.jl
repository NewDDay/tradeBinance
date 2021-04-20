module an
    """
        function sma(vec::Vector, len::Int)

    Средняя скользящая
    """
    function sma(vec::Vector, len::Int)
        size = length(vec)
        sma = Vector{Float64}(undef, 0)
        for i in 1:size
            ma_at_moment = sum(vec[((i-len+1) < 1 ? 1 : (i-len+1)):i]) / ((i-len+1) < 1 ? i : len)
            push!(sma, ma_at_moment)
        end
        return sma
    end



    # using Dates, JSON, CSV, DataFrames
    #
    # """
    #     logging(namefile::String, relevance::Integer, str::String)
    #
    # Записать событие в лог-файл.
    # Фиксирует время событие.
    # Можно присвоить цифру от 0 до 9 для убодного поиска.
    # # Examples
    # ```julia-repl
    # julia> logging(2, "Start")
    # [2020-07-02T15:42:13.14][2]     Start
    # ```
    # """
    # function logging(namefile::String, relevance::Integer, str::String)
    #     if -1 < relevance < 10
    #         try
    #             open("/home/rosenrot/tradeBinance/information/log/$namefile", "a") do io
    #                 write(io, "[$(now(UTC))][$relevance] \t$str \n")
    #             end
    #         catch
    #             @error("Не удаётся открыть лог файл") # "julia > book &". При это команде, эта строка выбьется в консоль
    #             println("Не удаётся открыть лог файл") # А эта в файл.
    #         end
    #     else
    #         @error("Не правильный приоритет! Логи не ведутся!")
    #         println("Не правильный приоритет! Логи не ведутся!")
    #     end
    # end
end


# vec = 1
# len = 2
# prices[vec]
#
# prices[1:3]
# 1 < 3
#
# if len
#
# function sma(vec::Int64, len::Int64)
#     # println((num-len+1), " - ", num)
#     sum(prices[(num-len+1):num])/len
# end
