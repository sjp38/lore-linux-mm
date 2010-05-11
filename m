Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id A82016B0201
	for <linux-mm@kvack.org>; Tue, 11 May 2010 12:15:36 -0400 (EDT)
Date: Tue, 11 May 2010 17:15:16 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 2/2] mm,migration: Avoid race between shift_arg_pages()
	and rmap_walk() during migration by not migrating temporary stacks
Message-ID: <20100511161516.GU26611@csn.ul.ie>
References: <1272529930-29505-1-git-send-email-mel@csn.ul.ie> <1272529930-29505-3-git-send-email-mel@csn.ul.ie> <alpine.DEB.2.00.1005012055010.2663@router.home> <20100504094522.GA20979@csn.ul.ie> <alpine.DEB.2.00.1005101239400.13652@router.home> <20100510175654.GL26611@csn.ul.ie> <alpine.DEB.2.00.1005110857350.1500@router.home> <20100511151142.GS26611@csn.ul.ie> <alpine.DEB.2.00.1005111055070.1500@router.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1005111055070.1500@router.home>
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

On Tue, May 11, 2010 at 10:56:00AM -0500, Christoph Lameter wrote:
> On Tue, 11 May 2010, Mel Gorman wrote:
> 
> > Or just identify the temporary stack from the migration side instead of
> > adding to the cost of exec?
> 
> Adding one off checks to a generic mechanism isnt really clean
> programming. Using the provided means of disabling a generic mechanism is.
> 

Andrea's solution is likely lighter than yours as it is one kmalloc and
an insertion into the VM as opposed to a page table walk with reference
counting. Better yet, it exists as a patch that has been tested and it
fits in with the generic mechanism by guaranteeing that rmap_walk finds
all the migration PTEs during the second walk.

The problem remains the same - that class of solution increases the cost of
a common operation (exec) to keep a much less operation (migration) happy.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
