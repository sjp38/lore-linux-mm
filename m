Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx199.postini.com [74.125.245.199])
	by kanga.kvack.org (Postfix) with SMTP id CCF8D6B005D
	for <linux-mm@kvack.org>; Fri, 17 Aug 2012 10:09:22 -0400 (EDT)
Date: Fri, 17 Aug 2012 14:09:21 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH V2] mm: introduce N_LRU_MEMORY to distinguish between
 normal and movable memory
In-Reply-To: <502DA342.7020005@huawei.com>
Message-ID: <0000013934eaad61-2dad9ff0-e671-4155-98d3-501f243caaba-000000@email.amazonses.com>
References: <502CA44C.80901@huawei.com> <502DA342.7020005@huawei.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hanjun Guo <guohanjun@huawei.com>
Cc: Wu Jianguo <wujianguo@huawei.com>, Jiang Liu <jiang.liu@huawei.com>, Tony Luck <tony.luck@intel.com>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Mel Gorman <mgorman@suse.de>, Yinghai Lu <yinghai@kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, David Rientjes <rientjes@google.com>, Minchan Kim <minchan@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Jiang Liu <liuj97@gmail.com>, qiuxishi <qiuxishi@huawei.com>

On Fri, 17 Aug 2012, Hanjun Guo wrote:

> N_NORMAL_MEMORY means non-LRU page allocs possible.

Hmmm... It may be better to say

N_NORMAL_MEMORY 	Allocations are allowed for pages that will not be
			managed via a LRU and that cannot be moved by the page migration logic.

N_LRU_MEMORY		Allocations are possible for pages that are managed via LRUs

N_HIGH_MEMORY		Allocations are allowed for pages that are only temporarliy mapped into kernel address space.

Any node that has the ability to allocate memory at all has at least N_LRU_MEMORY set.

>
>  /*
>   * Bitmasks that are kept for all the nodes.
> + * N_NORMAL_MEMORY means non-LRU page allocs possible.
> + * N_LRU_MEMORY means LRU page allocs possible,
> + * node with ZONE_DMA/ZONE_DMA32/ZONE_NORMAL is marked with
> + * N_LRU_MEMORY and N_NORMAL_MEMORY,
> + * node with ZONE_MOVABLE is *only* marked with N_LRU_MEMORY,
> + * node with ZONE_HIGHMEM is marked with N_LRU_MEMORY and N_HIGH_MEMORY.
> + * N_LRU_MEMORY also means node has any regular memory.
>   */
>  enum node_states {
>  	N_POSSIBLE,		/* The node could become online at some point */
>  	N_ONLINE,		/* The node is online */
> -	N_NORMAL_MEMORY,	/* The node has regular memory */
> +	N_NORMAL_MEMORY,	/* The node has normal memory */
> +	N_LRU_MEMORY,		/* The node has regular memory */

These comments are utter garbage and just repeat what the constant
alreadty expresses. . Please actually say something meaningful that
another developer can use when he attempts to understand what these bits
mean.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
