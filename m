Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id 59E386B0038
	for <linux-mm@kvack.org>; Mon,  2 Feb 2015 23:53:50 -0500 (EST)
Received: by mail-pa0-f48.google.com with SMTP id ey11so91408364pad.7
        for <linux-mm@kvack.org>; Mon, 02 Feb 2015 20:53:50 -0800 (PST)
Received: from mail-pa0-x229.google.com (mail-pa0-x229.google.com. [2607:f8b0:400e:c03::229])
        by mx.google.com with ESMTPS id yt1si1075496pab.64.2015.02.02.20.53.49
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 02 Feb 2015 20:53:49 -0800 (PST)
Received: by mail-pa0-f41.google.com with SMTP id kq14so91368085pab.0
        for <linux-mm@kvack.org>; Mon, 02 Feb 2015 20:53:49 -0800 (PST)
Date: Tue, 3 Feb 2015 13:53:48 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH] zram: check bd_openers instead bd_holders
Message-ID: <20150203045348.GC454@swordfish>
References: <20150203045046.GA13771@blaptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150203045046.GA13771@blaptop>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Nitin Gupta <ngupta@vflare.org>, Jerome Marchand <jmarchan@redhat.com>, Ganesh Mahendran <opensource.ganesh@gmail.com>

On (02/03/15 13:50), Minchan Kim wrote:
> Signed-off-by: Minchan Kim <minchan@kernel.org>

Acked-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

> ---
>  drivers/block/zram/zram_drv.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/drivers/block/zram/zram_drv.c b/drivers/block/zram/zram_drv.c
> index a32069f98afa..cc0e6a3ddb4f 100644
> --- a/drivers/block/zram/zram_drv.c
> +++ b/drivers/block/zram/zram_drv.c
> @@ -811,7 +811,7 @@ static ssize_t reset_store(struct device *dev,
>  
>  	mutex_lock(&bdev->bd_mutex);
>  	/* Do not reset an active device! */
> -	if (bdev->bd_holders) {
> +	if (bdev->bd_openers) {
>  		ret = -EBUSY;
>  		goto out;
>  	}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
