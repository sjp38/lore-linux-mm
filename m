Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id D16036B0055
	for <linux-mm@kvack.org>; Wed, 19 Aug 2009 04:57:06 -0400 (EDT)
Date: Wed, 19 Aug 2009 09:57:14 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 1/3] page-allocator: Split per-cpu list into
	one-list-per-migrate-type
Message-ID: <20090819085714.GA24809@csn.ul.ie>
References: <1250594162-17322-1-git-send-email-mel@csn.ul.ie> <1250594162-17322-2-git-send-email-mel@csn.ul.ie> <alpine.DEB.1.00.0908181550450.31547@mail.selltech.ca>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <alpine.DEB.1.00.0908181550450.31547@mail.selltech.ca>
Sender: owner-linux-mm@kvack.org
To: Vincent Li <macli@brc.ubc.ca>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Christoph Lameter <cl@linux-foundation.org>, Nick Piggin <npiggin@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Tue, Aug 18, 2009 at 03:57:00PM -0700, Vincent Li wrote:
> On Tue, 18 Aug 2009, Mel Gorman wrote:
> 
> > +	/*
> > +	 * We only track unreclaimable, reclaimable and movable on pcp lists.
> 			 ^^^^^^^^^^^^^  
> Is it unmovable? I don't see unreclaimable migrate type on pcp lists. 
> Just ask to make sure I undsterstand the comment right.
> 

It should have said unmovable. Sorry

> > +	 * Free ISOLATE pages back to the allocator because they are being
> > +	 * offlined but treat RESERVE as movable pages so we can get those
> > +	 * areas back if necessary. Otherwise, we may have to free
> > +	 * excessively into the page allocator
> > +	 */
> > +	if (migratetype >= MIGRATE_PCPTYPES) {
> > +		if (unlikely(migratetype == MIGRATE_ISOLATE)) {
> > +			free_one_page(zone, page, 0, migratetype);
> > +			goto out;
> > +		}
> > +		migratetype = MIGRATE_MOVABLE;
> > +	}
> > +
> 
> Vincent Li
> Biomedical Research Center
> University of British Columbia
> 

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
