Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id C00966B0047
	for <linux-mm@kvack.org>; Mon, 16 Mar 2009 07:46:49 -0400 (EDT)
Date: Mon, 16 Mar 2009 12:46:44 +0100
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [PATCH 20/35] Use a pre-calculated value for num_online_nodes()
Message-ID: <20090316114644.GC30802@wotan.suse.de>
References: <1237196790-7268-1-git-send-email-mel@csn.ul.ie> <1237196790-7268-21-git-send-email-mel@csn.ul.ie> <200903162242.35341.nickpiggin@yahoo.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <200903162242.35341.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Mel Gorman <mel@csn.ul.ie>, Linux Memory Management List <linux-mm@kvack.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lin Ming <ming.m.lin@intel.com>, Zhang Yanmin <yanmin_zhang@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>
List-ID: <linux-mm.kvack.org>

On Mon, Mar 16, 2009 at 10:42:34PM +1100, Nick Piggin wrote:
> On Monday 16 March 2009 20:46:15 Mel Gorman wrote:
> > num_online_nodes() is called by the page allocator to decide whether the
> > zonelist needs to be filtered based on cpusets or the zonelist cache.
> > This is actually a heavy function and touches a number of cache lines.
> > This patch stores the number of online nodes at boot time and when
> > nodes get onlined and offlined.
> >
> > Signed-off-by: Mel Gorman <mel@csn.ul.ie>
> > ---
> >  include/linux/nodemask.h |   16 ++++++++++++++--
> >  mm/page_alloc.c          |    6 ++++--
> >  2 files changed, 18 insertions(+), 4 deletions(-)
> >
> > diff --git a/include/linux/nodemask.h b/include/linux/nodemask.h
> > index 848025c..4749e30 100644
> > --- a/include/linux/nodemask.h
> > +++ b/include/linux/nodemask.h
> > @@ -449,13 +449,25 @@ static inline int num_node_state(enum node_states
> > state) node;					\
> >  })
> >
> > +/* Recorded value for num_online_nodes() */
> > +extern int static_num_online_nodes;
> 
> __read_mostly, please. Check this for any other place you've added
> global cachelines that are referenced by the allocator.

OK I'm blind, sorry ignore that :P

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
