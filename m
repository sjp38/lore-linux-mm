Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f180.google.com (mail-wi0-f180.google.com [209.85.212.180])
	by kanga.kvack.org (Postfix) with ESMTP id 72CC56B0253
	for <linux-mm@kvack.org>; Fri,  7 Aug 2015 10:18:07 -0400 (EDT)
Received: by wibhh20 with SMTP id hh20so67886597wib.0
        for <linux-mm@kvack.org>; Fri, 07 Aug 2015 07:18:07 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id bl2si20100141wjb.36.2015.08.07.07.18.05
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 07 Aug 2015 07:18:05 -0700 (PDT)
Subject: Re: [PATCH 1/1] mm: compaction: include compact_nodes in compaction.h
References: <1438956233-28690-1-git-send-email-pintu.k@samsung.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <55C4BE1A.8050408@suse.cz>
Date: Fri, 7 Aug 2015 16:18:02 +0200
MIME-Version: 1.0
In-Reply-To: <1438956233-28690-1-git-send-email-pintu.k@samsung.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pintu Kumar <pintu.k@samsung.com>, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, iamjoonsoo.kim@lge.com, mhocko@suse.cz, riel@redhat.com, emunson@akamai.com, mgorman@suse.de, zhangyanfei@cn.fujitsu.com, rientjes@google.com
Cc: cpgs@samsung.com, pintu_agarwal@yahoo.com, pintu.k@outlook.com, vishnu.ps@samsung.com, rohit.kr@samsung.com

On 08/07/2015 04:03 PM, Pintu Kumar wrote:
> This patch declares compact_nodes prototype in compaction.h
> header file.
> This will allow us to call compaction from other places.
> For example, during system suspend, suppose we want to check
> the fragmentation state of the system. Then based on certain
> threshold, we can invoke compaction, when system is idle.
> There could be other use cases.

Isn't it more common to introduce such visibility changes only as part 
of series that actually benefit from it?

Otherwise next month somebody might notice that it's unused outside 
compaction.c and send a cleanup patch to make it static again...

> Signed-off-by: Pintu Kumar <pintu.k@samsung.com>
> ---
>   include/linux/compaction.h |    2 +-
>   mm/compaction.c            |    2 +-
>   2 files changed, 2 insertions(+), 2 deletions(-)
>
> diff --git a/include/linux/compaction.h b/include/linux/compaction.h
> index aa8f61c..800ff50 100644
> --- a/include/linux/compaction.h
> +++ b/include/linux/compaction.h
> @@ -50,7 +50,7 @@ extern bool compaction_deferred(struct zone *zone, int order);
>   extern void compaction_defer_reset(struct zone *zone, int order,
>   				bool alloc_success);
>   extern bool compaction_restarting(struct zone *zone, int order);
> -
> +extern void compact_nodes(void);
>   #else
>   static inline unsigned long try_to_compact_pages(gfp_t gfp_mask,
>   			unsigned int order, int alloc_flags,
> diff --git a/mm/compaction.c b/mm/compaction.c
> index 16e1b57..b793922 100644
> --- a/mm/compaction.c
> +++ b/mm/compaction.c
> @@ -1657,7 +1657,7 @@ static void compact_node(int nid)
>   }
>
>   /* Compact all nodes in the system */
> -static void compact_nodes(void)
> +void compact_nodes(void)
>   {
>   	int nid;
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
