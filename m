Subject: Re: [patch 17/21] non-reclaimable mlocked pages
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <44c63dc40802282055q508af6ccsb0e8ac3fb5e67d24@mail.gmail.com>
References: <20080228192908.126720629@redhat.com>
	 <20080228192929.453373535@redhat.com>
	 <44c63dc40802282055q508af6ccsb0e8ac3fb5e67d24@mail.gmail.com>
Content-Type: text/plain
Date: Fri, 29 Feb 2008 09:47:44 -0500
Message-Id: <1204296464.5311.6.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: minchan Kim <barrioskmc@gmail.com>
Cc: Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 2008-02-29 at 13:55 +0900, minchan Kim wrote:
>         Index: linux-2.6.25-rc2-mm1/mm/page_alloc.c
>         ===================================================================
>         --- linux-2.6.25-rc2-mm1.orig/mm/page_alloc.c   2008-02-28
>         12:47:36.000000000 -0500
>         +++ linux-2.6.25-rc2-mm1/mm/page_alloc.c        2008-02-28
>         12:49:02.000000000 -0500
>         @@ -257,6 +257,7 @@ static void bad_page(struct page *page)
>                                1 << PG_swapcache |
>                                1 << PG_writeback |
>                                1 << PG_swapbacked |
>         +                       1 << PG_mlocked |
>                                1 << PG_buddy );
>                set_page_count(page, 0);
>                reset_page_mapcount(page);
>  
> It would be compile error unless CONFIG_NORECLAIM_MLOCK is defined.  
> 
> 
>         
>         @@ -656,7 +662,9 @@ static int prep_new_page(struct page *pa
>         
>                page->flags &= ~(1 << PG_uptodate | 1 << PG_error | 1
>         << PG_readahead |
>                                1 << PG_referenced | 1 << PG_arch_1 |
>         -                       1 << PG_owner_priv_1 | 1 <<
>         PG_mappedtodisk);
>         +                       1 << PG_owner_priv_1 | 1 <<
>         PG_mappedtodisk |
>         +//TODO take care of it here, for now.
>         +                       1 << PG_mlocked );
>                set_page_private(page, 0);
>                set_page_refcounted(page);
>  
> ditto 

Well, it will be a compile error for 32-bit systems, so we need to fix
it.   PG_mlocked is unconditionally defined/reserved when (BITS_PER_LONG
> 32).

Thanks,
Lee
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
