Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id C7DDD6B004F
	for <linux-mm@kvack.org>; Sun,  5 Jul 2009 13:42:20 -0400 (EDT)
Date: Sun, 5 Jul 2009 19:05:48 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 1/5] add per-zone statistics to show_free_areas()
Message-ID: <20090705110548.GA1898@localhost>
References: <20090705181400.08F1.A69D9226@jp.fujitsu.com> <20090705182259.08F6.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090705182259.08F6.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux-foundation.org>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

On Sun, Jul 05, 2009 at 05:23:35PM +0800, KOSAKI Motohiro wrote:
> Subject: [PATCH] add per-zone statistics to show_free_areas()
> 
> Currently, show_free_area() mainly display system memory usage. but it
> doesn't display per-zone memory usage information.
> 
> However, if DMA zone OOM occur, Administrator definitely need to know
> per-zone memory usage information.

DMA zone is normally lowmem-reserved. But I think the numbers still
make sense for DMA32.

Acked-by: Wu Fengguang <fengguang.wu@intel.com>

> 
> 
> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> ---
>  mm/page_alloc.c |   20 ++++++++++++++++++++
>  1 file changed, 20 insertions(+)
> 
> Index: b/mm/page_alloc.c
> ===================================================================
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -2151,6 +2151,16 @@ void show_free_areas(void)
>  			" inactive_file:%lukB"
>  			" unevictable:%lukB"
>  			" present:%lukB"
> +			" mlocked:%lukB"
> +			" dirty:%lukB"
> +			" writeback:%lukB"
> +			" mapped:%lukB"
> +			" slab_reclaimable:%lukB"
> +			" slab_unreclaimable:%lukB"
> +			" pagetables:%lukB"
> +			" unstable:%lukB"
> +			" bounce:%lukB"
> +			" writeback_tmp:%lukB"
>  			" pages_scanned:%lu"
>  			" all_unreclaimable? %s"
>  			"\n",
> @@ -2165,6 +2175,16 @@ void show_free_areas(void)
>  			K(zone_page_state(zone, NR_INACTIVE_FILE)),
>  			K(zone_page_state(zone, NR_UNEVICTABLE)),
>  			K(zone->present_pages),
> +			K(zone_page_state(zone, NR_MLOCK)),
> +			K(zone_page_state(zone, NR_FILE_DIRTY)),
> +			K(zone_page_state(zone, NR_WRITEBACK)),
> +			K(zone_page_state(zone, NR_FILE_MAPPED)),
> +			K(zone_page_state(zone, NR_SLAB_RECLAIMABLE)),
> +			K(zone_page_state(zone, NR_SLAB_UNRECLAIMABLE)),
> +			K(zone_page_state(zone, NR_PAGETABLE)),
> +			K(zone_page_state(zone, NR_UNSTABLE_NFS)),
> +			K(zone_page_state(zone, NR_BOUNCE)),
> +			K(zone_page_state(zone, NR_WRITEBACK_TEMP)),
>  			zone->pages_scanned,
>  			(zone_is_all_unreclaimable(zone) ? "yes" : "no")
>  			);
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
