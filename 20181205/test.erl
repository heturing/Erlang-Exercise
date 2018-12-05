-module(test).
-export([start/0]).

start() ->
    % START JOB_CENTRE SERVER
    job_centre:start_link(),
    
    % START UNION SERVER
    ex22_5:start_link(),

    % START TRACE PROGRAM
    ex22_5:start(),

    % ADD SOME JOB
    job_centre:add_job(a),
    job_centre:add_job(b),

    % DEFINE AN AUXILIARY FUNCTION
    Wait = fun() -> receive after infinity -> ok end end,

    % CREATE A WORKER AND TRY TO FIRE HIM BEFORE HE GETS WARNED.
    WorkerPid = spawn(fun() -> job_centre:work_wanted(), receive Msg -> io:format("received ~p~n", [Msg]), Wait() end end).
    %job_centre:fire_worker(WorkerPid).

    