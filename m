Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 6DD8C6B01FB
	for <linux-mm@kvack.org>; Tue, 11 May 2010 11:12:21 -0400 (EDT)
Date: Tue, 11 May 2010 16:11:42 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 2/2] mm,migration: Avoid race between shift_arg_pages()
	and rmap_walk() during migration by not migrating temporary stacks
Message-ID: <20100511151142.GS26611@csn.ul.ie>
References: <1272529930-29505-1-git-send-email-mel@csn.ul.ie> <1272529930-29505-3-git-send-email-mel@csn.ul.ie> <alpine.DEB.2.00.1005012055010.2663@router.home> <20100504094522.GA20979@csn.ul.ie> <alpine.DEB.2.00.1005101239400.13652@router.home> <20100510175654.GL26611@csn.ul.ie> <alpine.DEB.2.00.1005110857350.1500@router.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1005110857350.1500@router.home>
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

On Tue, May 11, 2010 at 08:59:12AM -0500, Christoph Lameter wrote:
> On Mon, 10 May 2010, Mel Gorman wrote:
> 
> > > A simple way to disallow migration of pages is to increment the refcount
> > > of a page.
> > I guess it could be done by walking the page-tables in advance of the move
> > and elevating the page count of any pages faulted and then finding those
> > pages afterwards.  The fail path would be a bit of a pain though if the page
> > tables are partially moved though. It's unnecessarily complicated when the
> > temporary stack can be easily avoided.
> 
> Faulting during exec?

Copying in arguments and the like

> Dont we hold mmap_sem for write? A get_user_pages()
> or so on the range will increment the refcount.
> 

Or just identify the temporary stack from the migration side instead of
adding to the cost of exec?

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
