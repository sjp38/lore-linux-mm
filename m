Message-ID: <3D6E9084.820B2608@zip.com.au>
Date: Thu, 29 Aug 2002 14:22:12 -0700
From: Andrew Morton <akpm@zip.com.au>
MIME-Version: 1.0
Subject: Re: [PATCH] low-latency zap_page_range()
References: <3D6E8B7F.8D5D20D8@zip.com.au> <1030655532.12110.2691.camel@phantasy>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Robert Love <rml@tech9.net>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Robert Love wrote:
> 
> On Thu, 2002-08-29 at 17:00, Andrew Morton wrote:
> 
> > That's an interesting point.  page_table_lock is one of those locks
> > which is occasionally held for ages, and frequently held for a short
> > time.
> 
> Since latency is a direct function of lock held times in the preemptible
> kernel, and I am seeing disgusting zap_page_range() latencies, the lock
> is held a long time.
> 
> So we know it is held forever and a day... but is there contention?

I'm sure there is, but nobody has measured the right workload.

Two CLONE_MM threads, one running mmap()/munmap(), the other trying
to fault in some pages.  I'm sure someone has some vital application
which does exactly this.  They always do :(
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
