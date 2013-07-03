Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx194.postini.com [74.125.245.194])
	by kanga.kvack.org (Postfix) with SMTP id 0AEA46B0033
	for <linux-mm@kvack.org>; Wed,  3 Jul 2013 11:28:27 -0400 (EDT)
Date: Wed, 3 Jul 2013 16:28:21 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 6/8] sched: Reschedule task on preferred NUMA node once
 selected
Message-ID: <20130703152821.GG1875@suse.de>
References: <1372257487-9749-1-git-send-email-mgorman@suse.de>
 <1372257487-9749-7-git-send-email-mgorman@suse.de>
 <20130702181522.GC23916@twins.programming.kicks-ass.net>
 <20130703095059.GH23916@twins.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20130703095059.GH23916@twins.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Wed, Jul 03, 2013 at 11:50:59AM +0200, Peter Zijlstra wrote:
> On Tue, Jul 02, 2013 at 08:15:22PM +0200, Peter Zijlstra wrote:
> > 
> > 
> > Something like this should avoid tasks being lumped back onto one node..
> > 
> > Compile tested only, need food.
> 
> OK, this one actually ran on my system and showed no negative effects on
> numa02 -- then again, I didn't have the problem to begin with :/
> 
> Srikar, could you see what your 8-node does with this?
> 
> I'll go dig around to see where I left my SpecJBB.
> 

I reshuffled the v2 series a bit to match your implied preference for layout
and rebased this on top of the end result. May not have the beans to
absorb it before I quit for the evening but I'll at least queue it up
overnight.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
