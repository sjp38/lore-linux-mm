Message-ID: <480F600B.9000802@cray.com>
Date: Wed, 23 Apr 2008 11:12:59 -0500
From: Andrew Hastings <abh@cray.com>
MIME-Version: 1.0
Subject: Re: [patch 11/18] mm: export prep_compound_page to mm
References: <20080423015302.745723000@nick.local0.net> <20080423015430.814185000@nick.local0.net>
In-Reply-To: <20080423015430.814185000@nick.local0.net>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: npiggin@suse.de
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, andi@firstfloor.org, kniht@linux.vnet.ibm.com, nacc@us.ibm.com, wli@holomorphy.com
List-ID: <linux-mm.kvack.org>

npiggin@suse.de wrote:
> hugetlb will need to get compound pages from bootmem to handle
> the case of them being larger than MAX_ORDER. Export

s/larger/greater than or equal to/

> the constructor function needed for this.
> 
> Signed-off-by: Andi Kleen <ak@suse.de>
> Signed-off-by: Nick Piggin <npiggin@suse.de>
> ---
>  mm/internal.h   |    2 ++
>  mm/page_alloc.c |    2 +-
>  2 files changed, 3 insertions(+), 1 deletion(-)
> 
> Index: linux-2.6/mm/internal.h
> ===================================================================
> --- linux-2.6.orig/mm/internal.h
> +++ linux-2.6/mm/internal.h
> @@ -13,6 +13,8 @@
>  
>  #include <linux/mm.h>
>  
> +extern void prep_compound_page(struct page *page, unsigned long order);
> +
>  static inline void set_page_count(struct page *page, int v)
>  {
>  	atomic_set(&page->_count, v);
> Index: linux-2.6/mm/page_alloc.c
> ===================================================================
> --- linux-2.6.orig/mm/page_alloc.c
> +++ linux-2.6/mm/page_alloc.c
> @@ -272,7 +272,7 @@ static void free_compound_page(struct pa
>  	__free_pages_ok(page, compound_order(page));
>  }
>  
> -static void prep_compound_page(struct page *page, unsigned long order)
> +void prep_compound_page(struct page *page, unsigned long order)
>  {
>  	int i;
>  	int nr_pages = 1 << order;
> 

-Andrew Hastings
  Cray Inc.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
