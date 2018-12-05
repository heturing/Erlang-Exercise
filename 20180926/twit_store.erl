-module(twit_store).
-export([init/1, store/2, fetch/1]).

init(K) ->
	case file:open("twit.txt",[raw,binary,write]) of
	     {ok,S} ->
	     	    Res = file:allocate(S,1,140 * K),
		    file:close(S),
		    Res;
	     {error, Why} ->
	     	     Why
	end.

store(N, Buf) ->
	case file:open("twit.txt",[read,raw,binary,write]) of
	     {ok,S} ->
	     	    Res = file:pwrite(S, 140 * (N - 1), Buf),
		    file:close(S),
		    Res;
	     {error,Why} ->
	     		 Why
	end.
	     	    

fetch(N) ->
	case file:open("twit.txt",[raw,binary,read]) of
	     {ok,S} ->
	     	    Res = file:pread(S, (N - 1) * 140, 140),
		    file:close(S),
		    Res;
	     {error,Why} ->
	     		 Why
	end.
	     
	     
	