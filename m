Return-Path: <SRS0=kGB6=SG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 20A5DC10F0C
	for <linux-mm@archiver.kernel.org>; Thu,  4 Apr 2019 08:23:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D1D5620882
	for <linux-mm@archiver.kernel.org>; Thu,  4 Apr 2019 08:23:57 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D1D5620882
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3F2426B0005; Thu,  4 Apr 2019 04:23:57 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 37B3D6B0006; Thu,  4 Apr 2019 04:23:57 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 243566B0007; Thu,  4 Apr 2019 04:23:57 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id C46406B0005
	for <linux-mm@kvack.org>; Thu,  4 Apr 2019 04:23:56 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id c40so975147eda.10
        for <linux-mm@kvack.org>; Thu, 04 Apr 2019 01:23:56 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=3SBR222Ov3C/ojpq26LC2+nwJQ8MBNAmHnnygJb5diw=;
        b=IB7ggK3KNHFWVgU6rXX4QlaVGpide34uOxCeERZ88t+qYkEEEggFrDoUSdwqkQocXo
         U1ZDeXvF0ZecJ3HnsmUL76hTxe4o7yKV0j5SoiiGtMgPvgOBwfLUkDeZfHnjF5Qa/L3B
         +wrO//tgllkFUYWGxnhttaaspo5HCWzY1snOGSjdOnDX6JS+uC/iwo/XHU2MwIFq65gT
         Me/53eZt3YH91v0Ee23eCHcR5IsuCNDs6hszC9hMa1NrgnlncPBxm+HVmIJfGG0RNPo5
         zdr3YSu5zcZu9ptl9ae3Ypx38RMnmxAsqHe9OLS4vvMEoWl2pfpa7cn0i9Skc2e+6wmm
         G8QQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
X-Gm-Message-State: APjAAAVX2UM+LVATrcciAjGFCFskkdPjc8ksLxplbAVwV9UOLj7AKUYR
	jLsTjSjbVTIN6yB8f/TcuA8NCan989igsTa0fdkP/SLq54uIMsH5WyuvlcCoEaQzNsWxhbC7hRp
	6sgmISu2tBAe0hpXseB0TGmeHGgxLAZjhzawuJUJAxY3xlta9u8HndC0aBRY8CACVsg==
X-Received: by 2002:a05:6402:144d:: with SMTP id d13mr2893171edx.64.1554366236330;
        Thu, 04 Apr 2019 01:23:56 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy6voQC33v9gEOThev+rCG77CGm3WUa4npt4zyHMIG5OWZTrBVRBZVGBxpAP4M0j2P3sDY+
X-Received: by 2002:a05:6402:144d:: with SMTP id d13mr2893117edx.64.1554366235240;
        Thu, 04 Apr 2019 01:23:55 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554366235; cv=none;
        d=google.com; s=arc-20160816;
        b=xlrJ1NQ/xeXqdi3hZgy+ifXGiv2mBenpCpI9ksEyp0Ft46HNHWmGS25maUq/Cb+xvp
         Aa1DdpZykg6Ga7w53SGoS9yIfWb+6Z3ZsyQRVRm5CTqXoP0p6aNCFpRr5aiGfwM3gElj
         FcJC0KnAjakWO7CZuyeWhjJLeKFo0iPxALGYG3YKIsxmGdHf34f9lucqHMdeJG7vTvmB
         riVv0BnL+u8xIfluE7nhWRj+9YESHf/nczi1K59RXA3ARJY4jKzLCgEVeKjYudTn/Dhd
         /PHO/OlTSlMETWoYX0na/OUkVnCnrp0PgSiZbd0be7SRUQ2rswE/X3uRxMAH8NMdXeXb
         Fu0A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=3SBR222Ov3C/ojpq26LC2+nwJQ8MBNAmHnnygJb5diw=;
        b=1LsEoO3J2KjWU72n1TIWqVPQoErYjXA+dmc+kXGLEw/pY7vObH5eAXimiz5SUmZNET
         X1/0mlvvkvDV36r+ci318ZIwctejlqHPcOs8BjPQydYgr/lxX4LjTqJHR62sSH/K4Rrm
         0coUjcTh4qqb5cJQxF8x6XboFPQoTR1cxXvnCbtgdeD9rdPrgtDkBQZwGHF3hqNFRCOT
         CzWmaPHHIBGjeCjOb2oAvo4tS2Z+dUcS2zao9zi9ihH+119dUafODCd83iRu0Kx1YGjT
         40iJE9Moe5oBRw0BZblWNnN1d+QQ+YYPGPCk3IuTw/p9Qvl/k38xc7JZHu8OwBOoVSTi
         ri4g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id s26si3996225ejx.262.2019.04.04.01.23.54
        for <linux-mm@kvack.org>;
        Thu, 04 Apr 2019 01:23:55 -0700 (PDT)
Received-SPF: pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id E851C80D;
	Thu,  4 Apr 2019 01:23:53 -0700 (PDT)
Received: from [10.162.40.100] (p8cg001049571a15.blr.arm.com [10.162.40.100])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 0FD773F557;
	Thu,  4 Apr 2019 01:23:47 -0700 (PDT)
Subject: Re: [PATCH 2/6] arm64/mm: Enable memory hot remove
To: Robin Murphy <robin.murphy@arm.com>, Logan Gunthorpe
 <logang@deltatee.com>, linux-kernel@vger.kernel.org,
 linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org,
 akpm@linux-foundation.org, will.deacon@arm.com, catalin.marinas@arm.com
Cc: mark.rutland@arm.com, mhocko@suse.com, david@redhat.com, cai@lca.pw,
 pasha.tatashin@oracle.com, Stephen Bates <sbates@raithlin.com>,
 james.morse@arm.com, cpandya@codeaurora.org, arunks@codeaurora.org,
 dan.j.williams@intel.com, mgorman@techsingularity.net, osalvador@suse.de
References: <1554265806-11501-1-git-send-email-anshuman.khandual@arm.com>
 <1554265806-11501-3-git-send-email-anshuman.khandual@arm.com>
 <f2ea761c-49b2-88f6-14fa-5aaec57952cb@deltatee.com>
 <85fbfe49-d49e-fd6e-21dd-ff4d9808610b@arm.com>
From: Anshuman Khandual <anshuman.khandual@arm.com>
Message-ID: <755a1c1a-12ac-e081-c315-117de53f7a4b@arm.com>
Date: Thu, 4 Apr 2019 13:53:49 +0530
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:52.0) Gecko/20100101
 Thunderbird/52.9.1
MIME-Version: 1.0
In-Reply-To: <85fbfe49-d49e-fd6e-21dd-ff4d9808610b@arm.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 04/03/2019 11:27 PM, Robin Murphy wrote:
> On 03/04/2019 18:32, Logan Gunthorpe wrote:
>>
>>
>> On 2019-04-02 10:30 p.m., Anshuman Khandual wrote:
>>> Memory removal from an arch perspective involves tearing down two different
>>> kernel based mappings i.e vmemmap and linear while releasing related page
>>> table pages allocated for the physical memory range to be removed.
>>>
>>> Define a common kernel page table tear down helper remove_pagetable() which
>>> can be used to unmap given kernel virtual address range. In effect it can
>>> tear down both vmemap or kernel linear mappings. This new helper is called
>>> from both vmemamp_free() and ___remove_pgd_mapping() during memory removal.
>>> The argument 'direct' here identifies kernel linear mappings.
>>>
>>> Vmemmap mappings page table pages are allocated through sparse mem helper
>>> functions like vmemmap_alloc_block() which does not cycle the pages through
>>> pgtable_page_ctor() constructs. Hence while removing it skips corresponding
>>> destructor construct pgtable_page_dtor().
>>>
>>> While here update arch_add_mempory() to handle __add_pages() failures by
>>> just unmapping recently added kernel linear mapping. Now enable memory hot
>>> remove on arm64 platforms by default with ARCH_ENABLE_MEMORY_HOTREMOVE.
>>>
>>> This implementation is overall inspired from kernel page table tear down
>>> procedure on X86 architecture.
>>
>> I've been working on very similar things for RISC-V. In fact, I'm
>> currently in progress on a very similar stripped down version of
>> remove_pagetable(). (Though I'm fairly certain I've done a bunch of
>> stuff wrong.)
>>
>> Would it be possible to move this work into common code that can be used
>> by all arches? Seems like, to start, we should be able to support both
>> arm64 and RISC-V... and maybe even x86 too.
>>
>> I'd be happy to help integrate and test such functions in RISC-V.

I am more inclined towards consolidating remove_pagetable() across platforms
like arm64 and RISC-V (probably others). But there are clear distinctions
between user page table and kernel page table tear down process.

> 
> Indeed, I had hoped we might be able to piggyback off generic code for this anyway,
> given that we have generic pagetable code which knows how to free process pagetables,
> and kernel pagetables are also pagetables.

But there are differences. To list some

* Freeing mapped and pagetable pages

	- Memory hot remove deals with both vmemmap and linear mappings
	- Selectively call pgtable_page_dtor() for linear mappings (arch specific)
	- Not actually freeing PTE|PMD|PUD mapped pages for linear mappings
	- Freeing mapped pages for vmemap mappings

* TLB shootdown

	- User page table process uses mmu_gather mechanism for TLB flush
	- Kernel page table tear down can do with less TLB flush invocations
		- Dont have to care about flush deferral etc

* THP and HugeTLB

	- Kernel page table tear down procedure does not have to understand THP or HugeTLB
	- Though it has to understand possible arch specific special block mappings

		- Specific kernel linear mappings on arm64
			- PUD|PMD|CONT_PMD|CONT_PTE large page mappings

		- Specific vmemmap mappings on arm64
			- PMD large or PTE mappings

	-User page table tear down procedure needs to understand THP and HugeTLB

* Page table locking

	- Kernel procedure locks init_mm.page_table_lock while clearing an individual entry
	- Kernel procedure does not have to worry about mmap_sem

* ZONE_DEVICE struct vmem_altmap

	- Kernel page table tear down procedure needs to accommodate 'struct vmem_altmap' when
	vmemmap mappings are created with pages allocated from 'struct vmem_altmap' (ZONE_DEVICE)
	rather than buddy allocator or memblock.

