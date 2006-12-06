Received: from d06nrmr1407.portsmouth.uk.ibm.com (d06nrmr1407.portsmouth.uk.ibm.com [9.149.38.185])
	by mtagate2.uk.ibm.com (8.13.8/8.13.8) with ESMTP id kB6IDQV7116920
	for <linux-mm@kvack.org>; Wed, 6 Dec 2006 18:13:26 GMT
Received: from d06av04.portsmouth.uk.ibm.com (d06av04.portsmouth.uk.ibm.com [9.149.37.216])
	by d06nrmr1407.portsmouth.uk.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id kB6IDQqK2629716
	for <linux-mm@kvack.org>; Wed, 6 Dec 2006 18:13:26 GMT
Received: from d06av04.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av04.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id kB6IDQ7Q005934
	for <linux-mm@kvack.org>; Wed, 6 Dec 2006 18:13:26 GMT
Date: Wed, 6 Dec 2006 19:13:17 +0100
From: Heiko Carstens <heiko.carstens@de.ibm.com>
Subject: Re: [RFC][PATCH] vmemmap on sparsemem v2 [1/5] generic vmemmap on sparsemem
Message-ID: <20061206181317.GA10042@osiris.ibm.com>
References: <20061205214517.5ad924f6.kamezawa.hiroyu@jp.fujitsu.com> <20061205214902.b8454d67.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20061205214902.b8454d67.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, clameter@engr.sgi.com, apw@shadowen.org
List-ID: <linux-mm.kvack.org>

> We can assume that total size of mem_map per section is aligned to PAGE_SIZE.
[...]
> +static int __meminit map_virtual_mem_map(unsigned long section, int node)
> +{
> +	unsigned long vmap_start, vmap_end, vmap;
> +	void *pg;
> +	pgd_t *pgd;
> +	pud_t *pud;
> +	pmd_t *pmd;
> +	pte_t *pte;
> +
> +	vmap_start = (unsigned long)pfn_to_page(section_nr_to_pfn(section));
> +	vmap_end = vmap_start + PAGES_PER_SECTION * sizeof(struct page);
> +
> +	for (vmap = vmap_start;
> +	     vmap != vmap_end;
> +	     vmap += PAGE_SIZE)
> +	{

Hmm.. maybe I'm just too tired. But why does this work? Why is vmap_start
PAGE_SIZE aligned and why is vmap_end PAGE_SIZE aligned too?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
