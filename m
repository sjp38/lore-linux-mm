Date: Mon, 16 May 2005 16:38:08 -0700 (PDT)
From: Christoph Lameter <clameter@engr.sgi.com>
Subject: Re: [PATCH] fix for mm counters to macros conversion
In-Reply-To: <Pine.LNX.4.61.0505162318310.9392@maxipes.logix.cz>
Message-ID: <Pine.LNX.4.62.0505161637300.3702@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.61.0505162318310.9392@maxipes.logix.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Michal Ludvig <michal@logix.cz>
Cc: Andrew Morton <akpm@osdl.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Ok. This is third or fourth time this patch was posted. I thought this 
already went in?

On Mon, 16 May 2005, Michal Ludvig wrote:

> Hi,
> 
> The patch of Christoph Lameter sent on March 15 contains this in
> mm/rmap.c:try_to_unmap_one() around line 590:
> 
> -	mm->rss--;
> +	inc_mm_counter(mm, rss);
> 
> I wonder if it was an intent to change dec to inc? In all other places the 
> conversion conforms to the previous operation except for this one. Perhaps 
> the following patch should be applied...
> 
> Signed-off-by: Michal Ludvig <michal@logix.cz>
> 
> 
> Index: linux-2.6.12-rc4/mm/rmap.c
> ===================================================================
> --- linux-2.6.12-rc4.orig/mm/rmap.c	2005-05-07 17:20:31.000000000 +1200
> +++ linux-2.6.12-rc4/mm/rmap.c	2005-05-17 11:16:40.716223000 +1200
> @@ -586,7 +586,7 @@
>  		dec_mm_counter(mm, anon_rss);
>  	}
>  
> -	inc_mm_counter(mm, rss);
> +	dec_mm_counter(mm, rss);
>  	page_remove_rmap(page);
>  	page_cache_release(page);
>  
> 
> 
> 
> Michal Ludvig
> -- 
> * Personal homepage - http://www.logix.cz/michal
> 
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
