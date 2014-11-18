Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f171.google.com (mail-pd0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id 02E0F6B0069
	for <linux-mm@kvack.org>; Mon, 17 Nov 2014 22:25:29 -0500 (EST)
Received: by mail-pd0-f171.google.com with SMTP id r10so22463273pdi.2
        for <linux-mm@kvack.org>; Mon, 17 Nov 2014 19:25:28 -0800 (PST)
Received: from fgwmail6.fujitsu.co.jp (fgwmail6.fujitsu.co.jp. [192.51.44.36])
        by mx.google.com with ESMTPS id w4si11516430pdi.115.2014.11.17.19.25.27
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 17 Nov 2014 19:25:27 -0800 (PST)
Received: from kw-mxoi1.gw.nic.fujitsu.com (unknown [10.0.237.133])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 382043EE0C1
	for <linux-mm@kvack.org>; Tue, 18 Nov 2014 12:25:26 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by kw-mxoi1.gw.nic.fujitsu.com (Postfix) with ESMTP id 36CBBAC049B
	for <linux-mm@kvack.org>; Tue, 18 Nov 2014 12:25:25 +0900 (JST)
Received: from g01jpfmpwkw01.exch.g01.fujitsu.local (g01jpfmpwkw01.exch.g01.fujitsu.local [10.0.193.38])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 953E21DB8050
	for <linux-mm@kvack.org>; Tue, 18 Nov 2014 12:25:24 +0900 (JST)
Message-ID: <546ABC02.4010905@jp.fujitsu.com>
Date: Tue, 18 Nov 2014 12:24:50 +0900
From: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: do not overwrite reserved pages counter at show_mem()
References: <e34cbf786f7c16d4330889825aa5b13141cc085c.1415989668.git.aquini@redhat.com>
In-Reply-To: <e34cbf786f7c16d4330889825aa5b13141cc085c.1415989668.git.aquini@redhat.com>
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rafael Aquini <aquini@redhat.com>, linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@suse.de>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Johannes Weiner <jweiner@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org

(2014/11/15 3:34), Rafael Aquini wrote:
> Minor fixlet to perform the reserved pages counter aggregation
> for each node, at show_mem()
> 
> Signed-off-by: Rafael Aquini <aquini@redhat.com>
> ---

Acked-by: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>

Thanks,
Yasuaki Ishimatsu

>   lib/show_mem.c | 2 +-
>   1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/lib/show_mem.c b/lib/show_mem.c
> index 0922579..5e25627 100644
> --- a/lib/show_mem.c
> +++ b/lib/show_mem.c
> @@ -28,7 +28,7 @@ void show_mem(unsigned int filter)
>   				continue;
>   
>   			total += zone->present_pages;
> -			reserved = zone->present_pages - zone->managed_pages;
> +			reserved += zone->present_pages - zone->managed_pages;
>   
>   			if (is_highmem_idx(zoneid))
>   				highmem += zone->present_pages;
> 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
