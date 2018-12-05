-module(ex19_3).
-compile(export_all).

start() ->
	Tab = ets:new(table, [set]),
	File = file:read_file("text1.txt"),
	write_checksum_into_ets(Tab, File).

write_checksum_into_ets(Tab, File) when erlang:length(File) >= 40 ->
			     DataList = rolling_checksum(File),
			     ets:insert(Tab, DataList).
			     
%rolling_checksum has been tested.

rolling_checksum(Context)->
			  A = calculate_init_checksum(Context),
			  rolling_checksum2(Context, erlang:length(Context), 2, [A]).

rolling_checksum2(Context, Length, Current, Result) when Current + 40 - 2 =:= Length ->
			   Result;

rolling_checksum2(Context, Length, Current, Result) ->
			   A = calculate_checksum(lists:last(Result), lists:nth(Current - 1, Context), lists:nth(Current + 40 - 1, Context)),
			   rolling_checksum2(Context, Length, Current + 1, lists:append(Result, [A])).

calculate_init_checksum(Context) ->
				 lists:sum(lists:sublist(Context, 40)).


calculate_checksum(Previous_checksum, Previous_char, Last_char) ->
				      Previous_checksum + Last_char - Previous_char.
			  
			     