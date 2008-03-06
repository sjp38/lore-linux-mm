From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: [patch 8/8] Pageflags: Eliminate PG_xxx aliases
Date: Thu, 6 Mar 2008 13:40:22 +1100
References: <20080305223815.574326323@sgi.com> <20080305223846.780991734@sgi.com>
In-Reply-To: <20080305223846.780991734@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200803061340.22990.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, ak@suse.de, Mel Gorman <mel@csn.ul.ie>, apw@shadowen.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thursday 06 March 2008 09:38, Christoph Lameter wrote:
> Remove aliases of PG_xxx. We can easily drop those now and alias by
> specifying the PG_xxx flag in the macro that generates the functions.
>
> Signed-off-by: Christoph Lameter <clameter@sgi.com>
>
> ---
>  include/linux/page-flags.h |   10 +++-------
>  mm/page_alloc.c            |    2 +-
>  2 files changed, 4 insertions(+), 8 deletions(-)
>
> Index: linux-2.6.25-rc3-mm1/mm/page_alloc.c
> ===================================================================
> --- linux-2.6.25-rc3-mm1.orig/mm/page_alloc.c	2008-03-05 14:17:09.963838055
> -0800 +++ linux-2.6.25-rc3-mm1/mm/page_alloc.c	2008-03-05
> 14:21:45.372755277 -0800 @@ -650,7 +650,7 @@ static int
> prep_new_page(struct page *pa
>  	if (PageReserved(page))
>  		return 1;
>
> -	page->flags &= ~(1 << PG_uptodate | 1 << PG_error | 1 << PG_readahead |
> +	page->flags &= ~(1 << PG_uptodate | 1 << PG_error | 1 << PG_reclaim |
>  			1 << PG_referenced | 1 << PG_arch_1 |
>  			1 << PG_owner_priv_1 | 1 << PG_mappedtodisk);
>  	set_page_private(page, 0);
> Index: linux-2.6.25-rc3-mm1/include/linux/page-flags.h
> ===================================================================
> --- linux-2.6.25-rc3-mm1.orig/include/linux/page-flags.h	2008-03-05
> 14:21:29.689386158 -0800 +++
> linux-2.6.25-rc3-mm1/include/linux/page-flags.h	2008-03-05
> 14:21:45.372755277 -0800 @@ -77,8 +77,6 @@ enum pageflags {
>  	PG_active,
>  	PG_slab,
>  	PG_owner_priv_1,	/* Owner use. If pagecache, fs may use*/
> -	PG_checked = PG_owner_priv_1, /* Used by some filesystems */
> -	PG_pinned = PG_owner_priv_1, /* Xen pinned pagetable */
>  	PG_arch_1,
>  	PG_reserved,
>  	PG_private,		/* If pagecache, has fs-private data */
> @@ -87,8 +85,6 @@ enum pageflags {
>  	PG_swapcache,		/* Swap page: swp_entry_t in private */
>  	PG_mappedtodisk,	/* Has blocks allocated on-disk */
>  	PG_reclaim,		/* To be reclaimed asap */
> -	/* PG_readahead is only used for file reads; PG_reclaim is only for
> writes */ -	PG_readahead = PG_reclaim, /* Reminder to do async read-ahead
> */ PG_buddy,		/* Page is free, on buddy lists */

IMO it's nice to see these alias up front.

Otherwise the patchset looks pretty good, nice work. I actually hate
macros for generating things, but I try to pick my fights ;)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
