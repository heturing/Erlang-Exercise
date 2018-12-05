-module(ex22_5).

-behaviour(gen_server).
-compile(export_all).

start_link() ->
    gen_server:start_link({local, ?MODULE}, ?MODULE, [], []),
    true.

init([]) ->
    S = dict:new(),
    {ok, S}.

show_all() ->
    gen_server:call(?MODULE, {show_all}).

add_worker(Pid) ->
    gen_server:call(?MODULE, {add_worker, Pid}).

delete_worker(Pid) ->
    gen_server:call(?MODULE, {delete_worker, Pid}).

is_registered_worker(Pid) ->
    gen_server:call(?MODULE, {is_registered_worker, Pid}).

is_alarmed(Pid) ->
    gen_server:call(?MODULE, {is_alarmed, Pid}).

update_worker_state(Pid) ->
    gen_server:call(?MODULE, {update_worker_state, Pid}).

handle_call({add_worker, Pid}, _From, State) ->
    State1 = dict:append(Pid,false,State),
    {reply,ok,State1};

handle_call({is_registered_worker, Pid}, _From, State)->
    Result = dict:is_key(Pid,State),
    {reply, Result, State};

handle_call({is_alarmed, Pid}, _From, State) ->
    Result = dict:fetch(Pid, State),
    {reply, Result, State};

handle_call({update_worker_state, Pid}, _From ,State) ->
    State1 = dict:update(Pid, fun(X) -> [true] end, State),
    {reply, ok, State1};

handle_call({show_all}, _From, State) ->
    Result = dict:to_list(State),
    {reply, Result, State};

handle_call({delete_worker, Pid}, _From, State) ->
    State1 = dict:erase(Pid, State),
    {reply, deleted, State1}.

start() ->
    Pid = spawn(?MODULE,tracer,[]),
    seq_trace:set_system_tracer(Pid), % set Pid as the system tracer 
    ok.

tracer() ->
    receive
        {seq_trace,Label,TraceInfo} ->
           print_trace(Label,TraceInfo,false);
        {seq_trace,Label,TraceInfo,Ts} ->
           print_trace(Label,TraceInfo,Ts);
        Other -> ignore
    end,
    tracer().        

print_trace(Label,TraceInfo,false) ->
    print_trace(TraceInfo);
print_trace(Label,TraceInfo,Ts) ->
    print_trace(TraceInfo).

print_trace({print,Serial,From,_,Info}) ->
    io:format("~p Info ~p WITH~n~p~n", [From,Serial,Info]);
print_trace({'receive',Serial,From,To,Message}) ->
    case is_registered_worker(To) andalso Message =:= {From,hurry_up} of
        true ->
            case is_alarmed(To) of
	        [true] ->
	            io:format("Already alarmed.~n");
	        [false] ->
		    update_worker_state(To),
	            io:format("Change state to alarm.~n");
		Any ->
		    io:format("received Any ~p~n",[Any])
	    end;
	false ->
	    false
    end;
print_trace({send,Serial,From,To,Message}) ->
    io:format("~p Sent ~p TO ~p WITH~n~p~n", 
              [From,Serial,To,Message]).