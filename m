Return-Path: <SRS0=CyaI=RD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9DAD6C43381
	for <linux-mm@archiver.kernel.org>; Thu, 28 Feb 2019 13:41:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4E7552171F
	for <linux-mm@archiver.kernel.org>; Thu, 28 Feb 2019 13:41:18 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=c-s.fr header.i=@c-s.fr header.b="NOmuiN3x"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4E7552171F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=c-s.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C98388E0004; Thu, 28 Feb 2019 08:41:17 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C478B8E0001; Thu, 28 Feb 2019 08:41:17 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B5FE08E0004; Thu, 28 Feb 2019 08:41:17 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id 5DB628E0001
	for <linux-mm@kvack.org>; Thu, 28 Feb 2019 08:41:17 -0500 (EST)
Received: by mail-wr1-f70.google.com with SMTP id h2so9795821wre.9
        for <linux-mm@kvack.org>; Thu, 28 Feb 2019 05:41:17 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=hOCOy++WiQFW15r8R0c7AKcxrMNwj6LqCNtElAGVP84=;
        b=C7Vm/Iexl9b6csnCFWyb/8PCIXlmsz72rR9KBp7zlqOAdOMwcj1k81BabANE2W1qYd
         hhiKTzdDz9wKcprk1oL7CCnml2/kc+pw4fIlEYmEX1zFTK7d8dcddgxISGm4xDbBomoG
         T8AXaD8a3zfognRTI/aTTwnjlNuj/TPMaxBDhbldAxsY6KjRt98eYvAwbaon9d20uH0u
         c0hOYs3+ZD5guxYTEUriAnyE5byMCmcnQwzTJqSPI1Pe8sDNgzS/EE/oPqRTy2tO65fG
         5fWm51NfYSdgryLUCS18LTrvVFM1IX7K1ruovw0ICZgbEIrJOUUaFQasFgxDqPDV8Gfq
         HdnQ==
X-Gm-Message-State: APjAAAVIwsTkQviJOiuEb5tlcy+QsGIwPmvv1MvpWJgP5Dbp9uiW7tvp
	k7lxW6S1UF28H35Dja30qPLgXBLBu9ZRdmx4foW3+ohzOBWuZrUVEFe9i+CbJuxC6Q/MGqlkgbi
	5lncxcHHiFlfJ/rJU7MnrHBIbloqblGXPP77EMzzzpnxj+Lrzsjeo/ZU1RHubLsjvzg==
X-Received: by 2002:adf:f691:: with SMTP id v17mr6567422wrp.66.1551361276798;
        Thu, 28 Feb 2019 05:41:16 -0800 (PST)
X-Google-Smtp-Source: APXvYqzfU/wpbcrkK7Ve63+hZbD1MPt9PajnWta6U6eCIcr6szu9oyVKFxHrKzqbQFCNHYvUPEMK
X-Received: by 2002:adf:f691:: with SMTP id v17mr6567349wrp.66.1551361275607;
        Thu, 28 Feb 2019 05:41:15 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551361275; cv=none;
        d=google.com; s=arc-20160816;
        b=PgsoPTmLjmN2CXQAgrD+S587KSkY8Rxd+CmG2iMGJrczKS2vv1Ue1nXT954WkPiuJk
         7SrweZrDkHVJkfDVpQ8dv0VpKiwG8MJlXiCk5/sOAHAMhJSUOU0YUoGWAx72NjF/S8Cc
         pSyRZsHA9Dh9TLDBUZ/F0+YEybkbiAFriWz2ln2bzGBaGLo9DwZzPCRFwAzlts2qrFmj
         NrGKIHjOk7y0sqjXYHfXGbhJQgzCJA1X47H7YKAu6GXba31yau205j7dzIToovpdQLws
         2CsmXlv1NfKn/HZNWDEkrgxUdi2rAcjZmiuFRtnOUrTehW/af39zg457wj5X5grcrylz
         Prvg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject
         :dkim-signature;
        bh=hOCOy++WiQFW15r8R0c7AKcxrMNwj6LqCNtElAGVP84=;
        b=VWwblGHJpibchuioOVxB4gkgrkklcMH5MjZ6DkssFONgab32B3qtFCZztXyQa5ocWF
         wIsbH9xTlhZ9wvF5hV5NWISCDrMoN/9rDbhQYL5uj1PhRNKvG+MvC/vDbk16O30KTK9L
         K0gsM8N78kv4Cm4kXc3m6+meLPIEA6CAh86tlTDTtF/SVIAyjcuew7ZC7FBvTGXFaRAp
         beBDF685/Naps7e4mLAEgukQwDGZHL3QN+yt/4iGVyYKVPiPYmHKxK4csVxxqwQlGF1R
         sq838teienhB8UNpUHl0ckc184diXt5rKktyuDPrr0NPsOarhsDWmGNNi6Fh50OUEV/F
         2BVg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@c-s.fr header.s=mail header.b=NOmuiN3x;
       spf=pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) smtp.mailfrom=christophe.leroy@c-s.fr
Received: from pegase1.c-s.fr (pegase1.c-s.fr. [93.17.236.30])
        by mx.google.com with ESMTPS id l13si12473134wrp.193.2019.02.28.05.41.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Feb 2019 05:41:15 -0800 (PST)
Received-SPF: pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) client-ip=93.17.236.30;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@c-s.fr header.s=mail header.b=NOmuiN3x;
       spf=pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) smtp.mailfrom=christophe.leroy@c-s.fr
Received: from localhost (mailhub1-int [192.168.12.234])
	by localhost (Postfix) with ESMTP id 449DGd3rpLz9tyYn;
	Thu, 28 Feb 2019 14:41:13 +0100 (CET)
Authentication-Results: localhost; dkim=pass
	reason="1024-bit key; insecure key"
	header.d=c-s.fr header.i=@c-s.fr header.b=NOmuiN3x; dkim-adsp=pass;
	dkim-atps=neutral
X-Virus-Scanned: Debian amavisd-new at c-s.fr
Received: from pegase1.c-s.fr ([192.168.12.234])
	by localhost (pegase1.c-s.fr [192.168.12.234]) (amavisd-new, port 10024)
	with ESMTP id d2fSe1RdEuf6; Thu, 28 Feb 2019 14:41:13 +0100 (CET)
Received: from messagerie.si.c-s.fr (messagerie.si.c-s.fr [192.168.25.192])
	by pegase1.c-s.fr (Postfix) with ESMTP id 449DGd1zHSz9tyYm;
	Thu, 28 Feb 2019 14:41:13 +0100 (CET)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=c-s.fr; s=mail;
	t=1551361273; bh=hOCOy++WiQFW15r8R0c7AKcxrMNwj6LqCNtElAGVP84=;
	h=Subject:To:Cc:References:From:Date:In-Reply-To:From;
	b=NOmuiN3xRGB3UR/PykRcWvdvpT9mMtp0BGLkMUJTt8wRtIGOqAkQPjv74oM+DZojD
	 HuHkj8/fxsud+/YEPv0J4O2uKbIF6PZ3R2Fv8Cj+JrmUmSI65S6e7RvCR+Wn9Vs/yC
	 +vqxLDUS5QCgiFGNtNQbvC464Z693gTxQJ2jqXy4=
Received: from localhost (localhost [127.0.0.1])
	by messagerie.si.c-s.fr (Postfix) with ESMTP id A62CC8BB46;
	Thu, 28 Feb 2019 14:41:14 +0100 (CET)
X-Virus-Scanned: amavisd-new at c-s.fr
Received: from messagerie.si.c-s.fr ([127.0.0.1])
	by localhost (messagerie.si.c-s.fr [127.0.0.1]) (amavisd-new, port 10023)
	with ESMTP id gfXiSERilif7; Thu, 28 Feb 2019 14:41:14 +0100 (CET)
Received: from PO15451 (unknown [192.168.4.90])
	by messagerie.si.c-s.fr (Postfix) with ESMTP id 9F9298BB1A;
	Thu, 28 Feb 2019 14:41:12 +0100 (CET)
Subject: Re: BUG: KASAN: stack-out-of-bounds
To: Andrey Ryabinin <aryabinin@virtuozzo.com>,
 Dmitry Vyukov <dvyukov@google.com>
Cc: Alexander Potapenko <glider@google.com>, Daniel Axtens <dja@axtens.net>,
 Linux-MM <linux-mm@kvack.org>, linuxppc-dev@lists.ozlabs.org,
 kasan-dev <kasan-dev@googlegroups.com>
References: <c6d80735-0cfe-b4ab-0349-673fc65b2e15@c-s.fr>
 <5f0203bd-77ea-d94c-11b7-1befba439cd4@virtuozzo.com>
 <15a40476-2852-cf5a-0982-d899dd79d9c1@c-s.fr>
 <7778f728-3ca2-7ad6-503f-72ca098863cb@virtuozzo.com>
 <CACT4Y+adjRarmcWTrQxotATzaHoFQ4TXbyiRXEpWozLPzjQBrQ@mail.gmail.com>
 <11314e32-6044-9207-a238-738e394ea2eb@virtuozzo.com>
From: Christophe Leroy <christophe.leroy@c-s.fr>
Message-ID: <fbdd1452-8305-9a1a-a80f-a10f56b41a88@c-s.fr>
Date: Thu, 28 Feb 2019 14:41:12 +0100
User-Agent: Mozilla/5.0 (Windows NT 6.1; WOW64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.1
MIME-Version: 1.0
In-Reply-To: <11314e32-6044-9207-a238-738e394ea2eb@virtuozzo.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: fr
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



Le 28/02/2019 à 10:47, Andrey Ryabinin a écrit :
> 
> 
> On 2/28/19 12:27 PM, Dmitry Vyukov wrote:
>> On Thu, Feb 28, 2019 at 10:22 AM Andrey Ryabinin
>> <aryabinin@virtuozzo.com> wrote:
>>>
>>>
>>>
>>> On 2/27/19 4:11 PM, Christophe Leroy wrote:
>>>>
>>>>
>>>> Le 27/02/2019 à 10:19, Andrey Ryabinin a écrit :
>>>>>
>>>>>
>>>>> On 2/27/19 11:25 AM, Christophe Leroy wrote:
>>>>>> With version v8 of the series implementing KASAN on 32 bits powerpc (https://patchwork.ozlabs.org/project/linuxppc-dev/list/?series=94309), I'm now able to activate KASAN on a mac99 is QEMU.
>>>>>>
>>>>>> Then I get the following reports at startup. Which of the two reports I get seems to depend on the option used to build the kernel, but for a given kernel I always get the same report.
>>>>>>
>>>>>> Is that a real bug, in which case how could I spot it ? Or is it something wrong in my implementation of KASAN ?
>>>>>>
>>>>>> I checked that after kasan_init(), the entire shadow memory is full of 0 only.
>>>>>>
>>>>>> I also made a try with the strong STACK_PROTECTOR compiled in, but no difference and nothing detected by the stack protector.
>>>>>>
>>>>>> ==================================================================
>>>>>> BUG: KASAN: stack-out-of-bounds in memchr+0x24/0x74
>>>>>> Read of size 1 at addr c0ecdd40 by task swapper/0
>>>>>>
>>>>>> CPU: 0 PID: 0 Comm: swapper Not tainted 5.0.0-rc7+ #1133
>>>>>> Call Trace:
>>>>>> [c0e9dca0] [c01c42a0] print_address_description+0x64/0x2bc (unreliable)
>>>>>> [c0e9dcd0] [c01c4684] kasan_report+0xfc/0x180
>>>>>> [c0e9dd10] [c089579c] memchr+0x24/0x74
>>>>>> [c0e9dd30] [c00a9e38] msg_print_text+0x124/0x574
>>>>>> [c0e9dde0] [c00ab710] console_unlock+0x114/0x4f8
>>>>>> [c0e9de40] [c00adc60] vprintk_emit+0x188/0x1c4
>>>>>> --- interrupt: c0e9df00 at 0x400f330
>>>>>>       LR = init_stack+0x1f00/0x2000
>>>>>> [c0e9de80] [c00ae3c4] printk+0xa8/0xcc (unreliable)
>>>>>> [c0e9df20] [c0c28e44] early_irq_init+0x38/0x108
>>>>>> [c0e9df50] [c0c16434] start_kernel+0x310/0x488
>>>>>> [c0e9dff0] [00003484] 0x3484
>>>>>>
>>>>>> The buggy address belongs to the variable:
>>>>>>    __log_buf+0xec0/0x4020
>>>>>> The buggy address belongs to the page:
>>>>>> page:c6eac9a0 count:1 mapcount:0 mapping:00000000 index:0x0
>>>>>> flags: 0x1000(reserved)
>>>>>> raw: 00001000 c6eac9a4 c6eac9a4 00000000 00000000 00000000 ffffffff 00000001
>>>>>> page dumped because: kasan: bad access detected
>>>>>>
>>>>>> Memory state around the buggy address:
>>>>>>    c0ecdc00: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
>>>>>>    c0ecdc80: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
>>>>>>> c0ecdd00: 00 00 00 00 00 00 00 00 f1 f1 f1 f1 00 00 00 00
>>>>>>                                      ^
>>>>>>    c0ecdd80: f3 f3 f3 f3 00 00 00 00 00 00 00 00 00 00 00 00
>>>>>>    c0ecde00: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
>>>>>> ==================================================================
>>>>>>
>>>>>
>>>>> This one doesn't look good. Notice that it says stack-out-of-bounds, but at the same time there is
>>>>>      "The buggy address belongs to the variable:  __log_buf+0xec0/0x4020"
>>>>>    which is printed by following code:
>>>>>      if (kernel_or_module_addr(addr) && !init_task_stack_addr(addr)) {
>>>>>          pr_err("The buggy address belongs to the variable:\n");
>>>>>          pr_err(" %pS\n", addr);
>>>>>      }
>>>>>
>>>>> So the stack unrelated address got stack-related poisoning. This could be a stack overflow, did you increase THREAD_SHIFT?
>>>>> KASAN with stack instrumentation significantly increases stack usage.
>>>>>
>>>>
>>>> I get the above with THREAD_SHIFT set to 13 (default value).
>>>> If increasing it to 14, I get the following instead. That means that in that case the problem arises a lot earlier in the boot process (but still after the final kasan shadow setup).
>>>>
>>>
>>> We usually use 15 (with 4k pages), but I think 14 should be enough for the clean boot.
>>>
>>>> ==================================================================
>>>> BUG: KASAN: stack-out-of-bounds in pmac_nvram_init+0x1f8/0x5d0
>>>> Read of size 1 at addr f6f37de0 by task swapper/0
>>>>
>>>> CPU: 0 PID: 0 Comm: swapper Not tainted 5.0.0-rc7+ #1143
>>>> Call Trace:
>>>> [c0e9fd60] [c01c43c0] print_address_description+0x164/0x2bc (unreliable)
>>>> [c0e9fd90] [c01c46a4] kasan_report+0xfc/0x180
>>>> [c0e9fdd0] [c0c226d4] pmac_nvram_init+0x1f8/0x5d0
>>>> [c0e9fef0] [c0c1f73c] pmac_setup_arch+0x298/0x314
>>>> [c0e9ff20] [c0c1ac40] setup_arch+0x250/0x268
>>>> [c0e9ff50] [c0c151dc] start_kernel+0xb8/0x488
>>>> [c0e9fff0] [00003484] 0x3484
>>>>
>>>>
>>>> Memory state around the buggy address:
>>>>   f6f37c80: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
>>>>   f6f37d00: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
>>>>> f6f37d80: 00 00 00 00 00 00 00 00 00 00 00 00 f1 f1 f1 f1
>>>>                                                 ^
>>>>   f6f37e00: 00 00 01 f4 f2 f2 f2 f2 00 00 00 00 f2 f2 f2 f2
>>>>   f6f37e80: 00 00 00 00 f3 f3 f3 f3 00 00 00 00 00 00 00 00
>>>> ==================================================================
>>>
>>> Powerpc's show_stack() prints stack addresses, so we know that stack is something near 0xc0e9f... address.
>>> f6f37de0 is definitely not stack address and it's to far for the stack overflow.
>>> So it looks like shadow for stack  - kasan_mem_to_shadow(0xc0e9f...) and shadow for address in report - kasan_mem_to_shadow(0xf6f37de0)
>>> point to the same physical page.
>>
>> Shouldn't shadow start at 0xf8 for powerpc32? I did some math
>> yesterday which I think lead me to 0xf8.
> 
> Dunno, maybe. How is this relevant? In case you referring to the 0xf6f* addresses in the report,
> these are not shadow, but accessed addresses.

Thanks for your help. Indeed you made me realise here that the access is 
to an IO Mapping, so being covered by the zero shadow page.

After some investigation I saw that the zero shadow page was being 
poisonned allthough i confirmed it was mapped RO in every page table 
entry referencing it.

What I finaly discovered is that in fact the HW still had some of the 
early page table entries pointing to the zero page in RW.

The reason for the above is due to the PGD having multiple entries 
pointing to kasan_early_shadow_pte[]. In powerpc hash32, a flag 
_PAGE_HASHPTE is set to tell when a PTE has been given to HW. Then when 
flush_tlb_kernel_range() is called, the kernel walks the page tables and 
only really flushes the pages having the _PAGE_HASHPTE flag, then clear it.
The consequence is that when the kernel walk again that PTE from a 
different PGD entry, it is seen as not needing flush anymore.

So, the conclusion to this that I'm finalising at the moment is to have 
the final shadow page table layout set up as soon as memblock is 
available and before switching from the early hash table to the final 
hash table.

Christophe

> 
>> This allows to cover at most 1GB of memory. Do you have more by any chance?
>>

