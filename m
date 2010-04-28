Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 4AA416B01F6
	for <linux-mm@kvack.org>; Wed, 28 Apr 2010 05:17:40 -0400 (EDT)
Date: Wed, 28 Apr 2010 10:17:18 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 0/3] Fix migration races in rmap_walk() V2
Message-ID: <20100428091718.GC15815@csn.ul.ie>
References: <1272403852-10479-1-git-send-email-mel@csn.ul.ie> <alpine.DEB.2.00.1004271723090.24133@router.home> <20100427223242.GG8860@random.random>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20100427223242.GG8860@random.random>
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Christoph Lameter <cl@linux.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Wed, Apr 28, 2010 at 12:32:42AM +0200, Andrea Arcangeli wrote:
> On Tue, Apr 27, 2010 at 05:27:36PM -0500, Christoph Lameter wrote:
> > Can we simply wait like in the fault path?
> 
> There is no bug there, no need to wait either. I already audited it
> before, and I didn't see any bug. Unless you can show a bug with CPU A
> running the rmap_walk on process1 before process2, there is no bug to
> fix there.
> 

Yes, this patch is now dropped.

> > 
> > > Patch 3 notes that while a VMA is moved under the anon_vma lock, the page
> > > 	tables are not similarly protected. Where migration PTEs are
> > > 	encountered, they are cleaned up.
> > 
> > This means they are copied / moved etc and "cleaned" up in a state when
> > the page was unlocked. Migration entries are not supposed to exist when
> > a page is not locked.
> 
> patch 3 is real, and the first thought I had was to lock down the page
> before running vma_adjust and unlock after move_page_tables. But these
> are virtual addresses. Maybe there's a simpler way to keep migration
> away while we run those two operations.
> 

I see there is a large discussion on that patch so I'll read that rather
than commenting here.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
