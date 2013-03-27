Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx108.postini.com [74.125.245.108])
	by kanga.kvack.org (Postfix) with SMTP id 3C00F6B0002
	for <linux-mm@kvack.org>; Wed, 27 Mar 2013 13:13:40 -0400 (EDT)
Date: Wed, 27 Mar 2013 18:13:38 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: mm: page_alloc: avoid marking zones full prematurely after
 zone_reclaim()
Message-ID: <20130327171338.GP16579@dhcp22.suse.cz>
References: <20130327060141.GA23703@longonot.mountain>
 <20130327165556.GA22966@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130327165556.GA22966@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Carpenter <dan.carpenter@oracle.com>
Cc: mgorman@suse.de, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>

And just for record. I wanted to give credit to Dan for reporting this
but I have no idea how when this gets merged into the original patch
which is still sitting in the -mm queue. I will leave that to Andrew ;)

On Wed 27-03-13 17:55:56, Michal Hocko wrote:
> From b60e75c65b855a0df827a28a509e6761b4cf45dd Mon Sep 17 00:00:00 2001
> From: Michal Hocko <mhocko@suse.cz>
> Date: Wed, 27 Mar 2013 17:53:09 +0100
> Subject: [PATCH] mm:
>  mm-page_alloc-avoid-marking-zones-full-prematurely-after-zone_reclaim-fix
> 
> Dan Carpenter has reported that (alloc_flags & ALLOC_WMARK_MIN) test
> doesn't make much sense as the flag is 0 and it is in fact intended for
> wmark indexing rather than being used as a flag.
> 
> Signed-off-by: Michal Hocko <mhocko@suse.cz>
> ---
>  mm/page_alloc.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index aa4b5c2..071e66a 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -1953,7 +1953,7 @@ zonelist_scan:
>  				 * when the watermark is between the low and
>  				 * min watermarks.
>  				 */
> -				if ((alloc_flags & ALLOC_WMARK_MIN) ||
> +				if (((alloc_flags & ALLOC_WMARK_MASK) == ALLOC_WMARK_MIN) ||
>  				    ret == ZONE_RECLAIM_SOME)
>  					goto this_zone_full;
>  
> -- 
> 1.7.10.4
> 
> -- 
> Michal Hocko
> SUSE Labs
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
