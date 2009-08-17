Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 85FAB6B004D
	for <linux-mm@kvack.org>; Mon, 17 Aug 2009 17:35:20 -0400 (EDT)
Date: Mon, 17 Aug 2009 14:34:47 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mv clear node_load[] to __build_all_zonelists()
Message-Id: <20090817143447.b1ecf5c6.akpm@linux-foundation.org>
In-Reply-To: <20090806195037.06e768f5.kamezawa.hiroyu@jp.fujitsu.com>
References: <COL115-W869FC30815A7D5B7A63339F0A0@phx.gbl>
	<20090806195037.06e768f5.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: bo-liu@hotmail.com, linux-mm@kvack.org, mel@csn.ul.ie, cl@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Thu, 6 Aug 2009 19:50:37 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> On Thu, 6 Aug 2009 18:44:40 +0800
> Bo Liu <bo-liu@hotmail.com> wrote:
> 
> > 
> >  If node_load[] is cleared everytime build_zonelists() is called,node_load[]
> >  will have no help to find the next node that should appear in the given node's
> >  fallback list.
> >  Signed-off-by: Bob Liu 
> 
> nice catch. (my old bug...sorry
> 
> Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
> BTW, do you have special reasons to hide your mail address in commit log ?
> 
> I added proper CC: list.
> Hmm, I think it's necessary to do total review/rewrite this function again..
> 
> 
> > ---
> >  mm/page_alloc.c |    2 +-
> >  1 files changed, 1 insertions(+), 1 deletions(-)
> >  
> > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> > index d052abb..72f7345 100644
> > --- a/mm/page_alloc.c
> > +++ b/mm/page_alloc.c
> > @@ -2544,7 +2544,6 @@ static void build_zonelists(pg_data_t *pgdat)
> >  	prev_node = local_node;
> >  	nodes_clear(used_mask);
> >  
> > -	memset(node_load, 0, sizeof(node_load));
> >  	memset(node_order, 0, sizeof(node_order));
> >  	j = 0;
> >  
> > @@ -2653,6 +2652,7 @@ static int __build_all_zonelists(void *dummy)
> >  {
> >  	int nid;
> >  
> > +	memset(node_load, 0, sizeof(node_load));
> >  	for_each_online_node(nid) {
> >  		pg_data_t *pgdat = NODE_DATA(nid);

What are the consequences of this bug?

Is the fix needed in 2.6.31?  Earlier?

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
