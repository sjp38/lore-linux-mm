Message-ID: <42025DCF.2080004@sgi.com>
Date: Thu, 03 Feb 2005 11:22:23 -0600
From: Ray Bryant <raybry@sgi.com>
MIME-Version: 1.0
Subject: lru_add_drain query
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm <linux-mm@kvack.org>
Cc: Nick Piggin <piggin@cyberone.com.au>
List-ID: <linux-mm.kvack.org>

The deferred lru_add operations (e. g. lru_cache_add_active()) defer the
actual addition of a page to the lru list until a batch of such additions
are available.  lru_cache_add_active() uses a per cpu variable 
(lru_add_active_pvecs) to hold the deferred pages.

So, to get the deferred adds to complete (so that the lru list is in a
consistent state and we can scan lru list to do some processing) one calls
lru_add_drain().  But AFAI can tell, this just drains the local cpu's
deferred add queue.  Right?

So, here's my question:  Why is it that I don't need to call lru_add_drain()
on each CPU in the system before I go scan/manipulate the lru list?  (i. e.
what about deferred adds in other CPU's lru_add_active_pvecs?)

What peice of magic am I missing here?

Thanks,

-- 
-----------------------------------------------
Ray Bryant
512-453-9679 (work)         512-507-7807 (cell)
raybry@sgi.com             raybry@austin.rr.com
The box said: "Requires Windows 98 or better",
	 so I installed Linux.
-----------------------------------------------

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
