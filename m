Date: Fri, 8 Dec 2006 12:06:07 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH] vmemmap on sparsemem v2 [1/5] generic vmemmap on
 sparsemem
Message-Id: <20061208120607.0e3a625f.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20061205214902.b8454d67.kamezawa.hiroyu@jp.fujitsu.com>
References: <20061205214517.5ad924f6.kamezawa.hiroyu@jp.fujitsu.com>
	<20061205214902.b8454d67.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, clameter@engr.sgi.com, apw@shadowen.org
List-ID: <linux-mm.kvack.org>

On Tue, 5 Dec 2006 21:49:02 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

>
> +#ifdef CONFIG_SPARSEMEM_VMEMMAP
> +/*
> + * sparse_vmem_map_start is defined by each arch.
> + * vmem_map is declared by each arch.
> + */
> +static inline struct page *__section_mem_map_addr(struct mem_section *section)
> +{
> +	return vmem_map;
> +}
> +#else

I confirmed that this style add one memory access (ld). I'll go back to
#define pfn_to_page(pfn)	(mem_map + pfn) 
style.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
