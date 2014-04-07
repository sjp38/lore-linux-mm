Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f180.google.com (mail-we0-f180.google.com [74.125.82.180])
	by kanga.kvack.org (Postfix) with ESMTP id 306C36B0031
	for <linux-mm@kvack.org>; Mon,  7 Apr 2014 10:40:16 -0400 (EDT)
Received: by mail-we0-f180.google.com with SMTP id p61so6963083wes.11
        for <linux-mm@kvack.org>; Mon, 07 Apr 2014 07:40:15 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id q10si2064956wjf.70.2014.04.07.07.40.14
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 07 Apr 2014 07:40:14 -0700 (PDT)
Message-ID: <5342B8CC.9020009@suse.cz>
Date: Mon, 07 Apr 2014 16:40:12 +0200
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [PATCH 1/2] mm/compaction: clean up unused code lines
References: <1396515424-18794-1-git-send-email-heesub.shin@samsung.com>
In-Reply-To: <1396515424-18794-1-git-send-email-heesub.shin@samsung.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Heesub Shin <heesub.shin@samsung.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mel Gorman <mgorman@suse.de>, Dongjun Shin <d.j.shin@samsung.com>, Sunghwan Yun <sunghwan.yun@samsung.com>

On 04/03/2014 10:57 AM, Heesub Shin wrote:
> This commit removes code lines currently not in use or never called.
>
> Signed-off-by: Heesub Shin <heesub.shin@samsung.com>
> Cc: Dongjun Shin <d.j.shin@samsung.com>
> Cc: Sunghwan Yun <sunghwan.yun@samsung.com>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

> ---
>   mm/compaction.c | 10 ----------
>   1 file changed, 10 deletions(-)
>
> diff --git a/mm/compaction.c b/mm/compaction.c
> index 9635083..1ef9144 100644
> --- a/mm/compaction.c
> +++ b/mm/compaction.c
> @@ -208,12 +208,6 @@ static bool compact_checklock_irqsave(spinlock_t *lock, unsigned long *flags,
>   	return true;
>   }
>
> -static inline bool compact_trylock_irqsave(spinlock_t *lock,
> -			unsigned long *flags, struct compact_control *cc)
> -{
> -	return compact_checklock_irqsave(lock, flags, false, cc);
> -}
> -
>   /* Returns true if the page is within a block suitable for migration to */
>   static bool suitable_migration_target(struct page *page)
>   {
> @@ -728,7 +722,6 @@ static void isolate_freepages(struct zone *zone,
>   			continue;
>
>   		/* Found a block suitable for isolating free pages from */
> -		isolated = 0;
>
>   		/*
>   		 * As pfn may not start aligned, pfn+pageblock_nr_page
> @@ -1160,9 +1153,6 @@ static void __compact_pgdat(pg_data_t *pgdat, struct compact_control *cc)
>   			if (zone_watermark_ok(zone, cc->order,
>   						low_wmark_pages(zone), 0, 0))
>   				compaction_defer_reset(zone, cc->order, false);
> -			/* Currently async compaction is never deferred. */
> -			else if (cc->sync)
> -				defer_compaction(zone, cc->order);
>   		}
>
>   		VM_BUG_ON(!list_empty(&cc->freepages));
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
