Message-ID: <3D479C8D.1DAB44D1@zip.com.au>
Date: Wed, 31 Jul 2002 01:15:09 -0700
From: Andrew Morton <akpm@zip.com.au>
MIME-Version: 1.0
Subject: swapout bandwidth
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Seems poor.  On mem=512M, with 30 megs/sec of swap
bandwidth, a

	memset(malloc(800megs))

takes 21 seconds, and 16 on 2.5.26.

There are big latencies during this too (vmstat freezes for
many seconds).  But I seem to have fixed that in the 
pagemap_lru_lock patches.  Not sure how though ;)
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
