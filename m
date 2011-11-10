Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id F1F346B0073
	for <linux-mm@kvack.org>; Thu, 10 Nov 2011 15:18:55 -0500 (EST)
Received: by pzk1 with SMTP id 1so1204174pzk.6
        for <linux-mm@kvack.org>; Thu, 10 Nov 2011 12:18:53 -0800 (PST)
Date: Thu, 10 Nov 2011 12:18:50 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch] slub: fix a code merge error
In-Reply-To: <1320912260.22361.247.camel@sli10-conroe>
Message-ID: <alpine.DEB.2.00.1111101218140.21036@chino.kir.corp.google.com>
References: <1320912260.22361.247.camel@sli10-conroe>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaohua Li <shaohua.li@intel.com>
Cc: linux-mm <linux-mm@kvack.org>, penberg@kernel.org, cl@linux-foundation.org

On Thu, 10 Nov 2011, Shaohua Li wrote:

> Looks there is a merge error in the slub tree. DEACTIVATE_TO_TAIL != 1.
> And this will cause performance regression.
> 
> Signed-off-by: Shaohua Li <shaohua.li@intel.com>
> 
> diff --git a/mm/slub.c b/mm/slub.c
> index 7d2a996..60e16c4 100644
> --- a/mm/slub.c
> +++ b/mm/slub.c
> @@ -1904,7 +1904,8 @@ static void unfreeze_partials(struct kmem_cache *s)
>  				if (l == M_PARTIAL)
>  					remove_partial(n, page);
>  				else
> -					add_partial(n, page, 1);
> +					add_partial(n, page,
> +						DEACTIVATE_TO_TAIL);
>  
>  				l = m;
>  			}

Acked-by: David Rientjes <rientjes@google.com>

Not sure where the "merge error" is, though, this is how it was proposed 
on linux-mm each time the patch was posted.  Probably needs a better title 
and changelog.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
