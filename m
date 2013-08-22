Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx201.postini.com [74.125.245.201])
	by kanga.kvack.org (Postfix) with SMTP id 9B6C86B0033
	for <linux-mm@kvack.org>; Wed, 21 Aug 2013 23:02:52 -0400 (EDT)
Date: Wed, 21 Aug 2013 23:02:42 -0400
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Message-ID: <1377140562-vx0ifft7-mutt-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <CAPgLHd8+CD8iNZ4d7OJgc-jqd4ObgLnE0WmkGM5S98Q1TtTROQ@mail.gmail.com>
References: <CAPgLHd8+CD8iNZ4d7OJgc-jqd4ObgLnE0WmkGM5S98Q1TtTROQ@mail.gmail.com>
Subject: Re: [PATCH -next] mm/page_alloc.c: remove duplicated include from
 page_alloc.c
Mime-Version: 1.0
Content-Type: text/plain;
 charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Yongjun <weiyj.lk@gmail.com>
Cc: akpm@linux-foundation.org, mgorman@suse.de, jiang.liu@huawei.com, cody@linux.vnet.ibm.com, minchan@kernel.org, yongjun_wei@trendmicro.com.cn, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Aug 22, 2013 at 10:47:27AM +0800, Wei Yongjun wrote:
> From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
> 
> Remove duplicated include.
> 
> Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
> ---
>  mm/page_alloc.c | 1 -
>  1 file changed, 1 deletion(-)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index efb2ffa..4751901 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -60,7 +60,6 @@
>  #include <linux/page-debug-flags.h>
>  #include <linux/hugetlb.h>
>  #include <linux/sched/rt.h>
> -#include <linux/hugetlb.h>
>  
>  #include <asm/sections.h>
>  #include <asm/tlbflush.h>
> 

That's my fault. Thank you for fixing.

Reviewed-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
