-module(ex19_3).
-compile(export_all).
%-export([test/0]).

test() ->
    TableId = pass1(["./file1.txt","./file2.txt"]),
    show_table(TableId),
    pass2("./file3.txt", TableId).

show_table(TableId) ->
    L = ets:tab2list(TableId),
    io:format("~w~n",[L]).

pass2(File, TableId) ->
    {ok,Bin} = file:read_file(File),
    Str = binary_to_list(Bin),
    L = rolling_checksum(Str),
    check_plagiarisms(L,1,TableId).

check_plagiarisms([],I,TableId) ->
    false;

check_plagiarisms([H|T], I, TableId) ->
    case ets:lookup(TableId, [H]) of
        [] ->
	    check_plagiarisms(T,I+1,TableId);
	Any ->
	    {true,Any,I}
    end.

pass1(Files) ->
    L = [{X,break_file(X)} || X <- Files],
    L1 = change_format(L,[]),
    TableId = ets:new(?MODULE, [duplicate_bag]),
    [ets:insert(TableId, X1) || X1 <- L1],
%    R = ets:tab2list(TableId),
%    io:format("~p",[R]),
    TableId.
   

change_format([H|T], Result) ->
    {Filename,Checksums} = H,
    L = Result ++ [{X,Filename} || X <- Checksums],
    change_format(T, L);
change_format([], Result) ->
    Result.

break_file(File) ->
    {ok,Bin} = file:read_file(File),
    Str = binary_to_list(Bin),
    L = break_list(Str,[]),
    L1 = [rolling_checksum(X) || X <- L],
    L1.
    

break_list(Str, Result) ->
    case erlang:length(Str) >= 40 of
        true ->
	    {Head, Tail} = lists:split(40,Str),
	    Result1 = Result ++ [Head],
	    break_list(Tail, Result1);
	false ->
	    Result ++ [Str]
    end.
    

rolling_checksum(Str) ->
    Len = string:length(Str),
    case Len - 40 =< 0 of
        true ->
	    [do_checksum(Str, 0)];
	false ->
	    Initial = do_checksum(string:slice(Str, 0 ,40), 0),
	    Index = 41,
	    left_checksums(Str, Index, Initial, []) ++ [Initial]
	    
    end.
	    

left_checksums(Str, Index, Lastchecksum, Result) ->
    case Index =< string:length(Str) of
        true ->
            This_checksum = next_checksum(get_char(Str, Index), get_char(Str, Index - 40), Lastchecksum),
            Result1 = Result ++ [This_checksum],
            left_checksums(Str, Index + 1, This_checksum, Result1);
	false ->
	    Result
    end.


get_char(Str, N) ->
    string:slice(Str, N - 1, 1).

do_checksum([H|T], Result) ->
    Result1 = Result + H,
    do_checksum(T, Result1);

do_checksum([], Result) ->
    Result.

next_checksum(Lastchar, Prevchar, Lastchecksum) ->
    hd(Lastchar) - hd(Prevchar) + Lastchecksum.