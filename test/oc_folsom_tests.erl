%% Copyright 2013 Opscode, Inc. All Rights Reserved.
%%
%% This file is provided to you under the Apache License,
%% Version 2.0 (the "License"); you may not use this file
%% except in compliance with the License.  You may obtain
%% a copy of the License at
%%
%%   http://www.apache.org/licenses/LICENSE-2.0
%%
%% Unless required by applicable law or agreed to in writing,
%% software distributed under the License is distributed on an
%% "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
%% KIND, either express or implied.  See the License for the
%% specific language governing permissions and limitations
%% under the License.
%%

-module(oc_folsom_tests).

-include_lib("eunit/include/eunit.hrl").

oc_folsom_test_() ->
    {setup,
     fun() ->
             application:start(folsom)
     end,
     fun(_) ->
             error_logger:delete_report_handler(error_logger_tty_h),
             application:stop(folsom)
     end,
     [
      {"application labels", generator,
       fun() ->
               [
                ?_assertEqual(<<"app.myapp.a_metric">>,
                              oc_folsom:app_label(myapp, <<"a_metric">>)),
                ?_assertEqual(<<"app.myapp.a_metric">>,
                              oc_folsom:app_label(myapp, 'a_metric'))
               ]
       end},

      {"mod fun labels", generator,
       fun() ->
               [
                ?_assertEqual(<<"function.ru_mod.funky">>,
                              oc_folsom:mf_label(ru_mod, funky))
                ]
       end},

      {"time records metrics",
       fun() ->
               oc_folsom:time(oc_folsom:app_label(myapp, test1),
                               fun() ->
                                       ok
                               end),
               Info = folsom_metrics:get_metrics_info(),
               Tester = fun({<<"app.myapp.test1.rate">>, L}) ->
                                ?assertEqual(meter, proplists:get_value(type, L));
                           ({<<"app.myapp.test1.duration">>, L}) ->
                                ?assertEqual(histogram, proplists:get_value(type, L))
                        end,
               [ Tester(I) || I <- Info ]
       end} 
      ]}.
