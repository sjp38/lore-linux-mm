Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx160.postini.com [74.125.245.160])
	by kanga.kvack.org (Postfix) with SMTP id AA4E36B0068
	for <linux-mm@kvack.org>; Tue, 19 Jun 2012 12:26:53 -0400 (EDT)
Date: Tue, 19 Jun 2012 17:26:43 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH] cma: cached pageblock type fixup
Message-ID: <20120619162643.GC8810@suse.de>
References: <201205230922.00530.b.zolnierkie@samsung.com>
 <201206191328.50781.b.zolnierkie@samsung.com>
 <20120619120044.GA8810@suse.de>
 <201206191504.59994.b.zolnierkie@samsung.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <201206191504.59994.b.zolnierkie@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
Cc: linux-mm@kvack.org, Michal Nazarewicz <mina86@mina86.com>, Marek Szyprowski <m.szyprowski@samsung.com>

On Tue, Jun 19, 2012 at 03:04:59PM +0200, Bartlomiej Zolnierkiewicz wrote:
> > If the page is on the wrong free list, just isolate it or move it to the
> > MIGRATE_ISOLATE free list at that point. If it has been allocated then
> > migrate it and move the resulting free page to the MIGRATE_ISOLATE list.
> 
> Thanks, this makes sense but still leaves us with some page allocation vs
> alloc_contig_range() races (i.e. pages "in-flight" state being added/removed
> to/from pcp lists so not being on the freelists and not being allocated).
> 

The races should not be forever or open-ended. Once the pageblock is
marked ISOLATE it should only take one pass to either move it from
MIGRATE_CMA to MIGRATE_ISOLATE free lists or to migrate the page and
free it to the MIGRATE_ISOLATE.

I would be very surprised if this cannot be properly handled in
alloc_contig_range() in a manner that does not wreck the page allocator
fast paths.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
