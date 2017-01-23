Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 692EC6B0033
	for <linux-mm@kvack.org>; Mon, 23 Jan 2017 00:30:43 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id 204so186897556pge.5
        for <linux-mm@kvack.org>; Sun, 22 Jan 2017 21:30:43 -0800 (PST)
Received: from mail-pf0-x242.google.com (mail-pf0-x242.google.com. [2607:f8b0:400e:c00::242])
        by mx.google.com with ESMTPS id f35si14542689plh.192.2017.01.22.21.30.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 22 Jan 2017 21:30:42 -0800 (PST)
Received: by mail-pf0-x242.google.com with SMTP id 19so9257433pfo.3
        for <linux-mm@kvack.org>; Sun, 22 Jan 2017 21:30:42 -0800 (PST)
Date: Mon, 23 Jan 2017 14:30:56 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH v7 11/12] zsmalloc: page migration support
Message-ID: <20170123053056.GB2327@jagdpanzerIV.localdomain>
References: <1464736881-24886-1-git-send-email-minchan@kernel.org>
 <1464736881-24886-12-git-send-email-minchan@kernel.org>
 <CGME20170119001317epcas1p188357c77e1f4ff08b6d3dcb76dedca06@epcas1p1.samsung.com>
 <afd38699-f1c4-f63f-7362-29c514e9ffb4@samsung.com>
 <20170119024421.GA9367@bbox>
 <0a184bbf-0612-5f71-df68-c37500fa1eda@samsung.com>
 <20170119062158.GB9367@bbox>
 <e0e1fcae-d2c4-9068-afa0-b838d57d8dff@samsung.com>
 <20170123052244.GC11763@bbox>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170123052244.GC11763@bbox>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Chulmin Kim <cmlaika.kim@samsung.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

On (01/23/17 14:22), Minchan Kim wrote:
[..]
> > Anyway, I will let you know the situation when it gets more clear.
> 
> Yeb, Thanks.
> 
> Perhaps, did you tried flush page before the writing?
> I think arm64 have no d-cache alising problem but worth to try it.
> Who knows :)

I thought that flush_dcache_page() is only for cases when we write
to page (store that makes pages dirty), isn't it?

	-ss

> diff --git a/drivers/block/zram/zram_drv.c b/drivers/block/zram/zram_drv.c
> index 46da1c4..a3a5520 100644
> --- a/drivers/block/zram/zram_drv.c
> +++ b/drivers/block/zram/zram_drv.c
> @@ -612,6 +612,8 @@ static int zram_bvec_write(struct zram *zram, struct bio_vec *bvec, u32 index,
>  	unsigned long element;
>  
>  	page = bvec->bv_page;
> +	flush_dcache_page(page);
> +
>  	if (is_partial_io(bvec)) {
>  		/*
>  		 * This is a partial IO. We need to read the full page

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
