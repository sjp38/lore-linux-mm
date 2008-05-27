Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e4.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m4RLiuLn003510
	for <linux-mm@kvack.org>; Tue, 27 May 2008 17:44:56 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m4RLiuqq151724
	for <linux-mm@kvack.org>; Tue, 27 May 2008 17:44:56 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m4RLit5V017339
	for <linux-mm@kvack.org>; Tue, 27 May 2008 17:44:56 -0400
Subject: Re: [patch 19/23] powerpc: function to allocate gigantic hugepages
From: Adam Litke <agl@us.ibm.com>
In-Reply-To: <20080525143454.129909000@nick.local0.net>
References: <20080525142317.965503000@nick.local0.net>
	 <20080525143454.129909000@nick.local0.net>
Content-Type: text/plain
Date: Tue, 27 May 2008 16:44:55 -0500
Message-Id: <1211924695.12036.52.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: npiggin@suse.de
Cc: linux-mm@kvack.org, kniht@us.ibm.com, andi-suse@firstfloor.org, nacc@us.ibm.com, abh@cray.com, joachim.deguara@amd.com, Jon Tollefson <kniht@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

On Mon, 2008-05-26 at 00:23 +1000, npiggin@suse.de wrote:
> plain text document attachment
> (powerpc-function-for-gigantic-hugepage-allocation.patch)
> The 16G page locations have been saved during early boot in an array.
> The alloc_bootmem_huge_page() function adds a page from here to the
> huge_boot_pages list.
> 
> Signed-off-by: Jon Tollefson <kniht@linux.vnet.ibm.com>
> Signed-off-by: Nick Piggin <npiggin@suse.de>

Acked-by: Adam Litke <agl@us.ibm.com>

> ---
> 
>  arch/powerpc/mm/hugetlbpage.c |   22 ++++++++++++++++++++++
>  1 file changed, 22 insertions(+)
> 
> Index: linux-2.6/arch/powerpc/mm/hugetlbpage.c
> ===================================================================
> --- linux-2.6.orig/arch/powerpc/mm/hugetlbpage.c
> +++ linux-2.6/arch/powerpc/mm/hugetlbpage.c
> @@ -29,6 +29,12 @@
> 
>  #define NUM_LOW_AREAS	(0x100000000UL >> SID_SHIFT)
>  #define NUM_HIGH_AREAS	(PGTABLE_RANGE >> HTLB_AREA_SHIFT)
> +#define MAX_NUMBER_GPAGES	1024
> +
> +/* Tracks the 16G pages after the device tree is scanned and before the
> + *  huge_boot_pages list is ready.  */

Minor nit: This comment format looks a bit wacky.

-- 
Adam Litke - (agl at us.ibm.com)
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
