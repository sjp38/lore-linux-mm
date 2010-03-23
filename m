Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id BD48F6B01C5
	for <linux-mm@kvack.org>; Tue, 23 Mar 2010 14:16:05 -0400 (EDT)
Date: Tue, 23 Mar 2010 18:15:40 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 07/11] Memory compaction core
Message-ID: <20100323181540.GD5870@csn.ul.ie>
References: <1269347146-7461-1-git-send-email-mel@csn.ul.ie> <1269347146-7461-8-git-send-email-mel@csn.ul.ie> <alpine.DEB.2.00.1003231253180.10178@router.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1003231253180.10178@router.home>
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, David Rientjes <rientjes@google.com>, Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Mar 23, 2010 at 12:56:30PM -0500, Christoph Lameter wrote:
> On Tue, 23 Mar 2010, Mel Gorman wrote:
> 
> > diff --git a/include/linux/swap.h b/include/linux/swap.h
> > index 1f59d93..cf8bba7 100644
> > --- a/include/linux/swap.h
> > +++ b/include/linux/swap.h
> > @@ -238,6 +239,11 @@ static inline void lru_cache_add_active_file(struct page *page)
> >  	__lru_cache_add(page, LRU_ACTIVE_FILE);
> >  }
> >
> > +/* LRU Isolation modes. */
> > +#define ISOLATE_INACTIVE 0	/* Isolate inactive pages. */
> > +#define ISOLATE_ACTIVE 1	/* Isolate active pages. */
> > +#define ISOLATE_BOTH 2		/* Isolate both active and inactive pages. */
> > +
> >  /* linux/mm/vmscan.c */
> >  extern unsigned long try_to_free_pages(struct zonelist *zonelist, int order,
> >  					gfp_t gfp_mask, nodemask_t *mask);
> > diff --git a/mm/vmscan.c b/mm/vmscan.c
> > index 79c8098..ef89600 100644
> > --- a/mm/vmscan.c
> > +++ b/mm/vmscan.c
> > @@ -839,11 +839,6 @@ keep:
> >  	return nr_reclaimed;
> >  }
> >
> > -/* LRU Isolation modes. */
> > -#define ISOLATE_INACTIVE 0	/* Isolate inactive pages. */
> > -#define ISOLATE_ACTIVE 1	/* Isolate active pages. */
> > -#define ISOLATE_BOTH 2		/* Isolate both active and inactive pages. */
> > -
> >  /*
> >   * Attempt to remove the specified page from its LRU.  Only take this page
> >   * if it is of the appropriate PageActive status.  Pages which are being
> 
> Put the above in a separate patch?
> 

I can if you prefer but it's so small, I didn't think it obscured the
clarity of the patch anyway. I would have somewhat expected the two
patches to be merged together before going upstream.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
