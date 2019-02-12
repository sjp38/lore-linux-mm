Return-Path: <SRS0=CIMh=QT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 70BFEC282CE
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 20:01:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2A3E4222C1
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 20:01:48 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2A3E4222C1
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BDB098E0003; Tue, 12 Feb 2019 15:01:47 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B89328E0001; Tue, 12 Feb 2019 15:01:47 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A4FBD8E0003; Tue, 12 Feb 2019 15:01:47 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 7A9008E0001
	for <linux-mm@kvack.org>; Tue, 12 Feb 2019 15:01:47 -0500 (EST)
Received: by mail-qk1-f199.google.com with SMTP id e9so16660366qka.11
        for <linux-mm@kvack.org>; Tue, 12 Feb 2019 12:01:47 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=5J3BEVMX8I3R6aDWiylH49L5Eh0Yio3E7KsL+Og9pHE=;
        b=R1aqUmCWAz8BoL6jjXQBcqdjCayCQTnQJwuHuqS1iSFv2w1UnhOWXFU2OoXWVx7/2L
         S4LDzcSd9kaJstU0DYrDxifUdgwrmtw/F2J2k7dNWXoCOPIbWGfB8avkC2Ctv5cCuo8f
         wG+5snGRS4Ltg+rCWVyRBYJrXbRDRezjU6536QgsHrGC2nhCqSnM1Sesi8ZjU6NcMdLd
         11b5sLN6fscaMA8zUd2wPDeoranQ/ECDpuis3sgJsfEP+jXrpxCVCbZOVgpYLH83ZeGj
         t7Zd+Itg2pGHmEnNsx3hpPmQlkzH/slub1qj+ChQugqwhvY7HnV8u/tzkuf9aSRVYzeh
         7maw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of labbott@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=labbott@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AHQUAub1+0cItpziOszrW53h/cXgJhE3kBd+kxN+qZFO927TNYB5QL4u
	0Wp9tJIHPjfaHyk3CNgExM7Blkknv4e3Grpoz/3MOP7Cwd9eIxg4dGw1QRhfnBFtu+5Vro2t5j8
	hcsLb1pCh7fEsX4ywdUEIs02wHlAqeg6vrKsqgbaeVrdMvSBD1lMxu0oKlECgRzA+CTradv3lYO
	90NeRRi7d5RepOaxQexlpuMW/ECmTt4swM3NmCPDHDuWXqYa3w8VJg4RqnX2xMQpAaYKAZ+OCy4
	BywOB7gstcMzVojDMUXtZTprhd2/gycPpMGLFFNOpB7XE9RxqvvV3iE8LOiRL4oEUi2+gkY7+p2
	bHWEa/vy+iyjMrS4n8p7rVbgEJ2ICv5gjR9/HpdKPaTzZ88Uumz5hb+VRMliYWpezgGXpeK8lqG
	n
X-Received: by 2002:a37:4a8b:: with SMTP id x133mr3862996qka.164.1550001707180;
        Tue, 12 Feb 2019 12:01:47 -0800 (PST)
X-Received: by 2002:a37:4a8b:: with SMTP id x133mr3862598qka.164.1550001701816;
        Tue, 12 Feb 2019 12:01:41 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550001701; cv=none;
        d=google.com; s=arc-20160816;
        b=rffAYG/USY1gXzZ24d4a2BdJXICsYclam1yNtLC+99sdn/rdWjx4YGJzc7gx3ZlD8L
         KDtv2Zrr5KXrNsqd51uFVuaNEFtzigIO0K9PlCIJQgFkwjKePmfGTAThLdTy6HCCgDYy
         l+5gQOCPM5WV/sR1dTCDtCqbSIPkOIYxcmX9ELHdkUfGrWnJH+1fTQsb65LDpg18k+6V
         C+MwMFuow8IXe3pimj7f1dgB87evrmeQG6nCx3lMBxPh4sTUySDeSUbX0IbNAJ2C8ebG
         UlKlbrtQkNstxmtyLIQuf7f1P0JfPMFzKZdm6QjL223ilwDg6Ookr+3RdFsaIuschUsJ
         16Hw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=5J3BEVMX8I3R6aDWiylH49L5Eh0Yio3E7KsL+Og9pHE=;
        b=QtVrG83Iog+b6CKDVmG3ORB5BUTDABc5qkB4U93VBy630TuPy0S5VNQhWagV7pz1+0
         2wbeHTxIrNZs/l9HfLxP3ijVB77NDvI4e8eY6e56EbZjOkKlLDFIRutAwnNHTn496dSS
         oOIbQpoWpu1V/DfmLXOAK8l2IsvXVvu0MqH2PsxW4r4LNMKFP5c/e1OgcdVUSH1jayVF
         9LT9l1n96JupBsaW+AqrvHWXjPPVw66AdolBdDwOA6WLJQ+3E/4JhTRXNqbxssh1zbRG
         uVZFcN+YCTKIR8XOXxCGVEWKt4qAENqhbNEdy87M/ja+3B1H2BOLUmzUYDsWl2WBdSq1
         f7Xg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of labbott@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=labbott@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a9sor17214032qtj.40.2019.02.12.12.01.41
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 12 Feb 2019 12:01:41 -0800 (PST)
Received-SPF: pass (google.com: domain of labbott@redhat.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of labbott@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=labbott@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Google-Smtp-Source: AHgI3Ibb/fAwJBL5b9xb1ME5M4mJiSWWwndBNvOjwi+A3vbQNEu+Xmy/HhD6sB4kQ8UGZQAnBK23iQ==
X-Received: by 2002:ac8:21ce:: with SMTP id 14mr4243520qtz.306.1550001701410;
        Tue, 12 Feb 2019 12:01:41 -0800 (PST)
Received: from ?IPv6:2601:602:9800:dae6::112f? ([2601:602:9800:dae6::112f])
        by smtp.gmail.com with ESMTPSA id t123sm14960812qkc.6.2019.02.12.12.01.37
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Feb 2019 12:01:40 -0800 (PST)
Subject: Re: [RFC PATCH v7 05/16] arm64/mm: Add support for XPFO
To: Khalid Aziz <khalid.aziz@oracle.com>,
 Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Cc: juergh@gmail.com, tycho@tycho.ws, jsteckli@amazon.de, ak@linux.intel.com,
 torvalds@linux-foundation.org, liran.alon@oracle.com, keescook@google.com,
 Juerg Haefliger <juerg.haefliger@canonical.com>,
 deepa.srinivasan@oracle.com, chris.hyser@oracle.com, tyhicks@canonical.com,
 dwmw@amazon.co.uk, andrew.cooper3@citrix.com, jcm@redhat.com,
 boris.ostrovsky@oracle.com, kanth.ghatraju@oracle.com,
 joao.m.martins@oracle.com, jmattson@google.com, pradeep.vincent@oracle.com,
 john.haxby@oracle.com, tglx@linutronix.de, kirill.shutemov@linux.intel.com,
 hch@lst.de, steven.sistare@oracle.com, kernel-hardening@lists.openwall.com,
 linux-mm@kvack.org, linux-kernel@vger.kernel.org,
 linux-arm-kernel@lists.infradead.org, Tycho Andersen <tycho@docker.com>
References: <cover.1547153058.git.khalid.aziz@oracle.com>
 <89f03091af87f5ab27bd6cafb032236d5bd81d65.1547153058.git.khalid.aziz@oracle.com>
 <20190123142410.GC19289@Konrads-MacBook-Pro.local>
 <4dfba458-1bf6-25ff-df4c-b96a1221cd95@oracle.com>
From: Laura Abbott <labbott@redhat.com>
Message-ID: <7497bd44-1fda-e073-ba7f-18a76577b64a@redhat.com>
Date: Tue, 12 Feb 2019 12:01:36 -0800
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <4dfba458-1bf6-25ff-df4c-b96a1221cd95@oracle.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 2/12/19 7:52 AM, Khalid Aziz wrote:
> On 1/23/19 7:24 AM, Konrad Rzeszutek Wilk wrote:
>> On Thu, Jan 10, 2019 at 02:09:37PM -0700, Khalid Aziz wrote:
>>> From: Juerg Haefliger <juerg.haefliger@canonical.com>
>>>
>>> Enable support for eXclusive Page Frame Ownership (XPFO) for arm64 and
>>> provide a hook for updating a single kernel page table entry (which is
>>> required by the generic XPFO code).
>>>
>>> v6: use flush_tlb_kernel_range() instead of __flush_tlb_one()
>>>
>>> CC: linux-arm-kernel@lists.infradead.org
>>> Signed-off-by: Juerg Haefliger <juerg.haefliger@canonical.com>
>>> Signed-off-by: Tycho Andersen <tycho@docker.com>
>>> Signed-off-by: Khalid Aziz <khalid.aziz@oracle.com>
>>> ---
>>>   arch/arm64/Kconfig     |  1 +
>>>   arch/arm64/mm/Makefile |  2 ++
>>>   arch/arm64/mm/xpfo.c   | 58 ++++++++++++++++++++++++++++++++++++++++++
>>>   3 files changed, 61 insertions(+)
>>>   create mode 100644 arch/arm64/mm/xpfo.c
>>>
>>> diff --git a/arch/arm64/Kconfig b/arch/arm64/Kconfig
>>> index ea2ab0330e3a..f0a9c0007d23 100644
>>> --- a/arch/arm64/Kconfig
>>> +++ b/arch/arm64/Kconfig
>>> @@ -171,6 +171,7 @@ config ARM64
>>>   	select SWIOTLB
>>>   	select SYSCTL_EXCEPTION_TRACE
>>>   	select THREAD_INFO_IN_TASK
>>> +	select ARCH_SUPPORTS_XPFO
>>>   	help
>>>   	  ARM 64-bit (AArch64) Linux support.
>>>   
>>> diff --git a/arch/arm64/mm/Makefile b/arch/arm64/mm/Makefile
>>> index 849c1df3d214..cca3808d9776 100644
>>> --- a/arch/arm64/mm/Makefile
>>> +++ b/arch/arm64/mm/Makefile
>>> @@ -12,3 +12,5 @@ KASAN_SANITIZE_physaddr.o	+= n
>>>   
>>>   obj-$(CONFIG_KASAN)		+= kasan_init.o
>>>   KASAN_SANITIZE_kasan_init.o	:= n
>>> +
>>> +obj-$(CONFIG_XPFO)		+= xpfo.o
>>> diff --git a/arch/arm64/mm/xpfo.c b/arch/arm64/mm/xpfo.c
>>> new file mode 100644
>>> index 000000000000..678e2be848eb
>>> --- /dev/null
>>> +++ b/arch/arm64/mm/xpfo.c
>>> @@ -0,0 +1,58 @@
>>> +/*
>>> + * Copyright (C) 2017 Hewlett Packard Enterprise Development, L.P.
>>> + * Copyright (C) 2016 Brown University. All rights reserved.
>>> + *
>>> + * Authors:
>>> + *   Juerg Haefliger <juerg.haefliger@hpe.com>
>>> + *   Vasileios P. Kemerlis <vpk@cs.brown.edu>
>>> + *
>>> + * This program is free software; you can redistribute it and/or modify it
>>> + * under the terms of the GNU General Public License version 2 as published by
>>> + * the Free Software Foundation.
>>> + */
>>> +
>>> +#include <linux/mm.h>
>>> +#include <linux/module.h>
>>> +
>>> +#include <asm/tlbflush.h>
>>> +
>>> +/*
>>> + * Lookup the page table entry for a virtual address and return a pointer to
>>> + * the entry. Based on x86 tree.
>>> + */
>>> +static pte_t *lookup_address(unsigned long addr)
>>> +{
>>> +	pgd_t *pgd;
>>> +	pud_t *pud;
>>> +	pmd_t *pmd;
>>> +
>>> +	pgd = pgd_offset_k(addr);
>>> +	if (pgd_none(*pgd))
>>> +		return NULL;
>>> +
>>> +	pud = pud_offset(pgd, addr);
>>> +	if (pud_none(*pud))
>>> +		return NULL;
>>> +
>>> +	pmd = pmd_offset(pud, addr);
>>> +	if (pmd_none(*pmd))
>>> +		return NULL;
>>> +
>>> +	return pte_offset_kernel(pmd, addr);
>>> +}
>>> +
>>> +/* Update a single kernel page table entry */
>>> +inline void set_kpte(void *kaddr, struct page *page, pgprot_t prot)
>>> +{
>>> +	pte_t *pte = lookup_address((unsigned long)kaddr);
>>> +
>>> +	set_pte(pte, pfn_pte(page_to_pfn(page), prot));
>>
>> Thought on the other hand.. what if the page is PMD? Do you really want
>> to do this?
>>
>> What if 'pte' is NULL?
>>> +}
>>> +
>>> +inline void xpfo_flush_kernel_tlb(struct page *page, int order)
>>> +{
>>> +	unsigned long kaddr = (unsigned long)page_address(page);
>>> +	unsigned long size = PAGE_SIZE;
>>> +
>>> +	flush_tlb_kernel_range(kaddr, kaddr + (1 << order) * size);
>>
>> Ditto here. You are assuming it is PTE, but it may be PMD or such.
>> Or worts - the lookup_address could be NULL.
>>
>>> +}
>>> -- 
>>> 2.17.1
>>>
> 
> Hi Konrad,
> 
> This makes sense. x86 version of set_kpte() checks pte for NULL and also
> checks if the page is PMD. Now what you said about adding level to
> lookup_address() for arm makes more sense.
> 
> Can someone with knowledge of arm64 mmu make recommendations here?
> 
> Thanks,
> Khalid
> 

arm64 can't split larger pages and requires everything must be
mapped as pages (see [RFC PATCH v7 08/16] arm64/mm: disable
section/contiguous mappings if XPFO is enabled) . Any
situation where we would get something other than a pte
would be a bug.

Thanks,
Laura

