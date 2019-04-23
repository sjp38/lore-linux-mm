Return-Path: <SRS0=sydr=SZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 70E5EC282E1
	for <linux-mm@archiver.kernel.org>; Tue, 23 Apr 2019 07:32:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1FF6420645
	for <linux-mm@archiver.kernel.org>; Tue, 23 Apr 2019 07:32:16 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1FF6420645
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B3B626B0003; Tue, 23 Apr 2019 03:32:15 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AE7C46B0006; Tue, 23 Apr 2019 03:32:15 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9B1816B0007; Tue, 23 Apr 2019 03:32:15 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 4B5076B0003
	for <linux-mm@kvack.org>; Tue, 23 Apr 2019 03:32:15 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id o3so7506567edr.6
        for <linux-mm@kvack.org>; Tue, 23 Apr 2019 00:32:15 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:subject
         :to:cc:references:message-id:date:user-agent:mime-version
         :in-reply-to:content-language:content-transfer-encoding;
        bh=Mdsn1hqOiVdoh781EYC9AX9axb3hKxh37ECIIawKCbw=;
        b=B0e4m3UnrjRkO/cOjN4BP/ymEKHDxK7f47kMBt4pPKPWbxMtd/QjV5zas9+0UvbMt6
         f8ftRSPt9+ogpqJ5p2zqbxR9cHE5TyHnGE5KZ/iHNQ+aSCKhOvgof0lHmTrG1+ce4qKU
         +EpZFX0DXImo/1x/hCjdCzNMTiGzZv6GSYGD7haTFaecS1N7lhgdwEYnYjDB4t7EBc7y
         q8L93ssKkBiS1gmP743f9FOzjTcz2otlw/fA7HxtTk4cM2bazPLasJJ1PrDCH+b9BHQu
         pCbx9hjDxugQGlHiKvGFnQFJTXa6uue7bkCA0tlNhyvNFQbPK1/PCoyXKjw7zzvH+cVi
         GsZg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
X-Gm-Message-State: APjAAAXPBLUGaWjCPexTEqqFmh6aBStjlIWcZMXZpZQEANnarKefwQxj
	NuI1ISLB6Hew6ppvZrxBxW0TzrIqQoLk7EoZwAObOVl2ucFpmf5SJUoHA3rTMa8+zdRh8V36bgr
	BMZHB99a/EaTNYo0Wo4G90POliaNQwC63BO4q9bhMXloYWLfK3L2ZLvWeHePZW67JNg==
X-Received: by 2002:a50:86bd:: with SMTP id r58mr14891078eda.155.1556004734805;
        Tue, 23 Apr 2019 00:32:14 -0700 (PDT)
X-Google-Smtp-Source: APXvYqycHsBPuIDBtHlyWKHns5k7xGFnCFjNnw637Ebz/GSkDHV9raU0IV4nRsFflF0gdQP/hv/x
X-Received: by 2002:a50:86bd:: with SMTP id r58mr14891026eda.155.1556004733753;
        Tue, 23 Apr 2019 00:32:13 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556004733; cv=none;
        d=google.com; s=arc-20160816;
        b=voltmbulvjdRuBQIYo8W+HvOTWMfKd3sqU0fGUV1J237n3L9Beki9TGqbVUzw4KyCM
         AeeUbEfkFGlFwhVlmPR2Kx/mZCNsIKpwD9vwZsPr+F5fYiaCwF57IcV85GDjj4rNIVRm
         K2LmhPZU5ZV1ah93jKgvshigaiSUGhseYwsUbJgx9ubvPlKPaBU2cpA1IqAC5ndAl7pP
         WZRb36ps4/g3+0JY5NkcsXuAPCHMJJLwHHio4GYs9/FWBZIN2KoEHOWCBkcncdM7Jn99
         ZC/PQX7UeeZiK4QrBfDL1ZbQ08uw86Tch+C6loCdI0JI54a8RM10mEGSVpsSZOqjZ39t
         IV9A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:references:cc:to:subject:from;
        bh=Mdsn1hqOiVdoh781EYC9AX9axb3hKxh37ECIIawKCbw=;
        b=C6dsScEJxa8gRfNj6q78BXS2kfLZU3Ic5njMpw1n5zFZyNkCdBNIe4ryrBpCayiWuo
         M09aYL0Dl9t2+gFzSo1Ow7Xxr2QIHg04I6yiqoEuAzP/SvgNuhnRrqhjLNn3eVlS29+9
         pzZ7MdfuA15/bzHK+2/euawp5IpYranM6cXpQ6z1jnd05E4+ux+y27wLO6wxS2KfqMw1
         Dxb66bQGWyRW/lx3ncjKOt0MT0f1GB7aFc0nlebSezIJfnMKQxNdQ3ot6y7ZJJkNl5UA
         rRmsD3h1gzn+3aZcOW4sHV0AK6nK66uvAHvq/kkPGelI9AhTno7sk8LBL0IVa16qDH4O
         Q5qA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id m7si3041115edi.175.2019.04.23.00.32.13
        for <linux-mm@kvack.org>;
        Tue, 23 Apr 2019 00:32:13 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 48ACFA78;
	Tue, 23 Apr 2019 00:32:12 -0700 (PDT)
Received: from [10.163.1.68] (unknown [10.163.1.68])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id D0ADC3F706;
	Tue, 23 Apr 2019 00:31:59 -0700 (PDT)
From: Anshuman Khandual <anshuman.khandual@arm.com>
Subject: Re: [PATCH V2 2/2] arm64/mm: Enable memory hot remove
To: Mark Rutland <mark.rutland@arm.com>
Cc: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
 linux-mm@kvack.org, akpm@linux-foundation.org, will.deacon@arm.com,
 catalin.marinas@arm.com, mhocko@suse.com, mgorman@techsingularity.net,
 james.morse@arm.com, robin.murphy@arm.com, cpandya@codeaurora.org,
 arunks@codeaurora.org, dan.j.williams@intel.com, osalvador@suse.de,
 david@redhat.com, cai@lca.pw, logang@deltatee.com, ira.weiny@intel.com
References: <1555221553-18845-1-git-send-email-anshuman.khandual@arm.com>
 <1555221553-18845-3-git-send-email-anshuman.khandual@arm.com>
 <20190415134841.GC13990@lakrids.cambridge.arm.com>
 <2faba38b-ab79-2dda-1b3c-ada5054d91fa@arm.com>
 <20190417142154.GA393@lakrids.cambridge.arm.com>
 <bba0b71c-2d04-d589-e2bf-5de37806548f@arm.com>
 <20190417173948.GB15589@lakrids.cambridge.arm.com>
 <1bdae67b-fcd6-7868-8a92-c8a306c04ec6@arm.com>
Message-ID: <97413c39-a4a9-ea1b-7093-eb18f950aad7@arm.com>
Date: Tue, 23 Apr 2019 13:01:58 +0530
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:52.0) Gecko/20100101
 Thunderbird/52.9.1
MIME-Version: 1.0
In-Reply-To: <1bdae67b-fcd6-7868-8a92-c8a306c04ec6@arm.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 04/18/2019 10:58 AM, Anshuman Khandual wrote:
> On 04/17/2019 11:09 PM, Mark Rutland wrote:
>> On Wed, Apr 17, 2019 at 10:15:35PM +0530, Anshuman Khandual wrote:
>>> On 04/17/2019 07:51 PM, Mark Rutland wrote:
>>>> On Wed, Apr 17, 2019 at 03:28:18PM +0530, Anshuman Khandual wrote:
>>>>> On 04/15/2019 07:18 PM, Mark Rutland wrote:
>>>>>> On Sun, Apr 14, 2019 at 11:29:13AM +0530, Anshuman Khandual wrote:
>>
>>>>>>> +	spin_unlock(&init_mm.page_table_lock);
>>>>>>
>>>>>> What precisely is the page_table_lock intended to protect?
>>>>>
>>>>> Concurrent modification to kernel page table (init_mm) while clearing entries.
>>>>
>>>> Concurrent modification by what code?
>>>>
>>>> If something else can *modify* the portion of the table that we're
>>>> manipulating, then I don't see how we can safely walk the table up to
>>>> this point without holding the lock, nor how we can safely add memory.
>>>>
>>>> Even if this is to protect something else which *reads* the tables,
>>>> other code in arm64 which modifies the kernel page tables doesn't take
>>>> the lock.
>>>>
>>>> Usually, if you can do a lockless walk you have to verify that things
>>>> didn't change once you've taken the lock, but we don't follow that
>>>> pattern here.
>>>>
>>>> As things stand it's not clear to me whether this is necessary or
>>>> sufficient.
>>>
>>> Hence lets take more conservative approach and wrap the entire process of
>>> remove_pagetable() under init_mm.page_table_lock which looks safe unless
>>> in the worst case when free_pages() gets stuck for some reason in which
>>> case we have bigger memory problem to deal with than a soft lock up.
>>
>> Sorry, but I'm not happy with _any_ solution until we understand where
>> and why we need to take the init_mm ptl, and have made some effort to
>> ensure that the kernel correctly does so elsewhere. It is not sufficient
>> to consider this code in isolation.
> 
> We will have to take the kernel page table lock to prevent assumption regarding
> present or future possible kernel VA space layout. Wrapping around the entire
> remove_pagetable() will be at coarse granularity but I dont see why it should
> not sufficient atleast from this particular tear down operation regardless of
> how this might affect other kernel pgtable walkers.
> 
> IIUC your concern is regarding other parts of kernel code (arm64/generic) which
> assume that kernel page table wont be changing and hence they normally walk the
> table without holding pgtable lock. Hence those current pgtabe walker will be
> affected after this change.
> 
>>
>> IIUC, before this patch we never clear non-leaf entries in the kernel
>> page tables, so readers don't presently need to take the ptl in order to
>> safely walk down to a leaf entry.
> 
> Got it. Will look into this.
> 
>>
>> For example, the arm64 ptdump code never takes the ptl, and as of this
>> patch it will blow up if it races with a hot-remove, regardless of
>> whether the hot-remove code itself holds the ptl.
> 
> Got it. Are there there more such examples where this can be problematic. I
> will be happy to investigate all such places and change/add locking scheme
> in there to make them work with memory hot remove.
> 
>>
>> Note that the same applies to the x86 ptdump code; we cannot assume that
>> just because x86 does something that it happens to be correct.
> 
> I understand. Will look into other non-x86 platforms as well on how they are
> dealing with this.
> 
>>
>> I strongly suspect there are other cases that would fall afoul of this,
>> in both arm64 and generic code.

On X86

- kernel_physical_mapping_init() takes the lock for pgtable page allocations as well
  as all leaf level entries including large mappings.

On Power

- remove_pagetable() take an overall high level init_mm.page_table_lock as I had
  suggested before. __map_kernel_page() calls [pud|pmd|pte]_alloc_[kernel] which
  allocates page table pages are protected with init_mm.page_table_lock but then
  the actual setting of the leaf entries are not (unlike x86)

	arch_add_memory()
		create_section_mapping()
			radix__create_section_mapping()
				create_physical_mapping()
					__map_kernel_page()
On arm64.

Both kernel page table dump and linear mapping (__create_pgd_mapping on init_mm)
will require init_mm.page_table_lock to be really safe against this new memory
hot remove code. I will do the necessary changes as part of this series next time
around. IIUC there is no equivalent generic feature for ARM64_PTDUMP_CORE/DEBUGFS.
	 > 
> Will start looking into all such possible cases both on arm64 and generic.
> Mean while more such pointers would be really helpful.

Generic usage for init_mm.pagetable_lock

Unless I have missed something else these are the generic init_mm kernel page table
modifiers at runtime (at least which uses init_mm.page_table_lock)

	1. ioremap_page_range()		/* Mapped I/O memory area */
	2. apply_to_page_range()	/* Change existing kernel linear map */
	3. vmap_page_range()		/* Vmalloc area */

A. IOREMAP

ioremap_page_range()
	ioremap_p4d_range()
		p4d_alloc()
		ioremap_try_huge_p4d() -> p4d_set_huge() -> set_p4d()
		ioremap_pud_range()
			pud_alloc()
			ioremap_try_huge_pud() -> pud_set_huge() -> set_pud()
			ioremap_pmd_range()
				pmd_alloc()
				ioremap_try_huge_pmd() -> pmd_set_huge() -> set_pmd()
				ioremap_pte_range()
					pte_alloc_kernel()
						set_pte_at() -> set_pte()
B. APPLY_TO_PAGE_RANGE

apply_to_page_range()
	apply_to_p4d_range()
		p4d_alloc()
		apply_to_pud_range()
			pud_alloc()
			apply_to_pmd_range()
				pmd_alloc()
				apply_to_pte_range()
					pte_alloc_kernel()

C. VMAP_PAGE_RANGE

vmap_page_range()
vmap_page_range_noflush()
	vmap_p4d_range()
		p4d_alloc()
		vmap_pud_range()
			pud_alloc()
			vmap_pmd_range()
				pmd_alloc()
				vmap_pte_range()
					pte_alloc_kernel()
					set_pte_at()

In all of the above.

- Page table pages [p4d|pud|pmd|pte]_alloc_[kernel] settings are protected with init_mm.page_table_lock
- Should not it require init_mm.page_table_lock for all leaf level (PUD|PMD|PTE) modification as well ?
- Should not this require init_mm.page_table_lock for page table walk itself ?

Not taking an overall lock for all these three operations will potentially race with an ongoing memory
hot remove operation which takes an overall lock as proposed. Wondering if this has this been safe till
now ?

