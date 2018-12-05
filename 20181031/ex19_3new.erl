-module(ex19_3new).
-compile(export_all).

test1() ->
    {ok,Bin1} = file:read_file("file1.txt"),
    Str1 = binary_to_list(Bin1),
    R1 = rolling_checksum(Str1),
    {ok,Bin2} = file:read_file("file2.txt"),
    Str2 = binary_to_list(Bin2),
    R2 = rolling_checksum(Str2),
    {R1,R2,Str1,Str2}.

test() ->
    TableId = create_ets_table("file1.txt"),
    check_plagiarisms("file2.txt", TableId).

check_plagiarisms(Filename, TableId) ->
    {ok,Bin} = file:read_file(Filename),
    Str = binary_to_list(Bin),
    Sample_list = ets:tab2list(TableId),
    Check_list = turn_element_into_tuple(rolling_checksum(Str),[]),
    do_compare(Sample_list, Check_list, 0, erlang:length(Check_list)).

create_ets_table(Filename) ->
    {ok,Bin} = file:read_file(Filename),
    Str = binary_to_list(Bin),
    TableId = ets:new(?MODULE, [duplicate_bag]),
    Data = turn_element_into_tuple(rolling_checksum(Str), []),
    ets:insert(TableId, Data),
    TableId.

turn_element_into_tuple([H|T], Result) ->
    Result1 = Result ++ [{H}],
    turn_element_into_tuple(T, Result1);

turn_element_into_tuple([], Result) ->
    Result.

% Assume file1 and file2 have the same length.
do_compare(L, [H2|T2], Num, Total_block) ->
    case lists:member(H2,L) of
        true ->
	    Num1 = Num + 1,
	    do_compare(L,T2,Num1,Total_block);
	false ->
	    do_compare(L,T2,Num,Total_block)
    end;

do_compare(_, [], Num, Total_block) ->
    io:format("The plagiarism rate is ~w%~n",[Num / Total_block * 100]).
	    

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