using Dates
include("/home/rosenrot/tradeBinance/robots/source/source.jl")
cd("/home/rosenrot/tradeBinance")

try
        run(`git add ./information/log/\*`)
        run(`git commit -m "log upd $(Date(now(UTC)))"`)
        run(`git push`)
        src.logging("common.log", 0, "Start jit_log_updater.jl")
catch
        src.logging("common.log", 0, "Failed to run git_log_updater.jl")
end
