Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx144.postini.com [74.125.245.144])
	by kanga.kvack.org (Postfix) with SMTP id A4A4A6B004D
	for <linux-mm@kvack.org>; Mon, 23 Jul 2012 17:13:43 -0400 (EDT)
Date: Mon, 23 Jul 2012 22:13:34 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: [MMTests] Sysbench read-only on ext3
Message-ID: <20120723211334.GA9222@suse.de>
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

Configuration:	global-dhp__io-sysbench-large-ro-ext3
Result: 	http://www.csn.ul.ie/~mel/postings/mmtests-20120424/global-dhp__io-sysbench-large-ro-ext3
Benchmarks:	sysbench

Summary
=======

Very large number of regressions.

Benchmark notes
===============

mkfs was run on system startup. No attempt was made to age it. No
special mkfs or mount options were used.

sysbench is an OLTP-like benchmark. The test type was "complex" and
read-only. The table size was 50,000,000 rows regardless of memory size
but far exceeds the memory size of any of the test machines. sysbench
was chosen because it's a reasonably complex OLTP-like benchmark with
straight-forward prerequisites.

The backing database was postgres.

===========================================================
Machine:	arnold
Result:		http://www.csn.ul.ie/~mel/postings/mmtests-20120424/global-dhp__io-sysbench-large-ro-ext3/arnold/comparison.html
Arch:		x86
CPUs:		1 socket, 2 threads
Model:		Pentium 4
Disk:		Single Rotary Disk
===========================================================

sysbench
--------
  Oddly two clients is better but 1 or 4 is worse. 

  Swapping for kernels 3.1 and 3.2 is crazy. Direct reclaim started since
  2.6.39 and has not eased off but in the context of the overall test is
  very low.

==========================================================
Machine:	hydra
Result:		http://www.csn.ul.ie/~mel/postings/mmtests-20120424/global-dhp__io-sysbench-large-ro-ext3/hydra/comparison.html
Arch:		x86-64
CPUs:		1 socket, 4 threads
Model:		AMD Phenom II X4 940
Disk:		Single Rotary Disk
Status:		Ok
==========================================================

sysbench
--------
  There are a lot of regressions here that were mostly introduced between
  2.6.39 and 3.0. In general, this is looking bad.

  Swapping in kernel 3.1 was higher.

==========================================================
Machine:	sandy
Result:		http://www.csn.ul.ie/~mel/postings/mmtests-20120424/global-dhp__io-sysbench-large-ro-ext3/sandy/comparison.html
Arch:		x86-64
CPUs:		1 socket, 8 threads
Model:		Intel Core i7-2600
Disk:		Single Rotary Disk
Status:		
==========================================================

  Generally this is telling a much better story but this could be because
  of the much larger memory size of this machine offsetting some other
  regression.

  Swapping in 3.1 and 3.2.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
