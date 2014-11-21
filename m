Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id C5E616B006E
	for <linux-mm@kvack.org>; Thu, 20 Nov 2014 22:43:51 -0500 (EST)
Received: by mail-pa0-f50.google.com with SMTP id bj1so3936322pad.37
        for <linux-mm@kvack.org>; Thu, 20 Nov 2014 19:43:51 -0800 (PST)
Received: from lgeamrelo02.lge.com (lgeamrelo02.lge.com. [156.147.1.126])
        by mx.google.com with ESMTP id e16si5933239pdj.196.2014.11.20.19.43.49
        for <linux-mm@kvack.org>;
        Thu, 20 Nov 2014 19:43:50 -0800 (PST)
Date: Fri, 21 Nov 2014 12:43:55 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH] mm/zsmalloc: avoid duplicate assignment of prev_class
Message-ID: <20141121034355.GA10123@bbox>
References: <1416488913-9691-1-git-send-email-opensource.ganesh@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <1416488913-9691-1-git-send-email-opensource.ganesh@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mahendran Ganesh <opensource.ganesh@gmail.com>
Cc: ngupta@vflare.org, iamjoonsoo.kim@lge.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Nov 20, 2014 at 09:08:33PM +0800, Mahendran Ganesh wrote:
> In zs_create_pool(), prev_class is assigned (ZS_SIZE_CLASSES - 1)
> times. And the prev_class only references to the previous alloc
> size_class. So we do not need unnecessary assignement.
> 
> This patch modifies *prev_class* to *prev_alloc_class*. And the
> *prev_alloc_class* will only be assigned when a new size_class
> structure is allocated.
> 
> Signed-off-by: Mahendran Ganesh <opensource.ganesh@gmail.com>
> ---
>  mm/zsmalloc.c |    9 +++++----
>  1 file changed, 5 insertions(+), 4 deletions(-)
> 
> diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
> index b3b57ef..ac2b396 100644
> --- a/mm/zsmalloc.c
> +++ b/mm/zsmalloc.c
> @@ -970,7 +970,7 @@ struct zs_pool *zs_create_pool(gfp_t flags)
>  		int size;
>  		int pages_per_zspage;
>  		struct size_class *class;
> -		struct size_class *prev_class;
> +		struct size_class *uninitialized_var(prev_alloc_class);

https://lkml.org/lkml/2012/10/27/71
In addition, I prefer prev_class.

Thanks.

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
