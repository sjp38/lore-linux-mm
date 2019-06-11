Return-Path: <SRS0=/KmR=UK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 62B09C31E44
	for <linux-mm@archiver.kernel.org>; Tue, 11 Jun 2019 21:20:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 194862086A
	for <linux-mm@archiver.kernel.org>; Tue, 11 Jun 2019 21:20:27 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=vmwopensource.org header.i=@vmwopensource.org header.b="GUhgBcpd"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 194862086A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=vmwopensource.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9982D6B000A; Tue, 11 Jun 2019 17:20:27 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 96E176B000C; Tue, 11 Jun 2019 17:20:27 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 85D446B000D; Tue, 11 Jun 2019 17:20:27 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lf1-f69.google.com (mail-lf1-f69.google.com [209.85.167.69])
	by kanga.kvack.org (Postfix) with ESMTP id 197406B000A
	for <linux-mm@kvack.org>; Tue, 11 Jun 2019 17:20:27 -0400 (EDT)
Received: by mail-lf1-f69.google.com with SMTP id a25so2209648lfl.0
        for <linux-mm@kvack.org>; Tue, 11 Jun 2019 14:20:27 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :organization:message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=fpPWXyzcTqDyQOGOwdmrCTI2tAI/vDnOgq3Rj+lOFLU=;
        b=Lf/361/QmZD7k/4bzWiYTf75f/BLwhmikAP0zXDKgpDdARpJz1xVsO1HSfuDOfCfpe
         3IZXuseGyF2FIUIeqyyor1qe1LnbV5a7G/yGfxMYwVetUQkk37Gv3ktCwjmYd2m7WYQd
         ePNktoxqDs91LCudK4DnLTfO1TNJjw2TYwCbbY8S31ju6O10DwNm2ZSYxF46N+3iW9tr
         8jKgHHWE+NmS8PTnOX2CsmfUoBLbzVh9ntuCsp1RA5puDJ8NEHvqYGebcacrJH1XVvkS
         IhCOJqswyh2Fg6+09sObo9PP38U3AjsTh7bwPioNha2zLaki1ll3xkNR/yBKeJ7ojc0A
         SXYA==
X-Gm-Message-State: APjAAAUcHadTPTudWwTqGdTwKPL+vNRfvUJHB/SZHOvadAmVjWKEoH+j
	FlgJLzXaXnl78OOEg6a4iSgwtOgK/eHNcxbsW7Uq+cVqXrBGh9Xb2iZ4vG0A/I6IMso82yPAW6c
	ZEoMdgNI1Yrqddd8v37xO6TSx3k1Bgg5sgE9Il9sgpS6BC+raS1/LAcXNeSHSVwQQvQ==
X-Received: by 2002:a19:ed07:: with SMTP id y7mr41094392lfy.56.1560288026293;
        Tue, 11 Jun 2019 14:20:26 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw1SGpxY1FCDrdvseu4SjqhoaTZYeIFDBfHACD4EnfhuK3BGHR1TcNKM8fDxVzKPFyGrf9c
X-Received: by 2002:a19:ed07:: with SMTP id y7mr41094347lfy.56.1560288025026;
        Tue, 11 Jun 2019 14:20:25 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560288025; cv=none;
        d=google.com; s=arc-20160816;
        b=TRewFRIs5FZabAFdepHg6r4j+S9pRFdZLwTOxqykuHImsi9pbPjNOLA6BTKWTFXoXj
         iV5sY0WREy2WCkw/HEJpBPXCdkvINe8o/PWSwQX6Js5QcGGhe5e5xEMkjdyuYXRyaOQO
         UanMs7zCnYrmDHhneOBEe9Jn8k3MFP4rI0RzejtDfGG3HxNHlMjZglpR3nFEX/fm/eQD
         WowwmKwCBTmaFdoQJHdvgHrQ0KcDoCKqXhlSONvAHmivbXuHgbw4b8Jev/dyGHPPvTTt
         9b+LzmsJCQ7VZYpoz6XxUTHuk1P1JLl+QcoQS2KN6s5m+nw3TL4XHj8jsVsJW/VKOciT
         lQOQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:organization:from:references:cc:to
         :subject:dkim-signature;
        bh=fpPWXyzcTqDyQOGOwdmrCTI2tAI/vDnOgq3Rj+lOFLU=;
        b=iXfcZz3VbfxkIXCda1SKrNRZ85fjbcOg7IAVhjI1xtVQC+4VwnIQEwNOcIclsrwvbA
         vAc6T/XuMSH4PRh0ZwTQtsbzoD1qnSpENPYlyQtU+C/tYD3xv0Lco44EvpEGwnjk+tHT
         UL4q1MfBQSTbXNoeaxgsbO1N62zbj6ygrIO1+BpgSflgFU2QUr4KaNimosUy47tC3WIJ
         prlEhCKrL6jvEk8g/aI8vqFFykKGnDDRsusgGVoiNgTnSQOvIpLqctBHkIZiE6Cs0rO/
         KL5XLUkCZt4CdWXXrtfJiGnSuBxpury6OqooSL8mk/5rLNTDHXmBiegCcWBw1GRhEQGk
         a38Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@vmwopensource.org header.s=mail header.b=GUhgBcpd;
       spf=pass (google.com: domain of thellstrom@vmwopensource.org designates 79.136.2.42 as permitted sender) smtp.mailfrom=thellstrom@vmwopensource.org
Received: from pio-pvt-msa3.bahnhof.se (pio-pvt-msa3.bahnhof.se. [79.136.2.42])
        by mx.google.com with ESMTPS id p74si11031764ljp.155.2019.06.11.14.20.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 11 Jun 2019 14:20:24 -0700 (PDT)
Received-SPF: pass (google.com: domain of thellstrom@vmwopensource.org designates 79.136.2.42 as permitted sender) client-ip=79.136.2.42;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@vmwopensource.org header.s=mail header.b=GUhgBcpd;
       spf=pass (google.com: domain of thellstrom@vmwopensource.org designates 79.136.2.42 as permitted sender) smtp.mailfrom=thellstrom@vmwopensource.org
Received: from localhost (localhost [127.0.0.1])
	by pio-pvt-msa3.bahnhof.se (Postfix) with ESMTP id 482C13F5A0;
	Tue, 11 Jun 2019 23:20:17 +0200 (CEST)
Authentication-Results: pio-pvt-msa3.bahnhof.se;
	dkim=pass (1024-bit key; unprotected) header.d=vmwopensource.org header.i=@vmwopensource.org header.b=GUhgBcpd;
	dkim-atps=neutral
X-Virus-Scanned: Debian amavisd-new at bahnhof.se
Received: from pio-pvt-msa3.bahnhof.se ([127.0.0.1])
	by localhost (pio-pvt-msa3.bahnhof.se [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id KGMqz9ZSUwae; Tue, 11 Jun 2019 23:20:07 +0200 (CEST)
Received: from mail1.shipmail.org (h-205-35.A357.priv.bahnhof.se [155.4.205.35])
	(Authenticated sender: mb878879)
	by pio-pvt-msa3.bahnhof.se (Postfix) with ESMTPA id 924623F534;
	Tue, 11 Jun 2019 23:20:05 +0200 (CEST)
Received: from localhost.localdomain (h-205-35.A357.priv.bahnhof.se [155.4.205.35])
	by mail1.shipmail.org (Postfix) with ESMTPSA id 1B349361A96;
	Tue, 11 Jun 2019 23:20:05 +0200 (CEST)
DKIM-Signature: v=1; a=rsa-sha256; c=simple/simple; d=vmwopensource.org;
	s=mail; t=1560288005;
	bh=V2aF3yRF7Uz8lqdX5QeHaQ5nkyndWzo6SqgyvKNG+to=;
	h=Subject:To:Cc:References:From:Date:In-Reply-To:From;
	b=GUhgBcpdyqxFQkx+JvWZ7LQeyQwlIAnuV5Z8+ZvBMTsKOHb+mF3Rdw1w82AzuEVsQ
	 XFWJ7EIeJMIS21RGmfijZao9K8tnZx7R15qWQsueBLeOBwcoalhItNc0BgVQ1Sbtxr
	 1ViNT6kAbRX0XK5JKaBcVr5K/OCv4jBkUFNhBZsA=
Subject: Re: [PATCH v4 3/9] mm: Add write-protect and clean utilities for
 address space ranges
To: Nadav Amit <nadav.amit@gmail.com>
Cc: dri-devel@lists.freedesktop.org, linux-graphics-maintainer@vmware.com,
 "VMware, Inc." <pv-drivers@vmware.com>, LKML <linux-kernel@vger.kernel.org>,
 Thomas Hellstrom <thellstrom@vmware.com>,
 Andrew Morton <akpm@linux-foundation.org>,
 Matthew Wilcox <willy@infradead.org>, Will Deacon <will.deacon@arm.com>,
 Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@surriel.com>,
 Minchan Kim <minchan@kernel.org>, Michal Hocko <mhocko@suse.com>,
 Huang Ying <ying.huang@intel.com>, Souptick Joarder <jrdr.linux@gmail.com>,
 =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>,
 Linux-MM <linux-mm@kvack.org>, Ralph Campbell <rcampbell@nvidia.com>,
 Dave Hansen <dave.hansen@intel.com>
References: <20190611122454.3075-1-thellstrom@vmwopensource.org>
 <20190611122454.3075-4-thellstrom@vmwopensource.org>
 <1CDAE797-4686-4041-938F-DE0456FFF451@gmail.com>
 <ac0b0ef5-8f76-5e55-2be2-f1860878841a@vmwopensource.org>
 <39CC6294-52B5-4ED7-852E-A644132DEA18@gmail.com>
From: =?UTF-8?Q?Thomas_Hellstr=c3=b6m_=28VMware=29?=
 <thellstrom@vmwopensource.org>
Organization: VMware Inc.
Message-ID: <f1a936c3-999a-f57e-6017-3315475967ad@vmwopensource.org>
Date: Tue, 11 Jun 2019 23:20:04 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <39CC6294-52B5-4ED7-852E-A644132DEA18@gmail.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Content-Language: en-US
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 6/11/19 9:10 PM, Nadav Amit wrote:
>> On Jun 11, 2019, at 11:26 AM, Thomas Hellström (VMware) <thellstrom@vmwopensource.org> wrote:
>>
>> Hi, Nadav,
>>
>> On 6/11/19 7:21 PM, Nadav Amit wrote:
>>>> On Jun 11, 2019, at 5:24 AM, Thomas Hellström (VMware) <thellstrom@vmwopensource.org> wrote:
>>>>
>>>> From: Thomas Hellstrom <thellstrom@vmware.com>
>>> [ snip ]
>>>
>>>> +/**
>>>> + * apply_pt_wrprotect - Leaf pte callback to write-protect a pte
>>>> + * @pte: Pointer to the pte
>>>> + * @token: Page table token, see apply_to_pfn_range()
>>>> + * @addr: The virtual page address
>>>> + * @closure: Pointer to a struct pfn_range_apply embedded in a
>>>> + * struct apply_as
>>>> + *
>>>> + * The function write-protects a pte and records the range in
>>>> + * virtual address space of touched ptes for efficient range TLB flushes.
>>>> + *
>>>> + * Return: Always zero.
>>>> + */
>>>> +static int apply_pt_wrprotect(pte_t *pte, pgtable_t token,
>>>> +			      unsigned long addr,
>>>> +			      struct pfn_range_apply *closure)
>>>> +{
>>>> +	struct apply_as *aas = container_of(closure, typeof(*aas), base);
>>>> +	pte_t ptent = *pte;
>>>> +
>>>> +	if (pte_write(ptent)) {
>>>> +		pte_t old_pte = ptep_modify_prot_start(aas->vma, addr, pte);
>>>> +
>>>> +		ptent = pte_wrprotect(old_pte);
>>>> +		ptep_modify_prot_commit(aas->vma, addr, pte, old_pte, ptent);
>>>> +		aas->total++;
>>>> +		aas->start = min(aas->start, addr);
>>>> +		aas->end = max(aas->end, addr + PAGE_SIZE);
>>>> +	}
>>>> +
>>>> +	return 0;
>>>> +}
>>>> +
>>>> +/**
>>>> + * struct apply_as_clean - Closure structure for apply_as_clean
>>>> + * @base: struct apply_as we derive from
>>>> + * @bitmap_pgoff: Address_space Page offset of the first bit in @bitmap
>>>> + * @bitmap: Bitmap with one bit for each page offset in the address_space range
>>>> + * covered.
>>>> + * @start: Address_space page offset of first modified pte relative
>>>> + * to @bitmap_pgoff
>>>> + * @end: Address_space page offset of last modified pte relative
>>>> + * to @bitmap_pgoff
>>>> + */
>>>> +struct apply_as_clean {
>>>> +	struct apply_as base;
>>>> +	pgoff_t bitmap_pgoff;
>>>> +	unsigned long *bitmap;
>>>> +	pgoff_t start;
>>>> +	pgoff_t end;
>>>> +};
>>>> +
>>>> +/**
>>>> + * apply_pt_clean - Leaf pte callback to clean a pte
>>>> + * @pte: Pointer to the pte
>>>> + * @token: Page table token, see apply_to_pfn_range()
>>>> + * @addr: The virtual page address
>>>> + * @closure: Pointer to a struct pfn_range_apply embedded in a
>>>> + * struct apply_as_clean
>>>> + *
>>>> + * The function cleans a pte and records the range in
>>>> + * virtual address space of touched ptes for efficient TLB flushes.
>>>> + * It also records dirty ptes in a bitmap representing page offsets
>>>> + * in the address_space, as well as the first and last of the bits
>>>> + * touched.
>>>> + *
>>>> + * Return: Always zero.
>>>> + */
>>>> +static int apply_pt_clean(pte_t *pte, pgtable_t token,
>>>> +			  unsigned long addr,
>>>> +			  struct pfn_range_apply *closure)
>>>> +{
>>>> +	struct apply_as *aas = container_of(closure, typeof(*aas), base);
>>>> +	struct apply_as_clean *clean = container_of(aas, typeof(*clean), base);
>>>> +	pte_t ptent = *pte;
>>>> +
>>>> +	if (pte_dirty(ptent)) {
>>>> +		pgoff_t pgoff = ((addr - aas->vma->vm_start) >> PAGE_SHIFT) +
>>>> +			aas->vma->vm_pgoff - clean->bitmap_pgoff;
>>>> +		pte_t old_pte = ptep_modify_prot_start(aas->vma, addr, pte);
>>>> +
>>>> +		ptent = pte_mkclean(old_pte);
>>>> +		ptep_modify_prot_commit(aas->vma, addr, pte, old_pte, ptent);
>>>> +
>>>> +		aas->total++;
>>>> +		aas->start = min(aas->start, addr);
>>>> +		aas->end = max(aas->end, addr + PAGE_SIZE);
>>>> +
>>>> +		__set_bit(pgoff, clean->bitmap);
>>>> +		clean->start = min(clean->start, pgoff);
>>>> +		clean->end = max(clean->end, pgoff + 1);
>>>> +	}
>>>> +
>>>> +	return 0;
>>> Usually, when a PTE is write-protected, or when a dirty-bit is cleared, the
>>> TLB flush must be done while the page-table lock for that specific table is
>>> taken (i.e., within apply_pt_clean() and apply_pt_wrprotect() in this case).
>>>
>>> Otherwise, in the case of apply_pt_clean() for example, another core might
>>> shortly after (before the TLB flush) write to the same page whose PTE was
>>> changed. The dirty-bit in such case might not be set, and the change get
>>> lost.
>> Hmm. Let's assume that was the case, we have two possible situations:
>>
>> A: pt_clean
>>
>> 1. That core's TLB entry is invalid. It will set the PTE dirty bit and continue. The dirty bit will probably remain set after the TLB flush.
> I guess you mean the PTE is not cached in the TLB.
Yes.
>
>> 2. That core's TLB entry is valid. It will just continue. The dirty bit will remain clear after the TLB flush.
>>
>> But I fail to see how having the TLB flush within the page table lock would help in this case. Since the writing core will never attempt to take it? In any case, if such a race occurs, the corresponding bit in the bitmap would have been set and we've recorded that the page is dirty.
> I don’t understand. What do you mean “recorded that the page is dirty”?
> IIUC, the PTE is clear in this case - you mean PG_dirty is set?

All PTEs we touch and clean are noted in the bitmap.

>
> To clarify, this code actually may work correctly on Intel CPUs, based on a
> recent discussion with Dave Hansen. Apparently, most Intel CPUs set the
> dirty bit in memory atomically when a page is first written.
>
> But this is a generic code and not arch-specific. My concern is that a
> certain page might be written to, but would not be marked as dirty in either
> the bitmap or the PTE.

Regardless of arch, we have four cases:
1. Writes occuring before we scan (and possibly modify) the PTE. Should 
be handled correctly.
2. Writes occurning after the TLB flush. Should be handled correctly, 
unless after a TLB flush the TLB cached entry and the PTE differs on the 
dirty bit. Then we could in theory go on writing without marking the PTE 
dirty. But that would probably be an arch code bug: I mean anything 
using tlb_gather_mmu() would flush TLB outside of the page table lock, 
and if, for example, unmap_mapping_range() left the TLB entries and the 
PTES in an inconsistent state, that wouldn't be good.
3. Writes occuring after the PTE scan, but before the TLB flush without 
us modifying the PTE: That would be the same as a spurious TLB flush. It 
should be harmless. The write will not be picked up in the bitmap, but 
the PTE dirty bit will be set.
4. Writes occuring after us clearing the dirty bit and before the TLB 
flush: We will detect the write, since the bitmap bit is already set. If 
the write continues after the TLB flush, we go to 2.

Note, for archs doing software PTE_DIRTY, that would be very similar to 
softdirty, which is also doing batched TLB flushes...

>
> The practice of flushing cleaned/write-protected PTEs while hold the
> page-table lock related (sorry for my confusion).
>
>> B: wrprotect situation, the situation is a bit different:
>>
>> 1. That core's TLB entry is invalid. It will read the PTE, cause a fault and block in mkwrite() on an external address space lock which is held over this operation. (Is it this situation that is your main concern?)
>> 2. That core's TLB entry is valid. It will just continue regardless of any locks.
>>
>> For both mkwrite() and dirty() if we act on the recorded pages *after* the TLB flush, we're OK. The difference is that just after the TLB flush there should be no write-enabled PTEs in the write-protect case, but there may be dirty PTEs in the pt_clean case. Something that is mentioned in the docs already.
> The wrprotect might work correctly, I guess. It does work to mprotect()
> (again, sorry for confusing).
>
>>> Does this function regards a certain use-case in which deferring the TLB
>>> flushes is fine? If so, assertions and documentation of the related
>>> assumption would be useful.
>> If I understand your comment correctly, the page table lock is sometimes used as the lock in B1, blocking a possible software fault until the TLB flush has happened.  Here we assume an external address space lock taken both around the wrprotect operation and in mkwrite(). Would it be OK if I add comments about the necessity of an external lock to the doc? Ok with a follow-up patch?
> I think the patch should explain itself. I think the comment:
>
>> + * WARNING: This function should only be used for address spaces that
>> + * completely own the pages / memory the page table points to. Typically a
>> + * device file.
> ... should be more concrete (define address spaces that completely own
> memory), and possibly backed by an (debug) assertion to ensure that it is
> only used correctly.

Agreed. To clarify we should only run this on VM_IO vmas without 
(trans)huge pages, for which there are already checks. I'll update the doc.

/Thomas



