Received: from megami.veritas.com (urd.veritas.com [192.203.47.101])
	by bacchus-int.veritas.com (8.11.0/8.9.1) with SMTP id f0OJsYH11572
	for <linux-mm@kvack.org>; Wed, 24 Jan 2001 11:54:34 -0800 (PST)
Received: from alloc([10.10.192.110]) (1337 bytes) by megami.veritas.com
	via sendmail with P:smtp/R:smart_host/T:smtp
	(sender: <markhe@veritas.com>)
	id <m14LW01-0000Z4C@megami.veritas.com>
	for <linux-mm@kvack.org>; Wed, 24 Jan 2001 11:54:33 -0800 (PST)
	(Smail-3.2.0.101 1997-Dec-17 #4 built 1999-Aug-24)
Received: from localhost (markhe@localhost)
	by alloc (8.9.3/8.8.7) with ESMTP id TAA13426
	for <linux-mm@kvack.org>; Wed, 24 Jan 2001 19:59:09 GMT
Date: Wed, 24 Jan 2001 19:59:09 +0000 (GMT)
From: Mark Hemment <markhe@veritas.com>
Subject: PF_MEMALLOC and direct_reclaim
Message-ID: <Pine.LNX.4.21.0101241945160.26195-100000@alloc>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

  Can anyone tell me the reasons a process marked PF_MEMALLOC isn't
allowed to pull pages directly off the inactive_clean lists?
  I understand the reasons for PF_MEMALLOC, but not this particular
limitation.  I can't find any deadlock suitation with regard to the
"pagecache_lock" and "pagemap_lru_lock" locks taken in reclaim_page(),
nor any possible case of recursion.

  To successfully complete I/O (data or meta-data), kswapd (or rather, the
underlying filesystem running in the context of kswapd or any other
task marked PF_MEMALLOC) may need more memory than is directly available
via the freearea pools, while there are plenty of pages in the 
inactive_clean list.

Thanks,
Mark

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
