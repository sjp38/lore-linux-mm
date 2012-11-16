Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx178.postini.com [74.125.245.178])
	by kanga.kvack.org (Postfix) with SMTP id 34DF76B005A
	for <linux-mm@kvack.org>; Fri, 16 Nov 2012 08:20:40 -0500 (EST)
Date: Fri, 16 Nov 2012 13:20:36 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: MMTests 0.07
Message-ID: <20121116132036.GY8218@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>
Cc: LKML <linux-kernel@vger.kernel.org>

MMTests 0.07 is a configurable test suite that runs a number of common
workloads of interest to MM developers. In this release the major point
of interest is specjbb automation which I was using for evaluating the
different automatic NUMA migration implementations with the configuration
file at configs/config-global-dhp__jvm-specjbb. Using this test will
require setting up an internal mirror with the specjbb tarball. There are
also some basic monitoring scripts for NUMA-related information.

Changelog since V0.06
o Add benchmark for specjbb
o Run multiple instances of tiobench and report variances
o Basic NUMA monitoring scripts
o Describe the components of autonumbench and add a configuration file

Changelog since v0.05
o Automatically install packages (need name mappings for other distros)
o Add benchmark for autonumabench
o Add support for benchmarking NAS with MPI
o Add pgbench for autonumabench (may need a bit more work)
o Upgrade postgres version to 9.2.1
o Upgrade kernel verion used for kernbench to 3.0 for newer toolchains
o Alter mailserver config to finish in a reasonable time
o Add monitor for perf sched
o Add moinitor that gathers ftrace information with trace-cmd
o Add preliminary monitors for NUMA stats (very basic)
o Specify ftrace events to monitor from config file
o Remove the bulk of whats left of VMRegress
o Convert shellpacks to a template format to auto-generate boilerplate code
o Collect lock_stat information if enabled
o Run multiple iterations of aim9
o Add basic regression tests for Cross Memory Attach
o Copy with preempt being enabled in highalloc stres tests
o Have largedd cope with a missing large file to work with
o Add a monitor-only mode to just capture logs
o Report receive-side throughput in netperf for results

At LSF/MM at some point a request was made that a series of tests
be identified that were of interest to MM developers and that could be
used for testing the Linux memory management subsystem. There is renewed
interest in some sort of general testing framework during discussions for
Kernel Summit 2012 so here is what I use.

http://www.csn.ul.ie/~mel/projects/mmtests/
http://www.csn.ul.ie/~mel/projects/mmtests/mmtests-0.07-mmtests-0.01.tar.gz

There is a git repository at

https://github.com/gormanm/mmtests.git

There are a number of stock configurations stored in configs/.  For example
config-global-dhp__pagealloc-performance runs a number of tests that
may be able to identify performance regressions or gains in the page
allocator. Similarly there network and scheduler configs. There are also
more complex options. config-global-dhp__parallelio-memcachetest will run
memcachetest in the foreground while doing IO of different sizes in the
background to measure how much unrelated IO affects the throughput of an
in-memory database.

Out of the box it should now do something useful by running a page fault
microbenchmark.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
