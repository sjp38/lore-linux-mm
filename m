Date: Mon, 19 May 2008 23:19:37 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: Possible partial miss in pages needed for zone's memory map?
Message-Id: <20080519231937.5fee7cf7.akpm@linux-foundation.org>
In-Reply-To: <87y769f7i4.fsf@saeurebad.de>
References: <87y769f7i4.fsf@saeurebad.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Johannes Weiner <hannes@saeurebad.de>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, 17 May 2008 14:19:15 +0200 Johannes Weiner <hannes@saeurebad.de> wrote:

> Hi,
> 
> I stumbled over the following in the zone initialization code.  Please
> let me know if I overlooked something here.
> 

hm, no takers.  Let's add linux-mm.

> 
> From: Johannes Weiner <hannes@saeurebad.de>
> Subject: [PATCH] Don't drop a partial page in a zone's memory map size
> 
> In a zone's present pages number, account for all pages occupied by the
> memory map, including a partial.
> 
> Signed-off-by: Johannes Weiner <hannes@saeurebad.de>
> ---
> 
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -3378,7 +3378,8 @@ static void __paginginit free_area_init_
>  		 * is used by this zone for memmap. This affects the watermark
>  		 * and per-cpu initialisations
>  		 */
> -		memmap_pages = (size * sizeof(struct page)) >> PAGE_SHIFT;
> +		memmap_pages =
> +			PAGE_ALIGN(size * sizeof(struct page)) >> PAGE_SHIFT;
>  		if (realsize >= memmap_pages) {
>  			realsize -= memmap_pages;
>  			printk(KERN_DEBUG

I looked in there for 30 seconds and collapsed in confusion over which
variables are in which units.

Hint: never ever name a variable or a /proc file or your cat 
or anything else anything dimensionless like "size".  It can always be
replaced with something which communicates its units.  zones_nrbytes,
zholes_nrpages, etc.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
