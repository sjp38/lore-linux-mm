Date: Wed, 23 Mar 2005 09:00:49 -0500
From: Martin Hicks <mort@bork.org>
Subject: Re: [PATCH] min_free_kbytes limit
Message-ID: <20050323140049.GC19113@localhost>
References: <2c1942a7050323033448e3b26f@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <2c1942a7050323033448e3b26f@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Levent Serinol <lserinol@gmail.com>
Cc: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, Mar 23, 2005 at 01:34:19PM +0200, Levent Serinol wrote:
> =================================================================
> --- linux-2.6.11.4/mm/page_alloc.c.org  2005-03-16 02:09:27.000000000 +0200
> +++ linux-2.6.11.4/mm/page_alloc.c      2005-03-23 13:13:47.000000000 +0200
> @@ -1946,11 +1946,16 @@ static void setup_per_zone_lowmem_reserv
>   */
>  static void setup_per_zone_pages_min(void)
>  {
> -       unsigned long pages_min = min_free_kbytes >> (PAGE_SHIFT - 10);
> +       unsigned long pages_min;
>         unsigned long lowmem_pages = 0;
>         struct zone *zone;
>         unsigned long flags;
> 
> +       if (min_free_kbytes < 128)
> +                min_free_kbytes = 128;
> +        if (min_free_kbytes > 65536)
> +                min_free_kbytes = 65536;
> +       pages_min = min_free_kbytes >> (PAGE_SHIFT - 10);


Who says 65MB of free ram is enough?   Where did you get these numbers
from?

mh

>         /* Calculate total number of !ZONE_HIGHMEM pages */
>         for_each_zone(zone) {
>                 if (!is_highmem(zone))
> =================================================================
> -- 
> 
> Stay out of the road, if you want to grow old. 
> ~ Pink Floyd ~.
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

-- 
Martin Hicks || mort@bork.org || PGP/GnuPG: 0x4C7F2BEE
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
