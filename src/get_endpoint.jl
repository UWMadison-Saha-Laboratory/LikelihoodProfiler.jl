"Structure storing one point from profile function"
struct ProfilePoint
    loss::Float64
    params::Array{Float64, 1}
    ret::Symbol
end

"End point storage"
struct EndPoint
    value::Float64
    profilePoints::Array{ProfilePoint, 1}
    status::Symbol
    direction::Symbol
    counter::Int64
end

# get left or right endpoint of CI for parameter component
function get_endpoint(
    theta_init::Vector{Float64},
    theta_num::Int64,
    loss_func::Function,
    loss_crit::Float64,
    method::Symbol,
    direction::Symbol = :right,
    scale::Vector{Symbol} = fill(:direct, length(theta_init));
    theta_bounds::Vector{Vector{Float64}} = ungarm.(
        fill([-Inf, Inf], length(theta_init)),
        scale
    ),
    kwargs...
)
    isLeft = direction == :left

    # set counter in the scope
    counter::Int64 = 0

    # transforming
    theta_init_gd = garm.(theta_init, scale)
    if isLeft theta_init_gd[theta_num] *= -1 end # change direction
    function loss_func_gd(theta_gd::Vector{Float64})
        theta_g = copy(theta_gd)
        if isLeft theta_g[theta_num] *= -1 end # change direction
        theta = ungarm.(theta_g, scale)
        # update counter
        counter += 1
        # calculate function
        loss_func(theta) - loss_crit
    end
    theta_bounds_gd = garm.(theta_bounds, scale)
    if isLeft theta_bounds_gd[theta_num] *= -1 end # change direction

    # calculate endpoint using base method
    (optf_gd, pp_gd, status) = get_right_endpoint(
        theta_init_gd,
        theta_num,
        loss_func_gd,
        Val(method);
        theta_bounds = theta_bounds_gd,
        kwargs...
    )

    # transforming back
    if isLeft optf_gd *= -1 end # change direction
    optf = ungarm(optf_gd, scale[theta_num])
    temp_fun = (pp::ProfilePoint) -> begin
        if isLeft pp.params[theta_num] *= -1 end # change direction
        ProfilePoint(
            pp.loss + loss_crit,
            ungarm.(pp.params, scale),
            pp.ret
        )
    end
    pps = [ temp_fun(pp_gd[i]) for i in 1:length(pp_gd) ]

    EndPoint(optf, pps, status, direction, counter)
end
