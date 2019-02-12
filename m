Return-Path: <SRS0=CIMh=QT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A3639C282C4
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 11:38:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 366E42083B
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 11:38:53 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=c-s.fr header.i=@c-s.fr header.b="rpiD7R85"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 366E42083B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=c-s.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C40BF8E0016; Tue, 12 Feb 2019 06:38:52 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BF0438E0014; Tue, 12 Feb 2019 06:38:52 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AB89E8E0016; Tue, 12 Feb 2019 06:38:52 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id 5520D8E0014
	for <linux-mm@kvack.org>; Tue, 12 Feb 2019 06:38:52 -0500 (EST)
Received: by mail-wr1-f70.google.com with SMTP id f4so887801wrj.11
        for <linux-mm@kvack.org>; Tue, 12 Feb 2019 03:38:52 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=+nWwf4m2ZiyJGOlotJzr2fuERjfLOsm0rPxjR/sxClc=;
        b=fTTLRpsIeJT7sADTKTJBjlig7CWRURsZEO0RAQZ6sO5vHu/tLk5Mg0ATDQpnRycSgT
         mvTVYwsNhmlRe/5w46VbOI8ZCYo2D5T00g/ZSu4bCeVFDuEP4SLzi2d7xEso2KSTaWre
         FEvvVZZ/CtQbBzb3Yrbusse3mlNBdv0VVKqF3hHD8FcmDkfAmE5G2OHLu3ttdDj8hDmf
         aHrc0mhlUwOXLp4BSJTWcjkIvdl/h7U/RLQ2awBfErzpLJNsA4dgFZjaevCgQIeGXHs1
         olOFURtdwhLC63E8cwalqhuCA/JcVw2T5M6o2DcXtjLqHtAa+3tt8iS7flsVGFJ8qPWx
         bvRw==
X-Gm-Message-State: AHQUAuZMzmTo3uJWiMEAKcv4DNW/EerKrZRMNy468VVWT8ySlz/Ln4Tj
	opUq2oY9urrCFWFIqD5lpk2UoHDqXBLQ1miL87h2jVYFddvan5nUHeBcxdidN9lG1WSlBt0nrpq
	8TT7HeZR0qXBVCeUIH8oE5+rbDhOkfESHRvDstXjiRyvHX0APaF/ESinEOyRdcw0JUQ==
X-Received: by 2002:a7b:c766:: with SMTP id x6mr2572959wmk.15.1549971531865;
        Tue, 12 Feb 2019 03:38:51 -0800 (PST)
X-Google-Smtp-Source: AHgI3Ibfi6Unu4jRzYLYt+BNs8oWzuPtRs8pT43ACbfEsbLVTOH4sbiSTi06KKvb7bRMMLQoBk/O
X-Received: by 2002:a7b:c766:: with SMTP id x6mr2572902wmk.15.1549971530792;
        Tue, 12 Feb 2019 03:38:50 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549971530; cv=none;
        d=google.com; s=arc-20160816;
        b=LVotlIDPDUBoPvxQ1Mh0xaI7ykLiQr50TmPuoZaORvABcUsCmgVAv6yy+1hQYisMMZ
         CUHvZP7/4nP4C+VoMnYvXB5+YiBd1J6PMQ32fuSEpULR4eAXLhXo3dlFsQeiXws7xwjj
         vxZSvqxz9VCNBY0N/gzJb2nBKB3IHm7dACUXD/b/2wT4bV+QNU2xTzqrld24ObojJNjo
         MeA/EZGmYe3EDSu5tSeyqa1Kazd1p68TsEBhcfK+RzO2PmXmcaiwju3NzDlVQMhaBPmf
         8T74K8XwYCwtrFgV/X0MMzM6REV5Do9hqdby8P9IGQpcebD93dDdaaVxAV6W+PFwVdIn
         BfCw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject
         :dkim-signature;
        bh=+nWwf4m2ZiyJGOlotJzr2fuERjfLOsm0rPxjR/sxClc=;
        b=CcwvZOgZQqr6WVYQZJF7nyAWTsQMg5x3G8s4vwhgpGEk2UgZyLiUBcSRu7kl4wFOub
         gLdmkfaVh+NIliHhl6mKOJ2PjJuxkwFLn1NapfQJChZYA6I0DyiXP+B3vFtRaiMllzGc
         gN4hNfbE6SAi/lAwVD4NzD2Klf4axofnHqidJGYXKYvNkon53n8/jxAgArlCsA/uCAqC
         J/lPzt2/TGy2KRkdRFAWv3GiYZbEc0//rzqqYdFz9n6K+FIatjJcLigctIU1YpDBFn2o
         FDCRrkrJTC6FlVECJviEMG0o4vDDGejPxQ3OWciQioo+FpPMWxpYycoYLySmf8LbnQ2D
         /cmQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@c-s.fr header.s=mail header.b=rpiD7R85;
       spf=pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) smtp.mailfrom=christophe.leroy@c-s.fr
Received: from pegase1.c-s.fr (pegase1.c-s.fr. [93.17.236.30])
        by mx.google.com with ESMTPS id l64si1579506wml.126.2019.02.12.03.38.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Feb 2019 03:38:50 -0800 (PST)
Received-SPF: pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) client-ip=93.17.236.30;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@c-s.fr header.s=mail header.b=rpiD7R85;
       spf=pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) smtp.mailfrom=christophe.leroy@c-s.fr
Received: from localhost (mailhub1-int [192.168.12.234])
	by localhost (Postfix) with ESMTP id 43zLJn040Nz9v0Gq;
	Tue, 12 Feb 2019 12:38:49 +0100 (CET)
Authentication-Results: localhost; dkim=pass
	reason="1024-bit key; insecure key"
	header.d=c-s.fr header.i=@c-s.fr header.b=rpiD7R85; dkim-adsp=pass;
	dkim-atps=neutral
X-Virus-Scanned: Debian amavisd-new at c-s.fr
Received: from pegase1.c-s.fr ([192.168.12.234])
	by localhost (pegase1.c-s.fr [192.168.12.234]) (amavisd-new, port 10024)
	with ESMTP id 983SEZ5gs7oC; Tue, 12 Feb 2019 12:38:48 +0100 (CET)
Received: from messagerie.si.c-s.fr (messagerie.si.c-s.fr [192.168.25.192])
	by pegase1.c-s.fr (Postfix) with ESMTP id 43zLJm5c2Kz9v0Gn;
	Tue, 12 Feb 2019 12:38:48 +0100 (CET)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=c-s.fr; s=mail;
	t=1549971528; bh=+nWwf4m2ZiyJGOlotJzr2fuERjfLOsm0rPxjR/sxClc=;
	h=Subject:To:Cc:References:From:Date:In-Reply-To:From;
	b=rpiD7R85ztjkH/+wDCOI2l0GT2FujLIBH6e6+uQv7WieZb9ApvMV6trd85wZeTr1j
	 TCdnNfj0HACYi6pq86RBnlP0YPSdGREgc/AYb2+iAV78syykOCBKCamQgAkfWj7/dI
	 LQcTZ9WsIiQatkuGRsFFCDcNonA2Pgv2YvDdOtiM=
Received: from localhost (localhost [127.0.0.1])
	by messagerie.si.c-s.fr (Postfix) with ESMTP id D65A08B7F3;
	Tue, 12 Feb 2019 12:38:49 +0100 (CET)
X-Virus-Scanned: amavisd-new at c-s.fr
Received: from messagerie.si.c-s.fr ([127.0.0.1])
	by localhost (messagerie.si.c-s.fr [127.0.0.1]) (amavisd-new, port 10023)
	with ESMTP id jGAZdQqgzJWR; Tue, 12 Feb 2019 12:38:49 +0100 (CET)
Received: from PO15451 (unknown [192.168.4.90])
	by messagerie.si.c-s.fr (Postfix) with ESMTP id BDB808B7EB;
	Tue, 12 Feb 2019 12:38:48 +0100 (CET)
Subject: Re: [PATCH v4 3/3] powerpc/32: Add KASAN support
To: Daniel Axtens <dja@axtens.net>, Andrey Ryabinin
 <aryabinin@virtuozzo.com>, Andrey Konovalov <andreyknvl@google.com>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>,
 Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>,
 Nicholas Piggin <npiggin@gmail.com>,
 "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>,
 Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>,
 Linux Memory Management List <linux-mm@kvack.org>,
 PowerPC <linuxppc-dev@lists.ozlabs.org>, LKML
 <linux-kernel@vger.kernel.org>, kasan-dev <kasan-dev@googlegroups.com>
References: <cover.1548166824.git.christophe.leroy@c-s.fr>
 <1f5629e03181d0e30efc603f00dad78912991a45.1548166824.git.christophe.leroy@c-s.fr>
 <87ef8i45km.fsf@dja-thinkpad.axtens.net>
 <69720148-fd19-0810-5a1d-96c45e2ec00c@c-s.fr>
 <CAAeHK+wcUwLiSQffUkcyiH2fuox=VihJadEqQqRG1YfU3Y2gDA@mail.gmail.com>
 <f8b9e9ec-991b-6824-46c2-f7fc0aaa7fb8@c-s.fr>
 <CAAeHK+zop5ajOJQ4KEYbuxMRegk2GM1LvuGcSbCU1O5EZxB0MA@mail.gmail.com>
 <805fbf9d-a10f-03e0-aa52-6f6bd16059b9@virtuozzo.com>
 <87imxpak4r.fsf@linkitivity.dja.id.au>
From: Christophe Leroy <christophe.leroy@c-s.fr>
Message-ID: <a11adaf3-beda-ed0c-e6aa-9ef30f2e80cf@c-s.fr>
Date: Tue, 12 Feb 2019 12:38:48 +0100
User-Agent: Mozilla/5.0 (Windows NT 6.1; WOW64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.0
MIME-Version: 1.0
In-Reply-To: <87imxpak4r.fsf@linkitivity.dja.id.au>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: fr
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



Le 12/02/2019 à 02:08, Daniel Axtens a écrit :
> Andrey Ryabinin <aryabinin@virtuozzo.com> writes:
> 
>> On 2/11/19 3:25 PM, Andrey Konovalov wrote:
>>> On Sat, Feb 9, 2019 at 12:55 PM christophe leroy
>>> <christophe.leroy@c-s.fr> wrote:
>>>>
>>>> Hi Andrey,
>>>>
>>>> Le 08/02/2019 à 18:40, Andrey Konovalov a écrit :
>>>>> On Fri, Feb 8, 2019 at 6:17 PM Christophe Leroy <christophe.leroy@c-s.fr> wrote:
>>>>>>
>>>>>> Hi Daniel,
>>>>>>
>>>>>> Le 08/02/2019 à 17:18, Daniel Axtens a écrit :
>>>>>>> Hi Christophe,
>>>>>>>
>>>>>>> I've been attempting to port this to 64-bit Book3e nohash (e6500),
>>>>>>> although I think I've ended up with an approach more similar to Aneesh's
>>>>>>> much earlier (2015) series for book3s.
>>>>>>>
>>>>>>> Part of this is just due to the changes between 32 and 64 bits - we need
>>>>>>> to hack around the discontiguous mappings - but one thing that I'm
>>>>>>> particularly puzzled by is what the kasan_early_init is supposed to do.
>>>>>>
>>>>>> It should be a problem as my patch uses a 'for_each_memblock(memory,
>>>>>> reg)' loop.
>>>>>>
>>>>>>>
>>>>>>>> +void __init kasan_early_init(void)
>>>>>>>> +{
>>>>>>>> +    unsigned long addr = KASAN_SHADOW_START;
>>>>>>>> +    unsigned long end = KASAN_SHADOW_END;
>>>>>>>> +    unsigned long next;
>>>>>>>> +    pmd_t *pmd = pmd_offset(pud_offset(pgd_offset_k(addr), addr), addr);
>>>>>>>> +    int i;
>>>>>>>> +    phys_addr_t pa = __pa(kasan_early_shadow_page);
>>>>>>>> +
>>>>>>>> +    BUILD_BUG_ON(KASAN_SHADOW_START & ~PGDIR_MASK);
>>>>>>>> +
>>>>>>>> +    if (early_mmu_has_feature(MMU_FTR_HPTE_TABLE))
>>>>>>>> +            panic("KASAN not supported with Hash MMU\n");
>>>>>>>> +
>>>>>>>> +    for (i = 0; i < PTRS_PER_PTE; i++)
>>>>>>>> +            __set_pte_at(&init_mm, (unsigned long)kasan_early_shadow_page,
>>>>>>>> +                         kasan_early_shadow_pte + i,
>>>>>>>> +                         pfn_pte(PHYS_PFN(pa), PAGE_KERNEL_RO), 0);
>>>>>>>> +
>>>>>>>> +    do {
>>>>>>>> +            next = pgd_addr_end(addr, end);
>>>>>>>> +            pmd_populate_kernel(&init_mm, pmd, kasan_early_shadow_pte);
>>>>>>>> +    } while (pmd++, addr = next, addr != end);
>>>>>>>> +}
>>>>>>>
>>>>>>> As far as I can tell it's mapping the early shadow page, read-only, over
>>>>>>> the KASAN_SHADOW_START->KASAN_SHADOW_END range, and it's using the early
>>>>>>> shadow PTE array from the generic code.
>>>>>>>
>>>>>>> I haven't been able to find an answer to why this is in the docs, so I
>>>>>>> was wondering if you or anyone else could explain the early part of
>>>>>>> kasan init a bit better.
>>>>>>
>>>>>> See https://www.kernel.org/doc/html/latest/dev-tools/kasan.html for an
>>>>>> explanation of the shadow.
>>>>>>
>>>>>> When shadow is 0, it means the memory area is entirely accessible.
>>>>>>
>>>>>> It is necessary to setup a shadow area as soon as possible because all
>>>>>> data accesses check the shadow area, from the begining (except for a few
>>>>>> files where sanitizing has been disabled in Makefiles).
>>>>>>
>>>>>> Until the real shadow area is set, all access are granted thanks to the
>>>>>> zero shadow area beeing for of zeros.
>>>>>
>>>>> Not entirely correct. kasan_early_init() indeed maps the whole shadow
>>>>> memory range to the same kasan_early_shadow_page. However as kernel
>>>>> loads and memory gets allocated this shadow page gets rewritten with
>>>>> non-zero values by different KASAN allocator hooks. Since these values
>>>>> come from completely different parts of the kernel, but all land on
>>>>> the same page, kasan_early_shadow_page's content can be considered
>>>>> garbage. When KASAN checks memory accesses for validity it detects
>>>>> these garbage shadow values, but doesn't print any reports, as the
>>>>> reporting routine bails out on the current->kasan_depth check (which
>>>>> has the value of 1 initially). Only after kasan_init() completes, when
>>>>> the proper shadow memory is mapped, current->kasan_depth gets set to 0
>>>>> and we start reporting bad accesses.
>>>>
>>>> That's surprising, because in the early phase I map the shadow area
>>>> read-only, so I do not expect it to get modified unless RO protection is
>>>> failing for some reason.
>>>
>>> Actually it might be that the allocator hooks don't modify shadow at
>>> this point, as the allocator is not yet initialized. However stack
>>> should be getting poisoned and unpoisoned from the very start. But the
>>> generic statement that early shadow gets dirtied should be correct.
>>> Might it be that you don't use stack instrumentation?
>>>
>>
>> Yes, stack instrumentation is not used here, because shadow offset which we pass to
>> the -fasan-shadow-offset= cflag is not specified here. So the logic in scrpits/Makefile.kasan
>> just fallbacks to CFLAGS_KASAN_MINIMAL, which is outline and without stack instrumentation.
>>
>> Christophe, you can specify KASAN_SHADOW_OFFSET either in Kconfig (e.g. x86_64) or
>> in Makefile (e.g. arm64). And make early mapping writable, because compiler generated code will write
>> to shadow memory in function prologue/epilogue.
> 
> Hmm. Is this limitation just that compilers have not implemented
> out-of-line support for stack instrumentation, or is there a deeper
> reason that stack/global instrumentation relies upon inline
> instrumentation?

No, it looks like as soon as we define KASAN_SHADOW_OFFSET in Makefile 
in addition to asm/kasan.h, stack instrumentation works with out-of-line.

I'll send series v5 soon.

Christophe

> 
> I ask because it's very common on ppc64 to have the virtual address
> space split up into discontiguous blocks. I know this means we lose
> inline instrumentation, but I didn't realise we'd also lose stack and
> global instrumentation...
> 
> I wonder if it would be worth, in the distant future, trying to
> implement a smarter scheme in compilers where we could insert more
> complex inline mapping schemes.
> 
> Regards,
> Daniel
> 

