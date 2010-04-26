Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 416D66B01E3
	for <linux-mm@kvack.org>; Mon, 26 Apr 2010 19:04:44 -0400 (EDT)
Date: Tue, 27 Apr 2010 01:04:12 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 0/2] Fix migration races in rmap_walk()
Message-ID: <20100426230412.GL8860@random.random>
References: <1272321478-28481-1-git-send-email-mel@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1272321478-28481-1-git-send-email-mel@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Mon, Apr 26, 2010 at 11:37:56PM +0100, Mel Gorman wrote:
> The other issues raised about expand_downwards will need to be re-examined to
> see if they still exist and transparent hugepage support will need further
> thinking to see if split_huge_page() can deal with these situations.

So patch 1 is for aa.git too, and patch 2 is only for mainline with
the new anon-vma changes (patch 2 not needed in current aa.git, and if
I apply it, it'll deadlock so...) right?

split_huge_page is somewhat simpler and more strict in its checking
than migrate.c in this respect, and yes patch 2 will also need to be
extended to cover split_huge_page the moment I stop backing out the
new anon-vma code (but it won't be any different, whatever works for
migrate will also work for split_huge_page later).

For now I'm much more interested in patch 1 and I'll leave patch 2 to
mainline digestion and check it later hope to find all issues fixed by
the time transparent hugepage gets merged.

About patch 1 it's very interesting because I looked at the race
against fork and migrate yesterday and I didn't see issues but I'm
going to read your patch 1 in detail now to understand what is the
problem you're fixing.

Good you posted this fast, so I can try to help ;)
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
