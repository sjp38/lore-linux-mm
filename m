Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f49.google.com (mail-wm0-f49.google.com [74.125.82.49])
	by kanga.kvack.org (Postfix) with ESMTP id C239D6B007E
	for <linux-mm@kvack.org>; Thu, 24 Mar 2016 11:51:17 -0400 (EDT)
Received: by mail-wm0-f49.google.com with SMTP id p65so72107782wmp.0
        for <linux-mm@kvack.org>; Thu, 24 Mar 2016 08:51:17 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id h83si10290668wmh.106.2016.03.24.08.51.11
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 24 Mar 2016 08:51:12 -0700 (PDT)
Subject: Re: [PATCH] mm/page_isolation: fix tracepoint to mirror check
 function behavior
References: <1458236456-465-1-git-send-email-l.stach@pengutronix.de>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <56F40CEE.9080201@suse.cz>
Date: Thu, 24 Mar 2016 16:51:10 +0100
MIME-Version: 1.0
In-Reply-To: <1458236456-465-1-git-send-email-l.stach@pengutronix.de>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Lucas Stach <l.stach@pengutronix.de>, Joonsoo Kim <js1304@gmail.com>, linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, kernel@pengutronix.de, patchwork-lst@pengutronix.de

On 03/17/2016 06:40 PM, Lucas Stach wrote:
> Page isolation has not failed if the fin pfn extends beyond the end pfn
> and test_pages_isolated checks this correctly. Fix the tracepoint to
> report the same result as the actual check function.

Right.

> Signed-off-by: Lucas Stach <l.stach@pengutronix.de>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

> ---
>   include/trace/events/page_isolation.h | 2 +-
>   1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/include/trace/events/page_isolation.h b/include/trace/events/page_isolation.h
> index 6fb644029c80..8738a78e6bf4 100644
> --- a/include/trace/events/page_isolation.h
> +++ b/include/trace/events/page_isolation.h
> @@ -29,7 +29,7 @@ TRACE_EVENT(test_pages_isolated,
>
>   	TP_printk("start_pfn=0x%lx end_pfn=0x%lx fin_pfn=0x%lx ret=%s",
>   		__entry->start_pfn, __entry->end_pfn, __entry->fin_pfn,
> -		__entry->end_pfn == __entry->fin_pfn ? "success" : "fail")
> +		__entry->end_pfn <= __entry->fin_pfn ? "success" : "fail")
>   );
>
>   #endif /* _TRACE_PAGE_ISOLATION_H */
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
