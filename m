Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 7D6E46B004F
	for <linux-mm@kvack.org>; Thu, 17 Sep 2009 09:28:21 -0400 (EDT)
Date: Thu, 17 Sep 2009 14:28:30 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 5/11] hugetlb:  add generic definition of NUMA_NO_NODE
Message-ID: <20090917132830.GC7205@csn.ul.ie>
References: <20090915204327.4828.4349.sendpatchset@localhost.localdomain> <20090915204452.4828.83793.sendpatchset@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20090915204452.4828.83793.sendpatchset@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
To: Lee Schermerhorn <lee.schermerhorn@hp.com>
Cc: linux-mm@kvack.org, linux-numa@vger.kernel.org, akpm@linux-foundation.org, Randy Dunlap <randy.dunlap@oracle.com>, Nishanth Aravamudan <nacc@us.ibm.com>, David Rientjes <rientjes@google.com>, Adam Litke <agl@us.ibm.com>, Andy Whitcroft <apw@canonical.com>, eric.whitney@hp.com
List-ID: <linux-mm.kvack.org>

On Tue, Sep 15, 2009 at 04:44:52PM -0400, Lee Schermerhorn wrote:
> [PATCH 5/11] - hugetlb:  promote NUMA_NO_NODE to generic constant
> 
> Against:  2.6.31-mmotm-090914-0157
> 
> New in V7 of series
> 
> Move definition of NUMA_NO_NODE from ia64 and x86_64 arch specific
> headers to generic header 'linux/numa.h' for use in generic code.
> NUMA_NO_NODE replaces bare '-1' where it's used in this series to
> indicate "no node id specified".  Ultimately, it can be used
> to replace the -1 elsewhere where it is used similarly.
> 
> Signed-off-by: Lee Schermerhorn <lee.schermerhorn@hp.com>
> Acked-by: David Rientjes <rientjes@google.com>
> 

Acked-by: Mel Gorman <mel@csn.ul.ie>

>  arch/ia64/include/asm/numa.h    |    2 --
>  arch/x86/include/asm/topology.h |    5 ++---
>  include/linux/numa.h            |    2 ++
>  3 files changed, 4 insertions(+), 5 deletions(-)
> 
> Index: linux-2.6.31-mmotm-090914-0157/arch/ia64/include/asm/numa.h
> ===================================================================
> --- linux-2.6.31-mmotm-090914-0157.orig/arch/ia64/include/asm/numa.h	2009-09-15 13:19:02.000000000 -0400
> +++ linux-2.6.31-mmotm-090914-0157/arch/ia64/include/asm/numa.h	2009-09-15 13:42:19.000000000 -0400
> @@ -22,8 +22,6 @@
>  
>  #include <asm/mmzone.h>
>  
> -#define NUMA_NO_NODE	-1
> -
>  extern u16 cpu_to_node_map[NR_CPUS] __cacheline_aligned;
>  extern cpumask_t node_to_cpu_mask[MAX_NUMNODES] __cacheline_aligned;
>  extern pg_data_t *pgdat_list[MAX_NUMNODES];
> Index: linux-2.6.31-mmotm-090914-0157/arch/x86/include/asm/topology.h
> ===================================================================
> --- linux-2.6.31-mmotm-090914-0157.orig/arch/x86/include/asm/topology.h	2009-09-15 13:19:02.000000000 -0400
> +++ linux-2.6.31-mmotm-090914-0157/arch/x86/include/asm/topology.h	2009-09-15 13:42:19.000000000 -0400
> @@ -35,11 +35,10 @@
>  # endif
>  #endif
>  
> -/* Node not present */
> -#define NUMA_NO_NODE	(-1)
> -
>  #ifdef CONFIG_NUMA
>  #include <linux/cpumask.h>
> +#include <linux/numa.h>
> +
>  #include <asm/mpspec.h>
>  
>  #ifdef CONFIG_X86_32
> Index: linux-2.6.31-mmotm-090914-0157/include/linux/numa.h
> ===================================================================
> --- linux-2.6.31-mmotm-090914-0157.orig/include/linux/numa.h	2009-09-15 13:19:02.000000000 -0400
> +++ linux-2.6.31-mmotm-090914-0157/include/linux/numa.h	2009-09-15 13:42:19.000000000 -0400
> @@ -10,4 +10,6 @@
>  
>  #define MAX_NUMNODES    (1 << NODES_SHIFT)
>  
> +#define	NUMA_NO_NODE	(-1)
> +
>  #endif /* _LINUX_NUMA_H */
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
