Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id CEA976B004A
	for <linux-mm@kvack.org>; Fri,  3 Sep 2010 16:06:54 -0400 (EDT)
Date: Fri, 3 Sep 2010 13:06:23 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] avoid warning when COMPACTION is selected
Message-Id: <20100903130623.00da1f96.akpm@linux-foundation.org>
In-Reply-To: <20100903153826.GB16761@random.random>
References: <20100903153826.GB16761@random.random>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 3 Sep 2010 17:38:26 +0200
Andrea Arcangeli <aarcange@redhat.com> wrote:

> From: Andrea Arcangeli <aarcange@redhat.com>
> 
> COMPACTION enables MIGRATION, but MIGRATION spawns a warning if numa
> or memhotplug aren't selected. However MIGRATION doesn't depend on
> them. I guess it's just trying to be strict doing a double check on
> who's enabling it, but it doesn't know that compaction also enables
> MIGRATION.
> 
> Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
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

Could you please send along a copy of the warning?  It's unclear
whether it's a compiler warning or a Kconfig warning or a runtime
warning or what.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
