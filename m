Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id EE44C8D0017
	for <linux-mm@kvack.org>; Mon, 15 Nov 2010 04:17:34 -0500 (EST)
Date: Mon, 15 Nov 2010 09:17:19 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 3/3] mm,vmscan: Reclaim order-0 and compact instead of
	lumpy reclaim when under light pressure
Message-ID: <20101115091719.GD27362@csn.ul.ie>
References: <1289502424-12661-4-git-send-email-mel@csn.ul.ie> <20101112093742.GA3537@csn.ul.ie> <20101114144155.E01F.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20101114144155.E01F.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Sun, Nov 14, 2010 at 02:43:12PM +0900, KOSAKI Motohiro wrote:
> > On Thu, Nov 11, 2010 at 07:07:04PM +0000, Mel Gorman wrote:
> > > +	if (COMPACTION_BUILD)
> > > +		sc->lumpy_reclaim_mode = LUMPY_MODE_COMPACTION;
> > > +	else
> > > +		sc->lumpy_reclaim_mode = LUMPY_MODE_CONTIGRECLAIM;
> > >  
> > 
> > Gack, I posted the slightly wrong version. This version prevents lumpy
> > reclaim ever being used. The figures I posted were for a patch where
> > this condition looked like
> > 
> >         if (COMPACTION_BUILD && priority > DEF_PRIORITY - 2)
> >                 sc->lumpy_reclaim_mode = LUMPY_MODE_COMPACTION;
> >         else
> >                 sc->lumpy_reclaim_mode = LUMPY_MODE_CONTIGRECLAIM;
> 
> In all other place, heavy reclaim detection are used folliowing.
> 
> 	if (priority < DEF_PRIORITY - 2)
> 
> 
> So, "priority >= DEF_PRIORITY - 2" is more symmetric, I think. but if you have strong
> reason, I don't oppse.
> 

I had no strong reason other than "I don't want lumpy reclaim to be used
easily". I will match the other places. Thanks

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
