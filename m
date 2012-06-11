Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx154.postini.com [74.125.245.154])
	by kanga.kvack.org (Postfix) with SMTP id 002BE6B006C
	for <linux-mm@kvack.org>; Sun, 10 Jun 2012 21:26:58 -0400 (EDT)
Message-ID: <4FD54959.6060500@kernel.org>
Date: Mon, 11 Jun 2012 10:26:49 +0900
From: Minchan Kim <minchan@kernel.org>
MIME-Version: 1.0
Subject: Re: [PATCH v10] mm: compaction: handle incorrect MIGRATE_UNMOVABLE
 type pageblocks
References: <201206081046.32382.b.zolnierkie@samsung.com>
In-Reply-To: <201206081046.32382.b.zolnierkie@samsung.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Dave Jones <davej@redhat.com>, Cong Wang <amwang@redhat.com>, Markus Trippelsdorf <markus@trippelsdorf.de>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Kyungmin Park <kyungmin.park@samsung.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>

Hi Bartlomiej,

On 06/08/2012 05:46 PM, Bartlomiej Zolnierkiewicz wrote:

> 
> Hi,
> 
> This version is much simpler as it just uses __count_immobile_pages()
> instead of using its own open coded version and it integrates changes


That's a good idea. I don't have noticed that function is there.
When I look at the function, it has a problem, too.
Please, look at this.

https://lkml.org/lkml/2012/6/10/180

If reviewer is okay that patch, I would like to resend your patch based on that. 

> from Minchan Kim (without page_count change as it doesn't seem correct


Why do you think so?
If it isn't correct, how can you prevent racing with THP page freeing?

> and __count_immobile_pages() does the check in the standard way; if it
> still is a problem I think that removing 1st phase check altogether
> would be better instead of adding more locking complexity).
> 
> The patch also adds compact_rescued_unmovable_blocks vmevent to vmstats
> to make it possible to easily check if the code is working in practice.


I think that part should be another patch.

1. Adding new vmstat would be arguable so it might interrupt this patch merging.
2. New vmstat adding is just for this patch is effective or not in real practice
   so if we prove it in future, let's revert the vmstat. Separating it would make it
   easily.

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
