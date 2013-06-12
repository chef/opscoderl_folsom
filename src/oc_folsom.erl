%% -*- erlang-indent-level: 4;indent-tabs-mode: nil; fill-column: 92-*-
%% ex: ts=4 sw=4 et
%% @author Seth Chisamore <schisamo@opscode.com>
%% @copyright 2012 Opscode, Inc.

%% @doc Helper module for instrumenting code with folsom metrics.
%%
%% This module provides convenience functions for standardizing the naming of metric labels
%% for use with folsom. All metric labels are binaries. Since the purpose of this module is
%% to concatenate things into a label, using binaries requires less work. The function
%% convert to binary using `iolist_to_binary'. If we used atoms, there would be an
%% additional step to translate back to an atom. Binaries are also GC'd, unlike atoms, which
%% would be a benefit for the unlikely case of dynamic metrics that come and go.
%%
%% We assume that the folsom application is started as a top-level application within an OTP
%% release.
%%
-module(oc_folsom).

-export([
         app_label/2,
         mf_label/2,
         time/2
        ]).

-define(APP_PREFIX, <<"app.">>).
-define(FUN_PREFIX, <<"function.">>).

-type atom_or_bin() :: atom() | binary().

%% @doc Generate a label for an application-level metric. The returned name will be prefixed
%% with "app.".
-spec app_label(atom_or_bin(), atom_or_bin()) -> binary().
app_label(App, Name) ->
    iolist_to_binary([?APP_PREFIX, to_bin(App), ".", to_bin(Name)]).

%% @doc Generate a folsom metric label for module `Mod' and function name `Fun'. The
%% returned label will be prefixed with "function.".
-spec mf_label(atom(), atom()) -> binary().
mf_label(Mod, Fun) ->
    ModBin = erlang:atom_to_binary(Mod, utf8),
    FunBin = erlang:atom_to_binary(Fun, utf8),
    iolist_to_binary([?FUN_PREFIX, ModBin, ".", FunBin]).

to_bin(B) when is_binary(B) ->
    B;
to_bin(A) when is_atom(A) ->
    erlang:atom_to_binary(A, utf8).

%% @doc Capturing duration and rate metrics for the execution of function `Fun'. Two metrics
%% will be recorded, `<<Metric/binary, ".rate">>' (meter) and `<<Metric/binary,
%% ".duration">>' (histogram). The run time of `Fun' is captured using `timer:tc'.
-spec time(binary(), fun(() -> any())) -> any().
time(Metric, Fun) when is_function(Fun) ->
    {Micros, Result} = timer:tc(Fun),
    Millis = Micros/1000,
    folsom_metrics:notify(<<Metric/binary, ".rate">>, 1, meter),
    folsom_metrics:notify(<<Metric/binary, ".duration">>, Millis, histogram),
    Result.
