Return-Path: <SRS0=Z+ZU=Q2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2F25AC4360F
	for <linux-mm@archiver.kernel.org>; Tue, 19 Feb 2019 04:10:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C8074217D7
	for <linux-mm@archiver.kernel.org>; Tue, 19 Feb 2019 04:10:06 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C8074217D7
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3DDFA8E0003; Mon, 18 Feb 2019 23:10:06 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 38D328E0002; Mon, 18 Feb 2019 23:10:06 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 255118E0003; Mon, 18 Feb 2019 23:10:06 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id BC4558E0002
	for <linux-mm@kvack.org>; Mon, 18 Feb 2019 23:10:05 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id f2so3017575edm.18
        for <linux-mm@kvack.org>; Mon, 18 Feb 2019 20:10:05 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=gTy9Mri9rrGHj3cxK1Z2aZifsCldPVJoy5cjVpIz4jY=;
        b=Stau8mssBC20McKijoAKf+2vWE+SCD3w2MByMLN0DkeE2mODrcHXb/oMrZfOvkgrP4
         PaRIM1F861GquLyYsYRLqd60dKH1avBfxx/BasfoJXVihlT6dVlVVV9f+5llXSEP/iEF
         i8Ym67E2TbrAAiaeGhdG5/LcFLgWKdcoZlS5Oqqt55DfMwWBll/lVm/WkScmGJwBayEO
         QVtnowrvB60B+uUvCP7SDtQauh0E5m7321EMNlMHhskzMtAb/WuXAyc5N5VzJvBmu5AN
         7btccBKG/86fAJEj21Gd4NwaddLTG7zqjLVk48/adyRsDbsgzWsybFcqEzigPC/fqS5M
         ndfg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
X-Gm-Message-State: AHQUAuZwfsZcSW4EZR91JK9wpP73tWvsEwM0Fa9xYrDPfdeM/CMU7k2+
	TIT/oKCTGIU4MMAzYsnHcvDyzR+rqaV5LCyFtaGhy9+OrxsTThVpyy2K+jhTS2bHClHn4NheOlG
	3ixCmrE38zAsWWbeM/lHOAigqOrBC8bNGuUlncv+00wCvAbzYmlkqJq81+2PogdrVMQ==
X-Received: by 2002:a50:9927:: with SMTP id k36mr21673714edb.31.1550549405307;
        Mon, 18 Feb 2019 20:10:05 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYO/7vISD9gYcc5313LBZa2DG1OYvSgWSqhqtqdfaf4GwZQu6AK/fyu8C7EeSt3HmAytxBk
X-Received: by 2002:a50:9927:: with SMTP id k36mr21673664edb.31.1550549404285;
        Mon, 18 Feb 2019 20:10:04 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550549404; cv=none;
        d=google.com; s=arc-20160816;
        b=0YYhFXqxS+b5ZjEi50za4YSedSyayny4Dzc1IiZRbfR7AFn7ia1LjWY7V2MqQNT/VX
         XNt/3KRec7I527lRQQyOyMqC6PBUPa/9FGp3troUoFD1AKk816Wo/ihYYJ9gWgwR0p1N
         P5xUWSKkhhzOHssBarXSchHW2aLihBRBvTc7+pD4hV3sewNslm5h2xkyMOnqJxxbPiac
         lj20OoBTrWOj7aEn9CBUN3c5qtvz+6yo+wOxTbfH1Bpo4BESCu0YmkMG633cW9zImahV
         7/xv45OvBkjcRelcVnJxv14rMGNRZKiKqmPZgUc2e9feDbTxOir3JXHV3hSpOk48XxAR
         9X2w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=gTy9Mri9rrGHj3cxK1Z2aZifsCldPVJoy5cjVpIz4jY=;
        b=zNz+U4zHTsKRKVtpcEJiVGzzlGhQbpUGiLzyEXmWgJcjJsXqG3aLrgky/gvAAv9mE7
         9vAaZec95GZ2phah4JtnKv2VZko7D1bsNF+3ddF9Ej2eszBgpEM7hXLdM2IjaQoAbZVn
         y5I44RSzUVNEiv4Aowt3k+svzL4scfrAMShaA8nlcxTDwl2Isyl5dMo834jkPwfsTK24
         sQW4zvznIPto3/ZQ3aGpcZjEZWEmc4jVs2Cf9BJqM0/hlVQrPxnmttgZ/bYBSPDkauPC
         gWS4DyROOwqZIrDJrEqPrhxNyyioyHubD5pdDFvSmQXW4f+Taey0elPCxMjW8irFW4TY
         fAmA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id s36si2408896eda.294.2019.02.18.20.10.03
        for <linux-mm@kvack.org>;
        Mon, 18 Feb 2019 20:10:04 -0800 (PST)
Received-SPF: pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 0E469EBD;
	Mon, 18 Feb 2019 20:10:01 -0800 (PST)
Received: from [10.162.40.139] (p8cg001049571a15.blr.arm.com [10.162.40.139])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 5C51B3F675;
	Mon, 18 Feb 2019 20:09:56 -0800 (PST)
Subject: Re: [PATCH] arm64: mm: enable per pmd page table lock
To: Yu Zhao <yuzhao@google.com>, Will Deacon <will.deacon@arm.com>
Cc: Catalin Marinas <catalin.marinas@arm.com>,
 "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>,
 Andrew Morton <akpm@linux-foundation.org>, Nick Piggin <npiggin@gmail.com>,
 Peter Zijlstra <peterz@infradead.org>,
 Joel Fernandes <joel@joelfernandes.org>,
 "Kirill A . Shutemov" <kirill@shutemov.name>,
 linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
 linux-arch@vger.kernel.org, linux-mm@kvack.org, mark.rutland@arm.com
References: <20190214211642.2200-1-yuzhao@google.com>
 <20190218151223.GB16091@fuggles.cambridge.arm.com>
 <20190218194938.GA184109@google.com>
From: Anshuman Khandual <anshuman.khandual@arm.com>
Message-ID: <885bcfa8-1085-d454-540d-4511f5f3886e@arm.com>
Date: Tue, 19 Feb 2019 09:39:59 +0530
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:52.0) Gecko/20100101
 Thunderbird/52.9.1
MIME-Version: 1.0
In-Reply-To: <20190218194938.GA184109@google.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 02/19/2019 01:19 AM, Yu Zhao wrote:
> On Mon, Feb 18, 2019 at 03:12:23PM +0000, Will Deacon wrote:
>> [+Mark]
>>
>> On Thu, Feb 14, 2019 at 02:16:42PM -0700, Yu Zhao wrote:
>>> Switch from per mm_struct to per pmd page table lock by enabling
>>> ARCH_ENABLE_SPLIT_PMD_PTLOCK. This provides better granularity for
>>> large system.
>>>
>>> I'm not sure if there is contention on mm->page_table_lock. Given
>>> the option comes at no cost (apart from initializing more spin
>>> locks), why not enable it now.
>>>
>>> Signed-off-by: Yu Zhao <yuzhao@google.com>
>>> ---
>>>  arch/arm64/Kconfig               |  3 +++
>>>  arch/arm64/include/asm/pgalloc.h | 12 +++++++++++-
>>>  arch/arm64/include/asm/tlb.h     |  5 ++++-
>>>  3 files changed, 18 insertions(+), 2 deletions(-)
>>>
>>> diff --git a/arch/arm64/Kconfig b/arch/arm64/Kconfig
>>> index a4168d366127..104325a1ffc3 100644
>>> --- a/arch/arm64/Kconfig
>>> +++ b/arch/arm64/Kconfig
>>> @@ -872,6 +872,9 @@ config ARCH_WANT_HUGE_PMD_SHARE
>>>  config ARCH_HAS_CACHE_LINE_SIZE
>>>  	def_bool y
>>>  
>>> +config ARCH_ENABLE_SPLIT_PMD_PTLOCK
>>> +	def_bool y
>>> +
>>>  config SECCOMP
>>>  	bool "Enable seccomp to safely compute untrusted bytecode"
>>>  	---help---
>>> diff --git a/arch/arm64/include/asm/pgalloc.h b/arch/arm64/include/asm/pgalloc.h
>>> index 52fa47c73bf0..dabba4b2c61f 100644
>>> --- a/arch/arm64/include/asm/pgalloc.h
>>> +++ b/arch/arm64/include/asm/pgalloc.h
>>> @@ -33,12 +33,22 @@
>>>  
>>>  static inline pmd_t *pmd_alloc_one(struct mm_struct *mm, unsigned long addr)
>>>  {
>>> -	return (pmd_t *)__get_free_page(PGALLOC_GFP);
>>> +	struct page *page;
>>> +
>>> +	page = alloc_page(PGALLOC_GFP);
>>> +	if (!page)
>>> +		return NULL;
>>> +	if (!pgtable_pmd_page_ctor(page)) {
>>> +		__free_page(page);
>>> +		return NULL;
>>> +	}
>>> +	return page_address(page);
>>
>> I'm a bit worried as to how this interacts with the page-table code in
>> arch/arm64/mm/mmu.c when pgd_pgtable_alloc is used as the allocator. It
>> looks like that currently always calls pgtable_page_ctor(), regardless of
>> level. Do we now need a separate allocator function for the PMD level?> 
> Thanks for reminding me, I never noticed this. The short answer is
> no.
> 
> I guess pgtable_page_ctor() is used on all pud/pmd/pte entries
> there because it's also compatible with pud, and pmd too without
> this patch. So your concern is valid. Thanks again.

pgtable_page_ctor() acts on a given page used as page table at any level
which sets appropriate page type (page flag PG_table) and increments the
zone stat for NR_PAGETABLE. pgtable_page_dtor() exactly does the inverse.

These two complimentary operations are required for every level page table
pages for their proper initialization, identification in buddy and zone
statistics. Hence these need to be called for all level page table pages.

pgtable_pmd_page_ctor()/pgtable_pmd_page_dtor() on the other hand just
init/free page table lock on the page for !THP cases and additionally
init page->pmd_huge_pte (deposited page table page) for THP cases.
Some archs seem to be calling pgtable_pmd_page_ctor() in place of
pgtable_page_ctor(). Wondering would not that approach skip page flag
and accounting requirements.

> 
> Why my answer is no? Because I don't think the ctor matters for
> pgd_pgtable_alloc(). The ctor is only required for userspace page
> tables, and that's why we don't have it in pte_alloc_one_kernel().

At present on arm64 certain kernel page table page allocations call
pgtable_pmd_page_ctor() and some dont. The series which I had posted
make sure that all kernel and user page table page allocations go through
pgtable_page_ctor()/dtor(). These constructs are required for kernel
page table pages as well for accurate init and accounting not just for
user space. The series just skips vmemmap struct page mapping from this
as that would require generic sparse vmemmap allocation/free functions
which I believe should also be changed going forward as well.

> AFAICT, none of the pgds (efi_mm.pgd, tramp_pg_dir and init_mm.pgd)
> pre-populated by pgd_pgtable_alloc() is. (I doubt we pre-populate
> userspace page tables in any other arch).
> 
> So to avoid future confusion, we might just remove the ctor from
> pgd_pgtable_alloc().

No. Instead we should just make sure the that those pages go through
dtor() destructor path when getting freed and the clean up series
does that.

