Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id EB9F76B00A3
	for <linux-mm@kvack.org>; Tue, 26 Jan 2010 13:38:43 -0500 (EST)
Date: Tue, 26 Jan 2010 18:38:20 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 05 of 31] fix bad_page to show the real reason the page
	is bad
Message-ID: <20100126183819.GJ16468@csn.ul.ie>
References: <patchbomb.1264513915@v2.random> <b64fb7a441f9ce407cc4.1264513920@v2.random>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <b64fb7a441f9ce407cc4.1264513920@v2.random>
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Andi Kleen <andi@firstfloor.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, Andrew Morton <akpm@linux-foundation.org>, bpicco@redhat.com, Christoph Hellwig <chellwig@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Tue, Jan 26, 2010 at 02:52:00PM +0100, Andrea Arcangeli wrote:
> From: Andrea Arcangeli <aarcange@redhat.com>
> 
> page_count shows the count of the head page, but the actual check is done on
> the tail page, so show what is really being checked.
> 
> Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>

Acked-by: Mel Gorman <mel@csn.ul.ie>

> ---
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -265,7 +265,7 @@ static void bad_page(struct page *page)
>  		current->comm, page_to_pfn(page));
>  	printk(KERN_ALERT
>  		"page:%p flags:%p count:%d mapcount:%d mapping:%p index:%lx\n",
> -		page, (void *)page->flags, page_count(page),
> +		page, (void *)page->flags, atomic_read(&page->_count),
>  		page_mapcount(page), page->mapping, page->index);
>  
>  	dump_stack();
> 

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
