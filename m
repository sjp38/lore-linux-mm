Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx192.postini.com [74.125.245.192])
	by kanga.kvack.org (Postfix) with SMTP id CCFE66B005D
	for <linux-mm@kvack.org>; Mon, 23 Jul 2012 17:22:32 -0400 (EDT)
Date: Mon, 23 Jul 2012 22:21:46 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: [MMTests] dbench4 async on ext3
Message-ID: <20120723212146.GG9222@suse.de>
References: <20120620113252.GE4011@suse.de>
 <20120629111932.GA14154@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20120629111932.GA14154@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org

Configuration:	global-dhp__io-dbench4-async-ext3
Result: 	http://www.csn.ul.ie/~mel/postings/mmtests-20120424/global-dhp__io-dbench4-async-ext3
Benchmarks:	dbench4

Summary
=======

In general there was a massive drop in throughput after 3.0. Very broadly
speaking it looks like the Read operation got faster but at the cost of
a big regression in the Flush operation.

Benchmark notes
===============

mkfs was run on system startup. No attempt was made to age it. No
special mkfs or mount options were used.

dbench 4 was used. Tests ran for 180 seconds once warmed up. A varying
number of clients were used up to 64*NR_CPU. osync, sync-directory and
fsync were all off.

===========================================================
Machine:	arnold
Result:		http://www.csn.ul.ie/~mel/postings/mmtests-20120424/global-dhp__io-dbench4-async-ext3/arnold/comparison.html
Arch:		x86
CPUs:		1 socket, 2 threads
Model:		Pentium 4
Disk:		Single Rotary Disk
===========================================================

dbench4
-------

  Generally worse with a big drop in throughput after 3.0 for small number
  of clients. In some cases there is an improvement in latency for 3.0
  and later kernels but not always.

==========================================================
Machine:	hydra
Result:		http://www.csn.ul.ie/~mel/postings/mmtests-20120424/global-dhp__io-dbench4-async-ext3/hydra/comparison.html
Arch:		x86-64
CPUs:		1 socket, 4 threads
Model:		AMD Phenom II X4 940
Disk:		Single Rotary Disk
Status:		Ok
==========================================================

dbench4
-------
  Similar to arnold, big drop in throughput after 3.0 for small numbers
  of clients. Unlike arnold, this is matched by an improvement in latency
  so it may be the case that IO is more fair even if dbench complains
  about the latency. Very very broadly speaking, it looks like the read
  operation got a lot faster but flush got a lot slower.

==========================================================
Machine:	sandy
Result:		http://www.csn.ul.ie/~mel/postings/mmtests-20120424/global-dhp__io-dbench4-async-ext3/sandy/comparison.html
Arch:		x86-64
CPUs:		1 socket, 8 threads
Model:		Intel Core i7-2600
Disk:		Single Rotary Disk
Status:		
==========================================================

dbench4
-------
  Same story, big drop in throughput after 3.0 with flush again looking very
  expensive for 3.1 and later kernels. Latency figures are a mixed bag.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
