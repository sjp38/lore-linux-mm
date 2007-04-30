Date: Mon, 30 Apr 2007 13:14:24 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 4/4] Add __GFP_TEMPORARY to identify allocations that
 are short-lived
In-Reply-To: <20070430201147.GB8205@skynet.ie>
Message-ID: <Pine.LNX.4.64.0704301312470.8679@schroedinger.engr.sgi.com>
References: <20070430185524.7142.56162.sendpatchset@skynet.skynet.ie>
 <20070430185644.7142.89206.sendpatchset@skynet.skynet.ie>
 <Pine.LNX.4.64.0704301202490.7258@schroedinger.engr.sgi.com>
 <20070430194427.GA8205@skynet.ie> <Pine.LNX.4.64.0704301250580.8361@schroedinger.engr.sgi.com>
 <20070430201147.GB8205@skynet.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@skynet.ie>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 30 Apr 2007, Mel Gorman wrote:

> > > >>  #ifdef CONFIG_JBD_DEBUG
> > > >>  	atomic_inc(&nr_journal_heads);
> > > >>  #endif
> > > >> -	ret = kmem_cache_alloc(journal_head_cache,
> > > >> -			set_migrateflags(GFP_NOFS, __GFP_RECLAIMABLE));
> > > >> +	ret = kmem_cache_alloc(journal_head_cache, GFP_NOFS);
> > > >>  	if (ret == 0) {
> > > >
> > > > This chunk belongs into the earlier patch.
> > > >
> > > 
> > > Why? kmem_cache_create() is changed here in this patch to use SLAB_TEMPORARY 
> > > which is not defined until this patch.
> > 
> > I do not see a SLAB_TEMPORARY here.
> 
> Here are the relevant portions of the fourth patch.

Ahh. Ok.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
