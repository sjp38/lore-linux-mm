Return-Path: <SRS0=5KBY=SK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 18F12C282CE
	for <linux-mm@archiver.kernel.org>; Mon,  8 Apr 2019 08:40:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C83F420880
	for <linux-mm@archiver.kernel.org>; Mon,  8 Apr 2019 08:40:18 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C83F420880
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=huawei.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4E0286B000D; Mon,  8 Apr 2019 04:40:18 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 48FDC6B0010; Mon,  8 Apr 2019 04:40:18 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 357576B0266; Mon,  8 Apr 2019 04:40:18 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f199.google.com (mail-oi1-f199.google.com [209.85.167.199])
	by kanga.kvack.org (Postfix) with ESMTP id 0523A6B000D
	for <linux-mm@kvack.org>; Mon,  8 Apr 2019 04:40:18 -0400 (EDT)
Received: by mail-oi1-f199.google.com with SMTP id o132so5384376oib.5
        for <linux-mm@kvack.org>; Mon, 08 Apr 2019 01:40:17 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to
         :references:cc:from:message-id:date:user-agent:mime-version
         :in-reply-to:content-transfer-encoding;
        bh=ZTnRJnt/9uvzdBNuKhtB5sQ24kvrcK1ktT8uppRyaM8=;
        b=e8s0Hcqo9DsMBqJed4ZShrdxdaBk81KmGLg9XMAjpDFRVijW55H5F0qlRJA21PGzBc
         rsEK8/FqspTpcTTlxcORrUt7iL/DnNUlFWoL8XKyemeUJ6BccndppWkLEq/SzxONIAwr
         Tx6lPS7o04qDy4jtxHILFlcNAgKLy53cgPSdywRdO578AO1qAomkEb61nYz1IKe3SkWh
         Och+C8fDfJW46d/ZxalTG6bB+7wMzD/HSDWPgwS9/9+KtpY639BXPHQKmDSber3iiIRC
         T8ZXWJc0oDQsZEPEkiJleHilu6Oa0Q9tkA6r6Upcyfa1PWM1ith4Q7RsWMkTiFYuDGzh
         sPFA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of chenzhou10@huawei.com designates 45.249.212.32 as permitted sender) smtp.mailfrom=chenzhou10@huawei.com
X-Gm-Message-State: APjAAAUCYAGLC7B3bkRBt6LFnWwUywJVPU6Z8HYQ1IwiPfQYt0wyGWbk
	J8oJv+lqRrceNykYgL79AHSAUnwxbn3oi740TI30aL3w0WFIFTqz2ipagsDMw+dZXncFbqWzNeR
	nEqkWhXKnYDOs/WXKsd/hMP89im6uxu8fM6yyf5V827z8Uyn3DnKs1L1Y3qSFlkFB2g==
X-Received: by 2002:a9d:57c4:: with SMTP id q4mr17694868oti.151.1554712817533;
        Mon, 08 Apr 2019 01:40:17 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxjEFuQ61VhP1NfGFOwksb5LL5WW1p487XGJ432+g1iqCXpPiQuccUkZF4T6VqU95EXfA5r
X-Received: by 2002:a9d:57c4:: with SMTP id q4mr17694840oti.151.1554712816572;
        Mon, 08 Apr 2019 01:40:16 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554712816; cv=none;
        d=google.com; s=arc-20160816;
        b=Tn9I0fMqSzsHmiyIosRAyyeTr55IaCsM9Ybx9ezfsLzZkyGocma+B/S7EK5TjY9fzu
         1MY6C654GvxQjBRJzNia+mZ0jnLvsmjhCyK/ui5UJkKtIsxisvSgx56GDs1NyXie9K9m
         fn76morhgHxoahIg2FVle83dKszZB/GzQPHcEkyV5Cq+pQ2n57LbQn3uHAYe11x/oE91
         YkB++8f7pvqQcoP2k5CriTyaLzS2B5lIwwXGPXZkQIY445cNhELl/+D+QOcD0apDlS/K
         7T97eAURKkKpa+0BqeJs6EfdTOusvHcav6+U8PXIYWWUHItnFANMWBQ3zy33Hex70GS4
         6NMA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:in-reply-to:mime-version:user-agent:date
         :message-id:from:cc:references:to:subject;
        bh=ZTnRJnt/9uvzdBNuKhtB5sQ24kvrcK1ktT8uppRyaM8=;
        b=SMHPhAGnLogIgJXtAxD7nevQg8Mikhm5ngeRmVi8r9MGWf1fAUI6WxeRFh94ZDu8Bq
         cD0EI/92vou9jEFihY0xQsIemg7xzWk6RDQ1L2y2gGNE76/++onFtUngQEEG2hEesmgf
         04OGGGJGhpu9mXvADAOFXQ6zU4vzG7EofsfWNhX/KtbV6573nAoRpV5BPs3WULZ1IGkM
         m02gTQyc8Dkil/s3yBpeB8nm8GzX81n+5B7wFeHJNHpS2LJNPfZIMSlD2olkAqdXkHdf
         6xL0dQrhwJi5Z18vMcL4iAg7qSVgjuDgypDz/FhFx8OZnJHNGUzl9ecCmdV1T2sCZhfJ
         qm9A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of chenzhou10@huawei.com designates 45.249.212.32 as permitted sender) smtp.mailfrom=chenzhou10@huawei.com
Received: from huawei.com (szxga06-in.huawei.com. [45.249.212.32])
        by mx.google.com with ESMTPS id v77si13171668oif.120.2019.04.08.01.40.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 08 Apr 2019 01:40:16 -0700 (PDT)
Received-SPF: pass (google.com: domain of chenzhou10@huawei.com designates 45.249.212.32 as permitted sender) client-ip=45.249.212.32;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of chenzhou10@huawei.com designates 45.249.212.32 as permitted sender) smtp.mailfrom=chenzhou10@huawei.com
Received: from DGGEMS401-HUB.china.huawei.com (unknown [172.30.72.60])
	by Forcepoint Email with ESMTP id D3C144B3660DE31C2D9C;
	Mon,  8 Apr 2019 16:40:10 +0800 (CST)
Received: from [127.0.0.1] (10.177.131.64) by DGGEMS401-HUB.china.huawei.com
 (10.3.19.201) with Microsoft SMTP Server id 14.3.408.0; Mon, 8 Apr 2019
 16:40:02 +0800
Subject: Re: [PATCH 2/3] arm64: kdump: support more than one crash kernel
 regions
To: Mike Rapoport <rppt@linux.ibm.com>
References: <20190403030546.23718-1-chenzhou10@huawei.com>
 <20190403030546.23718-3-chenzhou10@huawei.com>
 <20190403112929.GA7715@rapoport-lnx>
 <f98a5559-3659-fb35-3765-15861e70a796@huawei.com>
 <20190404144408.GA6433@rapoport-lnx>
 <783b8712-ddb1-a52b-81ee-0c6a216e5b7d@huawei.com>
 <4b188535-c12d-e05b-9154-2c2d580f903b@huawei.com>
 <20190408065711.GA8403@rapoport-lnx>
CC: <catalin.marinas@arm.com>, <will.deacon@arm.com>,
	<akpm@linux-foundation.org>, <ard.biesheuvel@linaro.org>,
	<takahiro.akashi@linaro.org>, <linux-arm-kernel@lists.infradead.org>,
	<linux-kernel@vger.kernel.org>, <kexec@lists.infradead.org>,
	<linux-mm@kvack.org>, <wangkefeng.wang@huawei.com>
From: Chen Zhou <chenzhou10@huawei.com>
Message-ID: <3fc772a2-292b-9c2a-465f-eabe86961dfd@huawei.com>
Date: Mon, 8 Apr 2019 16:39:59 +0800
User-Agent: Mozilla/5.0 (Windows NT 6.1; WOW64; rv:45.0) Gecko/20100101
 Thunderbird/45.7.1
MIME-Version: 1.0
In-Reply-To: <20190408065711.GA8403@rapoport-lnx>
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

On 2019/4/8 14:57, Mike Rapoport wrote:
> Hi,
> 
> On Fri, Apr 05, 2019 at 11:47:27AM +0800, Chen Zhou wrote:
>> Hi Mike,
>>
>> On 2019/4/5 10:17, Chen Zhou wrote:
>>> Hi Mike,
>>>
>>> On 2019/4/4 22:44, Mike Rapoport wrote:
>>>> Hi,
>>>>
>>>> On Wed, Apr 03, 2019 at 09:51:27PM +0800, Chen Zhou wrote:
>>>>> Hi Mike,
>>>>>
>>>>> On 2019/4/3 19:29, Mike Rapoport wrote:
>>>>>> On Wed, Apr 03, 2019 at 11:05:45AM +0800, Chen Zhou wrote:
>>>>>>> After commit (arm64: kdump: support reserving crashkernel above 4G),
>>>>>>> there may be two crash kernel regions, one is below 4G, the other is
>>>>>>> above 4G.
>>>>>>>
>>>>>>> Crash dump kernel reads more than one crash kernel regions via a dtb
>>>>>>> property under node /chosen,
>>>>>>> linux,usable-memory-range = <BASE1 SIZE1 [BASE2 SIZE2]>
>>>>>>>
>>>>>>> Signed-off-by: Chen Zhou <chenzhou10@huawei.com>
>>>>>>> ---
>>>>>>>  arch/arm64/mm/init.c     | 37 +++++++++++++++++++++++++------------
>>>>>>>  include/linux/memblock.h |  1 +
>>>>>>>  mm/memblock.c            | 40 ++++++++++++++++++++++++++++++++++++++++
>>>>>>>  3 files changed, 66 insertions(+), 12 deletions(-)
>>>>>>>
>>>>>>> diff --git a/arch/arm64/mm/init.c b/arch/arm64/mm/init.c
>>>>>>> index ceb2a25..769c77a 100644
>>>>>>> --- a/arch/arm64/mm/init.c
>>>>>>> +++ b/arch/arm64/mm/init.c
>>>>>>> @@ -64,6 +64,8 @@ EXPORT_SYMBOL(memstart_addr);
>>>>>>>  phys_addr_t arm64_dma_phys_limit __ro_after_init;
>>>>>>>  
>>>>>>>  #ifdef CONFIG_KEXEC_CORE
>>>>>>> +# define CRASH_MAX_USABLE_RANGES        2
>>>>>>> +
>>>>>>>  static int __init reserve_crashkernel_low(void)
>>>>>>>  {
>>>>>>>  	unsigned long long base, low_base = 0, low_size = 0;
>>>>>>> @@ -346,8 +348,8 @@ static int __init early_init_dt_scan_usablemem(unsigned long node,
>>>>>>>  		const char *uname, int depth, void *data)
>>>>>>>  {
>>>>>>>  	struct memblock_region *usablemem = data;
>>>>>>> -	const __be32 *reg;
>>>>>>> -	int len;
>>>>>>> +	const __be32 *reg, *endp;
>>>>>>> +	int len, nr = 0;
>>>>>>>  
>>>>>>>  	if (depth != 1 || strcmp(uname, "chosen") != 0)
>>>>>>>  		return 0;
>>>>>>> @@ -356,22 +358,33 @@ static int __init early_init_dt_scan_usablemem(unsigned long node,
>>>>>>>  	if (!reg || (len < (dt_root_addr_cells + dt_root_size_cells)))
>>>>>>>  		return 1;
>>>>>>>  
>>>>>>> -	usablemem->base = dt_mem_next_cell(dt_root_addr_cells, &reg);
>>>>>>> -	usablemem->size = dt_mem_next_cell(dt_root_size_cells, &reg);
>>>>>>> +	endp = reg + (len / sizeof(__be32));
>>>>>>> +	while ((endp - reg) >= (dt_root_addr_cells + dt_root_size_cells)) {
>>>>>>> +		usablemem[nr].base = dt_mem_next_cell(dt_root_addr_cells, &reg);
>>>>>>> +		usablemem[nr].size = dt_mem_next_cell(dt_root_size_cells, &reg);
>>>>>>> +
>>>>>>> +		if (++nr >= CRASH_MAX_USABLE_RANGES)
>>>>>>> +			break;
>>>>>>> +	}
>>>>>>>  
>>>>>>>  	return 1;
>>>>>>>  }
>>>>>>>  
>>>>>>>  static void __init fdt_enforce_memory_region(void)
>>>>>>>  {
>>>>>>> -	struct memblock_region reg = {
>>>>>>> -		.size = 0,
>>>>>>> -	};
>>>>>>> -
>>>>>>> -	of_scan_flat_dt(early_init_dt_scan_usablemem, &reg);
>>>>>>> -
>>>>>>> -	if (reg.size)
>>>>>>> -		memblock_cap_memory_range(reg.base, reg.size);
>>>>>>> +	int i, cnt = 0;
>>>>>>> +	struct memblock_region regs[CRASH_MAX_USABLE_RANGES];
>>>>>>> +
>>>>>>> +	memset(regs, 0, sizeof(regs));
>>>>>>> +	of_scan_flat_dt(early_init_dt_scan_usablemem, regs);
>>>>>>> +
>>>>>>> +	for (i = 0; i < CRASH_MAX_USABLE_RANGES; i++)
>>>>>>> +		if (regs[i].size)
>>>>>>> +			cnt++;
>>>>>>> +		else
>>>>>>> +			break;
>>>>>>> +	if (cnt)
>>>>>>> +		memblock_cap_memory_ranges(regs, cnt);
>>>>>>
>>>>>> Why not simply call memblock_cap_memory_range() for each region?
>>>>>
>>>>> Function memblock_cap_memory_range() removes all memory type ranges except specified range.
>>>>> So if we call memblock_cap_memory_range() for each region simply, there will be no usable-memory
>>>>> on kdump capture kernel.
>>>>
>>>> Thanks for the clarification.
>>>> I still think that memblock_cap_memory_ranges() is overly complex. 
>>>>
>>>> How about doing something like this:
>>>>
>>>> Cap the memory range for [min(regs[*].start, max(regs[*].end)] and then
>>>> removing the range in the middle?
>>>
>>> Yes, that would be ok. But that would do one more memblock_cap_memory_range operation.
>>> That is, if there are n regions, we need to do (n + 1) operations, which doesn't seem to
>>> matter.
>>>
>>> I agree with you, your idea is better.
>>>
>>> Thanks,
>>> Chen Zhou
>>
>> Sorry, just ignore my previous reply, I got that wrong.
>>
>> I think it carefully, we can cap the memory range for [min(regs[*].start, max(regs[*].end)]
>> firstly. But how to remove the middle ranges, we still can't use memblock_cap_memory_range()
>> directly and the extra remove operation may be complex.
>>
>> For more than one regions, i think add a new memblock_cap_memory_ranges() may be better.
>> Besides, memblock_cap_memory_ranges() is also applicable for one region.
>>
>> How about replace memblock_cap_memory_range() with memblock_cap_memory_ranges()?
> 
> arm64 is the only user of both MEMBLOCK_NOMAP and memblock_cap_memory_range()
> and I don't expect other architectures will use these interfaces.
> It seems that capping the memory for arm64 crash kernel the way I've
> suggested can be implemented in fdt_enforce_memory_region(). If we'd ever
> need such functionality elsewhere or CRASH_MAX_USABLE_RANGES will need to
> grow we'll rethink the solution.

Ok, i will implement that in fdt_enforce_memory_region() in next version.
And we will support at most two crash kernel regions now.

Thanks,
Chen Zhou

>  
>> Thanks,
>> Chen Zhou
> 

