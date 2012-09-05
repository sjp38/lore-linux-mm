Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx183.postini.com [74.125.245.183])
	by kanga.kvack.org (Postfix) with SMTP id 0FB3A6B005D
	for <linux-mm@kvack.org>; Wed,  5 Sep 2012 06:59:06 -0400 (EDT)
Date: Wed, 5 Sep 2012 11:59:00 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH v3 1/5] mm: fix tracing in free_pcppages_bulk()
Message-ID: <20120905105900.GJ11266@suse.de>
References: <1346765185-30977-1-git-send-email-b.zolnierkie@samsung.com>
 <1346765185-30977-2-git-send-email-b.zolnierkie@samsung.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1346765185-30977-2-git-send-email-b.zolnierkie@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
Cc: linux-mm@kvack.org, m.szyprowski@samsung.com, mina86@mina86.com, minchan@kernel.org, hughd@google.com, kyungmin.park@samsung.com

On Tue, Sep 04, 2012 at 03:26:21PM +0200, Bartlomiej Zolnierkiewicz wrote:
> page->private gets re-used in __free_one_page() to store page order
> so migratetype value must be cached locally.
> 
> Fixes regression introduced in a701623 ("mm: fix migratetype bug
> which slowed swapping").
> 

This is unrelated to the rest of the series and should be sent on its
own but otherwise.

Acked-by: Mel Gorman <mgorman@suse.de>

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
