Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 12A996B01C9
	for <linux-mm@kvack.org>; Tue, 23 Mar 2010 14:32:48 -0400 (EDT)
Date: Tue, 23 Mar 2010 18:32:28 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 08/11] Add /proc trigger for memory compaction
Message-ID: <20100323183228.GE5870@csn.ul.ie>
References: <1269347146-7461-1-git-send-email-mel@csn.ul.ie> <1269347146-7461-9-git-send-email-mel@csn.ul.ie> <alpine.DEB.2.00.1003231323410.10178@router.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1003231323410.10178@router.home>
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, David Rientjes <rientjes@google.com>, Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Mar 23, 2010 at 01:25:47PM -0500, Christoph Lameter wrote:
> On Tue, 23 Mar 2010, Mel Gorman wrote:
> 
> > diff --git a/mm/compaction.c b/mm/compaction.c
> > index 0d2e8aa..faa9b53 100644
> > --- a/mm/compaction.c
> > +++ b/mm/compaction.c
> > @@ -346,3 +347,63 @@ static int compact_zone(struct zone *zone, struct compact_control *cc)
> >  	return ret;
> >  }
> >
> > +/* Compact all zones within a node */
> > +static int compact_node(int nid)
> > +{
> > +	int zoneid;
> > +	pg_data_t *pgdat;
> > +	struct zone *zone;
> > +
> > +	if (nid < 0 || nid > nr_node_ids || !node_online(nid))
> 
> Must be nid >= nr_node_ids.
> 

Oops, correct. It should be "impossible" to supply an incorrect nid here
but still.

> Otherwise
> 
> Reviewed-by: Christoph Lameter <cl@linux-foundation.org>
> 

Thanks

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
