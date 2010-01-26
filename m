Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 3908F6B0071
	for <linux-mm@kvack.org>; Tue, 26 Jan 2010 06:41:18 -0500 (EST)
Date: Tue, 26 Jan 2010 11:41:01 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 01 of 31] define MADV_HUGEPAGE
Message-ID: <20100126114101.GB16468@csn.ul.ie>
References: <patchbomb.1264439931@v2.random> <edb236c55565378596ae.1264439932@v2.random>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <edb236c55565378596ae.1264439932@v2.random>
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Andi Kleen <andi@firstfloor.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, Andrew Morton <akpm@linux-foundation.org>, bpicco@redhat.com, Christoph Hellwig <chellwig@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Mon, Jan 25, 2010 at 06:18:52PM +0100, Andrea Arcangeli wrote:
> From: Andrea Arcangeli <aarcange@redhat.com>
> 
> Define MADV_HUGEPAGE.
> 
> Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
> ---
> 
> diff --git a/include/asm-generic/mman-common.h b/include/asm-generic/mman-common.h
> --- a/include/asm-generic/mman-common.h
> +++ b/include/asm-generic/mman-common.h
> @@ -45,6 +45,8 @@
>  #define MADV_MERGEABLE   12		/* KSM may merge identical pages */
>  #define MADV_UNMERGEABLE 13		/* KSM may not merge identical pages */
>  
> +#define MADV_HUGEPAGE	14		/* Worth backing with hugepages */
> +

The use of 14 collides with parisc

$ git grep MADV_ | grep define | grep 14
arch/parisc/include/asm/mman.h:#define MADV_16K_PAGES  14 /* Use 16K pages */

>  /* compatibility flags */
>  #define MAP_FILE	0
>  
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
