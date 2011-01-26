Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 282036B0092
	for <linux-mm@kvack.org>; Wed, 26 Jan 2011 03:14:43 -0500 (EST)
Date: Wed, 26 Jan 2011 08:14:14 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 1/3] When migrate_pages returns 0, all pages must have
	been released
Message-ID: <20110126081414.GK18984@csn.ul.ie>
References: <f60d811fd1abcb68d40ac19af35881d700a97cd2.1295539829.git.minchan.kim@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <f60d811fd1abcb68d40ac19af35881d700a97cd2.1295539829.git.minchan.kim@gmail.com>
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Andrea Arcangeli <aarcange@redhat.com>
List-ID: <linux-mm.kvack.org>

On Fri, Jan 21, 2011 at 01:17:05AM +0900, Minchan Kim wrote:
> From: Andrea Arcangeli <aarcange@redhat.com>
> 
> From: Andrea Arcangeli <aarcange@redhat.com>
> 
> In some cases migrate_pages could return zero while still leaving a
> few pages in the pagelist (and some caller wouldn't notice it has to
> call putback_lru_pages after commit
> cf608ac19c95804dc2df43b1f4f9e068aa9034ab).
> 
> Add one missing putback_lru_pages not added by commit
> cf608ac19c95804dc2df43b1f4f9e068aa9034ab.
> 
> Reviewed-by: Minchan Kim <minchan.kim@gmail.com>
> Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>

Better late than never;

Acked-by: Mel Gorman <mel@csn.ul.ie>

-- 
Mel Gorman
Linux Technology Center
IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
