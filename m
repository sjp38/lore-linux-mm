Date: Sat, 9 Jun 2007 03:59:44 +0200
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: [PATCH 10 of 16] stop useless vm trashing while we wait the TIF_MEMDIE task to exit
Message-ID: <20070609015944.GL9380@v2.random>
References: <24250f0be1aa26e5c6e3.1181332988@v2.random> <Pine.LNX.4.64.0706081446200.3646@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0706081446200.3646@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Jun 08, 2007 at 02:48:15PM -0700, Christoph Lameter wrote:
> On Fri, 8 Jun 2007, Andrea Arcangeli wrote:
> 
> > There's no point in trying to free memory if we're oom.
> 
> OOMs can occur because we are in a cpuset or have a memory policy that 
> restricts the allocations. So I guess that OOMness is a per node property 
> and not a global one.

I'm sorry to inform you that the oom killing in current mainline has
always been a global event not a per-node one, regardless of the fixes
I just posted.

    	 if (test_tsk_thread_flag(p, TIF_MEMDIE))
	     return ERR_PTR(-1UL);
[..]
		if (PTR_ERR(p) == -1UL)
	   	       goto out;

Best would be for you to send me more changes at the end of the
patchbomb so that for that the first time _ever_, the oom will become
a per-node event and not a global one anymore.

Said that it's not entirely obvious to me, that it makes any sense to
disrupt functionality instead of just running slower but safely (I
would generally prefer printk a warning instead of killing a task if
we've to override the restriction on the memory policy). But that's
your call, I'm fine either ways...

Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
