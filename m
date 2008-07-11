Date: Fri, 11 Jul 2008 16:13:49 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH][RFC] dirty balancing for cgroups
Message-Id: <20080711161349.c5831081.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080711055926.9AF4F5A03@siro.lan>
References: <20080711141511.515e69a5.kamezawa.hiroyu@jp.fujitsu.com>
	<20080711055926.9AF4F5A03@siro.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: YAMAMOTO Takashi <yamamoto@valinux.co.jp>
Cc: a.p.zijlstra@chello.nl, linux-mm@kvack.org, menage@google.com, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, 11 Jul 2008 14:59:26 +0900 (JST)
yamamoto@valinux.co.jp (YAMAMOTO Takashi) wrote:

> > > >  - This looks simple but, could you merge this into memory resource controller ?
> > > 
> > > why?
> > > 
> > 3 points.
> >  1. Is this useful if used alone ?
> 
> it can be.  why not?
> 
> >  2. memcg requires this kind of feature, basically.
> > 
> >  3. I wonder I need more work to make this work well under memcg.
> 
> i'm not sure if i understand these points.  can you explain a bit?
> 
In my understanding, dirty_ratio is for helping memory (reclaim) subsystem.

See comments in fs/page-writeback.c:: determin_dirtyable_memory()
==
/*
 * Work out the current dirty-memory clamping and background writeout
 * thresholds.
 *
 * The main aim here is to lower them aggressively if there is a lot of mapped
 * memory around.  To avoid stressing page reclaim with lots of unreclaimable
 * pages.  It is better to clamp down on writers than to start swapping, and
 * performing lots of scanning.
 *
 * We only allow 1/2 of the currently-unmapped memory to be dirtied.
 *
 * We don't permit the clamping level to fall below 5% - that is getting rather
 * excessive.
 *
 * We make sure that the background writeout level is below the adjusted
 * clamping level.
==

"To avoid stressing page reclaim with lots of unreclaimable pages"

Then, I think memcg should support this for helping relcaim under memcg.

> my patch penalizes heavy-writer cgroups as task_dirty_limit does
> for heavy-writer tasks.  i don't think that it's necessary to be
> tied to the memory subsystem because i merely want to group writers.
> 
Hmm, maybe what I need is different from this ;)
Does not seem to be a help for memory reclaim under memcg.


Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
