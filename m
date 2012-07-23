Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx159.postini.com [74.125.245.159])
	by kanga.kvack.org (Postfix) with SMTP id AFBD36B005D
	for <linux-mm@kvack.org>; Mon, 23 Jul 2012 17:23:31 -0400 (EDT)
Date: Mon, 23 Jul 2012 22:23:27 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: [MMTests] dbench4 async on ext4
Message-ID: <20120723212327.GH9222@suse.de>
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

Configuration:	global-dhp__io-dbench4-async-ext4
Result: 	http://www.csn.ul.ie/~mel/postings/mmtests-20120424/global-dhp__io-dbench4-async-ext4
Benchmarks:	dbench4

Summary
=======

Nothing majorly exciting although throughput has been declining
slightly in a number of cases. However, this is not consistent
between machines and latency has also been variable. Broadly
speaking, there is not need to take any action here.

Benchmark notes
===============

mkfs was run on system startup. No attempt was made to age it. No
special mkfs or mount options were used.

dbench 4 was used. Tests ran for 180 seconds once warmed up. A varying
number of clients were used up to 64*NR_CPU. osync, sync-directory and
fsync were all off.

===========================================================
Machine:	arnold
Result:		http://www.csn.ul.ie/~mel/postings/mmtests-20120424/global-dhp__io-dbench4-async-ext4/arnold/comparison.html
Arch:		x86
CPUs:		1 socket, 2 threads
Model:		Pentium 4
Disk:		Single Rotary Disk
===========================================================

dbench4
-------

  In very vague terms, throughput has been getting worse over time but
  it's very gradual. Latency has also been getting worse.

==========================================================
Machine:	hydra
Result:		http://www.csn.ul.ie/~mel/postings/mmtests-20120424/global-dhp__io-dbench4-async-ext4/hydra/comparison.html
Arch:		x86-64
CPUs:		1 socket, 4 threads
Model:		AMD Phenom II X4 940
Disk:		Single Rotary Disk
Status:		Ok
==========================================================

dbench4
-------

  This is a mixed bag, there are gains and losses and it's hard to draw
  any meaningful conclusion.

==========================================================
Machine:	sandy
Result:		http://www.csn.ul.ie/~mel/postings/mmtests-20120424/global-dhp__io-dbench4-async-ext4/sandy/comparison.html
Arch:		x86-64
CPUs:		1 socket, 8 threads
Model:		Intel Core i7-2600
Disk:		Single Rotary Disk
Status:		
==========================================================

dbench4
-------

  For the most part, there are few changes of note. Latency has
  been getting better particularly in 3.2 and later kernels.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
