Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 64A016B0010
	for <linux-mm@kvack.org>; Mon, 15 Oct 2018 04:30:39 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id b34-v6so11639501ede.5
        for <linux-mm@kvack.org>; Mon, 15 Oct 2018 01:30:39 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l1-v6si1624274ejq.26.2018.10.15.01.30.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 Oct 2018 01:30:37 -0700 (PDT)
Date: Mon, 15 Oct 2018 10:30:35 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: + memblock-warn-if-zero-alignment-was-requested.patch added to
 -mm tree
Message-ID: <20181015083035.GE18839@dhcp22.suse.cz>
References: <20181013000217.wEUYyrctL%akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181013000217.wEUYyrctL%akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: mm-commits@vger.kernel.org, rppt@linux.vnet.ibm.com, linux-mm@kvack.org

On Fri 12-10-18 17:02:17, Andrew Morton wrote:
> ------------------------------------------------------
> From: Mike Rapoport <rppt@linux.vnet.ibm.com>
> Subject: mm/memblock.c: warn if zero alignment was requested
> 
> After updating all memblock users to explicitly specify SMP_CACHE_BYTES
> alignment rather than use 0, it is still possible that uncovered users may
> sneak in.  Add a WARN_ON_ONCE for such cases.
> 
> Link: http://lkml.kernel.org/r/20181011060850.GA19822@rapoport-lnx
> Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
> Reviewed-by: Andrew Morton <akpm@linux-foundation.org>
> Cc: Michal Hocko <mhocko@suse.com>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
> 
> 
> --- a/mm/memblock.c~memblock-warn-if-zero-alignment-was-requested
> +++ a/mm/memblock.c
> @@ -1298,6 +1298,9 @@ static phys_addr_t __init memblock_alloc
>  {
>  	phys_addr_t found;
>  
> +	if (WARN_ON_ONCE(!align))
> +		align = SMP_CACHE_BYTES;
> +
>  	found = memblock_find_in_range_node(size, align, start, end, nid,
>  					    flags);
>  	if (found && !memblock_reserve(found, size)) {
> @@ -1420,6 +1423,9 @@ static void * __init memblock_alloc_inte
>  	if (WARN_ON_ONCE(slab_is_available()))
>  		return kzalloc_node(size, GFP_NOWAIT, nid);
>  
> +	if (WARN_ON_ONCE(!align))
> +		align = SMP_CACHE_BYTES;
> +
>  	if (max_addr > memblock.current_limit)
>  		max_addr = memblock.current_limit;
>  again:
> _
> 
> Patches currently in -mm which might be from rppt@linux.vnet.ibm.com are
> 
> hexagon-switch-to-no_bootmem.patch
> of-ignore-sub-page-memory-regions.patch
> nios2-use-generic-early_init_dt_add_memory_arch.patch
> nios2-switch-to-no_bootmem.patch
> um-setup_physmem-stop-using-global-variables.patch
> um-switch-to-no_bootmem.patch
> unicore32-switch-to-no_bootmem.patch
> alpha-switch-to-no_bootmem.patch
> mm-remove-config_no_bootmem.patch
> mm-remove-config_have_memblock.patch
> mm-remove-config_have_memblock-fix.patch
> mm-remove-config_have_memblock-fix-2.patch
> mm-remove-config_have_memblock-fix-3.patch
> mm-remove-bootmem-allocator-implementation.patch
> mm-nobootmem-remove-dead-code.patch
> memblock-rename-memblock_alloc_nid_try_nid-to-memblock_phys_alloc.patch
> memblock-remove-_virt-from-apis-returning-virtual-address.patch
> memblock-replace-alloc_bootmem_align-with-memblock_alloc.patch
> memblock-replace-alloc_bootmem_low-with-memblock_alloc_low.patch
> memblock-replace-__alloc_bootmem_node_nopanic-with-memblock_alloc_try_nid_nopanic.patch
> memblock-replace-alloc_bootmem_pages_nopanic-with-memblock_alloc_nopanic.patch
> memblock-replace-alloc_bootmem_low-with-memblock_alloc_low-2.patch
> memblock-replace-__alloc_bootmem_nopanic-with-memblock_alloc_from_nopanic.patch
> memblock-add-align-parameter-to-memblock_alloc_node.patch
> memblock-replace-alloc_bootmem_pages_node-with-memblock_alloc_node.patch
> memblock-replace-__alloc_bootmem_node-with-appropriate-memblock_-api.patch
> memblock-replace-alloc_bootmem_node-with-memblock_alloc_node.patch
> memblock-replace-alloc_bootmem_low_pages-with-memblock_alloc_low.patch
> memblock-replace-alloc_bootmem_pages-with-memblock_alloc.patch
> memblock-replace-__alloc_bootmem-with-memblock_alloc_from.patch
> memblock-replace-alloc_bootmem-with-memblock_alloc.patch
> mm-nobootmem-remove-bootmem-allocation-apis.patch
> memblock-replace-free_bootmem_node-with-memblock_free.patch
> memblock-replace-free_bootmem_late-with-memblock_free_late.patch
> memblock-rename-free_all_bootmem-to-memblock_free_all.patch
> memblock-rename-__free_pages_bootmem-to-memblock_free_pages.patch
> mm-remove-nobootmem.patch
> memblock-replace-bootmem_alloc_-with-memblock-variants.patch
> mm-remove-include-linux-bootmemh.patch
> docs-boot-time-mm-remove-bootmem-documentation.patch
> memblock-stop-using-implicit-alignement-to-smp_cache_bytes.patch
> memblock-warn-if-zero-alignment-was-requested.patch
> 

-- 
Michal Hocko
SUSE Labs
