Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx191.postini.com [74.125.245.191])
	by kanga.kvack.org (Postfix) with SMTP id 799E66B002B
	for <linux-mm@kvack.org>; Mon, 24 Sep 2012 17:30:14 -0400 (EDT)
Date: Mon, 24 Sep 2012 14:30:12 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v4 4/4] cma: fix watermark checking
Message-Id: <20120924143012.f72ad2bc.akpm@linux-foundation.org>
In-Reply-To: <201209241130.43480.b.zolnierkie@samsung.com>
References: <1347632974-20465-1-git-send-email-b.zolnierkie@samsung.com>
	<1347632974-20465-5-git-send-email-b.zolnierkie@samsung.com>
	<20120919125102.4a45e27c.akpm@linux-foundation.org>
	<201209241130.43480.b.zolnierkie@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
Cc: linux-mm@kvack.org, m.szyprowski@samsung.com, mina86@mina86.com, minchan@kernel.org, mgorman@suse.de, hughd@google.com, kyungmin.park@samsung.com

On Mon, 24 Sep 2012 11:30:43 +0200
Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com> wrote:

> On Wednesday 19 September 2012 21:51:02 Andrew Morton wrote:
> > >  
> > >  	/*
> > >  	 * Check whether it is worth even starting compaction. The order check is
> > > @@ -879,6 +880,10 @@ unsigned long try_to_compact_pages(struct zonelist *zonelist,
> > >  
> > >  	count_vm_event(COMPACTSTALL);
> > >  
> > > +#ifdef CONFIG_CMA
> > > +	if (allocflags_to_migratetype(gfp_mask) == MIGRATE_MOVABLE)
> > > +		alloc_flags |= ALLOC_CMA;
> > 
> > I find this rather obscure.  What is the significance of
> > MIGRATE_MOVABLE here?  If it had been 
> > 
> > :	if (allocflags_to_migratetype(gfp_mask) == MIGRATE_CMA)
> > :		alloc_flags |= ALLOC_CMA;
> > 
> > then I'd have read straight past it.  But it's unclear what's happening
> > here.  If we didn't have to resort to telepathy to understand the
> > meaning of ALLOC_CMA, this wouldn't be so hard.

This?

Or am I being more than usually thick?  Is everyone else finding

	if (allocflags_to_migratetype(gfp_mask) == MIGRATE_MOVABLE)
		alloc_flags |= ALLOC_CMA;

to be blindingly obvious?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
