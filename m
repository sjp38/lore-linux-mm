Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id C72196B0092
	for <linux-mm@kvack.org>; Wed, 26 Jan 2011 03:18:45 -0500 (EST)
Date: Wed, 26 Jan 2011 08:18:19 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 3/3] compaction: Check migrate_pages's return value
	instead of list_empty
Message-ID: <20110126081819.GL18984@csn.ul.ie>
References: <f60d811fd1abcb68d40ac19af35881d700a97cd2.1295539829.git.minchan.kim@gmail.com> <8d3d2470533ab99564cdcec88bfb7fcc96b383d3.1295539829.git.minchan.kim@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <8d3d2470533ab99564cdcec88bfb7fcc96b383d3.1295539829.git.minchan.kim@gmail.com>
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Fri, Jan 21, 2011 at 01:17:07AM +0900, Minchan Kim wrote:
> Many migrate_page's caller check return value instead of list_empy by
> cf608ac19c95804dc2.
> This patch makes compaction's migrate_pages consistent with others.
> This patch should not change old behavior.
> 
> NOTE : This patch depends on [1/3].
> 
> Cc: Mel Gorman <mel@csn.ul.ie>
> Signed-off-by: Minchan Kim <minchan.kim@gmail.com>

I haven't tested but I am not spotting a problem;

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
