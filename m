From: Dimitri Sivanich <sivanich@sgi.com>
Message-Id: <200406182144.i5ILiIFG001492@fsgi142.americas.sgi.com>
Subject: Re: [PATCH]: Option to run cache reap in thread mode
Date: Fri, 18 Jun 2004 16:44:18 -0500 (CDT)
In-Reply-To: <40D358C5.9060003@colorfullife.com> from "Manfred Spraul" at Jun 18, 2004 11:04:05 PM
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Manfred Spraul <manfred@colorfullife.com>
Cc: Andrew Morton <akpm@osdl.org>, Dimitri Sivanich <sivanich@sgi.com>, linux-kernel@vger.kernel.org, lse-tech@lists.sourceforge.net, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> 
> I'll write something:
> - allow to disable the DMA kmalloc caches for archs that do not need them.
> - increase the timer frequency and scan only a few caches in each timer.
> - perhaps a quicker test for cache_reap to notice that nothing needs to 
> be done. Right now four tests are done (!flags & _NO_REAP, 
> ac->touched==0, ac->avail != 0, global timer not yet expired). It's 
> possible to skip some tests. e.g. move the _NO_REAP caches on a separate 
> list, replace the time_after(.next_reap,jiffies) with a separate timer.
> 
> --
>     Manfred
>
Thanks for addressing this.  Sounds like some good improvements overall.

One question though:  What about possible spinlock contention issues in the
cache_reap timer processing, or is that unlikely here (even on a heavily loaded
system with a large number of CPUs)?

Dimitri Sivanich <sivanich@sgi.com>
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
