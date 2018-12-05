-module(ex15_3).
-export([cpu/0]).

cpu() ->
      os:cmd("sysctl -n machdep.cpu.brand_string").