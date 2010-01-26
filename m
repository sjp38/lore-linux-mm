Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 5A1D46B009A
	for <linux-mm@kvack.org>; Tue, 26 Jan 2010 14:34:30 -0500 (EST)
Date: Tue, 26 Jan 2010 19:34:15 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 12 of 31] config_transparent_hugepage
Message-ID: <20100126193415.GQ16468@csn.ul.ie>
References: <patchbomb.1264513915@v2.random> <e3f4fc366daf5ba210ab.1264513927@v2.random>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <e3f4fc366daf5ba210ab.1264513927@v2.random>
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Andi Kleen <andi@firstfloor.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, Andrew Morton <akpm@linux-foundation.org>, bpicco@redhat.com, Christoph Hellwig <chellwig@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Tue, Jan 26, 2010 at 02:52:07PM +0100, Andrea Arcangeli wrote:
> From: Andrea Arcangeli <aarcange@redhat.com>
> 
> Add config option.
> 
> Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
> ---
> 
> diff --git a/mm/Kconfig b/mm/Kconfig
> --- a/mm/Kconfig
> +++ b/mm/Kconfig
> @@ -283,3 +283,17 @@ config NOMMU_INITIAL_TRIM_EXCESS
>  	  of 1 says that all excess pages should be trimmed.
>  
>  	  See Documentation/nommu-mmap.txt for more information.
> +
> +config TRANSPARENT_HUGEPAGE
> +	bool "Transparent Hugepage support" if EMBEDDED
> +	depends on X86_64
> +	default y

Are there embedded x86-64 boxen? I'm surprised it's not a normal option
and is selected by default but don't have a problem with it as such.

Acked-by: Mel Gorman <mel@csn.ul.ie>

> +	help
> +	  Transparent Hugepages allows the kernel to use huge pages and
> +	  huge tlb transparently to the applications whenever possible.
> +	  This feature can improve computing performance to certain
> +	  applications by speeding up page faults during memory
> +	  allocation, by reducing the number of tlb misses and by speeding
> +	  up the pagetable walking.
> +
> +	  If memory constrained on embedded, you may want to say N.
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
