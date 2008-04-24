Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e3.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m3ONnZMs014989
	for <linux-mm@kvack.org>; Thu, 24 Apr 2008 19:49:35 -0400
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m3ONnXRI228220
	for <linux-mm@kvack.org>; Thu, 24 Apr 2008 19:49:35 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m3ONnMtf004256
	for <linux-mm@kvack.org>; Thu, 24 Apr 2008 19:49:23 -0400
Date: Thu, 24 Apr 2008 16:49:11 -0700
From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: Re: [patch 02/18] hugetlb: factor out huge_new_page
Message-ID: <20080424234911.GA4741@us.ibm.com>
References: <20080423015302.745723000@nick.local0.net> <20080423015429.834926000@nick.local0.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080423015429.834926000@nick.local0.net>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: npiggin@suse.de
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, andi@firstfloor.org, kniht@linux.vnet.ibm.com, abh@cray.com, wli@holomorphy.com
List-ID: <linux-mm.kvack.org>

On 23.04.2008 [11:53:04 +1000], npiggin@suse.de wrote:
> Needed to avoid code duplication in follow up patches.
> 
> This happens to fix a minor bug. When alloc_bootmem_node returns
> a fallback node on a different node than passed the old code
> would have put it into the free lists of the wrong node.
> Now it would end up in the freelist of the correct node.
> 
> Signed-off-by: Andi Kleen <ak@suse.de>
> Signed-off-by: Nick Piggin <npiggin@suse.de>
> ---
>  mm/hugetlb.c |   21 +++++++++++++--------
>  1 file changed, 13 insertions(+), 8 deletions(-)
> 
> Index: linux-2.6/mm/hugetlb.c
> ===================================================================
> --- linux-2.6.orig/mm/hugetlb.c
> +++ linux-2.6/mm/hugetlb.c
> @@ -190,6 +190,17 @@ static int adjust_pool_surplus(int delta
>  	return ret;
>  }
> 
> +static void prep_new_huge_page(struct page *page)
> +{
> +	unsigned nid = pfn_to_nid(page_to_pfn(page));

Why not just pass the nid here, which we've already got in the caller? I
assume because the future caller doesn't have it, but then that caller
can do this calculation in the invocation, rather than making all
callers do it?

Thanks,
Nish

-- 
Nishanth Aravamudan <nacc@us.ibm.com>
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
