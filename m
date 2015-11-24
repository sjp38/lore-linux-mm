Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f50.google.com (mail-wm0-f50.google.com [74.125.82.50])
	by kanga.kvack.org (Postfix) with ESMTP id 4CE646B0254
	for <linux-mm@kvack.org>; Tue, 24 Nov 2015 10:52:20 -0500 (EST)
Received: by wmww144 with SMTP id w144so144523181wmw.1
        for <linux-mm@kvack.org>; Tue, 24 Nov 2015 07:52:19 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 63si27719231wmo.1.2015.11.24.07.52.18
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 24 Nov 2015 07:52:19 -0800 (PST)
Subject: Re: [PATCH] mm/compaction: improve comment
References: <1448353427-4240-1-git-send-email-baiyaowei@cmss.chinamobile.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <565487B1.9090906@suse.cz>
Date: Tue, 24 Nov 2015 16:52:17 +0100
MIME-Version: 1.0
In-Reply-To: <1448353427-4240-1-git-send-email-baiyaowei@cmss.chinamobile.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yaowei Bai <baiyaowei@cmss.chinamobile.com>, akpm@linux-foundation.org
Cc: iamjoonsoo.kim@lge.com, riel@redhat.com, mina86@mina86.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 11/24/2015 09:23 AM, Yaowei Bai wrote:
> Make comment more accurate.

Make changelog more descriptive? :)

> Signed-off-by: Yaowei Bai <baiyaowei@cmss.chinamobile.com>
> ---
>   mm/compaction.c | 4 +++-
>   1 file changed, 3 insertions(+), 1 deletion(-)
>
> diff --git a/mm/compaction.c b/mm/compaction.c
> index de3e1e7..b3cf915 100644
> --- a/mm/compaction.c
> +++ b/mm/compaction.c
> @@ -1708,7 +1708,9 @@ static void compact_nodes(void)
>   /* The written value is actually unused, all memory is compacted */
>   int sysctl_compact_memory;
>
> -/* This is the entry point for compacting all nodes via /proc/sys/vm */
> +/* This is the entry point for compacting all nodes via
> + * /proc/sys/vm/compact_memory
> + */

Strictly speaking, multi-line comments should have a leading empty line, 
e.g.:

/*
  * This is the entry point ...



>   int sysctl_compaction_handler(struct ctl_table *table, int write,
>   			void __user *buffer, size_t *length, loff_t *ppos)
>   {
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
