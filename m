Return-Path: <SRS0=AiS9=SS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 11354C10F12
	for <linux-mm@archiver.kernel.org>; Tue, 16 Apr 2019 02:55:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C15F52075B
	for <linux-mm@archiver.kernel.org>; Tue, 16 Apr 2019 02:55:54 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C15F52075B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=huawei.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5B26E6B0003; Mon, 15 Apr 2019 22:55:54 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 563366B0006; Mon, 15 Apr 2019 22:55:54 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 478D56B0007; Mon, 15 Apr 2019 22:55:54 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f199.google.com (mail-oi1-f199.google.com [209.85.167.199])
	by kanga.kvack.org (Postfix) with ESMTP id 1FF906B0003
	for <linux-mm@kvack.org>; Mon, 15 Apr 2019 22:55:54 -0400 (EDT)
Received: by mail-oi1-f199.google.com with SMTP id s64so9072676oia.15
        for <linux-mm@kvack.org>; Mon, 15 Apr 2019 19:55:54 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to
         :references:cc:from:message-id:date:user-agent:mime-version
         :in-reply-to:content-transfer-encoding;
        bh=/GOQGKia2Uxdvs5ilK+dCGiernVe8iIIZr90DUqp+2E=;
        b=QxFhavBuz75nR1wS1DB8B0LocSnGXDh36yzMsixWyMbn+JVh350OhqED28IrDLL/Kg
         9Dw0q1Bjxro+ri3VcyM03AxWn8qa6SQH6Wd6GfEbRqYgsVCdLdqf87K1CMletKjdF2xz
         r2Meqx+U23GCN3oGV7CgT5tr9981t2gynmuW73hM5iLhnmThZtcUPK0f6HsOOP3linTY
         pmi63rL6AO9VwzRXgbl+Z/ghn8pIudeslyytGLSDcUk7/Z1idl1sVaWcnn47yc+X6U0v
         OBKn/izatjZgZ6M0OpFQm8nVwHsAuhxhnUeMn6nwcAfL0/9/Z13uh2Wf2UQrGAPojKdy
         nnSA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of chenzhou10@huawei.com designates 45.249.212.32 as permitted sender) smtp.mailfrom=chenzhou10@huawei.com
X-Gm-Message-State: APjAAAUWzrT+Z0y5qm1QUR9tj/cyZ2va3d7d8K0W8QjpqSLx2W2sUnoH
	DiqIqCbYRRhEhwkI8MEvs05beRVgDLyRoyTXsqTxAJGkJgC+5Ut8SE5ve/kRcfvzxMm4vYwhcoE
	xw7eQdrmxk40DUo6r9HAPikshGST9e+0aU9+Lj1z4ouWjtodOOldU7uhdCqKWg9N2cw==
X-Received: by 2002:aca:abce:: with SMTP id u197mr21544032oie.67.1555383353792;
        Mon, 15 Apr 2019 19:55:53 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxDeh5TXmtuifgBakZMSnoV1lekqfF4Sq1vpXr7MZD6NRres/DALckC08h+vXi1749tAjwn
X-Received: by 2002:aca:abce:: with SMTP id u197mr21543992oie.67.1555383352793;
        Mon, 15 Apr 2019 19:55:52 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555383352; cv=none;
        d=google.com; s=arc-20160816;
        b=nv9C9RNWvIaGywBFLt6BH5LVRypL9Vp4re4rwBs5F8jpqmovKy2iCiFsA2p0LyC6kH
         gDWt7KD4f4LgEDZvHxoIzQFowVGJ1pONudO2urfBMcndhx4e853Aj1yt2o0SrTxD9gGK
         /7dIguXLJR4XHUgVN3rjnpDZKuw5aeAHyAvaJOxQK1uzuXxfBqvIfNTH/cok3ZhMrhIS
         eweR/CXDPKMzRp2kduMTincVn1B8mwMCqQkJsP8enEwg9VuSuiLYOU3CEeSPqihnHKzG
         VfOrSS7xfIXCgkNt7TjAqEsXAvwe7pK547E8dPsYoUal0KwrraasAAUEwN6ZKUC+7Whq
         OOAw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:in-reply-to:mime-version:user-agent:date
         :message-id:from:cc:references:to:subject;
        bh=/GOQGKia2Uxdvs5ilK+dCGiernVe8iIIZr90DUqp+2E=;
        b=hsMiovSrYcvDX8JZ+FRkLTkvJP846A720ns4Oynj7orJJYCrX44AibbnRugxyXKlj2
         t8Al9RFNL3qZpBY+gcbqZ/5Yr4B+U91CTcU9Ef9sHC4p+k9jbJ6whekc21ROkCVrtnah
         TI08L74p1zkMWQ1a4hkogHjFxG9fflPrw/xuvNq0hWFDk3udRuyRkHXT6PbTd1rHuC9z
         rp2g1Z6IQgs5glgFOirENNhdpI4SKnoOWIQoDkZbuXbTxLS1HJ7jwuhJ3fvF2zCkVPIr
         h6HMf9/KF+b66F4iX8grg2/cycfwr0x78Cgo/b8B8DLzOXpGxN9YEP6b6Lk6deoEdzBm
         wcLA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of chenzhou10@huawei.com designates 45.249.212.32 as permitted sender) smtp.mailfrom=chenzhou10@huawei.com
Received: from huawei.com (szxga06-in.huawei.com. [45.249.212.32])
        by mx.google.com with ESMTPS id w205si23402755oib.102.2019.04.15.19.55.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 Apr 2019 19:55:52 -0700 (PDT)
Received-SPF: pass (google.com: domain of chenzhou10@huawei.com designates 45.249.212.32 as permitted sender) client-ip=45.249.212.32;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of chenzhou10@huawei.com designates 45.249.212.32 as permitted sender) smtp.mailfrom=chenzhou10@huawei.com
Received: from DGGEMS408-HUB.china.huawei.com (unknown [172.30.72.58])
	by Forcepoint Email with ESMTP id B2E4F7FC284ACB1266F9;
	Tue, 16 Apr 2019 10:55:46 +0800 (CST)
Received: from [127.0.0.1] (10.177.131.64) by DGGEMS408-HUB.china.huawei.com
 (10.3.19.208) with Microsoft SMTP Server id 14.3.408.0; Tue, 16 Apr 2019
 10:55:37 +0800
Subject: Re: [PATCH v4 3/5] memblock: add memblock_cap_memory_ranges for
 multiple ranges
To: Mike Rapoport <rppt@linux.ibm.com>
References: <20190415105725.22088-1-chenzhou10@huawei.com>
 <20190415105725.22088-4-chenzhou10@huawei.com>
 <20190415190940.GA6081@rapoport-lnx>
CC: <tglx@linutronix.de>, <mingo@redhat.com>, <bp@alien8.de>,
	<ebiederm@xmission.com>, <catalin.marinas@arm.com>, <will.deacon@arm.com>,
	<akpm@linux-foundation.org>, <ard.biesheuvel@linaro.org>,
	<horms@verge.net.au>, <takahiro.akashi@linaro.org>,
	<linux-arm-kernel@lists.infradead.org>, <linux-kernel@vger.kernel.org>,
	<kexec@lists.infradead.org>, <linux-mm@kvack.org>,
	<wangkefeng.wang@huawei.com>
From: Chen Zhou <chenzhou10@huawei.com>
Message-ID: <703cdbf0-b425-880b-b087-aaf3fe84673d@huawei.com>
Date: Tue, 16 Apr 2019 10:55:34 +0800
User-Agent: Mozilla/5.0 (Windows NT 6.1; WOW64; rv:45.0) Gecko/20100101
 Thunderbird/45.7.1
MIME-Version: 1.0
In-Reply-To: <20190415190940.GA6081@rapoport-lnx>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
X-Originating-IP: [10.177.131.64]
X-CFilter-Loop: Reflected
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Mike,

On 2019/4/16 3:09, Mike Rapoport wrote:
> Hi,
> 
> On Mon, Apr 15, 2019 at 06:57:23PM +0800, Chen Zhou wrote:
>> The memblock_cap_memory_range() removes all the memory except the
>> range passed to it. Extend this function to receive memblock_type
>> with the regions that should be kept.
>>
>> Enable this function in arm64 for reservation of multiple regions
>> for the crash kernel.
>>
>> Signed-off-by: Chen Zhou <chenzhou10@huawei.com>
>> Signed-off-by: Mike Rapoport <rppt@linux.ibm.com>
> 
> I didn't work on this version, please drop the signed-off.

Sorry about this. I should ask you firstly before doing it this way. I will drop it.

		remove_size);
>> +	}
>> +
>> +	memblock_remove_range(&memblock.reserved,
>> +			regs[nr - 1].base + regs[nr - 1].size, PHYS_ADDR_MAX);
>> +}
>> +
> 
> I've double-checked and I see no problem with using
> for_each_mem_range_rev() iterators for removing some ranges. And with them
> this functions becomes much clearer and more efficient.
> 
> Can you please check if the below patch works for you?
> 
>>From e25e6c9cd94a01abac124deacc66e5d258fdbf7c Mon Sep 17 00:00:00 2001
> From: Mike Rapoport <rppt@linux.ibm.com>
> Date: Wed, 10 Apr 2019 16:02:32 +0300
> Subject: [PATCH] memblock: extend memblock_cap_memory_range to multiple ranges
> 
> The memblock_cap_memory_range() removes all the memory except the range
> passed to it. Extend this function to receive an array of memblock_regions
> that should be kept. This allows switching to simple iteration over
> memblock arrays with 'for_each_mem_range_rev' to remove the unneeded memory.
> 
> Enable use of this function in arm64 for reservation of multiple regions for
> the crash kernel.
> 
> Signed-off-by: Mike Rapoport <rppt@linux.ibm.com>
> ---
>  arch/arm64/mm/init.c     | 34 ++++++++++++++++++++++++----------
>  include/linux/memblock.h |  2 +-
>  mm/memblock.c            | 44 ++++++++++++++++++++------------------------
>  3 files changed, 45 insertions(+), 35 deletions(-)
> 
> diff --git a/arch/arm64/mm/init.c b/arch/arm64/mm/init.c
> index 6bc1350..8665d29 100644
> --- a/arch/arm64/mm/init.c
> +++ b/arch/arm64/mm/init.c
> @@ -64,6 +64,10 @@ EXPORT_SYMBOL(memstart_addr);
>  phys_addr_t arm64_dma_phys_limit __ro_after_init;
>  
>  #ifdef CONFIG_KEXEC_CORE
> +
> +/* at most two crash kernel regions, low_region and high_region */
> +#define CRASH_MAX_USABLE_RANGES	2
> +
>  /*
>   * reserve_crashkernel() - reserves memory for crash kernel
>   *
> @@ -280,9 +284,9 @@ early_param("mem", early_mem);
>  static int __init early_init_dt_scan_usablemem(unsigned long node,
>  		const char *uname, int depth, void *data)
>  {
> -	struct memblock_region *usablemem = data;
> -	const __be32 *reg;
> -	int len;
> +	struct memblock_type *usablemem = data;
> +	const __be32 *reg, *endp;
> +	int len, nr = 0;
>  
>  	if (depth != 1 || strcmp(uname, "chosen") != 0)
>  		return 0;
> @@ -291,22 +295,32 @@ static int __init early_init_dt_scan_usablemem(unsigned long node,
>  	if (!reg || (len < (dt_root_addr_cells + dt_root_size_cells)))
>  		return 1;
>  
> -	usablemem->base = dt_mem_next_cell(dt_root_addr_cells, &reg);
> -	usablemem->size = dt_mem_next_cell(dt_root_size_cells, &reg);
> +	endp = reg + (len / sizeof(__be32));
> +	while ((endp - reg) >= (dt_root_addr_cells + dt_root_size_cells)) {
> +		unsigned long base = dt_mem_next_cell(dt_root_addr_cells, &reg);
> +		unsigned long size = dt_mem_next_cell(dt_root_size_cells, &reg);
>  
> +		if (memblock_add_range(usablemem, base, size, NUMA_NO_NODE,
> +				       MEMBLOCK_NONE))
> +			return 0;
> +		if (++nr >= CRASH_MAX_USABLE_RANGES)
> +			break;
> +	}
>  	return 1;
>  }
>  
>  static void __init fdt_enforce_memory_region(void)
>  {
> -	struct memblock_region reg = {
> -		.size = 0,
> +	struct memblock_region usable_regions[CRASH_MAX_USABLE_RANGES];
> +	struct memblock_type usablemem = {
> +		.max = CRASH_MAX_USABLE_RANGES,
> +		.regions = usable_regions,
>  	};
>  
> -	of_scan_flat_dt(early_init_dt_scan_usablemem, &reg);
> +	of_scan_flat_dt(early_init_dt_scan_usablemem, &usablemem);
>  
> -	if (reg.size)
> -		memblock_cap_memory_range(reg.base, reg.size);
> +	if (usablemem.cnt)
> +		memblock_cap_memory_ranges(usablemem.regions, usablemem.cnt);
>  }
>  
>  void __init arm64_memblock_init(void)
> diff --git a/include/linux/memblock.h b/include/linux/memblock.h
> index 294d5d8..f5c029b 100644
> --- a/include/linux/memblock.h
> +++ b/include/linux/memblock.h
> @@ -404,7 +404,7 @@ phys_addr_t memblock_mem_size(unsigned long limit_pfn);
>  phys_addr_t memblock_start_of_DRAM(void);
>  phys_addr_t memblock_end_of_DRAM(void);
>  void memblock_enforce_memory_limit(phys_addr_t memory_limit);
> -void memblock_cap_memory_range(phys_addr_t base, phys_addr_t size);
> +void memblock_cap_memory_ranges(struct memblock_region *regions, int count);
>  void memblock_mem_limit_remove_map(phys_addr_t limit);
>  bool memblock_is_memory(phys_addr_t addr);
>  bool memblock_is_map_memory(phys_addr_t addr);
> diff --git a/mm/memblock.c b/mm/memblock.c
> index e7665cf..8d4d060 100644
> --- a/mm/memblock.c
> +++ b/mm/memblock.c
> @@ -1605,36 +1605,31 @@ void __init memblock_enforce_memory_limit(phys_addr_t limit)
>  			      PHYS_ADDR_MAX);
>  }
>  
> -void __init memblock_cap_memory_range(phys_addr_t base, phys_addr_t size)
> -{
> -	int start_rgn, end_rgn;
> -	int i, ret;
> -
> -	if (!size)
> -		return;
> -
> -	ret = memblock_isolate_range(&memblock.memory, base, size,
> -						&start_rgn, &end_rgn);
> -	if (ret)
> -		return;
> -
> -	/* remove all the MAP regions */
> -	for (i = memblock.memory.cnt - 1; i >= end_rgn; i--)
> -		if (!memblock_is_nomap(&memblock.memory.regions[i]))
> -			memblock_remove_region(&memblock.memory, i);
> +void __init memblock_cap_memory_ranges(struct memblock_region *regions,
> +				       int count)
> +{
> +	struct memblock_type regions_to_keep = {
> +		.max = count,
> +		.cnt = count,
> +		.regions = regions,
> +	};
> +	phys_addr_t start, end;
> +	u64 i;
>  
> -	for (i = start_rgn - 1; i >= 0; i--)
> -		if (!memblock_is_nomap(&memblock.memory.regions[i]))
> -			memblock_remove_region(&memblock.memory, i);
> +	/* truncate memory while skipping NOMAP regions */
> +	for_each_mem_range_rev(i, &memblock.memory, &regions_to_keep,
> +			       NUMA_NO_NODE, MEMBLOCK_NONE, &start, &end, NULL)
> +		memblock_remove(start, end);

Yes, this works well.
A minor issue, replace memblock_remove(start, end) with memblock_remove(start, end - start).

>  
>  	/* truncate the reserved regions */
> -	memblock_remove_range(&memblock.reserved, 0, base);
> -	memblock_remove_range(&memblock.reserved,
> -			base + size, PHYS_ADDR_MAX);
> +	for_each_mem_range_rev(i, &memblock.reserved, &regions_to_keep,
> +			       NUMA_NO_NODE, MEMBLOCK_NONE, &start, &end, NULL)
> +		memblock_remove_range(&memblock.reserved, start, end);

The same as above. Replace memblock_remove_range(&memblock.reserved, start, end) with
memblock_remove_range(&memblock.reserved, start, end - start).

Thanks,
Chen Zhou

>  }
>  
>  void __init memblock_mem_limit_remove_map(phys_addr_t limit)
>  {
> +	struct memblock_region region = { 0 };
>  	phys_addr_t max_addr;
>  
>  	if (!limit)
> @@ -1646,7 +1641,8 @@ void __init memblock_mem_limit_remove_map(phys_addr_t limit)
>  	if (max_addr == PHYS_ADDR_MAX)
>  		return;
>  
> -	memblock_cap_memory_range(0, max_addr);
> +	region.size = max_addr;
> +	memblock_cap_memory_ranges(&region, 1);
>  }
>  
>  static int __init_memblock memblock_search(struct memblock_type *type, phys_addr_t addr)
> 

