Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id AA1D66B0033
	for <linux-mm@kvack.org>; Sun, 22 Jan 2017 22:11:28 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id d134so186975225pfd.0
        for <linux-mm@kvack.org>; Sun, 22 Jan 2017 19:11:28 -0800 (PST)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id f81si14262186pfa.44.2017.01.22.19.11.27
        for <linux-mm@kvack.org>;
        Sun, 22 Jan 2017 19:11:27 -0800 (PST)
Date: Mon, 23 Jan 2017 12:17:48 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [RFC PATCH 1/5] mm/vmstat: retrieve suitable free pageblock
 information just once
Message-ID: <20170123031747.GC24581@js1304-P5Q-DELUXE>
References: <1484291673-2239-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1484291673-2239-2-git-send-email-iamjoonsoo.kim@lge.com>
 <123434e3-1d63-6ba7-1bdb-7bb66b4619a6@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <123434e3-1d63-6ba7-1bdb-7bb66b4619a6@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>

On Thu, Jan 19, 2017 at 11:47:09AM +0100, Vlastimil Babka wrote:
> On 01/13/2017 08:14 AM, js1304@gmail.com wrote:
> > From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> > 
> > It's inefficient to retrieve buddy information for fragmentation index
> > calculation on every order. By using some stack memory, we could retrieve
> > it once and reuse it to compute all the required values. MAX_ORDER is
> > usually small enough so there is no big risk about stack overflow.
> > 
> > Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> 
> Sounds useful regardless of the rest of the series.
> 
> Acked-by: Vlastimil Babka <vbabka@suse.cz>

Thanks! I will submit this patch separately.

> 
> A nit below.
> 
> > ---
> >  mm/vmstat.c | 25 ++++++++++++-------------
> >  1 file changed, 12 insertions(+), 13 deletions(-)
> > 
> > diff --git a/mm/vmstat.c b/mm/vmstat.c
> > index 7c28df3..e1ca5eb 100644
> > --- a/mm/vmstat.c
> > +++ b/mm/vmstat.c
> > @@ -821,7 +821,7 @@ unsigned long node_page_state(struct pglist_data *pgdat,
> >  struct contig_page_info {
> >  	unsigned long free_pages;
> >  	unsigned long free_blocks_total;
> > -	unsigned long free_blocks_suitable;
> > +	unsigned long free_blocks_order[MAX_ORDER];
> 
> No need to rename _suitable to _order IMHO. The meaning is still the
> same, it's just an array now. For me a name "free_blocks_order" would
> suggest it's just simple zone->free_area[order].nr_free.

Okay. Will fix.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
