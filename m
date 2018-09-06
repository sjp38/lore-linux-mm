Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id D56336B77BB
	for <linux-mm@kvack.org>; Thu,  6 Sep 2018 04:08:06 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id b4-v6so3378330ede.4
        for <linux-mm@kvack.org>; Thu, 06 Sep 2018 01:08:06 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b13-v6si2860307edb.96.2018.09.06.01.08.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Sep 2018 01:08:05 -0700 (PDT)
Date: Thu, 6 Sep 2018 10:08:04 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH 15/29] memblock: replace alloc_bootmem_pages_node
 with memblock_alloc_node
Message-ID: <20180906080804.GX14951@dhcp22.suse.cz>
References: <1536163184-26356-1-git-send-email-rppt@linux.vnet.ibm.com>
 <1536163184-26356-16-git-send-email-rppt@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1536163184-26356-16-git-send-email-rppt@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Rapoport <rppt@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, "David S. Miller" <davem@davemloft.net>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Ingo Molnar <mingo@redhat.com>, Michael Ellerman <mpe@ellerman.id.au>, Paul Burton <paul.burton@mips.com>, Thomas Gleixner <tglx@linutronix.de>, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org, linux-mips@linux-mips.org, linuxppc-dev@lists.ozlabs.org, sparclinux@vger.kernel.org, linux-kernel@vger.kernel.org

On Wed 05-09-18 18:59:30, Mike Rapoport wrote:
> Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>

again a short work of wisdom please.

The change itself looks good.
Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  arch/ia64/mm/init.c | 8 ++++----
>  1 file changed, 4 insertions(+), 4 deletions(-)
> 
> diff --git a/arch/ia64/mm/init.c b/arch/ia64/mm/init.c
> index 3b85c3e..ffcc358 100644
> --- a/arch/ia64/mm/init.c
> +++ b/arch/ia64/mm/init.c
> @@ -447,19 +447,19 @@ int __init create_mem_map_page_table(u64 start, u64 end, void *arg)
>  	for (address = start_page; address < end_page; address += PAGE_SIZE) {
>  		pgd = pgd_offset_k(address);
>  		if (pgd_none(*pgd))
> -			pgd_populate(&init_mm, pgd, alloc_bootmem_pages_node(NODE_DATA(node), PAGE_SIZE));
> +			pgd_populate(&init_mm, pgd, memblock_alloc_node(PAGE_SIZE, PAGE_SIZE, node));
>  		pud = pud_offset(pgd, address);
>  
>  		if (pud_none(*pud))
> -			pud_populate(&init_mm, pud, alloc_bootmem_pages_node(NODE_DATA(node), PAGE_SIZE));
> +			pud_populate(&init_mm, pud, memblock_alloc_node(PAGE_SIZE, PAGE_SIZE, node));
>  		pmd = pmd_offset(pud, address);
>  
>  		if (pmd_none(*pmd))
> -			pmd_populate_kernel(&init_mm, pmd, alloc_bootmem_pages_node(NODE_DATA(node), PAGE_SIZE));
> +			pmd_populate_kernel(&init_mm, pmd, memblock_alloc_node(PAGE_SIZE, PAGE_SIZE, node));
>  		pte = pte_offset_kernel(pmd, address);
>  
>  		if (pte_none(*pte))
> -			set_pte(pte, pfn_pte(__pa(alloc_bootmem_pages_node(NODE_DATA(node), PAGE_SIZE)) >> PAGE_SHIFT,
> +			set_pte(pte, pfn_pte(__pa(memblock_alloc_node(PAGE_SIZE, PAGE_SIZE, node))) >> PAGE_SHIFT,
>  					     PAGE_KERNEL));
>  	}
>  	return 0;
> -- 
> 2.7.4
> 

-- 
Michal Hocko
SUSE Labs
