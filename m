Date: Wed, 28 Jul 2004 00:03:40 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [PATCH] Move cache_reap out of timer context
Message-Id: <20040728000340.7f95060f.akpm@osdl.org>
In-Reply-To: <20040714180942.GA18425@sgi.com>
References: <20040714180942.GA18425@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dimitri Sivanich <sivanich@sgi.com>
Cc: manfred@colorfullife.com, mingo@elte.hu, linux-kernel@vger.kernel.org, linux-mm@kvack.org, lse-tech@lists.sourceforge.net
List-ID: <linux-mm.kvack.org>

Dimitri Sivanich <sivanich@sgi.com> wrote:
>
> I'm submitting two patches associated with moving cache_reap functionality
>  out of timer context.  Note that these patches do not make any further
>  optimizations to cache_reap at this time.
> 
>  The first patch adds a function similiar to schedule_delayed_work to
>  allow work to be scheduled on another cpu.
> 
>  The second patch makes use of schedule_delayed_work_on to schedule
>  cache_reap to run from keventd.

It goes splat in cache_reap() if slab debugging is enabled, for rather
obvious reasons:

#if DEBUG
	BUG_ON(!in_interrupt());
	BUG_ON(in_irq());
#endif

I've so far spent nearly two days just getting all the gunk people have
sent in the last two weeks to compile properly.  Heaven knows how long
it'll take to test it.  So I need somebody to grump at.  So.  Grump.

May I have the temerity to suggest that it would be more efficient if
people were to test their own patches a bit more before sending them?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
