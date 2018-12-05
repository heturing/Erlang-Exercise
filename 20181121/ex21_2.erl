-module(ex21_2).
-export([test/0]).

test() ->
	D0 = my_dict_error:new(),
	D1 = my_dict_error:store(k1,100,D0),
	100 = my_dict_error:fetch(k1,D1),
	1 = my_dict_error:size(D1),
	D2 = my_dict_error:erase(k1,D1),
	0 = my_dict_error:size(D2),
	ok.