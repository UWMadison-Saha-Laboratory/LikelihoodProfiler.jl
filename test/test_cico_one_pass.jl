# specific tests for CICO_ONE_PASS

@testset "f_1p" begin
    res0 = [get_right_endpoint(
        [3.0],
        (x::Vector{Float64}) -> x[i],
        (x::Vector{Float64}) -> f_1p(x) - 9.,
        Val(:CICO_ONE_PASS)
    ) for i in 1:1]
    @test isapprox(res0[1][1], 5., atol=1e-2)
    @test res0[1][3] == :BORDER_FOUND_BY_SCAN_TOL
end

@testset "get endpoint for fun" begin
    res0 = get_endpoint(
        [10.0],
        (x::Vector{Float64}) -> x[1],
        (x::Vector{Float64}) -> f_1p(x),
        :CICO_ONE_PASS,
        :left;

        loss_crit = 9.,
        scale = [:log], # not working
        #theta_bounds = [(0., 45.)],
        #scan_bound = 5.
    )

    res1 = get_endpoint(
        [10.0],
        (x::Vector{Float64}) -> x[1],
        (x::Vector{Float64}) -> f_1p(x),
        :CICO_ONE_PASS,
        :right;

        loss_crit = 9.,
        scale = [:log], # not working
        #theta_bounds = [(0., 45.)],
        #scan_bound = 5.
    )
end
