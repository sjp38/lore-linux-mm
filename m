Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id B37386B0281
	for <linux-mm@kvack.org>; Tue,  4 May 2010 05:45:46 -0400 (EDT)
Date: Tue, 4 May 2010 10:45:22 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 2/2] mm,migration: Avoid race between shift_arg_pages()
	and rmap_walk() during migration by not migrating temporary stacks
Message-ID: <20100504094522.GA20979@csn.ul.ie>
References: <1272529930-29505-1-git-send-email-mel@csn.ul.ie> <1272529930-29505-3-git-send-email-mel@csn.ul.ie> <alpine.DEB.2.00.1005012055010.2663@router.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1005012055010.2663@router.home>
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

On Sat, May 01, 2010 at 08:56:18PM -0500, Christoph Lameter wrote:
> On Thu, 29 Apr 2010, Mel Gorman wrote:
> 
> > There is a race between shift_arg_pages and migration that triggers this bug.
> > A temporary stack is setup during exec and later moved. If migration moves
> > a page in the temporary stack and the VMA is then removed before migration
> > completes, the migration PTE may not be found leading to a BUG when the
> > stack is faulted.
> 
> A simpler solution would be to not allow migration of the temporary stack?
> 

The patch's intention is to not migrate pages within the temporary
stack. What are you suggesting that is different?

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
