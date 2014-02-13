Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f179.google.com (mail-pd0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id 334976B0035
	for <linux-mm@kvack.org>; Wed, 12 Feb 2014 21:17:55 -0500 (EST)
Received: by mail-pd0-f179.google.com with SMTP id fp1so9498301pdb.10
        for <linux-mm@kvack.org>; Wed, 12 Feb 2014 18:17:54 -0800 (PST)
Received: from smtp.codeaurora.org (smtp.codeaurora.org. [198.145.11.231])
        by mx.google.com with ESMTPS id vb2si302752pbc.67.2014.02.12.18.17.53
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 12 Feb 2014 18:17:53 -0800 (PST)
Message-ID: <52FC2B4F.6090201@codeaurora.org>
Date: Wed, 12 Feb 2014 18:17:51 -0800
From: Laura Abbott <lauraa@codeaurora.org>
MIME-Version: 1.0
Subject: Re: [PATCHv3 2/2] arm: Get rid of meminfo
References: <1392153265-14439-1-git-send-email-lauraa@codeaurora.org> <1392153265-14439-3-git-send-email-lauraa@codeaurora.org> <52FB8E91.8030400@ti.com>
In-Reply-To: <52FB8E91.8030400@ti.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Grygorii Strashko <grygorii.strashko@ti.com>, Russell King <linux@arm.linux.org.uk>, David Brown <davidb@codeaurora.org>, Daniel Walker <dwalker@fifo99.com>, Jason Cooper <jason@lakedaemon.net>, Andrew Lunn <andrew@lunn.ch>, Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>, Eric Miao <eric.y.miao@gmail.com>, Haojian Zhuang <haojian.zhuang@gmail.com>, Ben Dooks <ben-linux@fluff.org>, Kukjin Kim <kgene.kim@samsung.com>, linux-arm-kernel@lists.infradead.org
Cc: linux-kernel@vger.kernel.org, linux-arm-msm@vger.kernel.org, Leif Lindholm <leif.lindholm@linaro.org>, Catalin Marinas <catalin.marinas@arm.com>, Rob Herring <robherring2@gmail.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Will Deacon <will.deacon@arm.com>, Nicolas Pitre <nicolas.pitre@linaro.org>, Santosh Shilimkar <santosh.shilimkar@ti.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Courtney Cavin <courtney.cavin@sonymobile.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Grant Likely <grant.likely@secretlab.ca>

On 2/12/2014 7:09 AM, Grygorii Strashko wrote:
> Hi Laura,
>
> On 02/11/2014 11:14 PM, Laura Abbott wrote:
>> memblock is now fully integrated into the kernel and is the prefered
>> method for tracking memory. Rather than reinvent the wheel with
>> meminfo, migrate to using memblock directly instead of meminfo as
>> an intermediate.
>>
>> Acked-by: Jason Cooper <jason@lakedaemon.net>
>> Acked-by: Catalin Marinas <catalin.marinas@arm.com>
>> Acked-by: Santosh Shilimkar <santosh.shilimkar@ti.com>
>> Tested-by: Leif Lindholm <leif.lindholm@linaro.org>
>> Signed-off-by: Laura Abbott <lauraa@codeaurora.org>
>> ---
>>    arch/arm/include/asm/mach/arch.h         |    4 +-
>>    arch/arm/include/asm/memblock.h          |    3 +-
>>    arch/arm/include/asm/setup.h             |   23 ------
>>    arch/arm/kernel/atags_parse.c            |    5 +-
>>    arch/arm/kernel/devtree.c                |    5 --
>>    arch/arm/kernel/setup.c                  |   30 ++------
>>    arch/arm/mach-clps711x/board-clep7312.c  |    7 +-
>>    arch/arm/mach-clps711x/board-edb7211.c   |   10 +--
>>    arch/arm/mach-clps711x/board-p720t.c     |    2 +-
>>    arch/arm/mach-footbridge/cats-hw.c       |    2 +-
>>    arch/arm/mach-footbridge/netwinder-hw.c  |    2 +-
>>    arch/arm/mach-msm/board-halibut.c        |    6 --
>>    arch/arm/mach-msm/board-mahimahi.c       |   13 +---
>>    arch/arm/mach-msm/board-msm7x30.c        |    3 +-
>>    arch/arm/mach-msm/board-sapphire.c       |   13 ++--
>>    arch/arm/mach-msm/board-trout.c          |    8 +--
>>    arch/arm/mach-orion5x/common.c           |    3 +-
>>    arch/arm/mach-orion5x/common.h           |    3 +-
>>    arch/arm/mach-pxa/cm-x300.c              |    3 +-
>>    arch/arm/mach-pxa/corgi.c                |   10 +--
>>    arch/arm/mach-pxa/eseries.c              |    9 +--
>>    arch/arm/mach-pxa/poodle.c               |    8 +--
>>    arch/arm/mach-pxa/spitz.c                |    8 +--
>>    arch/arm/mach-pxa/tosa.c                 |    8 +--
>>    arch/arm/mach-realview/core.c            |   11 +--
>>    arch/arm/mach-realview/core.h            |    3 +-
>>    arch/arm/mach-realview/realview_pb1176.c |    8 +--
>>    arch/arm/mach-realview/realview_pbx.c    |   17 ++---
>>    arch/arm/mach-s3c24xx/mach-smdk2413.c    |    8 +--
>>    arch/arm/mach-s3c24xx/mach-vstms.c       |    8 +--
>>    arch/arm/mach-sa1100/assabet.c           |    2 +-
>>    arch/arm/mm/init.c                       |   67 +++++++-----------
>>    arch/arm/mm/mmu.c                        |  115 +++++++++---------------------
>
> The arch/arm/mm/nommu.c has to be updated too :)
>

Sure does.

> [...]
>
> I've tested your change on keystone (with some additional printouts in sanity_check_meminfo())
> and got following results:
>
> - without your change + HIGHMEM=ON
> [    0.000000] ==== memblock_limit0x00000000af800000, arm_lowmem_limit0x00000000af800000 high_memoryef800000 vmalloc_limit0x00000000af800000
>
>   - without your change + HIGHMEM=OFF
> [    0.000000] Truncating RAM at 80000000-bfffffff to -af7fffff (vmalloc region overlap).
> [    0.000000] ==== memblock_limit0x00000000af800000, arm_lowmem_limit0x00000000af800000 high_memoryef800000 vmalloc_limit0x00000000af800000
>
> - with your change + HIGHMEM=ON
> [    0.000000] ==== memblock_limit0x00000000af800000, arm_lowmem_limit0x00000000af800000 high_memoryef800000 vmalloc_limit0x00000000af800000
>
> - with your change + HIGHMEM=OFF
> [    0.000000] Truncating RAM at 0x0000000080000000-0x00000000c0000000 to -0x0000000010800000
>                                                                            ^printout changed
> [    0.000000] ==== memblock_limit0x00000000af800000, arm_lowmem_limit0x00000000af800000 high_memoryef800000 vmalloc_limit0x00000000af800000
>
> Keystone mem defined as: from@0x80000000 size@0x40000000 (LPAE=OFF)
>
> As result, i have few comments regarding sanity_check_meminfo() changes as I think there are
> some issues &side effects changes at least in printouts - see below.
>
>>    	memblock_reserve(__pa(_sdata), _end - _sdata);
>> @@ -413,54 +397,53 @@ free_memmap(unsigned long start_pfn, unsigned long end_pfn)
>>    /*
>>     * The mem_map array can get very big.  Free the unused area of the memory map.
>>     */
>> -static void __init free_unused_memmap(struct meminfo *mi)
>> +static void __init free_unused_memmap(void)
>>    {
>> -	unsigned long bank_start, prev_bank_end = 0;
>> -	unsigned int i;
>> +	unsigned long start, prev_end = 0;
>> +	struct memblock_region *reg;
>>
>>    	/*
>>    	 * This relies on each bank being in address order.
>>    	 * The banks are sorted previously in bootmem_init().
>>    	 */
>> -	for_each_bank(i, mi) {
>> -		struct membank *bank = &mi->bank[i];
>> -
>> -		bank_start = bank_pfn_start(bank);
>> +	for_each_memblock(memory, reg) {
>> +		start = __phys_to_pfn(reg->base);
>
> memblock_region_memory_base_pfn() can be used here.
>

Okay

>>
>>    #ifdef CONFIG_SPARSEMEM
>>    		/*
>>    		 * Take care not to free memmap entries that don't exist
>>    		 * due to SPARSEMEM sections which aren't present.
>>    		 */
>> -		bank_start = min(bank_start,
>> -				 ALIGN(prev_bank_end, PAGES_PER_SECTION));
>> +		start = min(start,
>> +				 ALIGN(prev_end, PAGES_PER_SECTION));
>>    #else
>>    		/*
>>    		 * Align down here since the VM subsystem insists that the
>>    		 * memmap entries are valid from the bank start aligned to
>>    		 * MAX_ORDER_NR_PAGES.
>>    		 */
>> -		bank_start = round_down(bank_start, MAX_ORDER_NR_PAGES);
>> +		start = round_down(start, MAX_ORDER_NR_PAGES);
>>    #endif
>>    		/*
>>    		 * If we had a previous bank, and there is a space
>>    		 * between the current bank and the previous, free it.
>>    		 */
>> -		if (prev_bank_end && prev_bank_end < bank_start)
>> -			free_memmap(prev_bank_end, bank_start);
>> +		if (prev_end && prev_end < start)
>> +			free_memmap(prev_end, start);
>>
>>    		/*
>>    		 * Align up here since the VM subsystem insists that the
>>    		 * memmap entries are valid from the bank end aligned to
>>    		 * MAX_ORDER_NR_PAGES.
>>    		 */
>> -		prev_bank_end = ALIGN(bank_pfn_end(bank), MAX_ORDER_NR_PAGES);
>> +		prev_end = ALIGN(start + __phys_to_pfn(reg->size),
>
> I think, start + __phys_to_pfn(reg->size) can be replaced by
> memblock_region_memory_end_pfn().
>

Okay

>> +				 MAX_ORDER_NR_PAGES);
>>    	}
>>
>>    #ifdef CONFIG_SPARSEMEM
>> -	if (!IS_ALIGNED(prev_bank_end, PAGES_PER_SECTION))
>> -		free_memmap(prev_bank_end,
>> -			    ALIGN(prev_bank_end, PAGES_PER_SECTION));
>> +	if (!IS_ALIGNED(prev_end, PAGES_PER_SECTION))
>> +		free_memmap(prev_end,
>> +			    ALIGN(prev_end, PAGES_PER_SECTION));
>>    #endif
>>    }
>>
>> @@ -536,7 +519,7 @@ void __init mem_init(void)
>>    	set_max_mapnr(pfn_to_page(max_pfn) - mem_map);
>>
>>    	/* this will put all unused low memory onto the freelists */
>> -	free_unused_memmap(&meminfo);
>> +	free_unused_memmap();
>>    	free_all_bootmem();
>>
>>    #ifdef CONFIG_SA1111
>> diff --git a/arch/arm/mm/mmu.c b/arch/arm/mm/mmu.c
>> index 4f08c13..23433ef 100644
>> --- a/arch/arm/mm/mmu.c
>> +++ b/arch/arm/mm/mmu.c
>> @@ -1046,74 +1046,44 @@ phys_addr_t arm_lowmem_limit __initdata = 0;
>>    void __init sanity_check_meminfo(void)
>>    {
>>    	phys_addr_t memblock_limit = 0;
>> -	int i, j, highmem = 0;
>> +	int highmem = 0;
>>    	phys_addr_t vmalloc_limit = __pa(vmalloc_min - 1) + 1;
>> +	struct memblock_region *reg;
>>
>> -	for (i = 0, j = 0; i < meminfo.nr_banks; i++) {
>> -		struct membank *bank = &meminfo.bank[j];
>> -		phys_addr_t size_limit;
>> -
>> -		*bank = meminfo.bank[i];
>> -		size_limit = bank->size;
>> +	for_each_memblock(memory, reg) {
>> +		phys_addr_t block_start = reg->base;
>> +		phys_addr_t block_end = reg->base + reg->size;
>> +		phys_addr_t size_limit = reg->size;
>>
>> -		if (bank->start >= vmalloc_limit)
>> +		if (reg->base >= vmalloc_limit)
>>    			highmem = 1;
>>    		else
>> -			size_limit = vmalloc_limit - bank->start;
>> +			size_limit = vmalloc_limit - reg->base;
>>
>> -		bank->highmem = highmem;
>>
>> -#ifdef CONFIG_HIGHMEM
>> -		/*
>> -		 * Split those memory banks which are partially overlapping
>> -		 * the vmalloc area greatly simplifying things later.
>> -		 */
>> -		if (!highmem && bank->size > size_limit) {
>> -			if (meminfo.nr_banks >= NR_BANKS) {
>> -				printk(KERN_CRIT "NR_BANKS too low, "
>> -						 "ignoring high memory\n");
>> -			} else {
>> -				memmove(bank + 1, bank,
>> -					(meminfo.nr_banks - i) * sizeof(*bank));
>> -				meminfo.nr_banks++;
>> -				i++;
>> -				bank[1].size -= size_limit;
>> -				bank[1].start = vmalloc_limit;
>> -				bank[1].highmem = highmem = 1;
>> -				j++;
>> +		if (!IS_ENABLED(CONFIG_HIGHMEM) || cache_is_vipt_aliasing()) {
>> +
>> +			if (highmem) {
>> +				pr_notice("Ignoring ram at %pa-%pa (!CONFIG_HIGHMEM)\n",
>> +					&block_start, &block_end);
>> +				memblock_remove(block_start, block_end);
>
> The wrong size is used here, should be => memblock_remove(block_start, reg->size);
> or => memblock_remove(block_start, size_limit);
>

Yes, you are correct. I'm guessing I meant to do block_end-block_start 
and missed the last part.

>> +				continue;
>>    			}
>> -			bank->size = size_limit;
>> -		}
>> -#else
>> -		/*
>> -		 * Highmem banks not allowed with !CONFIG_HIGHMEM.
>> -		 */
>> -		if (highmem) {
>> -			printk(KERN_NOTICE "Ignoring RAM at %.8llx-%.8llx "
>> -			       "(!CONFIG_HIGHMEM).\n",
>> -			       (unsigned long long)bank->start,
>> -			       (unsigned long long)bank->start + bank->size - 1);
>> -			continue;
>> -		}
>>
>> -		/*
>> -		 * Check whether this memory bank would partially overlap
>> -		 * the vmalloc area.
>> -		 */
>> -		if (bank->size > size_limit) {
>> -			printk(KERN_NOTICE "Truncating RAM at %.8llx-%.8llx "
>> -			       "to -%.8llx (vmalloc region overlap).\n",
>> -			       (unsigned long long)bank->start,
>> -			       (unsigned long long)bank->start + bank->size - 1,
>> -			       (unsigned long long)bank->start + size_limit - 1);
>> -			bank->size = size_limit;
>> +			if (reg->size > size_limit) {
>> +				phys_addr_t overlap_size = reg->size - size_limit;
>> +
>> +				pr_notice("Truncating RAM at %pa-%pa to -%pa",
>> +					&block_start, &block_end, &overlap_size);
>
> Pls, change it back to show new RAM limit instead of size.
> pr_notice("Truncating RAM at %pa-%pa to -%pa",
> 				&block_start, &block_end, &vmalloc_limit);
>
>
>> +				memblock_remove(vmalloc_limit, overlap_size);
>> +				block_end = vmalloc_limit;
>> +			}
>>    		}
>> -#endif
>> -		if (!bank->highmem) {
>> -			phys_addr_t bank_end = bank->start + bank->size;
>>
>> -			if (bank_end > arm_lowmem_limit)
>> -				arm_lowmem_limit = bank_end;
>> +		if (!highmem) {
>> +			if (block_end > arm_lowmem_limit)
>> +				arm_lowmem_limit = reg->base + size_limit;
>> +
>
> if !highmem then size_limit will be calculated as vmalloc_limit - reg->base
> which in turn can be greater than reg->size. So, arm_lowmem_limit can point on
> non existent memory address.
>
> Seems, it should be:
>    arm_lowmem_limit = block_end;
>

Yes, I believe so. I will review it.

>>
>>    			/*
>>    			 * Find the first non-section-aligned page, and point
>> @@ -1129,35 +1099,16 @@ void __init sanity_check_meminfo(void)
>>    			 * occurs before any free memory is mapped.
>>    			 */
>>    			if (!memblock_limit) {
>> -				if (!IS_ALIGNED(bank->start, SECTION_SIZE))
>> -					memblock_limit = bank->start;
>> -				else if (!IS_ALIGNED(bank_end, SECTION_SIZE))
>> -					memblock_limit = bank_end;
> [...]
>
> Thanks for your patience :)
>

Thanks for the review and debugging!

> Regards,
> -grygorii
>

Thanks,
Laura

-- 
Qualcomm Innovation Center, Inc. is a member of Code Aurora Forum,
hosted by The Linux Foundation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
