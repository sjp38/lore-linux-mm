Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx203.postini.com [74.125.245.203])
	by kanga.kvack.org (Postfix) with SMTP id 20CA46B004A
	for <linux-mm@kvack.org>; Thu, 23 Feb 2012 11:21:14 -0500 (EST)
Date: Thu, 23 Feb 2012 17:21:11 +0100
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH v3 21/21] mm: zone lru vectors interleaving
Message-ID: <20120223162111.GA4713@one.firstfloor.org>
References: <20120223133728.12988.5432.stgit@zurg> <20120223135328.12988.87152.stgit@zurg>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120223135328.12988.87152.stgit@zurg>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@openvz.org>
Cc: Hugh Dickins <hughd@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andi Kleen <andi@firstfloor.org>, tim.c.chen@linux.intel.com

> +config PAGE_LRU_SPLIT
> +	int "Memory lru lists per zone"
> +	default	4 if EXPERIMENTAL && SPARSEMEM_VMEMMAP
> +	default 1
> +	help
> +	  The number of lru lists in each memory zone for interleaving.
> +	  Allows to redeuce lru_lock contention, but adds some overhead.
> +	  Without SPARSEMEM_VMEMMAP might be costly. "1" means no split.

Could you turn those two numbers into a boot option? Compile time 
parameters are nasty to use.

I suppose it's ok to have an upper limit.

> +
> +config PAGE_LRU_INTERLEAVING
> +	int "Memory lru lists interleaving page-order"
> +	default	12
> +	help
> +	  Page order for lru lists interleaving. By default 12 (16Mb).
> +	  Must be greater than huge-page order.
> +	  With CONFIG_PAGE_LRU_SPLIT=1 has no effect.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
