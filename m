Date: Fri, 18 May 2007 11:21:12 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH] MM : alloc_large_system_hash() can free some memory for
 non power-of-two bucketsize
In-Reply-To: <20070518115454.d3e32f4d.dada1@cosmosbay.com>
Message-ID: <Pine.LNX.4.64.0705181118530.11881@schroedinger.engr.sgi.com>
References: <20070518115454.d3e32f4d.dada1@cosmosbay.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Eric Dumazet <dada1@cosmosbay.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, linux kernel <linux-kernel@vger.kernel.org>, David Miller <davem@davemloft.net>
List-ID: <linux-mm.kvack.org>

On Fri, 18 May 2007, Eric Dumazet wrote:

>  			table = (void*) __get_free_pages(GFP_ATOMIC, order);

ATOMIC? Is there some reason why we need atomic here?

> +			/*
> +			 * If bucketsize is not a power-of-two, we may free
> +			 * some pages at the end of hash table.
> +			 */
> +			if (table) {
> +				unsigned long alloc_end = (unsigned long)table +
> +						(PAGE_SIZE << order);
> +				unsigned long used = (unsigned long)table +
> +						PAGE_ALIGN(size);
> +				while (used < alloc_end) {
> +					free_page(used);

Isnt this going to interfere with the kernel_map_pages debug stuff?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
