Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id 23AA36B007B
	for <linux-mm@kvack.org>; Thu, 28 May 2015 23:41:20 -0400 (EDT)
Received: by paza2 with SMTP id a2so39766091paz.3
        for <linux-mm@kvack.org>; Thu, 28 May 2015 20:41:19 -0700 (PDT)
Received: from mail-pa0-x231.google.com (mail-pa0-x231.google.com. [2607:f8b0:400e:c03::231])
        by mx.google.com with ESMTPS id z5si6453584pdo.233.2015.05.28.20.41.19
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 May 2015 20:41:19 -0700 (PDT)
Received: by pabru16 with SMTP id ru16so39656968pab.1
        for <linux-mm@kvack.org>; Thu, 28 May 2015 20:41:19 -0700 (PDT)
Date: Fri, 29 May 2015 12:41:41 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH] zram: clear disk io accounting when reset zram device
Message-ID: <20150529034141.GA1157@swordfish>
References: <"000001d099be$fae6cc90$f0b465b0$@yang"@samsung.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <"000001d099be$fae6cc90$f0b465b0$@yang"@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Weijie Yang <weijie.yang@samsung.com>
Cc: 'Minchan Kim' <minchan@kernel.org>, 'Andrew Morton' <akpm@linux-foundation.org>, sergey.senozhatsky.work@gmail.com, ngupta@vflare.org, 'Weijie Yang' <weijie.yang.kh@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On (05/29/15 11:23), Weijie Yang wrote:
> This patch clears zram disk io accounting when reset the zram device,
> if don't do this, the residual io accounting stat will affect the
> diskstat in the next zram active cycle.
> 

thanks. my bad.

Acked-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

	-ss

> Signed-off-by: Weijie Yang <weijie.yang@samsung.com>
> ---
>  drivers/block/zram/zram_drv.c |    2 ++
>  1 file changed, 2 insertions(+)
> 
> diff --git a/drivers/block/zram/zram_drv.c b/drivers/block/zram/zram_drv.c
> index 8dcbced..6e134f4 100644
> --- a/drivers/block/zram/zram_drv.c
> +++ b/drivers/block/zram/zram_drv.c
> @@ -805,7 +805,9 @@ static void zram_reset_device(struct zram *zram)
>  	memset(&zram->stats, 0, sizeof(zram->stats));
>  	zram->disksize = 0;
>  	zram->max_comp_streams = 1;
> +
>  	set_capacity(zram->disk, 0);
> +	part_stat_set_all(&zram->disk->part0, 0);
>  
>  	up_write(&zram->init_lock);
>  	/* I/O operation under all of CPU are done so let's free */
> -- 
> 1.7.10.4
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
