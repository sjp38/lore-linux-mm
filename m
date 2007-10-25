Date: Thu, 25 Oct 2007 11:14:20 +0100
Subject: Re: [PATCH 1/2] Fix migratetype_names[] and make it available
Message-ID: <20071025101419.GB30732@skynet.ie>
References: <1193243864.30836.24.camel@dyn9047017100.beaverton.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1193243864.30836.24.camel@dyn9047017100.beaverton.ibm.com>
From: mel@skynet.ie (Mel Gorman)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Badari Pulavarty <pbadari@us.ibm.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, melgor@ie.ibm.com, haveblue@us.ibm.com, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On (24/10/07 09:37), Badari Pulavarty didst pronounce:
> Signed-off-by: Badari Pulavarty <pbadari@us.ibm.com>
> ---
>  include/linux/pageblock-flags.h |    1 +
>  mm/vmstat.c                     |    3 ++-
>  2 files changed, 3 insertions(+), 1 deletion(-)
> 
> Index: linux-2.6.23/include/linux/pageblock-flags.h
> ===================================================================
> --- linux-2.6.23.orig/include/linux/pageblock-flags.h	2007-10-23 13:04:46.000000000 -0700
> +++ linux-2.6.23/include/linux/pageblock-flags.h	2007-10-23 13:10:16.000000000 -0700
> @@ -72,4 +72,5 @@ void set_pageblock_flags_group(struct pa
>  #define set_pageblock_flags(page) \
>  			set_pageblock_flags_group(page, 0, NR_PAGEBLOCK_BITS-1)
>  
> +extern char * const migratetype_names[];
>  #endif	/* PAGEBLOCK_FLAGS_H */
> Index: linux-2.6.23/mm/vmstat.c
> ===================================================================
> --- linux-2.6.23.orig/mm/vmstat.c	2007-10-23 13:05:03.000000000 -0700
> +++ linux-2.6.23/mm/vmstat.c	2007-10-23 13:06:36.000000000 -0700
> @@ -382,11 +382,12 @@ void zone_statistics(struct zonelist *zo
>  
>  #include <linux/seq_file.h>
>  
> -static char * const migratetype_names[MIGRATE_TYPES] = {
> +char * const migratetype_names[MIGRATE_TYPES] = {
>  	"Unmovable",
>  	"Reclaimable",
>  	"Movable",
>  	"Reserve",
> +	"Isolate",
>  };

This also fixes up the output of /proc/pagetypeinfo which currently
prints out "null" for the Isolate string.

>  
>  static void *frag_start(struct seq_file *m, loff_t *pos)
> 
> 

Acked-by: Mel Gorman <mel@csn.ul.ie>

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
