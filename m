Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f41.google.com (mail-qg0-f41.google.com [209.85.192.41])
	by kanga.kvack.org (Postfix) with ESMTP id 12A7C82F84
	for <linux-mm@kvack.org>; Thu,  1 Oct 2015 16:02:42 -0400 (EDT)
Received: by qgx61 with SMTP id 61so77663143qgx.3
        for <linux-mm@kvack.org>; Thu, 01 Oct 2015 13:02:41 -0700 (PDT)
Received: from mail-qg0-x232.google.com (mail-qg0-x232.google.com. [2607:f8b0:400d:c04::232])
        by mx.google.com with ESMTPS id h4si7090663qgf.120.2015.10.01.13.02.41
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Oct 2015 13:02:41 -0700 (PDT)
Received: by qgev79 with SMTP id v79so77441208qge.0
        for <linux-mm@kvack.org>; Thu, 01 Oct 2015 13:02:41 -0700 (PDT)
Message-ID: <560d9160.0c5b8c0a.eb9c4.169d@mx.google.com>
Date: Thu, 01 Oct 2015 13:02:40 -0700 (PDT)
From: Yasuaki Ishimatsu <yasu.isimatu@gmail.com>
Subject: Re: [PATCH] mm: fix overflow in find_zone_movable_pfns_for_nodes()
In-Reply-To: <560BAC76.6050002@huawei.com>
References: <560BAC76.6050002@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xishi Qiu <qiuxishi@huawei.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Tang Chen <tangchen@cn.fujitsu.com>, zhongjiang@huawei.com, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>


On Wed, 30 Sep 2015 17:33:42 +0800
Xishi Qiu <qiuxishi@huawei.com> wrote:

> If user set "movablecore=xx" to a large number, corepages will overflow,
> this patch fix the problem.
> 
> Signed-off-by: Xishi Qiu <qiuxishi@huawei.com>
> ---

Looks good to me.

Reviewed-by: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>

Thanks,
Yasuaki Ishimatsu

>  mm/page_alloc.c | 1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 48aaf7b..af3c9bd 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -5668,6 +5668,7 @@ static void __init find_zone_movable_pfns_for_nodes(void)
>  		 */
>  		required_movablecore =
>  			roundup(required_movablecore, MAX_ORDER_NR_PAGES);
> +		required_movablecore = min(totalpages, required_movablecore);
>  		corepages = totalpages - required_movablecore;
>  
>  		required_kernelcore = max(required_kernelcore, corepages);
> -- 
> 2.0.0
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
