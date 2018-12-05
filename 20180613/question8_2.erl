-module(question8_2).
-export([mostFunctions/0, mostcommon/0,unambiguous/0]).


% return the name list of all loaded modules 
getModules() ->
	     L = code:all_loaded(),
	     [ X || {X, _} <- L].

% return a list of tuple which consisted by module name and the number of functions in the module
getFunctions(Mods) ->
		   L = [ list_to_tuple(X:module_info()) || X <- Mods],
		   [ {ModuleName, length(FunctionList)}|| {{module,ModuleName},{exports,FunctionList},_,_,_,_} <- L].

% return the module which has the most functions
mostFunctions() ->
                    L = getFunctions(getModules()),
		    [{Name,Function}|_] = lists:sort(fun mygrter/2, L),
		    io:format("~n module ~p has the most functions, the number is ~p~n", [Name, Function]).

% compare two tuple
mygrter({_,Num1}, {_,Num2}) when Num1 >= Num2 -> true;
mygrter({_,Num1}, {_,Num2}) -> false.

% input: a list of module names
% output: a map of function name and the time of the function
functiontomap(Mods) ->
		  L = [ list_to_tuple(X:module_info()) || X <- Mods],
		  L1 = [ {ModuleName, FunctionList}|| {{module,ModuleName},{exports,FunctionList},_,_,_,_} <- L],
		  L2 = myMerge( [ X || {_,X} <- L1]),
		  L3 = [ X || {X,_} <- L2],
		  add_to_map(L3,#{}).

%input : a map
%output : the most common function
mostcommon() ->
              M = functiontomap(getModules()),
	      [{FuncName,Times}|_] = lists:sort(fun mygrter/2, maps:to_list(M)),
	      io:format("~n function ~p is the most common functions, there are  ~p functions have the same the name ~p~n", [FuncName, Times, FuncName]).

% return a list of keys which has value 1.
unambiguous() ->
	       L = maps:to_list(functiontomap(getModules())),
	       io:format("these function are unambiguous~n"),
	       io:format("~p",[[ X || {X,1} <- L]]).
		 


add_to_map([H|T], M) ->
		  M1 = maps:update_with(H, fun addone/1, 1, M),
		  add_to_map(T,M1);
add_to_map([],M) -> M.
		  

addone(X) -> X+1.

myMerge([H|T]) ->
	       lists:merge(H, myMerge(T));

myMerge([]) -> [].
		  
	 
		   
		    

