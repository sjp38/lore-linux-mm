Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f171.google.com (mail-pd0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id B275F6B0032
	for <linux-mm@kvack.org>; Wed, 25 Mar 2015 20:27:10 -0400 (EDT)
Received: by pdbcz9 with SMTP id cz9so44700478pdb.3
        for <linux-mm@kvack.org>; Wed, 25 Mar 2015 17:27:10 -0700 (PDT)
Received: from mail-pa0-x233.google.com (mail-pa0-x233.google.com. [2607:f8b0:400e:c03::233])
        by mx.google.com with ESMTPS id ia1si5768739pbc.241.2015.03.25.17.27.09
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 25 Mar 2015 17:27:09 -0700 (PDT)
Received: by pacwe9 with SMTP id we9so45384666pac.1
        for <linux-mm@kvack.org>; Wed, 25 Mar 2015 17:27:09 -0700 (PDT)
Date: Thu, 26 Mar 2015 09:27:17 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [withdrawn]
 zsmalloc-remove-extra-cond_resched-in-__zs_compact.patch removed from -mm
 tree
Message-ID: <20150326002717.GA1669@swordfish>
References: <5513199f.t25SPuX5ULuM6JS8%akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5513199f.t25SPuX5ULuM6JS8%akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: minchan@kernel.org
Cc: akpm@linux-foundation.org, sergey.senozhatsky@gmail.com, ngupta@vflare.org, sfr@canb.auug.org.au, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On (03/25/15 13:25), akpm@linux-foundation.org wrote:
> The patch titled
>      Subject: zsmalloc: remove extra cond_resched() in __zs_compact
> has been removed from the -mm tree.  Its filename was
>      zsmalloc-remove-extra-cond_resched-in-__zs_compact.patch
> 
> This patch was dropped because it was withdrawn
> 
> ------------------------------------------------------
> From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
> Subject: zsmalloc: remove extra cond_resched() in __zs_compact
> 
> Do not perform cond_resched() before the busy compaction loop in
> __zs_compact(), because this loop does it when needed.
> 
> Signed-off-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
> Cc: Minchan Kim <minchan@kernel.org>
> Cc: Nitin Gupta <ngupta@vflare.org>
> Cc: Stephen Rothwell <sfr@canb.auug.org.au>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> ---
> 
>  mm/zsmalloc.c |    2 --
>  1 file changed, 2 deletions(-)
> 
> diff -puN mm/zsmalloc.c~zsmalloc-remove-extra-cond_resched-in-__zs_compact mm/zsmalloc.c
> --- a/mm/zsmalloc.c~zsmalloc-remove-extra-cond_resched-in-__zs_compact
> +++ a/mm/zsmalloc.c
> @@ -1717,8 +1717,6 @@ static unsigned long __zs_compact(struct
>  	struct page *dst_page = NULL;
>  	unsigned long nr_total_migrated = 0;
>  
> -	cond_resched();
> -
>  	spin_lock(&class->lock);
>  	while ((src_page = isolate_source_page(class))) {
>  

Hello,

Minchan, did I miss your NACK on this patch? or could you please ACK it?

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
