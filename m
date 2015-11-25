Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f50.google.com (mail-wm0-f50.google.com [74.125.82.50])
	by kanga.kvack.org (Postfix) with ESMTP id 0285D6B0038
	for <linux-mm@kvack.org>; Wed, 25 Nov 2015 05:23:57 -0500 (EST)
Received: by wmuu63 with SMTP id u63so131532351wmu.0
        for <linux-mm@kvack.org>; Wed, 25 Nov 2015 02:23:56 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id yo9si33490825wjc.233.2015.11.25.02.23.55
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 25 Nov 2015 02:23:55 -0800 (PST)
Subject: Re: [PATCH] mm/compaction: improve comment for compact_memory tunable
 knob handler
References: <1448442448-3268-1-git-send-email-baiyaowei@cmss.chinamobile.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <56558C39.1010305@suse.cz>
Date: Wed, 25 Nov 2015 11:23:53 +0100
MIME-Version: 1.0
In-Reply-To: <1448442448-3268-1-git-send-email-baiyaowei@cmss.chinamobile.com>
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yaowei Bai <baiyaowei@cmss.chinamobile.com>, akpm@linux-foundation.org
Cc: iamjoonsoo.kim@lge.com, riel@redhat.com, mina86@mina86.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 11/25/2015 10:07 AM, Yaowei Bai wrote:
> Sysctl_compaction_handler() is the handler function for compact_memory
> tunable knob under /proc/sys/vm, add the missing knob name to make this
> more accurate in comment.
> 
> No functional change.
> 
> Signed-off-by: Yaowei Bai <baiyaowei@cmss.chinamobile.com>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

> ---
>  mm/compaction.c | 5 ++++-
>  1 file changed, 4 insertions(+), 1 deletion(-)
> 
> diff --git a/mm/compaction.c b/mm/compaction.c
> index de3e1e7..ac6c694 100644
> --- a/mm/compaction.c
> +++ b/mm/compaction.c
> @@ -1708,7 +1708,10 @@ static void compact_nodes(void)
>  /* The written value is actually unused, all memory is compacted */
>  int sysctl_compact_memory;
>  
> -/* This is the entry point for compacting all nodes via /proc/sys/vm */
> +/*
> + * This is the entry point for compacting all nodes via
> + * /proc/sys/vm/compact_memory
> + */
>  int sysctl_compaction_handler(struct ctl_table *table, int write,
>  			void __user *buffer, size_t *length, loff_t *ppos)
>  {
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
