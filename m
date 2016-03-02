Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f49.google.com (mail-wm0-f49.google.com [74.125.82.49])
	by kanga.kvack.org (Postfix) with ESMTP id E42A86B0009
	for <linux-mm@kvack.org>; Wed,  2 Mar 2016 04:22:55 -0500 (EST)
Received: by mail-wm0-f49.google.com with SMTP id p65so70799996wmp.1
        for <linux-mm@kvack.org>; Wed, 02 Mar 2016 01:22:55 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id q16si3785850wmb.111.2016.03.02.01.22.54
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 02 Mar 2016 01:22:54 -0800 (PST)
Subject: Re: [PATCH] mm/compaction: don't use modular references for non
 modular code
References: <1455403654-28951-1-git-send-email-paul.gortmaker@windriver.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <56D6B0EC.2010601@suse.cz>
Date: Wed, 2 Mar 2016 10:22:52 +0100
MIME-Version: 1.0
In-Reply-To: <1455403654-28951-1-git-send-email-paul.gortmaker@windriver.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Paul Gortmaker <paul.gortmaker@windriver.com>, linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>

On 02/13/2016 11:47 PM, Paul Gortmaker wrote:
> replace module_init with subsys_initcall ; which will be two
> levels earlier, but mm smells like a subsystem to me.

I admit I don't know the exact differences here, but it makes sense as 
it's not a module.
I just copied this code from kswapd, which also uses module_init(). 
Should it be also converted?

> Compile tested only.
>
> Cc: Vlastimil Babka <vbabka@suse.cz>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
> ---
>
> [Feel free to squash this into the original, if desired.]
>
>   mm/compaction.c | 4 +---
>   1 file changed, 1 insertion(+), 3 deletions(-)
>
> diff --git a/mm/compaction.c b/mm/compaction.c
> index 4cb1c2ef5abb..4d99e1f5055c 100644
> --- a/mm/compaction.c
> +++ b/mm/compaction.c
> @@ -20,7 +20,6 @@
>   #include <linux/kasan.h>
>   #include <linux/kthread.h>
>   #include <linux/freezer.h>
> -#include <linux/module.h>
>   #include "internal.h"
>
>   #ifdef CONFIG_COMPACTION
> @@ -1954,7 +1953,6 @@ static int __init kcompactd_init(void)
>   	hotcpu_notifier(cpu_callback, 0);
>   	return 0;
>   }
> -
> -module_init(kcompactd_init)
> +subsys_initcall(kcompactd_init)
>
>   #endif /* CONFIG_COMPACTION */
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
