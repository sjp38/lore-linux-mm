Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f71.google.com (mail-pa0-f71.google.com [209.85.220.71])
	by kanga.kvack.org (Postfix) with ESMTP id 723996B007E
	for <linux-mm@kvack.org>; Thu,  2 Jun 2016 03:10:23 -0400 (EDT)
Received: by mail-pa0-f71.google.com with SMTP id x1so37121880pav.3
        for <linux-mm@kvack.org>; Thu, 02 Jun 2016 00:10:23 -0700 (PDT)
Received: from mail-pf0-x242.google.com (mail-pf0-x242.google.com. [2607:f8b0:400e:c00::242])
        by mx.google.com with ESMTPS id zq1si6112240pac.130.2016.06.02.00.10.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 02 Jun 2016 00:10:22 -0700 (PDT)
Received: by mail-pf0-x242.google.com with SMTP id b124so6951277pfb.0
        for <linux-mm@kvack.org>; Thu, 02 Jun 2016 00:10:22 -0700 (PDT)
Date: Thu, 2 Jun 2016 16:10:17 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH 4/4] mm/zsmalloc: remove unused header cpumask.h
Message-ID: <20160602071017.GA439@swordfish>
References: <7cc1b41351a96e7d67fcf4bd2a6987b71793cb27.1464847139.git.geliangtang@gmail.com>
 <f0fa3738403f886988141182e8e4bac7efed05c7.1464847139.git.geliangtang@gmail.com>
 <866efd744a89b6e16c9d3acd1a00b011adbd59af.1464847139.git.geliangtang@gmail.com>
 <94e9f6fee719fcaa91ee5767a9ad64658c6f5237.1464847139.git.geliangtang@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <94e9f6fee719fcaa91ee5767a9ad64658c6f5237.1464847139.git.geliangtang@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Geliang Tang <geliangtang@gmail.com>
Cc: Minchan Kim <minchan@kernel.org>, Nitin Gupta <ngupta@vflare.org>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On (06/02/16 14:15), Geliang Tang wrote:
> Remove unused header cpumask.h from mm/zsmalloc.c.
> 
> Signed-off-by: Geliang Tang <geliangtang@gmail.com>
> ---
>  mm/zsmalloc.c | 1 -
>  1 file changed, 1 deletion(-)
> 
> diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
> index b6d4f25..a93327e 100644
> --- a/mm/zsmalloc.c
> +++ b/mm/zsmalloc.c
> @@ -57,7 +57,6 @@
>  #include <linux/slab.h>
>  #include <asm/tlbflush.h>
>  #include <asm/pgtable.h>
> -#include <linux/cpumask.h>
>  #include <linux/cpu.h>
>  #include <linux/vmalloc.h>
>  #include <linux/preempt.h>

NAK. I don't think it's "unused".

zs_register_cpu_notifier()
	for_each_online_cpu()


which is coming from include/linux/cpumask.h

#define for_each_online_cpu(cpu)   for_each_cpu((cpu), cpu_online_mask)

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
