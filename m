Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id B66A06B03D9
	for <linux-mm@kvack.org>; Mon, 23 Aug 2010 13:03:49 -0400 (EDT)
Received: by iwn33 with SMTP id 33so4620910iwn.14
        for <linux-mm@kvack.org>; Mon, 23 Aug 2010 10:03:48 -0700 (PDT)
Date: Tue, 24 Aug 2010 02:03:40 +0900
From: Minchan Kim <minchan.kim@gmail.com>
Subject: Re: [PATCH] compaction: fix COMPACTPAGEFAILED counting
Message-ID: <20100823170340.GA2304@barrios-desktop>
References: <1282580114-2136-1-git-send-email-minchan.kim@gmail.com>
 <alpine.DEB.2.00.1008231140320.9496@router.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1008231140320.9496@router.home>
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux Kernel List <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Hugh Dickins <hughd@google.com>, Andi Kleen <andi@firstfloor.org>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

On Mon, Aug 23, 2010 at 11:41:49AM -0500, Christoph Lameter wrote:
> On Tue, 24 Aug 2010, Minchan Kim wrote
> 
> > This patch introude new argument 'cleanup' to migrate_pages.
> > Only if we set 1 to 'cleanup', migrate_page will clean up the lists.
> > Otherwise, caller need to clean up the lists so it has a chance to postprocess
> > the pages.
> 
> Could we simply make migrate_pages simply not do any cleanup?

If migrate_pages always return number of pages not migrated, it's possible.
But now it can return the number of pages not migrated or error code. 
In case of returning error code, caller has a complex routine to know count the 
number of success.

> Caller has to call putback_lru_pages()?
> 
Hmm. yes it's not good. At least we can help some NOTE.
migrate_pages isn't generic kernel API so i think documentation is enough. 

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
