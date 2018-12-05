-module(ex13_6).
-export([start/0, stop/1, stopNormal/1]).

aWorker(N) ->
	   %io:format("worker ~p~n", [N]),
	   receive
		stop -> io:format("worker ~p stoped abnormally ~n", [N]),
		     	exit(abnormal);
		stopNormal ->  io:format("worker ~p stoped normally ~n", [N])
	   after 2500 ->
	   	      io:format("worker ~p is working, Pid is ~p~n", [N, self()]),
		      aWorker(N)
	   end.

workerMonitor(Pids) ->
		[erlang:monitor(process,Pid) || Pid <- Pids],
		receive
			%Msg -> io:format("Monitor stops with ~p",[Msg])
			{'DOWN', Ref, process, P, Why}  when Why =/= normal ->
				[exit(Pid, abnormal) || Pid <- Pids],
				start()
		end.
					 

start() ->
	Pid1 = spawn(fun() -> aWorker(1) end),
	Pid2 = spawn(fun() -> aWorker(2) end),
	Pid3 = spawn(fun() -> aWorker(3) end),
	PidMonitor = spawn(fun() -> workerMonitor([Pid1, Pid2, Pid3]) end),
	io:format("Pid1 is ~p, Pid2 is ~p, Pid3 is ~p, PidMonitor is ~p~n",[Pid1, Pid2, Pid3, PidMonitor]).
	

stop(Pid) ->
	  Pid ! stop.

stopNormal(Pid) ->
		Pid ! stopNormal.


			       