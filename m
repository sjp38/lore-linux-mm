Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id C4A336B004F
	for <linux-mm@kvack.org>; Tue, 15 Sep 2009 16:26:38 -0400 (EDT)
Date: Tue, 15 Sep 2009 21:26:01 +0100 (BST)
From: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Subject: Re: [PATCH 5/8] mm: follow_hugetlb_page flags
In-Reply-To: <20090914132737.GB11778@csn.ul.ie>
Message-ID: <Pine.LNX.4.64.0909152117060.22199@sister.anvils>
References: <Pine.LNX.4.64.0909072222070.15424@sister.anvils>
 <Pine.LNX.4.64.0909072235360.15430@sister.anvils> <20090909113143.GG24614@csn.ul.ie>
 <Pine.LNX.4.64.0909131548001.22865@sister.anvils> <20090914132737.GB11778@csn.ul.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Linus Torvalds <torvalds@linux-foundation.org>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 14 Sep 2009, Mel Gorman wrote:
> On Sun, Sep 13, 2009 at 04:35:44PM +0100, Hugh Dickins wrote:
> > On Wed, 9 Sep 2009, Mel Gorman wrote:
> 
> > > and called something like hugetlbfs_pagecache_present()
> > 
> > Can call it that if you prefer, either name suits me.
> 
> I don't feel strongly enough to ask for a new version. If this is not
> the final version that is merged, then a name-change would be nice.
> Otherwise, it's not worth the hassle.

You've raised several points, so worth a patch on top to keep you sweet!

> > > or else reuse
> > > the function and have the caller unlock_page but it's probably not worth
> > > addressing.
> > 
> > I did originally want to do it that way, but the caller is holding
> > page_table_lock, so cannot lock_page there.
> 
> Gack, fair point. If there is another version, a comment to that effect
> wouldn't hurt.

Righto, done.

> And nothing else other than core dumping will be using FOLL_DUMP so
> there should be no assumptions broken.

You have no idea of the depths of depravity to which I might sink:
see patch 1/4 in the coming group, you might be inclined to protest.

> > But it does seem that we've confused each other: what to say instead?
> 
> /*
>  * When core-dumping, it's suits the get_dump_page() if an error is
>  * returned if there is a hole and no huge pagecache to back it.
>  * get_dump_page() is concerned with individual pages and by
>  * returning the page as an error, the core dump file still gets
>  * zeros but a hugepage allocation is avoided.
>  */

I've added a sentence to that comment, not quite what you've
suggested above, but something I hope makes it clearer.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
