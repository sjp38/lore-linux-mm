Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 12A66280253
	for <linux-mm@kvack.org>; Mon, 21 Nov 2016 01:42:06 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id 3so377162795pgd.3
        for <linux-mm@kvack.org>; Sun, 20 Nov 2016 22:42:06 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id t82si5577000pgb.173.2016.11.20.22.42.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 20 Nov 2016 22:42:04 -0800 (PST)
Received: from pps.filterd (m0098393.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id uAL6dnui012063
	for <linux-mm@kvack.org>; Mon, 21 Nov 2016 01:42:04 -0500
Received: from e23smtp04.au.ibm.com (e23smtp04.au.ibm.com [202.81.31.146])
	by mx0a-001b2d01.pphosted.com with ESMTP id 26ut1vuw7t-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 21 Nov 2016 01:42:04 -0500
Received: from localhost
	by e23smtp04.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Mon, 21 Nov 2016 16:42:01 +1000
Received: from d23relay07.au.ibm.com (d23relay07.au.ibm.com [9.190.26.37])
	by d23dlp01.au.ibm.com (Postfix) with ESMTP id 78B302CE8056
	for <linux-mm@kvack.org>; Mon, 21 Nov 2016 17:41:59 +1100 (EST)
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay07.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id uAL6fxt130539818
	for <linux-mm@kvack.org>; Mon, 21 Nov 2016 17:41:59 +1100
Received: from d23av02.au.ibm.com (localhost [127.0.0.1])
	by d23av02.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id uAL6fwHa019034
	for <linux-mm@kvack.org>; Mon, 21 Nov 2016 17:41:59 +1100
Subject: Re: [HMM v13 01/18] mm/memory/hotplug: convert device parameter bool
 to set of flags
References: <1479493107-982-1-git-send-email-jglisse@redhat.com>
 <1479493107-982-2-git-send-email-jglisse@redhat.com>
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Date: Mon, 21 Nov 2016 12:11:50 +0530
MIME-Version: 1.0
In-Reply-To: <1479493107-982-2-git-send-email-jglisse@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Message-Id: <5832972E.1050405@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: John Hubbard <jhubbard@nvidia.com>, Russell King <linux@armlinux.org.uk>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Yoshinori Sato <ysato@users.sourceforge.jp>, Rich Felker <dalias@libc.org>, Chris Metcalf <cmetcalf@mellanox.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>

On 11/18/2016 11:48 PM, JA(C)rA'me Glisse wrote:
> Only usefull for arch where we support ZONE_DEVICE and where we want to

A small nit s/usefull/useful/

> also support un-addressable device memory. We need struct page for such
> un-addressable memory. But we should avoid populating the kernel linear
> mapping for the physical address range because there is no real memory
> or anything behind those physical address.
> 
> Hence we need more flags than just knowing if it is device memory or not.
> 
> Signed-off-by: JA(C)rA'me Glisse <jglisse@redhat.com>
> Cc: Russell King <linux@armlinux.org.uk>
> Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
> Cc: Paul Mackerras <paulus@samba.org>
> Cc: Michael Ellerman <mpe@ellerman.id.au>
> Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>
> Cc: Heiko Carstens <heiko.carstens@de.ibm.com>
> Cc: Yoshinori Sato <ysato@users.sourceforge.jp>
> Cc: Rich Felker <dalias@libc.org>
> Cc: Chris Metcalf <cmetcalf@mellanox.com>
> Cc: Thomas Gleixner <tglx@linutronix.de>
> Cc: Ingo Molnar <mingo@redhat.com>
> Cc: "H. Peter Anvin" <hpa@zytor.com>
> ---
>  arch/ia64/mm/init.c            | 19 ++++++++++++++++---
>  arch/powerpc/mm/mem.c          | 18 +++++++++++++++---
>  arch/s390/mm/init.c            | 10 ++++++++--
>  arch/sh/mm/init.c              | 18 +++++++++++++++---
>  arch/tile/mm/init.c            | 10 ++++++++--
>  arch/x86/mm/init_32.c          | 19 ++++++++++++++++---
>  arch/x86/mm/init_64.c          | 19 ++++++++++++++++---
>  include/linux/memory_hotplug.h | 17 +++++++++++++++--
>  kernel/memremap.c              |  4 ++--
>  mm/memory_hotplug.c            |  4 ++--
>  10 files changed, 113 insertions(+), 25 deletions(-)
> 
> diff --git a/arch/ia64/mm/init.c b/arch/ia64/mm/init.c
> index 1841ef6..95a2fa5 100644
> --- a/arch/ia64/mm/init.c
> +++ b/arch/ia64/mm/init.c
> @@ -645,7 +645,7 @@ mem_init (void)
>  }
>  
>  #ifdef CONFIG_MEMORY_HOTPLUG
> -int arch_add_memory(int nid, u64 start, u64 size, bool for_device)
> +int arch_add_memory(int nid, u64 start, u64 size, int flags)
>  {
>  	pg_data_t *pgdat;
>  	struct zone *zone;
> @@ -653,10 +653,17 @@ int arch_add_memory(int nid, u64 start, u64 size, bool for_device)
>  	unsigned long nr_pages = size >> PAGE_SHIFT;
>  	int ret;
>  
> +	/* Need to add support for device and unaddressable memory if needed */
> +	if (flags & MEMORY_UNADDRESSABLE) {
> +		BUG();
> +		return -EINVAL;
> +	}
> +
>  	pgdat = NODE_DATA(nid);
>  
>  	zone = pgdat->node_zones +
> -		zone_for_memory(nid, start, size, ZONE_NORMAL, for_device);
> +		zone_for_memory(nid, start, size, ZONE_NORMAL,
> +				flags & MEMORY_DEVICE);
>  	ret = __add_pages(nid, zone, start_pfn, nr_pages);
>  
>  	if (ret)
> @@ -667,13 +674,19 @@ int arch_add_memory(int nid, u64 start, u64 size, bool for_device)
>  }
>  
>  #ifdef CONFIG_MEMORY_HOTREMOVE
> -int arch_remove_memory(u64 start, u64 size)
> +int arch_remove_memory(u64 start, u64 size, int flags)
>  {
>  	unsigned long start_pfn = start >> PAGE_SHIFT;
>  	unsigned long nr_pages = size >> PAGE_SHIFT;
>  	struct zone *zone;
>  	int ret;
>  
> +	/* Need to add support for device and unaddressable memory if needed */
> +	if (flags & MEMORY_UNADDRESSABLE) {
> +		BUG();
> +		return -EINVAL;
> +	}
> +
>  	zone = page_zone(pfn_to_page(start_pfn));
>  	ret = __remove_pages(zone, start_pfn, nr_pages);
>  	if (ret)
> diff --git a/arch/powerpc/mm/mem.c b/arch/powerpc/mm/mem.c
> index 5f84433..e3c0532 100644
> --- a/arch/powerpc/mm/mem.c
> +++ b/arch/powerpc/mm/mem.c
> @@ -126,7 +126,7 @@ int __weak remove_section_mapping(unsigned long start, unsigned long end)
>  	return -ENODEV;
>  }
>  
> -int arch_add_memory(int nid, u64 start, u64 size, bool for_device)
> +int arch_add_memory(int nid, u64 start, u64 size, int flags)
>  {
>  	struct pglist_data *pgdata;
>  	struct zone *zone;
> @@ -134,6 +134,12 @@ int arch_add_memory(int nid, u64 start, u64 size, bool for_device)
>  	unsigned long nr_pages = size >> PAGE_SHIFT;
>  	int rc;
>  
> +	/* Need to add support for device and unaddressable memory if needed */
> +	if (flags & MEMORY_UNADDRESSABLE) {
> +		BUG();
> +		return -EINVAL;
> +	}
> +
>  	pgdata = NODE_DATA(nid);
>  
>  	start = (unsigned long)__va(start);
> @@ -147,18 +153,24 @@ int arch_add_memory(int nid, u64 start, u64 size, bool for_device)
>  
>  	/* this should work for most non-highmem platforms */
>  	zone = pgdata->node_zones +
> -		zone_for_memory(nid, start, size, 0, for_device);
> +		zone_for_memory(nid, start, size, 0, flags & MEMORY_DEVICE);
>  
>  	return __add_pages(nid, zone, start_pfn, nr_pages);
>  }
>  
>  #ifdef CONFIG_MEMORY_HOTREMOVE
> -int arch_remove_memory(u64 start, u64 size)
> +int arch_remove_memory(u64 start, u64 size, int flags)
>  {
>  	unsigned long start_pfn = start >> PAGE_SHIFT;
>  	unsigned long nr_pages = size >> PAGE_SHIFT;
>  	struct zone *zone;
>  	int ret;
> +	
> +	/* Need to add support for device and unaddressable memory if needed */
> +	if (flags & MEMORY_UNADDRESSABLE) {
> +		BUG();
> +		return -EINVAL;
> +	}
>  
>  	zone = page_zone(pfn_to_page(start_pfn));
>  	ret = __remove_pages(zone, start_pfn, nr_pages);
> diff --git a/arch/s390/mm/init.c b/arch/s390/mm/init.c
> index f56a39b..4147b87 100644
> --- a/arch/s390/mm/init.c
> +++ b/arch/s390/mm/init.c
> @@ -149,7 +149,7 @@ void __init free_initrd_mem(unsigned long start, unsigned long end)
>  #endif
>  
>  #ifdef CONFIG_MEMORY_HOTPLUG
> -int arch_add_memory(int nid, u64 start, u64 size, bool for_device)
> +int arch_add_memory(int nid, u64 start, u64 size, int flags)
>  {
>  	unsigned long normal_end_pfn = PFN_DOWN(memblock_end_of_DRAM());
>  	unsigned long dma_end_pfn = PFN_DOWN(MAX_DMA_ADDRESS);
> @@ -158,6 +158,12 @@ int arch_add_memory(int nid, u64 start, u64 size, bool for_device)
>  	unsigned long nr_pages;
>  	int rc, zone_enum;
>  
> +	/* Need to add support for device and unaddressable memory if needed */
> +	if (flags & MEMORY_UNADDRESSABLE) {
> +		BUG();
> +		return -EINVAL;
> +	}
> +
>  	rc = vmem_add_mapping(start, size);
>  	if (rc)
>  		return rc;
> @@ -197,7 +203,7 @@ unsigned long memory_block_size_bytes(void)
>  }
>  
>  #ifdef CONFIG_MEMORY_HOTREMOVE
> -int arch_remove_memory(u64 start, u64 size)
> +int arch_remove_memory(u64 start, u64 size, int flags)
>  {
>  	/*
>  	 * There is no hardware or firmware interface which could trigger a
> diff --git a/arch/sh/mm/init.c b/arch/sh/mm/init.c
> index 7549186..f72a402 100644
> --- a/arch/sh/mm/init.c
> +++ b/arch/sh/mm/init.c
> @@ -485,19 +485,25 @@ void free_initrd_mem(unsigned long start, unsigned long end)
>  #endif
>  
>  #ifdef CONFIG_MEMORY_HOTPLUG
> -int arch_add_memory(int nid, u64 start, u64 size, bool for_device)
> +int arch_add_memory(int nid, u64 start, u64 size, int flags)
>  {
>  	pg_data_t *pgdat;
>  	unsigned long start_pfn = PFN_DOWN(start);
>  	unsigned long nr_pages = size >> PAGE_SHIFT;
>  	int ret;
>  
> +	/* Need to add support for device and unaddressable memory if needed */
> +	if (flags & MEMORY_UNADDRESSABLE) {
> +		BUG();
> +		return -EINVAL;
> +	}
> +
>  	pgdat = NODE_DATA(nid);
>  
>  	/* We only have ZONE_NORMAL, so this is easy.. */
>  	ret = __add_pages(nid, pgdat->node_zones +
>  			zone_for_memory(nid, start, size, ZONE_NORMAL,
> -			for_device),
> +					flags & MEMORY_DEVICE),
>  			start_pfn, nr_pages);
>  	if (unlikely(ret))
>  		printk("%s: Failed, __add_pages() == %d\n", __func__, ret);
> @@ -516,13 +522,19 @@ EXPORT_SYMBOL_GPL(memory_add_physaddr_to_nid);
>  #endif
>  
>  #ifdef CONFIG_MEMORY_HOTREMOVE
> -int arch_remove_memory(u64 start, u64 size)
> +int arch_remove_memory(u64 start, u64 size, int flags)
>  {
>  	unsigned long start_pfn = PFN_DOWN(start);
>  	unsigned long nr_pages = size >> PAGE_SHIFT;
>  	struct zone *zone;
>  	int ret;
>  
> +	/* Need to add support for device and unaddressable memory if needed */
> +	if (flags & MEMORY_UNADDRESSABLE) {
> +		BUG();
> +		return -EINVAL;
> +	}
> +
>  	zone = page_zone(pfn_to_page(start_pfn));
>  	ret = __remove_pages(zone, start_pfn, nr_pages);
>  	if (unlikely(ret))
> diff --git a/arch/tile/mm/init.c b/arch/tile/mm/init.c
> index adce254..5fd972c 100644
> --- a/arch/tile/mm/init.c
> +++ b/arch/tile/mm/init.c
> @@ -863,13 +863,19 @@ void __init mem_init(void)
>   * memory to the highmem for now.
>   */
>  #ifndef CONFIG_NEED_MULTIPLE_NODES
> -int arch_add_memory(u64 start, u64 size, bool for_device)
> +int arch_add_memory(u64 start, u64 size, int flags)
>  {
>  	struct pglist_data *pgdata = &contig_page_data;
>  	struct zone *zone = pgdata->node_zones + MAX_NR_ZONES-1;
>  	unsigned long start_pfn = start >> PAGE_SHIFT;
>  	unsigned long nr_pages = size >> PAGE_SHIFT;
>  
> +	/* Need to add support for device and unaddressable memory if needed */
> +	if (flags & MEMORY_UNADDRESSABLE) {
> +		BUG();
> +		return -EINVAL;
> +	}
> +
>  	return __add_pages(zone, start_pfn, nr_pages);
>  }
>  
> @@ -879,7 +885,7 @@ int remove_memory(u64 start, u64 size)
>  }
>  
>  #ifdef CONFIG_MEMORY_HOTREMOVE
> -int arch_remove_memory(u64 start, u64 size)
> +int arch_remove_memory(u64 start, u64 size, int flags)
>  {
>  	/* TODO */
>  	return -EBUSY;
> diff --git a/arch/x86/mm/init_32.c b/arch/x86/mm/init_32.c
> index cf80590..16a9095 100644
> --- a/arch/x86/mm/init_32.c
> +++ b/arch/x86/mm/init_32.c
> @@ -816,24 +816,37 @@ void __init mem_init(void)
>  }
>  
>  #ifdef CONFIG_MEMORY_HOTPLUG
> -int arch_add_memory(int nid, u64 start, u64 size, bool for_device)
> +int arch_add_memory(int nid, u64 start, u64 size, int flags)
>  {
>  	struct pglist_data *pgdata = NODE_DATA(nid);
>  	struct zone *zone = pgdata->node_zones +
> -		zone_for_memory(nid, start, size, ZONE_HIGHMEM, for_device);
> +		zone_for_memory(nid, start, size, ZONE_HIGHMEM,
> +				flags & MEMORY_DEVICE);
>  	unsigned long start_pfn = start >> PAGE_SHIFT;
>  	unsigned long nr_pages = size >> PAGE_SHIFT;
>  
> +	/* Need to add support for device and unaddressable memory if needed */
> +	if (flags & MEMORY_UNADDRESSABLE) {
> +		BUG();
> +		return -EINVAL;
> +	}
> +
>  	return __add_pages(nid, zone, start_pfn, nr_pages);
>  }
>  
>  #ifdef CONFIG_MEMORY_HOTREMOVE
> -int arch_remove_memory(u64 start, u64 size)
> +int arch_remove_memory(u64 start, u64 size, int flags)
>  {
>  	unsigned long start_pfn = start >> PAGE_SHIFT;
>  	unsigned long nr_pages = size >> PAGE_SHIFT;
>  	struct zone *zone;
>  
> +	/* Need to add support for device and unaddressable memory if needed */
> +	if (flags & MEMORY_UNADDRESSABLE) {
> +		BUG();
> +		return -EINVAL;
> +	}
> +
>  	zone = page_zone(pfn_to_page(start_pfn));
>  	return __remove_pages(zone, start_pfn, nr_pages);
>  }
> diff --git a/arch/x86/mm/init_64.c b/arch/x86/mm/init_64.c
> index 14b9dd7..8c4abb0 100644
> --- a/arch/x86/mm/init_64.c
> +++ b/arch/x86/mm/init_64.c
> @@ -651,15 +651,22 @@ static void  update_end_of_memory_vars(u64 start, u64 size)
>   * Memory is added always to NORMAL zone. This means you will never get
>   * additional DMA/DMA32 memory.
>   */
> -int arch_add_memory(int nid, u64 start, u64 size, bool for_device)
> +int arch_add_memory(int nid, u64 start, u64 size, int flags)
>  {
>  	struct pglist_data *pgdat = NODE_DATA(nid);
>  	struct zone *zone = pgdat->node_zones +
> -		zone_for_memory(nid, start, size, ZONE_NORMAL, for_device);
> +		zone_for_memory(nid, start, size, ZONE_NORMAL,
> +				flags & MEMORY_DEVICE);
>  	unsigned long start_pfn = start >> PAGE_SHIFT;
>  	unsigned long nr_pages = size >> PAGE_SHIFT;
>  	int ret;
>  
> +	/* Need to add support for device and unaddressable memory if needed */
> +	if (flags & MEMORY_UNADDRESSABLE) {
> +		BUG();
> +		return -EINVAL;
> +	}
> +
>  	init_memory_mapping(start, start + size);
>  
>  	ret = __add_pages(nid, zone, start_pfn, nr_pages);
> @@ -956,7 +963,7 @@ kernel_physical_mapping_remove(unsigned long start, unsigned long end)
>  	remove_pagetable(start, end, true);
>  }
>  
> -int __ref arch_remove_memory(u64 start, u64 size)
> +int __ref arch_remove_memory(u64 start, u64 size, int flags)
>  {
>  	unsigned long start_pfn = start >> PAGE_SHIFT;
>  	unsigned long nr_pages = size >> PAGE_SHIFT;
> @@ -965,6 +972,12 @@ int __ref arch_remove_memory(u64 start, u64 size)
>  	struct zone *zone;
>  	int ret;
>  
> +	/* Need to add support for device and unaddressable memory if needed */
> +	if (flags & MEMORY_UNADDRESSABLE) {
> +		BUG();
> +		return -EINVAL;
> +	}
> +
>  	/* With altmap the first mapped page is offset from @start */
>  	altmap = to_vmem_altmap((unsigned long) page);
>  	if (altmap)

So with this patch none of the architectures support un-addressable
memory but then support will be added through later patches ?
zone_for_memory function's flag now takes MEMORY_DEVICE parameter.
Then we need to change all the previous ZONE_DEVICE changes which
ever took "for_device" to accommodate this new flag ? just curious.

> diff --git a/include/linux/memory_hotplug.h b/include/linux/memory_hotplug.h
> index 01033fa..ba9b12e 100644
> --- a/include/linux/memory_hotplug.h
> +++ b/include/linux/memory_hotplug.h
> @@ -103,7 +103,7 @@ extern bool memhp_auto_online;
>  
>  #ifdef CONFIG_MEMORY_HOTREMOVE
>  extern bool is_pageblock_removable_nolock(struct page *page);
> -extern int arch_remove_memory(u64 start, u64 size);
> +extern int arch_remove_memory(u64 start, u64 size, int flags);
>  extern int __remove_pages(struct zone *zone, unsigned long start_pfn,
>  	unsigned long nr_pages);
>  #endif /* CONFIG_MEMORY_HOTREMOVE */
> @@ -275,7 +275,20 @@ extern int add_memory(int nid, u64 start, u64 size);
>  extern int add_memory_resource(int nid, struct resource *resource, bool online);
>  extern int zone_for_memory(int nid, u64 start, u64 size, int zone_default,
>  		bool for_device);
> -extern int arch_add_memory(int nid, u64 start, u64 size, bool for_device);
> +
> +/*
> + * For device memory we want more informations than just knowing it is device
> + * memory. We want to know if we can migrate it (ie it is not storage memory
> + * use by DAX). Is it addressable by the CPU ? Some device memory like GPU
> + * memory can not be access by CPU but we still want struct page so that we
> + * can use it like regular memory.

Some typos here. Needs to be cleaned up as well. But please have a
look at comment below over the classification itself.

> + */
> +#define MEMORY_FLAGS_NONE 0
> +#define MEMORY_DEVICE (1 << 0)
> +#define MEMORY_MOVABLE (1 << 1)
> +#define MEMORY_UNADDRESSABLE (1 << 2)

It should be DEVICE_MEMORY_* instead of MEMORY_* as we are trying to
classify device memory (though they are represented with struct page)
not regular system ram memory. This should attempt to classify device
memory which is backed by struct pages. arch_add_memory/arch_remove
_memory does not come into play if it's traditional device memory
which is just PFN and does not have struct page associated with it.

Broadly they are either CPU accessible or in-accessible. Storage
memory like persistent memory represented though ZONE_DEVICE fall
under the accessible (coherent) category. IIUC right now they are
not movable because page->pgmap replaces page->lru in struct page
hence its inability to be on standard LRU lists as one of the
reasons. As there was a need to have struct page to exploit more
core VM features on these memory going forward it will have to be
migratable one way or the other to accommodate features like
compaction, HW poison etc in these storage memory. Hence my point
here is lets not classify any of these memories as non-movable.
Just addressable or not should be the only classification.

> +
> +extern int arch_add_memory(int nid, u64 start, u64 size, int flags);
>  extern int offline_pages(unsigned long start_pfn, unsigned long nr_pages);
>  extern bool is_memblock_offlined(struct memory_block *mem);
>  extern void remove_memory(int nid, u64 start, u64 size);
> diff --git a/kernel/memremap.c b/kernel/memremap.c
> index b501e39..07665eb 100644
> --- a/kernel/memremap.c
> +++ b/kernel/memremap.c
> @@ -246,7 +246,7 @@ static void devm_memremap_pages_release(struct device *dev, void *data)
>  	/* pages are dead and unused, undo the arch mapping */
>  	align_start = res->start & ~(SECTION_SIZE - 1);
>  	align_size = ALIGN(resource_size(res), SECTION_SIZE);
> -	arch_remove_memory(align_start, align_size);
> +	arch_remove_memory(align_start, align_size, MEMORY_DEVICE);
>  	untrack_pfn(NULL, PHYS_PFN(align_start), align_size);
>  	pgmap_radix_release(res);
>  	dev_WARN_ONCE(dev, pgmap->altmap && pgmap->altmap->alloc,
> @@ -358,7 +358,7 @@ void *devm_memremap_pages(struct device *dev, struct resource *res,
>  	if (error)
>  		goto err_pfn_remap;
>  
> -	error = arch_add_memory(nid, align_start, align_size, true);
> +	error = arch_add_memory(nid, align_start, align_size, MEMORY_DEVICE);
>  	if (error)
>  		goto err_add_memory;
>  
> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> index 9629273..b2942d7 100644
> --- a/mm/memory_hotplug.c
> +++ b/mm/memory_hotplug.c
> @@ -1386,7 +1386,7 @@ int __ref add_memory_resource(int nid, struct resource *res, bool online)
>  	}
>  
>  	/* call arch's memory hotadd */
> -	ret = arch_add_memory(nid, start, size, false);
> +	ret = arch_add_memory(nid, start, size, MEMORY_FLAGS_NONE);
>  
>  	if (ret < 0)
>  		goto error;
> @@ -2205,7 +2205,7 @@ void __ref remove_memory(int nid, u64 start, u64 size)
>  	memblock_free(start, size);
>  	memblock_remove(start, size);
>  
> -	arch_remove_memory(start, size);
> +	arch_remove_memory(start, size, MEMORY_FLAGS_NONE);

Right, these are system RAM hotplug paths and device memory should
never get plugged in/out from this path.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
