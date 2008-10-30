Message-ID: <4909FBAE.4080002@cs.helsinki.fi>
Date: Thu, 30 Oct 2008 20:23:42 +0200
From: Pekka Enberg <penberg@cs.helsinki.fi>
MIME-Version: 1.0
Subject: Re: [PATCH] slab: unsigned slabp->inuse cannot be less than 0
References: <4908D30F.1020206@gmail.com>
In-Reply-To: <4908D30F.1020206@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: roel kluin <roel.kluin@gmail.com>
Cc: linux-mm@kvack.org, cl@linux-foundation.org
List-ID: <linux-mm.kvack.org>

roel kluin wrote:
> unsigned slabp->inuse cannot be less than 0

Christoph, this is on my to-merge list but an ACK would be nice.

> Signed-off-by: Roel Kluin <roel.kluin@gmail.com>
> ---
> N.B. It could be possible that a different check is needed.
> I may not be able to respond for a few weeks.
> 
> diff --git a/mm/slab.c b/mm/slab.c
> index 0918751..f634a87 100644
> --- a/mm/slab.c
> +++ b/mm/slab.c
> @@ -2997,7 +2997,7 @@ retry:
>  		 * there must be at least one object available for
>  		 * allocation.
>  		 */
> -		BUG_ON(slabp->inuse < 0 || slabp->inuse >= cachep->num);
> +		BUG_ON(slabp->inuse >= cachep->num);
>  
>  		while (slabp->inuse < cachep->num && batchcount--) {
>  			STATS_INC_ALLOCED(cachep);
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
