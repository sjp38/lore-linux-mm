Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id BF4D86B02A4
	for <linux-mm@kvack.org>; Thu,  8 Jul 2010 17:02:26 -0400 (EDT)
Date: Thu, 8 Jul 2010 16:01:48 -0500 (CDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [PATCH v2 2/2] vmscan: shrink_slab() require number of lru_pages,
 not page order
In-Reply-To: <20100708133152.5e556508.akpm@linux-foundation.org>
Message-ID: <alpine.DEB.2.00.1007081540400.15083@router.home>
References: <20100708163401.CD34.A69D9226@jp.fujitsu.com> <20100708163934.CD37.A69D9226@jp.fujitsu.com> <alpine.DEB.2.00.1007080901460.9707@router.home> <20100708133152.5e556508.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>
List-ID: <linux-mm.kvack.org>

On Thu, 8 Jul 2010, Andrew Morton wrote:

> > AFAICT this is not argument error but someone changed the naming of the
> > parameter.
>
> It's been there since day zero:
>
> : commit 2a16e3f4b0c408b9e50297d2ec27e295d490267a
> : Author:     Christoph Lameter <clameter@engr.sgi.com>
> : AuthorDate: Wed Feb 1 03:05:35 2006 -0800
> : Commit:     Linus Torvalds <torvalds@g5.osdl.org>
> : CommitDate: Wed Feb 1 08:53:16 2006 -0800
> :
> :     [PATCH] Reclaim slab during zone reclaim

That only shows that the order parameter was passed to shrink_slab() which
is what I remember being done intentionally.

Vaguely recall that this was necessary to avoid shrink_slab() throwing out
too many pages for higher order allocs.

Initially zone_reclaim was full of heuristics that later were replaced by
counter as the new ZVCs became available and gradually better ways of
accounting for pages became possible.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
