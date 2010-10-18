Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id E5F406B00B9
	for <linux-mm@kvack.org>; Mon, 18 Oct 2010 11:51:57 -0400 (EDT)
Date: Mon, 18 Oct 2010 10:51:57 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [experimental][PATCH] mm,vmstat: per cpu stat flush too when
 per cpu page cache flushed
In-Reply-To: <20101013160640.ADC9.A69D9226@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1010181050000.1294@router.home>
References: <20101013121913.ADB4.A69D9226@jp.fujitsu.com> <20101013151723.ADBD.A69D9226@jp.fujitsu.com> <20101013160640.ADC9.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Mel Gorman <mel@csn.ul.ie>, Shaohua Li <shaohua.li@intel.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Wed, 13 Oct 2010, KOSAKI Motohiro wrote:

> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 194bdaa..8b50e52 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -1093,6 +1093,7 @@ static void drain_pages(unsigned int cpu)
>  		pcp = &pset->pcp;
>  		free_pcppages_bulk(zone, pcp->count, pcp);
>  		pcp->count = 0;
> +		__flush_zone_state(zone, NR_FREE_PAGES);
>  		local_irq_restore(flags);
>  	}
>  }

drain_zone_pages() is called from refresh_vm_stats() and
refresh_vm_stats() already flushes the counters. The patch will not change
anything.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
