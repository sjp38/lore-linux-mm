Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 8E62B280281
	for <linux-mm@kvack.org>; Wed, 17 Jan 2018 03:43:35 -0500 (EST)
Received: by mail-wr0-f199.google.com with SMTP id g13so12598978wrh.19
        for <linux-mm@kvack.org>; Wed, 17 Jan 2018 00:43:35 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t6si3057806wmh.147.2018.01.17.00.43.33
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 17 Jan 2018 00:43:34 -0800 (PST)
Subject: Re: [PATCH] mm/compaction: fix the comment for try_to_compact_pages
References: <1515801336-20611-1-git-send-email-yang.shi@linux.alibaba.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <149a38e1-a8cc-1029-eb68-5cce1fa39496@suse.cz>
Date: Wed, 17 Jan 2018 09:43:32 +0100
MIME-Version: 1.0
In-Reply-To: <1515801336-20611-1-git-send-email-yang.shi@linux.alibaba.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yang Shi <yang.shi@linux.alibaba.com>, akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mel Gorman <mgorman@techsingularity.net>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Michal Hocko <mhocko@suse.com>

On 01/13/2018 12:55 AM, Yang Shi wrote:
> "mode" argument is not used by try_to_compact_pages() and sub functions
> anymore, it has been replaced by "prio". Fix the comment to explain the
> use of "prio" argument.
> 
> Cc: Vlastimil Babka <vbabka@suse.cz>
> Cc: Mel Gorman <mgorman@techsingularity.net>
> Cc: David Rientjes <rientjes@google.com>
> Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> Cc: Michal Hocko <mhocko@suse.com>
> Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

> ---
>  mm/compaction.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/mm/compaction.c b/mm/compaction.c
> index 10cd757..2c8999d 100644
> --- a/mm/compaction.c
> +++ b/mm/compaction.c
> @@ -1738,7 +1738,7 @@ static enum compact_result compact_zone_order(struct zone *zone, int order,
>   * @order: The order of the current allocation
>   * @alloc_flags: The allocation flags of the current allocation
>   * @ac: The context of current allocation
> - * @mode: The migration mode for async, sync light, or sync migration
> + * @prio: Determines how hard direct compaction should try to succeed
>   *
>   * This is the main entry point for direct page compaction.
>   */
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
