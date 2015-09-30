Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id B9DB66B0257
	for <linux-mm@kvack.org>; Wed, 30 Sep 2015 06:33:55 -0400 (EDT)
Received: by pacex6 with SMTP id ex6so37291938pac.0
        for <linux-mm@kvack.org>; Wed, 30 Sep 2015 03:33:55 -0700 (PDT)
Received: from heian.cn.fujitsu.com ([59.151.112.132])
        by mx.google.com with ESMTP id ir5si608692pbb.212.2015.09.30.03.33.33
        for <linux-mm@kvack.org>;
        Wed, 30 Sep 2015 03:33:54 -0700 (PDT)
Message-ID: <560BBA12.5090102@cn.fujitsu.com>
Date: Wed, 30 Sep 2015 18:31:46 +0800
From: Tang Chen <tangchen@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: fix overflow in find_zone_movable_pfns_for_nodes()
References: <560BAC76.6050002@huawei.com>
In-Reply-To: <560BAC76.6050002@huawei.com>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xishi Qiu <qiuxishi@huawei.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, zhongjiang@huawei.com, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
Cc: Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, tangchen@cn.fujitsu.com


Seems OK to me.

Thanks.

On 09/30/2015 05:33 PM, Xishi Qiu wrote:
> If user set "movablecore=xx" to a large number, corepages will overflow,
> this patch fix the problem.
>
> Signed-off-by: Xishi Qiu <qiuxishi@huawei.com>
> ---
>   mm/page_alloc.c | 1 +
>   1 file changed, 1 insertion(+)
>
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 48aaf7b..af3c9bd 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -5668,6 +5668,7 @@ static void __init find_zone_movable_pfns_for_nodes(void)
>   		 */
>   		required_movablecore =
>   			roundup(required_movablecore, MAX_ORDER_NR_PAGES);
> +		required_movablecore = min(totalpages, required_movablecore);
>   		corepages = totalpages - required_movablecore;
>   
>   		required_kernelcore = max(required_kernelcore, corepages);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
