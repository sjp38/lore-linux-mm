Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f173.google.com (mail-io0-f173.google.com [209.85.223.173])
	by kanga.kvack.org (Postfix) with ESMTP id 278BD6B025D
	for <linux-mm@kvack.org>; Thu, 24 Sep 2015 02:45:35 -0400 (EDT)
Received: by ioii196 with SMTP id i196so67310024ioi.3
        for <linux-mm@kvack.org>; Wed, 23 Sep 2015 23:45:35 -0700 (PDT)
Received: from mail-pa0-x234.google.com (mail-pa0-x234.google.com. [2607:f8b0:400e:c03::234])
        by mx.google.com with ESMTPS id g7si3415650igq.93.2015.09.23.23.45.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 23 Sep 2015 23:45:34 -0700 (PDT)
Received: by pacfv12 with SMTP id fv12so65228787pac.2
        for <linux-mm@kvack.org>; Wed, 23 Sep 2015 23:45:33 -0700 (PDT)
Date: Thu, 24 Sep 2015 15:46:20 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH v2] zsmalloc: add comments for ->inuse to zspage
Message-ID: <20150924064620.GC626@swordfish>
References: <1443075194-26291-1-git-send-email-zhuhui@xiaomi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1443075194-26291-1-git-send-email-zhuhui@xiaomi.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hui Zhu <zhuhui@xiaomi.com>
Cc: minchan@kernel.org, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, teawater@gmail.com, sergey.senozhatsky@gmail.com

Cc Andrew

On (09/24/15 14:13), Hui Zhu wrote:
> Signed-off-by: Hui Zhu <zhuhui@xiaomi.com>

Reviewed-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

	-ss

> ---
>  mm/zsmalloc.c | 1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
> index f135b1b..f62f2fb 100644
> --- a/mm/zsmalloc.c
> +++ b/mm/zsmalloc.c
> @@ -38,6 +38,7 @@
>   *	page->lru: links together first pages of various zspages.
>   *		Basically forming list of zspages in a fullness group.
>   *	page->mapping: class index and fullness group of the zspage
> + *	page->inuse: the objects number that is used in this zspage
>   *
>   * Usage of struct page flags:
>   *	PG_private: identifies the first component page
> -- 
> 1.9.1
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
