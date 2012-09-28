Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx184.postini.com [74.125.245.184])
	by kanga.kvack.org (Postfix) with SMTP id 9BD8C6B006C
	for <linux-mm@kvack.org>; Fri, 28 Sep 2012 09:10:53 -0400 (EDT)
Date: Fri, 28 Sep 2012 14:10:43 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH] CMA: decrease cc.nr_migratepages after reclaiming
 pagelist
Message-ID: <20120928131043.GD29125@suse.de>
References: <1348642212-29394-1-git-send-email-minchan@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1348642212-29394-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Michal Nazarewicz <mina86@mina86.com>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, Marek Szyprowski <m.szyprowski@samsung.com>

On Wed, Sep 26, 2012 at 03:50:12PM +0900, Minchan Kim wrote:
> The reclaim_clean_pages_from_list reclaims clean pages before
> migration so cc.nr_migratepages should be updated.
> Currently, there is no problem but it can be wrong if we
> try to use the vaule in future.
> 
> Cc: Mel Gorman <mgorman@suse.de>
> Cc: Michal Nazarewicz <mina86@mina86.com>
> Cc: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
> Cc: Marek Szyprowski <m.szyprowski@samsung.com>
> Signed-off-by: Minchan Kim <minchan@kernel.org>

Yeah ok. As you say, it shouldn't actually affect anything currently and
cc.migratepages is expected to go out of date after migration meaning we
need update_nr_listpages. This patch looks ok though.

Acked-by: Mel Gorman <mgorman@suse.de>

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
