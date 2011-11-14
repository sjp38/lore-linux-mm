Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id A95FE6B002D
	for <linux-mm@kvack.org>; Mon, 14 Nov 2011 18:44:11 -0500 (EST)
Date: Mon, 14 Nov 2011 15:44:08 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: Do not stall in synchronous compaction for THP
 allocations
Message-Id: <20111114154408.10de1bc7.akpm@linux-foundation.org>
In-Reply-To: <20111111101414.GJ3083@suse.de>
References: <20111110100616.GD3083@suse.de>
	<20111110142202.GE3083@suse.de>
	<CAEwNFnCRCxrru5rBk7FpypqeL8nD=SY5W3-TaA7Ap5o4CgDSbg@mail.gmail.com>
	<20111110161331.GG3083@suse.de>
	<20111110151211.523fa185.akpm@linux-foundation.org>
	<alpine.DEB.2.00.1111101536330.2194@chino.kir.corp.google.com>
	<20111111101414.GJ3083@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: David Rientjes <rientjes@google.com>, Minchan Kim <minchan.kim@gmail.com>, Jan Kara <jack@suse.cz>, Andy Isaacson <adi@hexapodia.org>, Johannes Weiner <jweiner@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, 11 Nov 2011 10:14:14 +0000
Mel Gorman <mgorman@suse.de> wrote:

> On Thu, Nov 10, 2011 at 03:37:32PM -0800, David Rientjes wrote:
> > On Thu, 10 Nov 2011, Andrew Morton wrote:
> > 
> > > > This patch once again prevents sync migration for transparent
> > > > hugepage allocations as it is preferable to fail a THP allocation
> > > > than stall.
> > > 
> > > Who said?  ;) Presumably some people would prefer to get lots of
> > > huge pages for their 1000-hour compute job, and waiting a bit to get
> > > those pages is acceptable.
> > > 
> > 
> > Indeed.  It seems like the behavior would better be controlled with 
> > /sys/kernel/mm/transparent_hugepage/defrag which is set aside specifically 
> > to control defragmentation for transparent hugepages and for that 
> > synchronous compaction should certainly apply.
> 
> With khugepaged in place, it's adding a tunable that is unnecessary and
> will not be used. Even if such a tuneable was created, the default
> behaviour should be "do not stall".

(who said?)

Let me repeat my cruelly unanswered question: do we have sufficient
instrumentation in place so that operators can determine that this
change is causing them to get less huge pages than they'd like?

Because some people really really want those huge pages.  If we go and
silently deprive them of those huge pages via changes like this, how do
they *know* it's happening?

And what are their options for making the kernel try harder to get
those pages?

And how do we communicate all of this to those operators?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
