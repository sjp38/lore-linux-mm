Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 287F56B0044
	for <linux-mm@kvack.org>; Fri, 18 Dec 2009 14:16:27 -0500 (EST)
Date: Fri, 18 Dec 2009 19:16:18 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 22 of 28] clear_huge_page fix
Message-ID: <20091218191618.GG21194@csn.ul.ie>
References: <patchbomb.1261076403@v2.random> <1a99eca9036dcf88bf0f.1261076425@v2.random>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1a99eca9036dcf88bf0f.1261076425@v2.random>
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Andi Kleen <andi@firstfloor.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Thu, Dec 17, 2009 at 07:00:25PM -0000, Andrea Arcangeli wrote:
> From: Andrea Arcangeli <aarcange@redhat.com>
> 
> sz is in bytes, MAX_ORDER_NR_PAGES is in pages.
> 
> Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>

While accurate, it doesn't seem to have anything to do with the set.
Should be sent up separetly.

> ---
> 
> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -402,7 +402,7 @@ static void clear_huge_page(struct page 
>  {
>  	int i;
>  
> -	if (unlikely(sz > MAX_ORDER_NR_PAGES)) {
> +	if (unlikely(sz/PAGE_SIZE > MAX_ORDER_NR_PAGES)) {
>  		clear_gigantic_page(page, addr, sz);
>  		return;
>  	}
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
