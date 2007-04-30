Date: Mon, 30 Apr 2007 10:30:01 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: Antifrag patchset comments
In-Reply-To: <Pine.LNX.4.64.0704301016180.32439@skynet.skynet.ie>
Message-ID: <Pine.LNX.4.64.0704301026460.6343@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0704271854480.6208@schroedinger.engr.sgi.com>
 <Pine.LNX.4.64.0704281229040.20054@skynet.skynet.ie>
 <Pine.LNX.4.64.0704281425550.12304@schroedinger.engr.sgi.com>
 <Pine.LNX.4.64.0704301016180.32439@skynet.skynet.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Mon, 30 Apr 2007, Mel Gorman wrote:

> > Indeed that is a good thing.... It would be good if a movable area
> > would be a dynamic split of a zone and not be a separate zone that has to
> > be configured on the kernel command line.
> There are problems with doing that. In particular, the zone can only be sized
> on one direction and can only be sized at the zone boundary because zones do
> not currently overlap and I believe there will be assumptions made about them
> not overlapping within a node. It's worth looking into in the future but I'm
> putting it at the bottom of the TODO list.

Its is better to have a dynamic limit rather than OOMing.
 
> > > If the RECLAIMABLE areas could be properly targeted, it would make sense
> > > to
> > > mark these pages RECLAIMABLE instead but that is not the situation today.
> > What is the problem with targeting?
> It's currently not possible to target effectively.

Could you be more specific?
 
> > > Because they might be ramfs pages which are not movable -
> > > http://lkml.org/lkml/2006/11/24/150
> > 
> > URL does not provide any useful information regarding the issue.
> > 
> 
> Not all pages allocated via shmem_alloc_page() are movable because they may
> pages for ramfs.

Not familiar with ramfs. There would have to be work on ramfs to make them 
movable?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
