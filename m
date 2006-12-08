Date: Fri, 8 Dec 2006 10:09:32 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH] vmemmap on sparsemem v2 [3/5] ia64 vmemamp on
 sparsemem
Message-Id: <20061208100932.09872376.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20061205215905.3fb8a582.kamezawa.hiroyu@jp.fujitsu.com>
References: <20061205214517.5ad924f6.kamezawa.hiroyu@jp.fujitsu.com>
	<20061205215905.3fb8a582.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, clameter@engr.sgi.com, apw@shadowen.org
List-ID: <linux-mm.kvack.org>

On Tue, 5 Dec 2006 21:59:05 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

>
> +/* fixed at compile time */
> +#ifndef __ASSEMBLY__
> +extern struct page vmem_map[];
> +#endif
> +
I'm sorry that this cannot be compiled by gcc-4.0 because 'struct page' is not
declared. I'll move this or use pointer struct page *vmem_map.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
