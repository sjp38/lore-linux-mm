Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx145.postini.com [74.125.245.145])
	by kanga.kvack.org (Postfix) with SMTP id 9F22D6B0031
	for <linux-mm@kvack.org>; Mon,  1 Jul 2013 12:36:24 -0400 (EDT)
Received: by mail-pb0-f42.google.com with SMTP id un1so5069605pbc.15
        for <linux-mm@kvack.org>; Mon, 01 Jul 2013 09:36:23 -0700 (PDT)
Message-ID: <51D1AFFB.4010307@gmail.com>
Date: Tue, 02 Jul 2013 00:36:11 +0800
From: Zhang Yanfei <zhangyanfei.yes@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm, slab: Drop unnecessary slabp->inuse < cachep->num
 test
References: <51D1AE84.8010404@gmail.com>
In-Reply-To: <51D1AE84.8010404@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: penberg@kernel.org, cl@linux-foundation.org, mpm@selenic.com
Cc: Linux MM <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>

Sorry for making noise. I've made a mistake and please ignore this patch.

On 07/02/2013 12:29 AM, Zhang Yanfei wrote:
> From: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
> 
> In function cache_alloc_refill, we have used BUG_ON to ensure
> that slabp->inuse is less than cachep->num before the while
> test. And in the while body, we do not change the value of
> slabp->inuse and cachep->num, so it is not necessary to test
> if slabp->inuse < cachep->num test for every loop.
> 
> Signed-off-by: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
> ---
>  mm/slab.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/mm/slab.c b/mm/slab.c
> index 8ccd296..c2076c2 100644
> --- a/mm/slab.c
> +++ b/mm/slab.c
> @@ -3004,7 +3004,7 @@ retry:
>  		 */
>  		BUG_ON(slabp->inuse >= cachep->num);
>  
> -		while (slabp->inuse < cachep->num && batchcount--) {
> +		while (batchcount--) {
>  			STATS_INC_ALLOCED(cachep);
>  			STATS_INC_ACTIVE(cachep);
>  			STATS_SET_HIGH(cachep);


-- 
Thanks.
Zhang Yanfei

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
