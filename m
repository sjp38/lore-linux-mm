Date: Mon, 25 Mar 2002 16:05:51 -0600
From: Art Haas <ahaas@neosoft.com>
Subject: Re: [PATCH] latest radix-tree pagecache patch and 2.4.19-pre3-ac6
Message-ID: <20020325160551.B1424@debian>
References: <20020325114947.A606@debian> <20020325194317.A31878@caldera.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20020325194317.A31878@caldera.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Hellwig <hch@caldera.de>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Mar 25, 2002 at 07:43:18PM +0100, Christoph Hellwig wrote:
>
> [ ... my comments ... ]
> 
> I think I have found at least once obvious bug:
> 
>  a) this cannot actually compile, pagecache_lock is gone..
>  b) find_get_page already does locking internally AND also
>     grabs a reference to the page.
> 
> This should probably be just a radix_tree_lookup()
> 
> @@ -1064,7 +999,7 @@
>  	spin_lock(&pagemap_lru_lock);
>  	while (--index >= start) {
>  		spin_lock(&pagecache_lock);
> -		page = __find_page(mapping, index);
> +		page = find_get_page(mapping, index);
>  		spin_unlock(&pagecache_lock);
>  		if (!page || !PageActive(page))
>  			break;
> 

The file does compile, and my kernel running now does have
the changes I've made. I must be picking up the variable
from somewhere else, and I can't say where that is right
now. Hmmmm ....

Thanks for looking over the patch. I'll make the change
and try things out. Thanks again for working on the radix-tree
patches!

-- 
They that can give up essential liberty to obtain a little temporary
safety deserve neither liberty nor safety.
 -- Benjamin Franklin, Historical Review of Pennsylvania, 1759
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
