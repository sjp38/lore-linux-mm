Return-Path: <SRS0=l6tt=TQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C4E9EC04E84
	for <linux-mm@archiver.kernel.org>; Thu, 16 May 2019 03:19:20 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6A1A720833
	for <linux-mm@archiver.kernel.org>; Thu, 16 May 2019 03:19:20 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6A1A720833
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=huawei.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C94F36B0005; Wed, 15 May 2019 23:19:19 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C45286B0006; Wed, 15 May 2019 23:19:19 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AE6556B0007; Wed, 15 May 2019 23:19:19 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f199.google.com (mail-oi1-f199.google.com [209.85.167.199])
	by kanga.kvack.org (Postfix) with ESMTP id 80A6D6B0005
	for <linux-mm@kvack.org>; Wed, 15 May 2019 23:19:19 -0400 (EDT)
Received: by mail-oi1-f199.google.com with SMTP id b10so874311oie.23
        for <linux-mm@kvack.org>; Wed, 15 May 2019 20:19:19 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to
         :references:cc:from:message-id:date:user-agent:mime-version
         :in-reply-to:content-transfer-encoding;
        bh=wUPrlayxZAHEPFNnUw2o9RSmBgOUg082vXAxTNTDyj4=;
        b=JEI2s7FVOWXBtVLRry1RHxA+3VDgAUf9x3nXeb+JAGJrGVeaMvfLCN4O8iP3k1JSig
         W6zX84KTR/vp/RMqrW8YsIJ/scg0o6n/KJPjUPkzcqtuQNK8BNzrYv5h1NeeUicigIsc
         Vz5pO/GVDNshe0HKW3e2J+O28BB75JGZeo1uZeF77Mm98oY44QnXPkekcAUADKLsVBlK
         frmpf8dpxH/Hnouz7GRHhPSRWGCIESSrwtl4tb7h/zEUUeQUwSJHF5do7JjL0CmT4ejS
         rSPseV3yN6ujtlAFL6qOpKA5S0Gtwlyy0DMCIxHQmcIOaodLqHA58DWnTNxG5Jcfkfp1
         erqA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of chenzhou10@huawei.com designates 45.249.212.32 as permitted sender) smtp.mailfrom=chenzhou10@huawei.com
X-Gm-Message-State: APjAAAWQMInXhItRB7JquVVxLx1sF9Y+8Qs6Wsi3gjSkpcaTAtzG9UWq
	KaNxEa7X4jFQBBzPte985rdLZxWS5pER33mB+ob0R07WSf1MBW+UtVRe7CkkY9yiAledo5QQSv+
	cS0f6MXrv9OiRjRelNYYRHiO3LEo/6e5YBeoWA/0w7wTSh2MiYoEwDICgyDR+iEJbgA==
X-Received: by 2002:a9d:7503:: with SMTP id r3mr11150270otk.265.1557976759065;
        Wed, 15 May 2019 20:19:19 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwebxtwBM+5chTvG7QNHZM9Qxf4IhfjhVxg6AFONsGsIIxWAeqXEVN/y/H1HtoISbNeLCiX
X-Received: by 2002:a9d:7503:: with SMTP id r3mr11150240otk.265.1557976758093;
        Wed, 15 May 2019 20:19:18 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557976758; cv=none;
        d=google.com; s=arc-20160816;
        b=YWx0oEwndrhDTYeG7dkPi0AT5cL/A30pOHmciYbQGi0sp2U4aEcYKRHxUDrNo88Nv+
         3Vx0+C67eKzLsJdciL3EwoPtYjHnIc+puqnqcxm1y1vk9uUuE6u9cejCJFPAxJD+R8r9
         0Asi7FhAAqrMiHDYM+cPQMUrt2chzVD29RysRKFVeicm9fB/5ApmBA5uP+RaTJORBJWQ
         aMaZcSs8NfwbBjzoFyvqqq5h5xf4y1qOoZeoYxYuZZakS9FNZBykXP+tuqqq4Z7CjVLC
         8wEtXuOAPH0AColfxuDs94FMDV8bWwmHdqUT25SFFFRe7PWH7hYjxypUV3HCmvaRG3qW
         WFGg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:in-reply-to:mime-version:user-agent:date
         :message-id:from:cc:references:to:subject;
        bh=wUPrlayxZAHEPFNnUw2o9RSmBgOUg082vXAxTNTDyj4=;
        b=U8WtlQiQXqAvaZN1B7fmsecbax862RVwjGwvc9gI/fG6kFXAt7k1SNkug32Twxceus
         Fubr+dsCkRxxPsU1faVpXzSyhhfQJcyqOUJbE1aHySg+KDuRhV072ZUcEVlTn4a9MYCH
         wdDsPEVDZWU6/eamGPGrjWOHCocynvdguJzueyRiRVTV7/cvUIYOuW5AgJAdhperFLvS
         uhM0QnVl7cK8+yNPTVCqf2KKby1ssEta9NnJh+5Alg2G+r9mwkuMIkGGneFsFqXp3O4J
         76hHdewuqp8kPcrcpyO4qCGPI8Z5uQIivVLkUOD3DcGjDGnA/+iUJfCAQEkTDlbQVjpz
         WVNQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of chenzhou10@huawei.com designates 45.249.212.32 as permitted sender) smtp.mailfrom=chenzhou10@huawei.com
Received: from huawei.com (szxga06-in.huawei.com. [45.249.212.32])
        by mx.google.com with ESMTPS id w76si1949047oiw.72.2019.05.15.20.19.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 15 May 2019 20:19:18 -0700 (PDT)
Received-SPF: pass (google.com: domain of chenzhou10@huawei.com designates 45.249.212.32 as permitted sender) client-ip=45.249.212.32;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of chenzhou10@huawei.com designates 45.249.212.32 as permitted sender) smtp.mailfrom=chenzhou10@huawei.com
Received: from DGGEMS414-HUB.china.huawei.com (unknown [172.30.72.60])
	by Forcepoint Email with ESMTP id 97C3BD4F352B9FFE6FAD;
	Thu, 16 May 2019 11:19:13 +0800 (CST)
Received: from [127.0.0.1] (10.177.131.64) by DGGEMS414-HUB.china.huawei.com
 (10.3.19.214) with Microsoft SMTP Server id 14.3.439.0; Thu, 16 May 2019
 11:19:07 +0800
Subject: Re: [PATCH 0/4] support reserving crashkernel above 4G on arm64 kdump
To: Bhupesh Sharma <bhsharma@redhat.com>, <catalin.marinas@arm.com>,
	<will.deacon@arm.com>, <akpm@linux-foundation.org>,
	<ard.biesheuvel@linaro.org>, <rppt@linux.ibm.com>, <tglx@linutronix.de>,
	<mingo@redhat.com>, <bp@alien8.de>, <ebiederm@xmission.com>
References: <20190507035058.63992-1-chenzhou10@huawei.com>
 <a9d017d0-82d3-3e5f-4af2-4c611393106d@redhat.com>
CC: <wangkefeng.wang@huawei.com>, <linux-mm@kvack.org>,
	<kexec@lists.infradead.org>, <linux-kernel@vger.kernel.org>,
	<takahiro.akashi@linaro.org>, <horms@verge.net.au>,
	<linux-arm-kernel@lists.infradead.org>, Bhupesh SHARMA
	<bhupesh.linux@gmail.com>
From: Chen Zhou <chenzhou10@huawei.com>
Message-ID: <bf4050c5-cfb7-fd69-4892-1e0b65861d34@huawei.com>
Date: Thu, 16 May 2019 11:19:05 +0800
User-Agent: Mozilla/5.0 (Windows NT 6.1; WOW64; rv:45.0) Gecko/20100101
 Thunderbird/45.7.1
MIME-Version: 1.0
In-Reply-To: <a9d017d0-82d3-3e5f-4af2-4c611393106d@redhat.com>
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-Originating-IP: [10.177.131.64]
X-CFilter-Loop: Reflected
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Bhupesh,

On 2019/5/15 13:06, Bhupesh Sharma wrote:
> +Cc kexec-list.
> 
> Hi Chen,
> 
> I think we are still in the quiet period of the merge cycle, but this is a change which will be useful for systems like HPE Apollo where we are looking at reserving crashkernel across a larger range.
> 
> Some comments inline and in respective patch threads..
> 
> On 05/07/2019 09:20 AM, Chen Zhou wrote:
>> This patch series enable reserving crashkernel on high memory in arm64.
> 
> Please fix the patch subject, it should be v5.
> Also please Cc the kexec-list (kexec@lists.infradead.org) for future versions to allow wider review of the patchset.
> 
>> We use crashkernel=X to reserve crashkernel below 4G, which will fail
>> when there is no enough memory. Currently, crashkernel=Y@X can be used
>> to reserve crashkernel above 4G, in this case, if swiotlb or DMA buffers
>> are requierd, capture kernel will boot failure because of no low memory.
> 
> ... ^^ required
> 
> s/capture kernel will boot failure because of no low memory./capture kernel boot will fail because there is no low memory available for allocation.
> 
>> When crashkernel is reserved above 4G in memory, kernel should reserve
>> some amount of low memory for swiotlb and some DMA buffers. So there may
>> be two crash kernel regions, one is below 4G, the other is above 4G. Then
>> Crash dump kernel reads more than one crash kernel regions via a dtb
>> property under node /chosen,
>> linux,usable-memory-range = <BASE1 SIZE1 [BASE2 SIZE2]>.
> 
> Please use consistent naming for the second kernel, better to use crash dump kernel.
> 
> I have tested this on my HPE Apollo machine and with crashkernel=886M,high syntax, I can get the board to reserve a larger memory range for the crashkernel (i.e. 886M):
> 
> # dmesg | grep -i crash
> [    0.000000] kexec_core: Reserving 256MB of low memory at 3560MB for crashkernel (System low RAM: 2029MB)
> [    0.000000] crashkernel reserved: 0x0000000bc5a00000 - 0x0000000bfd000000 (886 MB)
> 
> kexec/kdump can also work also work fine on the board.
> 
> So, with the changes suggested in this cover letter and individual patches, please feel free to add:
> 
> Reviewed-and-Tested-by: Bhupesh Sharma <bhsharma@redhat.com>
> 
> Thanks,
> Bhupesh
> 

Thanks for you review and test. I will fix these later.

Thanks,
Chen Zhou

>> Besides, we need to modify kexec-tools:
>>    arm64: support more than one crash kernel regions(see [1])
>>
>> I post this patch series about one month ago. The previous changes and
>> discussions can be retrived from:
>>
>> Changes since [v4]
>> - reimplement memblock_cap_memory_ranges for multiple ranges by Mike.
>>
>> Changes since [v3]
>> - Add memblock_cap_memory_ranges back for multiple ranges.
>> - Fix some compiling warnings.
>>
>> Changes since [v2]
>> - Split patch "arm64: kdump: support reserving crashkernel above 4G" as
>>    two. Put "move reserve_crashkernel_low() into kexec_core.c" in a separate
>>    patch.
>>
>> Changes since [v1]:
>> - Move common reserve_crashkernel_low() code into kernel/kexec_core.c.
>> - Remove memblock_cap_memory_ranges() i added in v1 and implement that
>>    in fdt_enforce_memory_region().
>>    There are at most two crash kernel regions, for two crash kernel regions
>>    case, we cap the memory range [min(regs[*].start), max(regs[*].end)]
>>    and then remove the memory range in the middle.
>>
>> [1]: http://lists.infradead.org/pipermail/kexec/2019-April/022792.html
>> [v1]: https://lkml.org/lkml/2019/4/2/1174
>> [v2]: https://lkml.org/lkml/2019/4/9/86
>> [v3]: https://lkml.org/lkml/2019/4/9/306
>> [v4]: https://lkml.org/lkml/2019/4/15/273
>>
>> Chen Zhou (3):
>>    x86: kdump: move reserve_crashkernel_low() into kexec_core.c
>>    arm64: kdump: support reserving crashkernel above 4G
>>    kdump: update Documentation about crashkernel on arm64
>>
>> Mike Rapoport (1):
>>    memblock: extend memblock_cap_memory_range to multiple ranges
>>
>>   Documentation/admin-guide/kernel-parameters.txt |  6 +--
>>   arch/arm64/include/asm/kexec.h                  |  3 ++
>>   arch/arm64/kernel/setup.c                       |  3 ++
>>   arch/arm64/mm/init.c                            | 72 +++++++++++++++++++------
>>   arch/x86/include/asm/kexec.h                    |  3 ++
>>   arch/x86/kernel/setup.c                         | 66 +++--------------------
>>   include/linux/kexec.h                           |  5 ++
>>   include/linux/memblock.h                        |  2 +-
>>   kernel/kexec_core.c                             | 56 +++++++++++++++++++
>>   mm/memblock.c                                   | 44 +++++++--------
>>   10 files changed, 157 insertions(+), 103 deletions(-)
>>
> 
> 
> .
> 

