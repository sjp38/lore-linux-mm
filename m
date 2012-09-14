Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx205.postini.com [74.125.245.205])
	by kanga.kvack.org (Postfix) with SMTP id 9C2C56B0196
	for <linux-mm@kvack.org>; Thu, 13 Sep 2012 21:48:18 -0400 (EDT)
Date: Fri, 14 Sep 2012 10:50:29 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v3 1/5] mm: fix tracing in free_pcppages_bulk()
Message-ID: <20120914015029.GF5085@bbox>
References: <1346765185-30977-1-git-send-email-b.zolnierkie@samsung.com>
 <1346765185-30977-2-git-send-email-b.zolnierkie@samsung.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1346765185-30977-2-git-send-email-b.zolnierkie@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
Cc: linux-mm@kvack.org, m.szyprowski@samsung.com, mina86@mina86.com, mgorman@suse.de, hughd@google.com, kyungmin.park@samsung.com

On Tue, Sep 04, 2012 at 03:26:21PM +0200, Bartlomiej Zolnierkiewicz wrote:
> page->private gets re-used in __free_one_page() to store page order

Please write down result of end-user by this bug.
"So trace_mm_page_pcpu_drain may print order instead of migratetype"

> so migratetype value must be cached locally.
> 
> Fixes regression introduced in a701623 ("mm: fix migratetype bug
> which slowed swapping").
> 
> Cc: Marek Szyprowski <m.szyprowski@samsung.com>
> Cc: Michal Nazarewicz <mina86@mina86.com>
> Cc: Minchan Kim <minchan@kernel.org>
> Cc: Mel Gorman <mgorman@suse.de>
> Cc: Hugh Dickins <hughd@google.com>
> Signed-off-by: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
> Signed-off-by: Kyungmin Park <kyungmin.park@samsung.com>
Acked-by: Minchan Kim <minchan@kernel.org>

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
