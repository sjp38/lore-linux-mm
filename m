Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f200.google.com (mail-yw0-f200.google.com [209.85.161.200])
	by kanga.kvack.org (Postfix) with ESMTP id A7DC86B025F
	for <linux-mm@kvack.org>; Mon, 18 Sep 2017 10:04:07 -0400 (EDT)
Received: by mail-yw0-f200.google.com with SMTP id s62so856074ywg.3
        for <linux-mm@kvack.org>; Mon, 18 Sep 2017 07:04:07 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id i82sor3135398iod.237.2017.09.18.07.04.06
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 18 Sep 2017 07:04:06 -0700 (PDT)
Subject: Re: [PATCH] bdi: fix cleanup when fail to percpu_counter_init
References: <20170915182700.GA2489@localhost.didichuxing.com>
From: Jens Axboe <axboe@kernel.dk>
Message-ID: <21c323b8-7ec4-518f-5fe5-3ed724506c31@kernel.dk>
Date: Mon, 18 Sep 2017 08:04:04 -0600
MIME-Version: 1.0
In-Reply-To: <20170915182700.GA2489@localhost.didichuxing.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: weiping zhang <zhangweiping@didichuxing.com>, jack@suse.cz, tj@kernel.org
Cc: linux-mm@kvack.org

On 09/15/2017 12:27 PM, weiping zhang wrote:
> when percpu_counter_init fail at i, 0 ~ (i-1) should be destoried, not
> 1 ~ i.
> 
> Signed-off-by: weiping zhang <zhangweiping@didichuxing.com>
> ---
>  mm/backing-dev.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/mm/backing-dev.c b/mm/backing-dev.c
> index e19606b..d399d3c 100644
> --- a/mm/backing-dev.c
> +++ b/mm/backing-dev.c
> @@ -334,7 +334,7 @@ static int wb_init(struct bdi_writeback *wb, struct backing_dev_info *bdi,
>  	return 0;
>  
>  out_destroy_stat:
> -	while (i--)
> +	while (--i >= 0)

These two constructs will produce identical results.

-- 
Jens Axboe

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
