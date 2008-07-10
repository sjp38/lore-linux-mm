Date: Thu, 10 Jul 2008 17:35:52 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [RFC PATCH 1/4] mm: remove mm_init compilation dependency on CONFIG_DEBUG_MEMORY_INIT
Message-ID: <20080710163552.GE6664@csn.ul.ie>
References: <20080708180348.GB14908@us.ibm.com> <20080708180542.GC14908@us.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20080708180542.GC14908@us.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nishanth Aravamudan <nacc@us.ibm.com>
Cc: npiggin@suse.de, agl@us.ibm.com, akpm@linux-foundation.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On (08/07/08 11:05), Nishanth Aravamudan didst pronounce:
> Towards the end of putting all core mm initialization in mm_init.c, I
> plan on putting the creation of a mm kobject in a function in that file.
> However, the file is currently only compiled if CONFIG_DEBUG_MEMORY_INIT
> is set. Remove this dependency, but put the code under an #ifdef on the
> same config option. This should result in no functional changes.
> 
> Signed-off-by: Nishanth Aravamudan <nacc@us.ibm.com>
> 

Acked-by: Mel Gorman <mel@csn.ul.ie>

> diff --git a/mm/Makefile b/mm/Makefile
> index f54232d..cbe29d2 100644
> --- a/mm/Makefile
> +++ b/mm/Makefile
> @@ -11,7 +11,7 @@ obj-y			:= bootmem.o filemap.o mempool.o oom_kill.o fadvise.o \
>  			   maccess.o page_alloc.o page-writeback.o pdflush.o \
>  			   readahead.o swap.o truncate.o vmscan.o \
>  			   prio_tree.o util.o mmzone.o vmstat.o backing-dev.o \
> -			   page_isolation.o $(mmu-y)
> +			   page_isolation.o mm_init.o $(mmu-y)
>  
>  obj-$(CONFIG_PAGE_WALKER) += pagewalk.o
>  obj-$(CONFIG_BOUNCE)	+= bounce.o
> @@ -26,7 +26,6 @@ obj-$(CONFIG_TMPFS_POSIX_ACL) += shmem_acl.o
>  obj-$(CONFIG_TINY_SHMEM) += tiny-shmem.o
>  obj-$(CONFIG_SLOB) += slob.o
>  obj-$(CONFIG_SLAB) += slab.o
> -obj-$(CONFIG_DEBUG_MEMORY_INIT) += mm_init.o
>  obj-$(CONFIG_SLUB) += slub.o
>  obj-$(CONFIG_MEMORY_HOTPLUG) += memory_hotplug.o
>  obj-$(CONFIG_FS_XIP) += filemap_xip.o
> diff --git a/mm/mm_init.c b/mm/mm_init.c
> index ce445ca..eaf0d3b 100644
> --- a/mm/mm_init.c
> +++ b/mm/mm_init.c
> @@ -9,6 +9,7 @@
>  #include <linux/init.h>
>  #include "internal.h"
>  
> +#ifdef CONFIG_DEBUG_MEMORY_INIT
>  int __meminitdata mminit_loglevel;
>  
>  /* The zonelists are simply reported, validation is manual. */
> @@ -132,3 +133,4 @@ static __init int set_mminit_loglevel(char *str)
>  	return 0;
>  }
>  early_param("mminit_loglevel", set_mminit_loglevel);
> +#endif /* CONFIG_DEBUG_MEMORY_INIT */
> 
> -- 
> Nishanth Aravamudan <nacc@us.ibm.com>
> IBM Linux Technology Center
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
