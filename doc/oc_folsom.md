

# Module oc_folsom #
* [Description](#description)
* [Data Types](#types)
* [Function Index](#index)
* [Function Details](#functions)


Helper module for instrumenting code with folsom metrics.
Copyright (c) 2012 Opscode, Inc.

__Authors:__ Seth Chisamore ([`schisamo@opscode.com`](mailto:schisamo@opscode.com)).
<a name="description"></a>

## Description ##



This module provides convenience functions for standardizing the naming of metric labels
for use with folsom. All metric labels are binaries. Since the purpose of this module is
to concatenate things into a label, using binaries requires less work. The function
convert to binary using `iolist_to_binary`. If we used atoms, there would be an
additional step to translate back to an atom. Binaries are also GC'd, unlike atoms, which
would be a benefit for the unlikely case of dynamic metrics that come and go.


We assume that the folsom application is started as a top-level application within an OTP
release.

<a name="types"></a>

## Data Types ##




### <a name="type-atom_or_bin">atom_or_bin()</a> ###



<pre><code>
atom_or_bin() = atom() | binary()
</code></pre>


<a name="index"></a>

## Function Index ##


<table width="100%" border="1" cellspacing="0" cellpadding="2" summary="function index"><tr><td valign="top"><a href="#app_label-2">app_label/2</a></td><td>Generate a label for an application-level metric.</td></tr><tr><td valign="top"><a href="#mf_label-2">mf_label/2</a></td><td>Generate a folsom metric label for module <code>Mod</code> and function name <code>Fun</code>.</td></tr><tr><td valign="top"><a href="#time-2">time/2</a></td><td>Capturing duration and rate metrics for the execution of function <code>Fun</code>.</td></tr></table>


<a name="functions"></a>

## Function Details ##

<a name="app_label-2"></a>

### app_label/2 ###


<pre><code>
app_label(App::<a href="#type-atom_or_bin">atom_or_bin()</a>, Name::<a href="#type-atom_or_bin">atom_or_bin()</a>) -&gt; binary()
</code></pre>

<br></br>


Generate a label for an application-level metric. The returned name will be prefixed
with "app.".
<a name="mf_label-2"></a>

### mf_label/2 ###


<pre><code>
mf_label(Mod::atom(), Fun::atom()) -&gt; binary()
</code></pre>

<br></br>


Generate a folsom metric label for module `Mod` and function name `Fun`. The
returned label will be prefixed with "function.".
<a name="time-2"></a>

### time/2 ###


<pre><code>
time(Metric::binary(), Fun::fun(() -&gt; any())) -&gt; any()
</code></pre>

<br></br>


Capturing duration and rate metrics for the execution of function `Fun`. Two metrics
will be recorded, `<<Metric/binary, ".rate">>` (meter) and `<<Metric/binary,
".duration">>` (histogram). The run time of `Fun` is captured using `timer:tc`.
