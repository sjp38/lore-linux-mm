Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id CB9558D0017
	for <linux-mm@kvack.org>; Mon, 15 Nov 2010 04:27:11 -0500 (EST)
Date: Mon, 15 Nov 2010 09:26:55 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 2/3] mm,compaction: Add COMPACTION_BUILD
Message-ID: <20101115092655.GG27362@csn.ul.ie>
References: <1289502424-12661-1-git-send-email-mel@csn.ul.ie> <1289502424-12661-3-git-send-email-mel@csn.ul.ie> <20101114144413.E022.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20101114144413.E022.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Sun, Nov 14, 2010 at 02:45:07PM +0900, KOSAKI Motohiro wrote:
> > To avoid #ifdef COMPACTION in a following patch, this patch adds
> > COMPACTION_BUILD that is similar to NUMA_BUILD in operation.
> > 
> > Signed-off-by: Mel Gorman <mel@csn.ul.ie>
> > ---
> >  include/linux/kernel.h |    7 +++++++
> >  1 files changed, 7 insertions(+), 0 deletions(-)
> > 
> > diff --git a/include/linux/kernel.h b/include/linux/kernel.h
> > index 450092c..c00c5d1 100644
> > --- a/include/linux/kernel.h
> > +++ b/include/linux/kernel.h
> > @@ -826,6 +826,13 @@ struct sysinfo {
> >  #define NUMA_BUILD 0
> >  #endif
> >  
> > +/* This helps us avoid #ifdef CONFIG_COMPACTION */
> > +#ifdef CONFIG_COMPACTION
> > +#define COMPACTION_BUILD 1
> > +#else
> > +#define COMPACTION_BUILD 0
> > +#endif
> > +
> 
> Looks good, of cource. but I think this patch can be fold [3/3] beucase 
> it doesn't have any change.
> 

Ok, I can do that.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
