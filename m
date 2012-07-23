Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx194.postini.com [74.125.245.194])
	by kanga.kvack.org (Postfix) with SMTP id 159F06B0068
	for <linux-mm@kvack.org>; Mon, 23 Jul 2012 17:25:37 -0400 (EDT)
Date: Mon, 23 Jul 2012 22:25:33 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: [MMTests] Threaded IO Performance on xfs
Message-ID: <20120723212533.GJ9222@suse.de>
References: <20120620113252.GE4011@suse.de>
 <20120629111932.GA14154@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20120629111932.GA14154@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, xfs@oss.sgi.com

Configuration:	global-dhp__io-threaded-xfs
Result: 	http://www.csn.ul.ie/~mel/postings/mmtests-20120424/global-dhp__io-threaded-xfs
Benchmarks:	tiobench

Summary
=======

There have been many improvements in the sequential read/write case but
3.4 is noticably worse than 3.3 in a number of cases.

Benchmark notes
===============

mkfs was run on system startup.
mkfs parameters -f -d agcount=8
mount options inode64,delaylog,logbsize=262144,nobarrier for the most part.
        On kernels to old to support delaylog was removed. On kernels
        where it was the default, it was specified and the warning ignored.

The size parameter for tiobench was 2*RAM. This is barely sufficient for
	this particular test where the size parameter should be multiple
	times the size of memory. The running time of the benchmark is
	already excessive and this is not likely to be changed.

===========================================================
Machine:	arnold
Result:		http://www.csn.ul.ie/~mel/postings/mmtests-20120424/global-dhp__io-threaded-xfs/arnold/comparison.html
Arch:		x86
CPUs:		1 socket, 2 threads
Model:		Pentium 4
Disk:		Single Rotary Disk
==========================================================

tiobench
--------
  This is a mixed bag. For low numbers of clients, throughput on
  sequential reads has improved.  For larger number of clients, there
  are many regressions but this is not consistent.  This could be due to
  weakness in the methodology due to both a small filesize and a small
  number of iterations.

  Random read is generally bad.

  For many kernels sequential write is good with the notable exception
  of 2.6.39 and 3.0 kernels.

  There was unexpected swapping on 3.1 and 3.2 kernels.

==========================================================
Machine:	hydra
Result:		http://www.csn.ul.ie/~mel/postings/mmtests-20120424/global-dhp__io-threaded-xfs/hydra/comparison.html
Arch:		x86-64
CPUs:		1 socket, 4 threads
Model:		AMD Phenom II X4 940
Disk:		Single Rotary Disk
==========================================================

tiobench
--------

  Like arnold, performance for sequential read is good for low number
  of clients.

  Random read looks good.

  With the exception of 3.0 in general and single threaded writes for all
  kernels, sequential writes have generally improved.

  Random write has a number of regressions.

  Kernels 3.1 and 3.2 had unexpected swapping.

==========================================================
Machine:	sandy
Result:		http://www.csn.ul.ie/~mel/postings/mmtests-20120424/global-dhp__io-threaded-xfs/sandy/comparison.html
Arch:		x86-64
CPUs:		1 socket, 8 threads
Model:		Intel Core i7-2600
Disk:		Single Rotary Disk
==========================================================

tiobench
--------

  Like hydra, sequential reads were generally better for low numbers of
  clients. 3.4 is notable in that it regressed and 3.1 was also bad which
  is roughly similar to what was seen on ext3. There are differences in
  the memory sizes and therefore the filesize and it implies that there
  is not a single cause of the regression.

  Random read has generally improved except with the obvious exception of
  the single-threaded case.

  Sequential writes have generally improved but it is interesting to note
  that 3.4 is worse than 3.3 and this was also seen for ext3.

  Random write is a mixed bad but again 3.4 is worse than 3.3.

  Like the other machines, 3.1 and 3.2 saw unexpected swapping.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
