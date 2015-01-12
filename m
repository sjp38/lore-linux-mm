Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f169.google.com (mail-wi0-f169.google.com [209.85.212.169])
	by kanga.kvack.org (Postfix) with ESMTP id 2D5BD6B0032
	for <linux-mm@kvack.org>; Mon, 12 Jan 2015 09:23:59 -0500 (EST)
Received: by mail-wi0-f169.google.com with SMTP id r20so14176589wiv.0
        for <linux-mm@kvack.org>; Mon, 12 Jan 2015 06:23:58 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ei2si14145170wib.99.2015.01.12.06.23.57
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 12 Jan 2015 06:23:58 -0800 (PST)
Message-ID: <54B3D8E4.8030009@suse.cz>
Date: Mon, 12 Jan 2015 15:23:32 +0100
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [PATCH v2 1/5] mm/compaction: change tracepoint format from decimal
 to hexadecimal
References: <1421050875-26332-1-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1421050875-26332-1-git-send-email-iamjoonsoo.kim@lge.com>
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 01/12/2015 09:21 AM, Joonsoo Kim wrote:
> To check the range that compaction is working, tracepoint print
> start/end pfn of zone and start pfn of both scanner with decimal format.
> Since we manage all pages in order of 2 and it is well represented by
> hexadecimal, this patch change the tracepoint format from decimal to
> hexadecimal. This would improve readability. For example, it makes us
> easily notice whether current scanner try to compact previously
> attempted pageblock or not.
> 
> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

> ---
>  include/trace/events/compaction.h |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/include/trace/events/compaction.h b/include/trace/events/compaction.h
> index c6814b9..1337d9e 100644
> --- a/include/trace/events/compaction.h
> +++ b/include/trace/events/compaction.h
> @@ -104,7 +104,7 @@ TRACE_EVENT(mm_compaction_begin,
>  		__entry->zone_end = zone_end;
>  	),
>  
> -	TP_printk("zone_start=%lu migrate_start=%lu free_start=%lu zone_end=%lu",
> +	TP_printk("zone_start=0x%lx migrate_start=0x%lx free_start=0x%lx zone_end=0x%lx",
>  		__entry->zone_start,
>  		__entry->migrate_start,
>  		__entry->free_start,
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
