Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx113.postini.com [74.125.245.113])
	by kanga.kvack.org (Postfix) with SMTP id BCA206B0081
	for <linux-mm@kvack.org>; Fri, 27 Apr 2012 11:48:29 -0400 (EDT)
Message-ID: <4F9ABFC8.5000009@redhat.com>
Date: Fri, 27 Apr 2012 11:48:24 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH v4] mm: compaction: handle incorrect Unmovable type pageblocks
References: <201204271257.11501.b.zolnierkie@samsung.com>
In-Reply-To: <201204271257.11501.b.zolnierkie@samsung.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
Cc: linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Kyungmin Park <kyungmin.park@samsung.com>

On 04/27/2012 06:57 AM, Bartlomiej Zolnierkiewicz wrote:

> +/*
> + * compaction supports three modes
> + *
> + * COMPACT_ASYNC_MOVABLE uses asynchronous migration and only scans
> + *    MIGRATE_MOVABLE pageblocks as migration sources and targets.
> + * COMPACT_ASYNC_UNMOVABLE uses asynchronous migration and only scans
> + *    MIGRATE_MOVABLE pageblocks as migration sources.
> + *    MIGRATE_UNMOVABLE pageblocks are scanned as potential migration
> + *    targets and convers them to MIGRATE_MOVABLE if possible

                      ^^^^^^^^^^^^ converted to?

> + * COMPACT_SYNC uses synchronous migration and scans all pageblocks
> + */

The rest of the patch looks good to me.

Reviewed-by: Rik van Riel <riel@redhat.com>

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
