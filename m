Date: Mon, 14 May 2007 11:01:43 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 1/2] Have kswapd keep a minimum order free other than
 order-0
In-Reply-To: <20070514173238.6787.57003.sendpatchset@skynet.skynet.ie>
Message-ID: <Pine.LNX.4.64.0705141058590.11319@schroedinger.engr.sgi.com>
References: <20070514173218.6787.56089.sendpatchset@skynet.skynet.ie>
 <20070514173238.6787.57003.sendpatchset@skynet.skynet.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: apw@shadowen.org, nicolas.mailhot@laposte.net, akpm@linux-foundation.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 14 May 2007, Mel Gorman wrote:

> +++ linux-2.6.21-mm2-001_kswapd_minorder/mm/slub.c	2007-05-14 17:09:39.000000000 +0100
> @@ -2131,6 +2131,7 @@ static struct kmem_cache *kmalloc_caches
>  static int __init setup_slub_min_order(char *str)
>  {
>  	get_option (&str, &slub_min_order);
> +	raise_kswapd_order(slub_min_order);
>  	user_override = 1;
>  	return 1;
>  }

You need to do this for slub_max_order not for slub_min_order. Also the
slub_max_order may not necessarily be used. It is just the maximum allowed 
order. I could maintain a slub_max_used_order variable. When that is 
increased I could call raise_kswapd_order?

The same call needs to be put into kmem_cache_init? Or is this only for 
orders > 3?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
