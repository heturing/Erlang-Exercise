-module(ex21_3).
-compile(export_all).

start() ->
    cover:start(),
    cover:compile(my_dict_error).

stop() ->
    cover:analyse_to_file(my_dict_error),
    cover:stop().

test() ->
    D0 = my_dict_error:new(),
    D1 = my_dict_error:store(k1,100,D0),
    100 = my_dict_error:fetch(k1,D1),
    1 = my_dict_error:size(D1),

% New test starts from here.
    my_dict_error:is_key(k1,D1),
    D3 = my_dict_error:append(k2,1,D1),
    D4 = my_dict_error:append_list(k3,[2,3,4],D3),
    my_dict_error:fetch_keys(D4),
    my_dict_error:filter(fun(K, V) -> K =/= V end, D4),
    my_dict_error:find(k1,D4),
    my_dict_error:fold(fun(K,V,Acc) -> Acc ++ [{K,V}] end, [], D4),
    D5 = my_dict_error:from_list([{a,1},{b,2},{c,3},{d,4}]),
    my_dict_error:is_empty(D5),
    D6 = my_dict_error:map(fun(K,V) -> 0 end, D5),
    D7 = my_dict_error:merge(fun(K,V1,V2) -> -1 end, D3,D5),
    my_dict_error:take(k1,D1),
    my_dict_error:to_list(D1),
    D8 = my_dict_error:update(k1,fun(X) -> X + 50 end,D1),
    D9 = my_dict_error:update(k5,fun(X) -> X + 40 end,-2,D1),
    D10 = my_dict_error:update_counter(k1,5,D8),
    D2 = my_dict_error:erase(k1,D1),
    ok.