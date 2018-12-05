-module(ex18_1).
-compile(export_all).

%Because we cannot execute the code of chapter 18, we implement the exercise 18.%1 by changing Browser to File. In other words, we output the results to a file.

%We also need two process - a browser process(Write data into File) and a client process(Simulate inputbox)

%To simulate the input process, we send client process a message {BrowserPid, Bin}, and the result will be written into file.

%Function test() is a simple example. 


%By calling start, we start a process to simulate client, and TableId is used to save commands.
start(Browser) ->
    B0 = erl_eval:new_bindings(),
    TableId = ets:new(?MODULE,[duplicate_bag,public]), 
    spawn(?MODULE, running, [Browser, B0, 1, TableId]).
running(Browser, B0, N, TableId) ->
    receive
	{Browser, Bin} ->
	    case string2value(binary_to_list(Bin), B0) of
	         {Value, B1} ->
		      ets:insert(TableId, {Bin}),
		      BV = bf("~w > ~s~n~p",[N, Bin, Value]),
	    	      Browser ! {show, BV},
	    	      running(Browser, B1, N+1, TableId);
		 parse_error ->
		      BV = bf("~w > ~p",[N, "Invaild input"]), 
		      Browser ! {show, BV},
		      running(Browser, B0, N, TableId)
	    end;
	showOldCommand ->
	    Commands = ets:tab2list(TableId),
	    Browser ! {showOldCommand, Commands},
	    running(Browser, B0, N, TableId);
	Other ->
	      io:format("other error~n")
    end.

string2value(Str, Bindings0) ->
    case erl_scan:string(Str, 0) of
      {ok, Tokens, _} ->
        case erl_parse:parse_exprs(Tokens) of
          {ok, Exprs} -> 
            {value, Val, Bindings1} = erl_eval:exprs(Exprs, Bindings0),
              {Val, Bindings1};
	    Other ->
	      io:format("cannot parse:~p Reason=~p~n",[Tokens,Other]),
		        parse_error
	end;
      Other ->
        io:format("cannot tokenise:~p Reason=~p~n",[Str,Other])
    end.

bf(F, D) ->
    list_to_binary(io_lib:format(F, D)).

%% This function is for simulating a browser.
browser() ->
	  spawn(?MODULE, browser1, []).

%%The browser will send message Bin to Client if it received a message {send, Client, Bin}.
browser1() ->
    receive
        {show, Data} ->
	       write_to_file(binary_to_list(Data)),
	       browser1();
	{showOldCommand, Data} ->
	       Data1 = [ tuple_to_list(X) || X <- Data],
	       write_to_file1(Data1),
	       browser1();
	{send, Client, Bin} ->
	       Client ! {self(), Bin},
	       browser1()
    end.

write_to_file(Bin) ->
	{ok,S} = file:open("./test.dat", [read,write,append,binary]),
	io:format(S, "~s~n", [Bin]),
	file:close(S).

write_to_file1(Bin) ->
	{ok,S} = file:open("./test.dat", [read,write,append,binary]),
	io:format(S,"~s~n",["old commands:"]),
	[io:format(S, "~s~n", [X]) || X <- Bin ],
	file:close(S).

%This is a simple example, and it checks whether our program crash when there are some error in our input.
test() ->
       BrowserPid = browser(),
       ClientPid = start(BrowserPid),
       ClientPid ! {BrowserPid, <<"X=10.">>},
       ClientPid ! {BrowserPid, <<"X*X*X.">>},
       ClientPid ! {BrowserPid, <<"X*X*X">>},
       ClientPid ! {BrowserPid, <<"X*X*X.">>},
       ClientPid ! showOldCommand.
       
