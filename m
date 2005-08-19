Date: Thu, 18 Aug 2005 21:49:24 -0700 (PDT)
From: Linus Torvalds <torvalds@osdl.org>
Subject: Re: [RFC] Concept for delayed counter updates in mm_struct
In-Reply-To: <20050818212939.7dca44c3.akpm@osdl.org>
Message-ID: <Pine.LNX.4.58.0508182141250.3412@g5.osdl.org>
References: <20050817151723.48c948c7.akpm@osdl.org> <20050817174359.0efc7a6a.akpm@osdl.org>
 <Pine.LNX.4.61.0508182116110.11409@goblin.wat.veritas.com>
 <Pine.LNX.4.62.0508182052120.10236@schroedinger.engr.sgi.com>
 <20050818212939.7dca44c3.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Christoph Lameter <clameter@engr.sgi.com>, hugh@veritas.com, nickpiggin@yahoo.com.au, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


On Thu, 18 Aug 2005, Andrew Morton wrote:
> Christoph Lameter <clameter@engr.sgi.com> wrote:
>
> > What is missing in this patch are points were mm_counter_catchup can be called.
> > These points must be code where the page table lock is held. One way of providing
> > these would be to call mm_counter_catchup when a task is in the scheduler.
> > 
> 
> That sounds sane.

But that patch doesn't work.

There's no locking around the scheduler. It's all per-CPU, and the only 
exclusivity is in the per-rq locking.

So if you gather the mm counters in the scheduler, you'd need to do it all 
with atomic ops. But you're still using the non-atomic add_mm_counter..

So you need to make those mm counters really atomic now. 

		Linus
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
