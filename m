Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx175.postini.com [74.125.245.175])
	by kanga.kvack.org (Postfix) with SMTP id 1C8B96B005A
	for <linux-mm@kvack.org>; Mon, 23 Jul 2012 17:14:49 -0400 (EDT)
Date: Mon, 23 Jul 2012 22:14:44 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: [MMTests] Sysbench read-only on ext4
Message-ID: <20120723211444.GB9222@suse.de>
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

Configuration:	global-dhp__io-sysbench-large-ro-ext4
Result: 	http://www.csn.ul.ie/~mel/postings/mmtests-20120424/global-dhp__io-sysbench-large-ro-ext4
Benchmarks:	sysbench

Summary
=======

Looking better in places than ext3 but still of concern.

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
Result:		http://www.csn.ul.ie/~mel/postings/mmtests-20120424/global-dhp__io-sysbench-large-ro-ext4/arnold/comparison.html
Arch:		x86
CPUs:		1 socket, 2 threads
Model:		Pentium 4
Disk:		Single Rotary Disk
===========================================================

sysbench
--------
  Generally regresssed.

  Swapping for kernels 3.1 and 3.2 is very high.

==========================================================
Machine:	hydra
Result:		http://www.csn.ul.ie/~mel/postings/mmtests-20120424/global-dhp__io-sysbench-large-ro-ext4/hydra/comparison.html
Arch:		x86-64
CPUs:		1 socket, 4 threads
Model:		AMD Phenom II X4 940
Disk:		Single Rotary Disk
Status:		Ok
==========================================================

sysbench
--------
  For low number of clients, this has generally improved.

  Swapping in kernel 3.1 was high.

==========================================================
Machine:	sandy
Result:		http://www.csn.ul.ie/~mel/postings/mmtests-20120424/global-dhp__io-sysbench-large-ro-ext4/sandy/comparison.html
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
