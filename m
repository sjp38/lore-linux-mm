Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 4A6126B004A
	for <linux-mm@kvack.org>; Tue,  7 Jun 2011 14:03:57 -0400 (EDT)
Date: Tue, 7 Jun 2011 14:03:28 -0400
From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Subject: Re: [PATCH V4 4/4] mm: frontswap: config and doc files
Message-ID: <20110607180328.GC32207@dumpdata.com>
References: <20110527194925.GA27229@ca-server1.us.oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110527194925.GA27229@ca-server1.us.oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, jeremy@goop.org, hughd@google.com, ngupta@vflare.org, JBeulich@novell.com, kurt.hackel@oracle.com, npiggin@suse.de, akpm@linux-foundation.org, riel@redhat.com, hannes@cmpxchg.org, matthew@wil.cx, chris.mason@oracle.com

On Fri, May 27, 2011 at 12:49:25PM -0700, Dan Magenheimer wrote:
> [PATCH V4 4/4] mm: frontswap: config and doc files
> 
> Add configuration and documentation files.
> 
> Signed-off-by: Dan Magenheimer <dan.magenheimer@oracle.com>
> 
> Diffstat:
>  Documentation/ABI/testing/sysfs-kernel-mm-frontswap |   16 
>  Documentation/vm/frontswap.txt                      |  210 ++++++++++
>  mm/Kconfig                                          |   16 
>  mm/Makefile                                         |    1 
>  4 files changed, 243 insertions(+)
> 
> --- linux-2.6.39/mm/Makefile	2011-05-18 22:06:34.000000000 -0600
> +++ linux-2.6.39-frontswap/mm/Makefile	2011-05-26 15:37:25.262292918 -0600
> @@ -25,6 +25,7 @@ obj-$(CONFIG_HAVE_MEMBLOCK) += memblock.
>  
>  obj-$(CONFIG_BOUNCE)	+= bounce.o
>  obj-$(CONFIG_SWAP)	+= page_io.o swap_state.o swapfile.o thrash.o
> +obj-$(CONFIG_FRONTSWAP)	+= frontswap.o
>  obj-$(CONFIG_HAS_DMA)	+= dmapool.o
>  obj-$(CONFIG_HUGETLBFS)	+= hugetlb.o
>  obj-$(CONFIG_NUMA) 	+= mempolicy.o
> --- linux-2.6.39/mm/Kconfig	2011-05-18 22:06:34.000000000 -0600
> +++ linux-2.6.39-frontswap/mm/Kconfig	2011-05-26 15:39:26.294884780 -0600
> @@ -347,3 +347,19 @@ config NEED_PER_CPU_KM
>  	depends on !SMP
>  	bool
>  	default y
> +
> +config FRONTSWAP
> +	bool "Enable frontswap pseudo-RAM driver to cache swap pages"
> +	default y

default n

> +	help
> + 	  Frontswap is so named because it can be thought of as the opposite of
> + 	  a "backing" store for a swap device.  The storage is assumed to be
> + 	  a synchronous concurrency-safe page-oriented pseudo-RAM device (such
> +	  as Xen's Transcendent Memory, aka "tmem") which is not directly
> +	  accessible or addressable by the kernel and is of unknown (and
> +	  possibly time-varying) size.  When a pseudo-RAM device is available,
> +	  a signficant swap I/O reduction may be achieved.  When none is
> +	  available, all frontswap calls are reduced to a single pointer-
> +	  compare-against-NULL resulting in a negligible performance hit.
> +
> +	  If unsure, say Y to enable frontswap.
> --- linux-2.6.39/Documentation/ABI/testing/sysfs-kernel-mm-frontswap	1969-12-31 17:00:00.000000000 -0700
> +++ linux-2.6.39-frontswap/Documentation/ABI/testing/sysfs-kernel-mm-frontswap	2011-05-26 15:37:25.135819879 -0600
> @@ -0,0 +1,16 @@
> +What:		/sys/kernel/mm/frontswap/
> +Date:		June 2010

Not 2011?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
