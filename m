Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx143.postini.com [74.125.245.143])
	by kanga.kvack.org (Postfix) with SMTP id 1371E6B005D
	for <linux-mm@kvack.org>; Mon, 23 Jul 2012 17:20:08 -0400 (EDT)
Date: Mon, 23 Jul 2012 22:20:03 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: [MMTests] Stress high-order allocations on ext3
Message-ID: <20120723212003.GF9222@suse.de>
References: <20120620113252.GE4011@suse.de>
 <20120629111932.GA14154@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20120629111932.GA14154@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org

Configuration:	global-dhp__stress-highalloc-performance-ext3
Result: 	http://www.csn.ul.ie/~mel/postings/mmtests-20120424/global-dhp__stress-highalloc-performance-ext3
Benchmarks:	kernbench vmr-stream sysbench stress-highalloc

Summary
=======

Allocation success rates of huge pages were looking great until 3.4 when
they dropped through the floor.

Benchmark notes
===============

All machines were booted with mem=4096M due to limitations of the test

This is an old series of benchmarks that stressed anti-fragmentation
and the allocation of huge pages. It is being replaced with other series
of tests which will be more representative but it still produces some
interesting results. I tend to use these results as an early warning
system before doing a more detailed series of tests.

Only the results from the stress-highalloc benchmark are actually of
interest and the other benchmarks are just there to age the machine
in terms of fragmentation.

===========================================================
Machine:	arnold
Result:		http://www.csn.ul.ie/~mel/postings/mmtests-20120424/global-dhp__stress-highalloc-performance-ext3/arnold/comparison.html
Arch:		x86
CPUs:		1 socket, 2 threads
Model:		Pentium 4
Disk:		Single Rotary Disk
===========================================================

stress-highalloc
----------------

Generally this is going in the right direction. High-order allocations
are reasonably successful and where they drop, they have been matched
by a large reduction in the length of time it takes to complete the test.
Success rates in 3.4 did drop sharply though.


==========================================================
Machine:	hydra
Result:		http://www.csn.ul.ie/~mel/postings/mmtests-20120424/global-dhp__stress-highalloc-performance-ext3/hydra/comparison.html
Arch:		x86-64
CPUs:		1 socket, 4 threads
Model:		AMD Phenom II X4 940
Disk:		Single Rotary Disk
==========================================================

stress-highalloc
----------------

Until 3.4, this was looking good. Unfortunately in 3.4 there was a massive
drop in success rates. This correlates with the removal of lumpy reclaim
which compaction indirectly depended upon. This strongly indicates that
enough memory is not being reclaimed for compaction to make forward
progress or compaction is being disabled routinely due to failed attempts
at compaction.

The success rates at the end of the test when the machine is idle are 
still high implying that anti-fragmentation itself is still working
as expected.

==========================================================
Machine:	sandy
Result:		http://www.csn.ul.ie/~mel/postings/mmtests-20120424/global-dhp__stress-highalloc-performance-ext3/sandy/comparison.html
Arch:		x86-64
CPUs:		1 socket, 8 threads
Model:		Intel Core i7-2600
Disk:		Single Rotary Disk
==========================================================

Same as hydra, this was looking good until 3.4 and then success rates dropped
through the floor.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
