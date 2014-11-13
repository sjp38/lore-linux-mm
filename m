Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id DECAC6B00DA
	for <linux-mm@kvack.org>; Thu, 13 Nov 2014 09:55:14 -0500 (EST)
Received: by mail-pa0-f53.google.com with SMTP id kx10so15200294pab.26
        for <linux-mm@kvack.org>; Thu, 13 Nov 2014 06:55:14 -0800 (PST)
Received: from mail-pd0-x22e.google.com (mail-pd0-x22e.google.com. [2607:f8b0:400e:c02::22e])
        by mx.google.com with ESMTPS id lj12si25973718pab.5.2014.11.13.06.55.13
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 13 Nov 2014 06:55:13 -0800 (PST)
Received: by mail-pd0-f174.google.com with SMTP id p10so14616989pdj.19
        for <linux-mm@kvack.org>; Thu, 13 Nov 2014 06:55:13 -0800 (PST)
Date: Thu, 13 Nov 2014 23:55:33 +0900
From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Subject: Re: [PATCH] mm/zram: correct ZRAM_ZERO flag bit position
Message-ID: <20141113145533.GA1408@swordfish>
References: <1415803038-7913-1-git-send-email-opensource.ganesh@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1415803038-7913-1-git-send-email-opensource.ganesh@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mahendran Ganesh <opensource.ganesh@gmail.com>
Cc: ngupta@vflare.org, minchan@kernel.org, weijie.yang@samsung.com, sergey.senozhatsky@gmail.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On (11/12/14 22:37), Mahendran Ganesh wrote:
> In struct zram_table_entry, the element *value* contains obj size and
> obj zram flags. Bit 0 to bit (ZRAM_FLAG_SHIFT - 1) represent obj size,
> and bit ZRAM_FLAG_SHIFT to the highest bit of unsigned long represent obj
> zram_flags. So the first zram flag(ZRAM_ZERO) should be from ZRAM_FLAG_SHIFT
> instead of (ZRAM_FLAG_SHIFT + 1).
> 
> This patch fixes this issue.

well, I wouldn't say this is an issue; but still.

Acked-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

	-ss

> Also this patch fixes a typo, "page in now accessed" -> "page is now accessed"
> 
> Signed-off-by: Mahendran Ganesh <opensource.ganesh@gmail.com>
> ---
>  drivers/block/zram/zram_drv.h |    4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/block/zram/zram_drv.h b/drivers/block/zram/zram_drv.h
> index c6ee271..b05a816 100644
> --- a/drivers/block/zram/zram_drv.h
> +++ b/drivers/block/zram/zram_drv.h
> @@ -66,8 +66,8 @@ static const size_t max_zpage_size = PAGE_SIZE / 4 * 3;
>  /* Flags for zram pages (table[page_no].value) */
>  enum zram_pageflags {
>  	/* Page consists entirely of zeros */
> -	ZRAM_ZERO = ZRAM_FLAG_SHIFT + 1,
> -	ZRAM_ACCESS,	/* page in now accessed */
> +	ZRAM_ZERO = ZRAM_FLAG_SHIFT,
> +	ZRAM_ACCESS,	/* page is now accessed */
>  
>  	__NR_ZRAM_PAGEFLAGS,
>  };
> -- 
> 1.7.9.5
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
