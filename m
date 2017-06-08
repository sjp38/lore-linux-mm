Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f200.google.com (mail-ot0-f200.google.com [74.125.82.200])
	by kanga.kvack.org (Postfix) with ESMTP id 912166B0372
	for <linux-mm@kvack.org>; Thu,  8 Jun 2017 00:54:51 -0400 (EDT)
Received: by mail-ot0-f200.google.com with SMTP id k68so7763174otc.5
        for <linux-mm@kvack.org>; Wed, 07 Jun 2017 21:54:51 -0700 (PDT)
Received: from szxga03-in.huawei.com (szxga03-in.huawei.com. [45.249.212.189])
        by mx.google.com with ESMTPS id s137si1598309oih.129.2017.06.07.21.54.50
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 07 Jun 2017 21:54:50 -0700 (PDT)
Message-ID: <5938D6CB.70208@huawei.com>
Date: Thu, 8 Jun 2017 12:47:07 +0800
From: zhong jiang <zhongjiang@huawei.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: correct the comment when reclaimed pages exceed the
 scanned pages
References: <1496824266-25235-1-git-send-email-zhongjiang@huawei.com>
In-Reply-To: <1496824266-25235-1-git-send-email-zhongjiang@huawei.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: minchan@kernel.org
Cc: akpm@linux-foundation.org, vinayakm.list@gmail.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 2017/6/7 16:31, zhongjiang wrote:
> The commit e1587a494540 ("mm: vmpressure: fix sending wrong events on
> underflow") declare that reclaimed pages exceed the scanned pages due
> to the thp reclaim. it is incorrect because THP will be spilt to normal
> page and loop again. which will result in the scanned pages increment.
>
> Signed-off-by: zhongjiang <zhongjiang@huawei.com>
> ---
>  mm/vmpressure.c | 5 +++--
>  1 file changed, 3 insertions(+), 2 deletions(-)
>
> diff --git a/mm/vmpressure.c b/mm/vmpressure.c
> index 6063581..0e91ba3 100644
> --- a/mm/vmpressure.c
> +++ b/mm/vmpressure.c
> @@ -116,8 +116,9 @@ static enum vmpressure_levels vmpressure_calc_level(unsigned long scanned,
>  
>  	/*
>  	 * reclaimed can be greater than scanned in cases
> -	 * like THP, where the scanned is 1 and reclaimed
> -	 * could be 512
> +	 * like reclaimed slab pages, shrink_node just add
> +	 * reclaimed page without a related increment to
> +	 * scanned pages.
>  	 */
>  	if (reclaimed >= scanned)
>  		goto out;
Hi, minchan

what  suggstion about  the patch

Thanks
zhongjiang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
