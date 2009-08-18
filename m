Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 59AD66B004D
	for <linux-mm@kvack.org>; Tue, 18 Aug 2009 08:57:27 -0400 (EDT)
Date: Tue, 18 Aug 2009 13:57:35 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 3/3] page-allocator: Move pcp static fields for high
	and batch off-pcp and onto the zone
Message-ID: <20090818125735.GC31469@csn.ul.ie>
References: <1250594162-17322-1-git-send-email-mel@csn.ul.ie> <1250594162-17322-4-git-send-email-mel@csn.ul.ie> <20090818114752.GP9962@wotan.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20090818114752.GP9962@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Christoph Lameter <cl@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Tue, Aug 18, 2009 at 01:47:52PM +0200, Nick Piggin wrote:
> On Tue, Aug 18, 2009 at 12:16:02PM +0100, Mel Gorman wrote:
> > Having multiple lists per PCPU increased the size of the per-pcpu
> > structure. Two of the fields, high and batch, do not change within a
> > zone making that information redundant. This patch moves those fields
> > off the PCP and onto the zone to reduce the size of the PCPU.
> 
> Hmm.. I did have some patches a long long time ago that among other
> things made the lists larger for the local node only....
> 

To reduce the remote node lists, one could look at applying some fixed factor
to the high value or basing remote lists on some percentage of high.

> But I guess if something like that is ever shown to be a good idea
> then we can go back to the old scheme. So yeah this seems OK.
> 

Thanks.

> > 
> > Signed-off-by: Mel Gorman <mel@csn.ul.ie>
> > ---
> >  include/linux/mmzone.h |    9 +++++----
> >  mm/page_alloc.c        |   47 +++++++++++++++++++++++++----------------------
> >  mm/vmstat.c            |    4 ++--
> >  3 files changed, 32 insertions(+), 28 deletions(-)
> > 
> > <SNIP>

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
