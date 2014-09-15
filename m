Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id 25B8F6B0035
	for <linux-mm@kvack.org>; Mon, 15 Sep 2014 02:51:44 -0400 (EDT)
Received: by mail-pa0-f49.google.com with SMTP id lf10so5670874pab.8
        for <linux-mm@kvack.org>; Sun, 14 Sep 2014 23:51:43 -0700 (PDT)
Received: from lgemrelse6q.lge.com (LGEMRELSE6Q.lge.com. [156.147.1.121])
        by mx.google.com with ESMTP id c2si10278411pdj.97.2014.09.14.23.51.41
        for <linux-mm@kvack.org>;
        Sun, 14 Sep 2014 23:51:43 -0700 (PDT)
Date: Mon, 15 Sep 2014 15:51:52 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH] mm: correct comment for fullness group computation in
 zsmalloc.c
Message-ID: <20140915065152.GL2160@bbox>
References: <1410681467-13891-1-git-send-email-shhuiw@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <1410681467-13891-1-git-send-email-shhuiw@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wang Sheng-Hui <shhuiw@gmail.com>
Cc: ngupta@vflare.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>

On Sun, Sep 14, 2014 at 03:57:47PM +0800, Wang Sheng-Hui wrote:
> The letter 'f' in "n <= N/f" stands for fullness_threshold_frac, not
> 1/fullness_threshold_frac.
> 
> Signed-off-by: Wang Sheng-Hui <shhuiw@gmail.com>
Acked-by: Minchan Kim <minchan@kernel.org>

Thanks.

> ---
>  mm/zsmalloc.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
> index 94f38fa..287a8dc 100644
> --- a/mm/zsmalloc.c
> +++ b/mm/zsmalloc.c
> @@ -175,7 +175,7 @@ enum fullness_group {
>   *	n <= N / f, where
>   * n = number of allocated objects
>   * N = total number of objects zspage can store
> - * f = 1/fullness_threshold_frac
> + * f = fullness_threshold_frac
>   *
>   * Similarly, we assign zspage to:
>   *	ZS_ALMOST_FULL	when n > N / f
> -- 
> 1.8.3.2
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
