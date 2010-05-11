Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id BA3746B01FB
	for <linux-mm@kvack.org>; Tue, 11 May 2010 10:40:34 -0400 (EDT)
Date: Tue, 11 May 2010 08:59:12 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 2/2] mm,migration: Avoid race between shift_arg_pages()
 and rmap_walk() during migration by not migrating temporary stacks
In-Reply-To: <20100510175654.GL26611@csn.ul.ie>
Message-ID: <alpine.DEB.2.00.1005110857350.1500@router.home>
References: <1272529930-29505-1-git-send-email-mel@csn.ul.ie> <1272529930-29505-3-git-send-email-mel@csn.ul.ie> <alpine.DEB.2.00.1005012055010.2663@router.home> <20100504094522.GA20979@csn.ul.ie> <alpine.DEB.2.00.1005101239400.13652@router.home>
 <20100510175654.GL26611@csn.ul.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

On Mon, 10 May 2010, Mel Gorman wrote:

> > A simple way to disallow migration of pages is to increment the refcount
> > of a page.
> I guess it could be done by walking the page-tables in advance of the move
> and elevating the page count of any pages faulted and then finding those
> pages afterwards.  The fail path would be a bit of a pain though if the page
> tables are partially moved though. It's unnecessarily complicated when the
> temporary stack can be easily avoided.

Faulting during exec? Dont we hold mmap_sem for write? A get_user_pages()
or so on the range will increment the refcount.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
