Return-Path: <SRS0=aXoD=SR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A4AC8C282CE
	for <linux-mm@archiver.kernel.org>; Mon, 15 Apr 2019 02:05:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 327B72084E
	for <linux-mm@archiver.kernel.org>; Mon, 15 Apr 2019 02:05:35 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 327B72084E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=huawei.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8DB196B0003; Sun, 14 Apr 2019 22:05:34 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8613E6B0006; Sun, 14 Apr 2019 22:05:34 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 72A8C6B0007; Sun, 14 Apr 2019 22:05:34 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f71.google.com (mail-ot1-f71.google.com [209.85.210.71])
	by kanga.kvack.org (Postfix) with ESMTP id 3EA296B0003
	for <linux-mm@kvack.org>; Sun, 14 Apr 2019 22:05:34 -0400 (EDT)
Received: by mail-ot1-f71.google.com with SMTP id w11so8366030otq.7
        for <linux-mm@kvack.org>; Sun, 14 Apr 2019 19:05:34 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to
         :references:cc:from:message-id:date:user-agent:mime-version
         :in-reply-to:content-transfer-encoding;
        bh=VG4iy0kN7LCiQxzI4cVJokR7b8b9Na+kC4ax7SFlVb8=;
        b=KE3I7xFkAE4NmAau8eBrXX/BaT/I9vjP0HQsfJP4SZdU7y9NugVBXuslOmieIx5AdV
         RPNi1mXAiR+deirhWzvNn5ZhQyescXm1khRcdYyOwAau8/ccutZ1bAwPkRCrdhqErCW9
         gYh1q2PH9ToJfE8U4SrSgsgR5ZpNS2XHmzg9av8vCRIDr+Yfrj+XfXDVud1NwCSZaSFz
         O3h9LUBioQMQoV++lhZoP0nTTsvzKvgh8DWebuxE/TnC/pMxHlu9Otzb2xDnFAhcpwPZ
         5Or4GQdv8ap6RWqDfwp3tiJV6cc0LE6jKsVSOuaETrAB3/42BwjWV4AU2l67Tpzg0u+V
         Shrg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of chenzhou10@huawei.com designates 45.249.212.35 as permitted sender) smtp.mailfrom=chenzhou10@huawei.com
X-Gm-Message-State: APjAAAWFg6L/2XGO2C0s4UPz1yVsG2WWftnhzkf2AhJGboq46Vpm4qMP
	Cl1yEIqADH973Hq/+4Mbgvfzoh2iW2kI7ulFrdu0oT8AwfUFZOfFTWkV6RKgxfTGjiatO5QnaFm
	mY6xuIMX0NfTR7/KyCLDYmrgwXKj/leLgkRgHjSeetkyj8tmgL7WfpmbNzcGznfb31g==
X-Received: by 2002:aca:fc8f:: with SMTP id a137mr17659417oii.141.1555293933814;
        Sun, 14 Apr 2019 19:05:33 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzBFIwJiJC2ByVqcPT9jzW6y9bYuKC3xHAmVJs7e5AetQR6e/Z7HL+NUYrBN5r//YOlSr9d
X-Received: by 2002:aca:fc8f:: with SMTP id a137mr17659387oii.141.1555293932650;
        Sun, 14 Apr 2019 19:05:32 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555293932; cv=none;
        d=google.com; s=arc-20160816;
        b=q8XHkqCKnbMMOTCsOUBpmQr8t6osLzTfPklE5ZN7WO/dVcoEh/+SIujGJGHAW06RtW
         P9cXhekO0R1xx9ZOceUSj/E/an9qpik4M2vK8GbMl3RSLA61c9vcqe3959krO/RIPeBC
         XyAe5b5WeVIZ5rp2CVvB11tRPWhneS8B4DKcpwlPkQJUm6b+eMOh35+yaapHWNUrNCHK
         F3MpiTmTJw5IYkfafs5GuXvTD3lv9yvv2ZcXlq10C/j2BMknN+DjkDRdxPGCaC3b9XKv
         9aN/zYIYLpvvSD8ut0h07lM/GNm/RY4Zsk7MhoUUwvI4hm2qTIX9LCJBbpQbzB0rlb9M
         Yguw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:in-reply-to:mime-version:user-agent:date
         :message-id:from:cc:references:to:subject;
        bh=VG4iy0kN7LCiQxzI4cVJokR7b8b9Na+kC4ax7SFlVb8=;
        b=PJFWuQUN3CA3gXxx1QECz5fpzMAmG9lHfKAqspZfCaY7XzVheV8CTlpyWIFnPnhYUJ
         FYhHtDsDrqUXuXr5XqeAGrwS89xDckSkQzOYS+vx7dlimxUe8Gp6JAHZ6qPYmiDo5SWP
         MYFepacTfQFdVaZYjlkKRd5Ub8APOKYwugdn47DCq5axxx6yegaPmVg0Yj56ugbW9bX4
         YcnuaUN8miw9yYhSK1qol0rmWGXEwZOZQqpUgG9vzJFslRLYnTrBNLO0bbn2NPL5qhOH
         wICLd64lVtTBzUhKBtz/yrFcaMxTx4VDgENjGn0itQEAAKP8d7Hnezi5LzFjEjP1IPH9
         cVyw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of chenzhou10@huawei.com designates 45.249.212.35 as permitted sender) smtp.mailfrom=chenzhou10@huawei.com
Received: from huawei.com (szxga07-in.huawei.com. [45.249.212.35])
        by mx.google.com with ESMTPS id q15si22386704ota.111.2019.04.14.19.05.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 14 Apr 2019 19:05:32 -0700 (PDT)
Received-SPF: pass (google.com: domain of chenzhou10@huawei.com designates 45.249.212.35 as permitted sender) client-ip=45.249.212.35;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of chenzhou10@huawei.com designates 45.249.212.35 as permitted sender) smtp.mailfrom=chenzhou10@huawei.com
Received: from DGGEMS411-HUB.china.huawei.com (unknown [172.30.72.59])
	by Forcepoint Email with ESMTP id 2B1A3B1DC1772B0485CC;
	Mon, 15 Apr 2019 10:05:27 +0800 (CST)
Received: from [127.0.0.1] (10.177.131.64) by DGGEMS411-HUB.china.huawei.com
 (10.3.19.211) with Microsoft SMTP Server id 14.3.408.0; Mon, 15 Apr 2019
 10:05:21 +0800
Subject: Re: [PATCH v3 3/4] arm64: kdump: support more than one crash kernel
 regions
To: Mike Rapoport <rppt@linux.ibm.com>
References: <20190409102819.121335-1-chenzhou10@huawei.com>
 <20190409102819.121335-4-chenzhou10@huawei.com>
 <20190410130917.GC17196@rapoport-lnx>
 <137bef2e-8726-fd8f-1cb0-7592074f7870@huawei.com>
 <20190414121058.GC20947@rapoport-lnx>
CC: <tglx@linutronix.de>, <mingo@redhat.com>, <bp@alien8.de>,
	<ebiederm@xmission.com>, <catalin.marinas@arm.com>, <will.deacon@arm.com>,
	<akpm@linux-foundation.org>, <ard.biesheuvel@linaro.org>,
	<horms@verge.net.au>, <takahiro.akashi@linaro.org>,
	<linux-arm-kernel@lists.infradead.org>, <linux-kernel@vger.kernel.org>,
	<kexec@lists.infradead.org>, <linux-mm@kvack.org>,
	<wangkefeng.wang@huawei.com>
From: Chen Zhou <chenzhou10@huawei.com>
Message-ID: <b5206f0c-d711-427e-256a-98b2e30c1ab0@huawei.com>
Date: Mon, 15 Apr 2019 10:05:18 +0800
User-Agent: Mozilla/5.0 (Windows NT 6.1; WOW64; rv:45.0) Gecko/20100101
 Thunderbird/45.7.1
MIME-Version: 1.0
In-Reply-To: <20190414121058.GC20947@rapoport-lnx>
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
X-Originating-IP: [10.177.131.64]
X-CFilter-Loop: Reflected
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Mike,

On 2019/4/14 20:10, Mike Rapoport wrote:
> Hi,
> 
> On Thu, Apr 11, 2019 at 08:17:43PM +0800, Chen Zhou wrote:
>> Hi Mike,
>>
>> This overall looks well.
>> Replacing memblock_cap_memory_range() with memblock_cap_memory_ranges() was what i wanted
>> to do in v1, sorry for don't express that clearly.
> 
> I didn't object to memblock_cap_memory_ranges() in general, I was worried
> about it's complexity and I hoped that we could find a simpler solution.
>  
>> But there are some issues as below. After fixing this, it can work correctly.
>>
>> On 2019/4/10 21:09, Mike Rapoport wrote:
>>> Hi,
>>>
>>> On Tue, Apr 09, 2019 at 06:28:18PM +0800, Chen Zhou wrote:
>>>> After commit (arm64: kdump: support reserving crashkernel above 4G),
>>>> there may be two crash kernel regions, one is below 4G, the other is
>>>> above 4G.
>>>>
>>>> Crash dump kernel reads more than one crash kernel regions via a dtb
>>>> property under node /chosen,
>>>> linux,usable-memory-range = <BASE1 SIZE1 [BASE2 SIZE2]>
>>>>
>>>> Signed-off-by: Chen Zhou <chenzhou10@huawei.com>
>>>> ---
>>>>  arch/arm64/mm/init.c     | 66 ++++++++++++++++++++++++++++++++++++++++--------
>>>>  include/linux/memblock.h |  6 +++++
>>>>  mm/memblock.c            |  7 ++---
>>>>  3 files changed, 66 insertions(+), 13 deletions(-)
>>>>
>>>> diff --git a/arch/arm64/mm/init.c b/arch/arm64/mm/init.c
>>>> index 3bebddf..0f18665 100644
>>>> --- a/arch/arm64/mm/init.c
>>>> +++ b/arch/arm64/mm/init.c
>>>> @@ -65,6 +65,11 @@ phys_addr_t arm64_dma_phys_limit __ro_after_init;
>>>>  
>>>>  #ifdef CONFIG_KEXEC_CORE
>>>>  
>>>> +/* at most two crash kernel regions, low_region and high_region */
>>>> +#define CRASH_MAX_USABLE_RANGES	2
>>>> +#define LOW_REGION_IDX			0
>>>> +#define HIGH_REGION_IDX			1
>>>> +
>>>>  /*
>>>>   * reserve_crashkernel() - reserves memory for crash kernel
>>>>   *
>>>> @@ -297,8 +302,8 @@ static int __init early_init_dt_scan_usablemem(unsigned long node,
>>>>  		const char *uname, int depth, void *data)
>>>>  {
>>>>  	struct memblock_region *usablemem = data;
>>>> -	const __be32 *reg;
>>>> -	int len;
>>>> +	const __be32 *reg, *endp;
>>>> +	int len, nr = 0;
>>>>  
>>>>  	if (depth != 1 || strcmp(uname, "chosen") != 0)
>>>>  		return 0;
>>>> @@ -307,22 +312,63 @@ static int __init early_init_dt_scan_usablemem(unsigned long node,
>>>>  	if (!reg || (len < (dt_root_addr_cells + dt_root_size_cells)))
>>>>  		return 1;
>>>>  
>>>> -	usablemem->base = dt_mem_next_cell(dt_root_addr_cells, &reg);
>>>> -	usablemem->size = dt_mem_next_cell(dt_root_size_cells, &reg);
>>>> +	endp = reg + (len / sizeof(__be32));
>>>> +	while ((endp - reg) >= (dt_root_addr_cells + dt_root_size_cells)) {
>>>> +		usablemem[nr].base = dt_mem_next_cell(dt_root_addr_cells, &reg);
>>>> +		usablemem[nr].size = dt_mem_next_cell(dt_root_size_cells, &reg);
>>>> +
>>>> +		if (++nr >= CRASH_MAX_USABLE_RANGES)
>>>> +			break;
>>>> +	}
>>>>  
>>>>  	return 1;
>>>>  }
>>>>  
>>>>  static void __init fdt_enforce_memory_region(void)
>>>>  {
>>>> -	struct memblock_region reg = {
>>>> -		.size = 0,
>>>> -	};
>>>> +	int i, cnt = 0;
>>>> +	struct memblock_region regs[CRASH_MAX_USABLE_RANGES];
>>>
>>> I only now noticed that fdt_enforce_memory_region() uses memblock_region to
>>> pass the ranges around. If we'd switch to memblock_type instead, the
>>> implementation of memblock_cap_memory_ranges() would be really
>>> straightforward. Can you check if the below patch works for you? 
>>>
>>> >From e476d584098e31273af573e1a78e308880c5cf28 Mon Sep 17 00:00:00 2001
>>> From: Mike Rapoport <rppt@linux.ibm.com>
>>> Date: Wed, 10 Apr 2019 16:02:32 +0300
>>> Subject: [PATCH] memblock: extend memblock_cap_memory_range to multiple ranges
>>>
>>> The memblock_cap_memory_range() removes all the memory except the range
>>> passed to it. Extend this function to recieve memblock_type with the
>>> regions that should be kept. This allows switching to simple iteration over
>>> memblock arrays with 'for_each_mem_range' to remove the unneeded memory.
>>>
>>> Enable use of this function in arm64 for reservation of multile regions for
>>> the crash kernel.
>>>
>>> Signed-off-by: Mike Rapoport <rppt@linux.ibm.com>
>>> ---
>>>  arch/arm64/mm/init.c     | 34 ++++++++++++++++++++++++----------
>>>  include/linux/memblock.h |  2 +-
>>>  mm/memblock.c            | 45 ++++++++++++++++++++++-----------------------
>>>  3 files changed, 47 insertions(+), 34 deletions(-)
>>>
>>>  
>>> -void __init memblock_cap_memory_range(phys_addr_t base, phys_addr_t size)
>>> +void __init memblock_cap_memory_ranges(struct memblock_type *regions_to_keep)
>>>  {
>>> -	int start_rgn, end_rgn;
>>> -	int i, ret;
>>> -
>>> -	if (!size)
>>> -		return;
>>> -
>>> -	ret = memblock_isolate_range(&memblock.memory, base, size,
>>> -						&start_rgn, &end_rgn);
>>> -	if (ret)
>>> -		return;
>>> -
>>> -	/* remove all the MAP regions */
>>> -	for (i = memblock.memory.cnt - 1; i >= end_rgn; i--)
>>> -		if (!memblock_is_nomap(&memblock.memory.regions[i]))
>>> -			memblock_remove_region(&memblock.memory, i);
>>> +	phys_addr_t start, end;
>>> +	u64 i;
>>>  
>>> -	for (i = start_rgn - 1; i >= 0; i--)
>>> -		if (!memblock_is_nomap(&memblock.memory.regions[i]))
>>> -			memblock_remove_region(&memblock.memory, i);
>>> +	/* truncate memory while skipping NOMAP regions */
>>> +	for_each_mem_range(i, &memblock.memory, regions_to_keep, NUMA_NO_NODE,
>>> +			   MEMBLOCK_NONE, &start, &end, NULL)
>>> +		memblock_remove(start, end);
>>
>> 1. use memblock_remove(start, size) instead of memblock_remove(start, end).
>>
>> 2. There is a another hidden issue. We couldn't mix __next_mem_range()(called by for_each_mem_range) operation
>> with remove operation because __next_mem_range() records the index of last time. If we do remove between
>> __next_mem_range(), the index may be mess.
> 
> Oops, I've really missed that :)
>  
>> Therefore, we could do remove operation after for_each_mem_range like this, solution A:
>>  void __init memblock_cap_memory_ranges(struct memblock_type *regions_to_keep)
>>  {
>> -	phys_addr_t start, end;
>> -	u64 i;
>> +	phys_addr_t start[INIT_MEMBLOCK_RESERVED_REGIONS * 2];
>> +	phys_addr_t end[INIT_MEMBLOCK_RESERVED_REGIONS * 2];
>> +	u64 i, nr = 0;
>>
>>  	/* truncate memory while skipping NOMAP regions */
>>  	for_each_mem_range(i, &memblock.memory, regions_to_keep, NUMA_NO_NODE,
>> -			   MEMBLOCK_NONE, &start, &end, NULL)
>> -		memblock_remove(start, end);
>> +			   MEMBLOCK_NONE, &start[nr], &end[nr], NULL)
>> +		nr++;
>> +	for (i = 0; i < nr; i++)
>> +		memblock_remove(start[i], end[i] - start[i]);
>>
>>  	/* truncate the reserved regions */
>> +	nr = 0;
>>  	for_each_mem_range(i, &memblock.reserved, regions_to_keep, NUMA_NO_NODE,
>> -			   MEMBLOCK_NONE, &start, &end, NULL)
>> -		memblock_remove_range(&memblock.reserved, start, end);
>> +			   MEMBLOCK_NONE, &start[nr], &end[nr], NULL)
>> +		nr++;
>> +	for (i = 0; i < nr; i++)
>> +		memblock_remove_range(&memblock.reserved, start[i],
>> +				end[i] - start[i]);
>>  }
>>
>> But a warning occurs when compiling:
>>   CALL    scripts/atomic/check-atomics.sh
>>   CALL    scripts/checksyscalls.sh
>>   CHK     include/generated/compile.h
>>   CC      mm/memblock.o
>> mm/memblock.c: In function ‘memblock_cap_memory_ranges’:
>> mm/memblock.c:1635:1: warning: the frame size of 36912 bytes is larger than 2048 bytes [-Wframe-larger-than=]
>>  }
>>
>> another solution is my implementation in v1, solution B:
>> +void __init memblock_cap_memory_ranges(struct memblock_type *regions_to_keep)
>> +{
>> +   int start_rgn[INIT_MEMBLOCK_REGIONS], end_rgn[INIT_MEMBLOCK_REGIONS];
>> +   int i, j, ret, nr = 0;
>> +   memblock_region *regs = regions_to_keep->regions;
>> +
>> +   nr = regions_to_keep -> cnt;
>> +   if (!nr)
>> +       return;
>> +
>> +   /* remove all the MAP regions */
>> +   for (i = memblock.memory.cnt - 1; i >= end_rgn[nr - 1]; i--)
>> +       if (!memblock_is_nomap(&memblock.memory.regions[i]))
>> +           memblock_remove_region(&memblock.memory, i);
>> +
>> +   for (i = nr - 1; i > 0; i--)
>> +       for (j = start_rgn[i] - 1; j >= end_rgn[i - 1]; j--)
>> +           if (!memblock_is_nomap(&memblock.memory.regions[j]))
>> +               memblock_remove_region(&memblock.memory, j);
>> +
>> +   for (i = start_rgn[0] - 1; i >= 0; i--)
>> +       if (!memblock_is_nomap(&memblock.memory.regions[i]))
>> +           memblock_remove_region(&memblock.memory, i);
>> +
>> +   /* truncate the reserved regions */
>> +   memblock_remove_range(&memblock.reserved, 0, regs[0].base);
>> +
>> +   for (i = nr - 1; i > 0; i--)
>> +       memblock_remove_range(&memblock.reserved,
>> +               regs[i - 1].base + regs[i - 1].size,
>> +		regs[i].base - regs[i - 1].base - regs[i - 1].size);
>> +
>> +   memblock_remove_range(&memblock.reserved,
>> +           regs[nr - 1].base + regs[nr - 1].size, PHYS_ADDR_MAX);
>> +}
>>
>> solution A: 	phys_addr_t start[INIT_MEMBLOCK_RESERVED_REGIONS * 2];
>> 		phys_addr_t end[INIT_MEMBLOCK_RESERVED_REGIONS * 2];
>> start, end is physical addr
>>
>> solution B: 	int start_rgn[INIT_MEMBLOCK_REGIONS], end_rgn[INIT_MEMBLOCK_REGIONS];
>> start_rgn, end_rgn is rgn index		
>>
>> Solution B do less remove operations and with no warning comparing to solution A.
>> I think solution B is better, could you give some suggestions?
>  
> Solution B is indeed better that solution A, but I'm still worried by
> relatively large arrays on stack and the amount of loops :(
> 
> The very least we could do is to call memblock_cap_memory_range() to drop
> the memory before and after the ranges we'd like to keep.

1. relatively large arrays
As my said above, the start_rgn, end_rgn is rgn index, we could use unsigned char type.

2. loops
Loops always exist, and the solution with fewer loops may be just encapsulated well.

Thanks,
Chen Zhou

> 
>>>  
>>>  	/* truncate the reserved regions */
>>> -	memblock_remove_range(&memblock.reserved, 0, base);
>>> -	memblock_remove_range(&memblock.reserved,
>>> -			base + size, PHYS_ADDR_MAX);
>>> +	for_each_mem_range(i, &memblock.reserved, regions_to_keep, NUMA_NO_NODE,
>>> +			   MEMBLOCK_NONE, &start, &end, NULL)
>>> +		memblock_remove_range(&memblock.reserved, start, end);
>>
>> There are the same issues as above.
>>
>>>  }
>>>  
>>>  void __init memblock_mem_limit_remove_map(phys_addr_t limit)
>>>  {
>>> +	struct memblock_region rgn = {
>>> +		.base = 0,
>>> +	};
>>> +
>>> +	struct memblock_type region_to_keep = {
>>> +		.cnt = 1,
>>> +		.max = 1,
>>> +		.regions = &rgn,
>>> +	};
>>> +
>>>  	phys_addr_t max_addr;
>>>  
>>>  	if (!limit)
>>> @@ -1646,7 +1644,8 @@ void __init memblock_mem_limit_remove_map(phys_addr_t limit)
>>>  	if (max_addr == PHYS_ADDR_MAX)
>>>  		return;
>>>  
>>> -	memblock_cap_memory_range(0, max_addr);
>>> +	region_to_keep.regions[0].size = max_addr;
>>> +	memblock_cap_memory_ranges(&region_to_keep);
>>>  }
>>>  
>>>  static int __init_memblock memblock_search(struct memblock_type *type, phys_addr_t addr)
>>>
>>
>> Thanks,
>> Chen Zhou
>>
> 

