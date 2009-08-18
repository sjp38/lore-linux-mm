Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 0C4A46B004D
	for <linux-mm@kvack.org>; Tue, 18 Aug 2009 16:50:44 -0400 (EDT)
Date: Tue, 18 Aug 2009 21:50:50 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 3/3] page-allocator: Move pcp static fields for high
	and batch off-pcp and onto the zone
Message-ID: <20090818205050.GA756@csn.ul.ie>
References: <1250594162-17322-1-git-send-email-mel@csn.ul.ie> <1250594162-17322-4-git-send-email-mel@csn.ul.ie> <alpine.DEB.1.10.0908181015420.32284@gentwo.org> <20090818164216.GA13435@csn.ul.ie> <alpine.DEB.1.10.0908181355490.3840@gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <alpine.DEB.1.10.0908181355490.3840@gentwo.org>
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Nick Piggin <npiggin@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Tue, Aug 18, 2009 at 01:56:22PM -0400, Christoph Lameter wrote:
> On Tue, 18 Aug 2009, Mel Gorman wrote:
> 
> > On Tue, Aug 18, 2009 at 10:18:48AM -0400, Christoph Lameter wrote:
> > >
> > > This will increase the cache footprint for the hot code path. Could these
> > > new variable be moved next to zone fields that are already in use there?
> > > The pageset array is used f.e.
> > >
> >
> > pageset is ____cacheline_aligned_in_smp so putting pcp->high/batch near
> > it won't help in terms of cache footprint. This is why I located it near
> > watermarks because it's known they'll be needed at roughly the same time
> > pcp->high/batch would be normally accessed.
> 
> watermarks are not accessed from the hot code path in free_hot_cold page.
> 

They are used in a commonly-used path for allocation so there is some
advantage. Put beside pageset, there is no advantage as that structure
is already aligned to a cache-line.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
