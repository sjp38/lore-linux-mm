Date: Wed, 3 May 2000 18:26:19 +0200 (CEST)
From: Andrea Arcangeli <andrea@suse.de>
Subject: classzone-VM + mapped pages out of lru_cache
Message-ID: <Pine.LNX.4.21.0005031813040.489-100000@alpha.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.rutgers.edu, quintela@fi.udc.es
List-ID: <linux-mm.kvack.org>

This patch will convert the internal pg_data_t design from zone to
classzone to give correctness to the memory balancing and memory
allocation decisions. It also moves the lru_cache inside the pg_data_t for
NUMA.

It also splits the LRU in two parts, one for swap cache and one for the
more interesting cache and last but not the least it keeps mapped pages
without overlapped buffer headers out of the lru so that we don't waste
time in shrink_mmap trying to release mapped pages when we have to shrink
the cache.

	ftp://ftp.*.kernel.org/pub/linux/kernel/people/andrea/kernels/v2.3/2.3.99-pre7-pre3/classzone-18.gz

It gives me smoother swap behaviour since the swap cache hardly pollutes
the lru_cache now.

Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
