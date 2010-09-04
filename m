Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id B6D1D6B0047
	for <linux-mm@kvack.org>; Sat,  4 Sep 2010 06:30:04 -0400 (EDT)
Date: Sat, 4 Sep 2010 11:29:46 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH] avoid warning when COMPACTION is selected
Message-ID: <20100904102946.GD8384@csn.ul.ie>
References: <20100903153826.GB16761@random.random>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20100903153826.GB16761@random.random>
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Sep 03, 2010 at 05:38:26PM +0200, Andrea Arcangeli wrote:
> From: Andrea Arcangeli <aarcange@redhat.com>
> 
> COMPACTION enables MIGRATION, but MIGRATION spawns a warning if numa
> or memhotplug aren't selected. However MIGRATION doesn't depend on
> them. I guess it's just trying to be strict doing a double check on
> who's enabling it, but it doesn't know that compaction also enables
> MIGRATION.
> 
> Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>

Acked-by: Mel Gorman <mel@csn.ul.ie>

This was the way an earlier version of compaction had Kconfig. I'm not sure
at what point the "|| COMPACTION" got dropped.

> ---
> 
> diff --git a/mm/Kconfig b/mm/Kconfig
> --- a/mm/Kconfig
> +++ b/mm/Kconfig
> @@ -189,7 +189,7 @@ config COMPACTION
>  config MIGRATION
>  	bool "Page migration"
>  	def_bool y
> -	depends on NUMA || ARCH_ENABLE_MEMORY_HOTREMOVE
> +	depends on NUMA || ARCH_ENABLE_MEMORY_HOTREMOVE || COMPACTION
>  	help
>  	  Allows the migration of the physical location of pages of processes
>  	  while the virtual addresses are not changed. This is useful in
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
