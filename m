Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 22AC56B03CE
	for <linux-mm@kvack.org>; Mon, 23 Aug 2010 12:41:54 -0400 (EDT)
Date: Mon, 23 Aug 2010 11:41:49 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] compaction: fix COMPACTPAGEFAILED counting
In-Reply-To: <1282580114-2136-1-git-send-email-minchan.kim@gmail.com>
Message-ID: <alpine.DEB.2.00.1008231140320.9496@router.home>
References: <1282580114-2136-1-git-send-email-minchan.kim@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux Kernel List <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Hugh Dickins <hughd@google.com>, Andi Kleen <andi@firstfloor.org>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

On Tue, 24 Aug 2010, Minchan Kim wrote

> This patch introude new argument 'cleanup' to migrate_pages.
> Only if we set 1 to 'cleanup', migrate_page will clean up the lists.
> Otherwise, caller need to clean up the lists so it has a chance to postprocess
> the pages.

Could we simply make migrate_pages simply not do any cleanup?
Caller has to call putback_lru_pages()?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
