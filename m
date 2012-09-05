Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx107.postini.com [74.125.245.107])
	by kanga.kvack.org (Postfix) with SMTP id CC63A6B005D
	for <linux-mm@kvack.org>; Wed,  5 Sep 2012 06:56:15 -0400 (EDT)
Date: Wed, 5 Sep 2012 11:56:11 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 2/2] mm: support MIGRATE_DISCARD
Message-ID: <20120905105611.GI11266@suse.de>
References: <1346832673-12512-1-git-send-email-minchan@kernel.org>
 <1346832673-12512-2-git-send-email-minchan@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1346832673-12512-2-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, Rik van Riel <riel@redhat.com>

On Wed, Sep 05, 2012 at 05:11:13PM +0900, Minchan Kim wrote:
> This patch introudes MIGRATE_DISCARD mode in migration.
> It drops *clean cache pages* instead of migration so that
> migration latency could be reduced by avoiding (memcpy + page remapping).
> It's useful for CMA because latency of migration is very important rather
> than eviction of background processes's workingset. In addition, it needs
> less free pages for migration targets so it could avoid memory reclaiming
> to get free pages, which is another factor increase latency.
> 

Bah, this was released while I was reviewing the older version. I did
not read this one as closely but I see the enum problems have gone away
at least. I'd still prefer if CMA had an additional helper to discard
some pages with shrink_page_list() and migrate the remaining pages with
migrate_pages(). That would remove the need to add a MIGRATE_DISCARD
migrate mode at all.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
