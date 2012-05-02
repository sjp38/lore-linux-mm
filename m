Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx102.postini.com [74.125.245.102])
	by kanga.kvack.org (Postfix) with SMTP id 29BEB6B004D
	for <linux-mm@kvack.org>; Wed,  2 May 2012 16:04:11 -0400 (EDT)
Message-ID: <4FA19339.7000808@redhat.com>
Date: Wed, 02 May 2012 16:04:09 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH v5] mm: compaction: handle incorrect MIGRATE_UNMOVABLE
 type pageblocks
References: <201205021047.45188.b.zolnierkie@samsung.com>
In-Reply-To: <201205021047.45188.b.zolnierkie@samsung.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
Cc: linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Kyungmin Park <kyungmin.park@samsung.com>

On 05/02/2012 04:47 AM, Bartlomiej Zolnierkiewicz wrote:
> From: Bartlomiej Zolnierkiewicz<b.zolnierkie@samsung.com>
> Subject: [PATCH v5] mm: compaction: handle incorrect MIGRATE_UNMOVABLE type pageblocks
>
> When MIGRATE_UNMOVABLE pages are freed from MIGRATE_UNMOVABLE
> type pageblock (and some MIGRATE_MOVABLE pages are left in it)
> waiting until an allocation takes ownership of the block may
> take too long.  The type of the pageblock remains unchanged
> so the pageblock cannot be used as a migration target during
> compaction.
>
> Fix it by:

> Cc: Mel Gorman<mgorman@suse.de>
> Cc: Minchan Kim<minchan@kernel.org>
> Cc: Rik van Riel<riel@redhat.com>
> Cc: Marek Szyprowski<m.szyprowski@samsung.com>
> Signed-off-by: Bartlomiej Zolnierkiewicz<b.zolnierkie@samsung.com>
> Signed-off-by: Kyungmin Park<kyungmin.park@samsung.com>

Acked-by: Rik van Riel <riel@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
