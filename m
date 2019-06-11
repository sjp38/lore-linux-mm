Return-Path: <SRS0=/KmR=UK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 500BCC31E46
	for <linux-mm@archiver.kernel.org>; Tue, 11 Jun 2019 21:59:51 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 06F4A20866
	for <linux-mm@archiver.kernel.org>; Tue, 11 Jun 2019 21:59:50 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="LQ6S9B5W"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 06F4A20866
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 902D36B0006; Tue, 11 Jun 2019 17:59:50 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8B4B66B000C; Tue, 11 Jun 2019 17:59:50 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 77BC16B000D; Tue, 11 Jun 2019 17:59:50 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 40A2F6B0006
	for <linux-mm@kvack.org>; Tue, 11 Jun 2019 17:59:50 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id f10so4927882plr.17
        for <linux-mm@kvack.org>; Tue, 11 Jun 2019 14:59:50 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:subject:from
         :in-reply-to:date:cc:content-transfer-encoding:message-id:references
         :to;
        bh=VmhJMV0Np4v0eA65Qt+YfIQRgnxKyiiKiYRlh0slvOA=;
        b=sApoOJz3B/FeUu55wgZHi81tID9BNoZbcI2DivobnSGp96yB5Cqa0Z2HnGg80GEjqT
         vVS/TfGDi76GaJYE+zkVVy56xPwOqe3ZxXRlEcc7FQBZJvQXVLt4hcUQH7k89OhSqlry
         q8brWjNjWg9d3C1MNoaUfJasj8PZ7F3PtUTjCUjEURKysTuFas4lNiwjmZpEMYRP0F9u
         IYB0WNHaCWF5DwKNWgsGU+6cepcKF5OSmjY3yFPfUa+5sB3nmKAfSQvLjF/fxTznaI7M
         ZJxoRqc1s146WJ0AnN6XUPVvsHh/g5R4bf1MUs0amWfQYaJ49IGVSq2+hxKFIeHhs9R0
         0cJg==
X-Gm-Message-State: APjAAAUx1TQfxIpt9jRjwitkK3WwPvBpT1WHFIUBcVsi1+AesIOJmjpK
	xGuoOYa3nzVAiiuUfji4vvprL1LXVC9qmpjuWzLBZxU9fWyLPs/5dKqWA6SiSe72ZuRR8iihtv7
	KfYjGvW3CwSZx6GL3+g8H2j5zKFmzd1BmocULmQTd4/b/MjCGgAUQcDCL/yigwPfKZg==
X-Received: by 2002:a17:90a:db52:: with SMTP id u18mr13209784pjx.107.1560290389765;
        Tue, 11 Jun 2019 14:59:49 -0700 (PDT)
X-Received: by 2002:a17:90a:db52:: with SMTP id u18mr13209728pjx.107.1560290388726;
        Tue, 11 Jun 2019 14:59:48 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560290388; cv=none;
        d=google.com; s=arc-20160816;
        b=F4dNgpMvrFqNLOdHlHfnHVGoV2GqwvbQY209lMcZgE1JQG70iD5+54vSQ1iA61BGgN
         TBxpoMfNjrbzAeSthDNGYoSB27sZfBWvtWqNvwawXtYgHJbEOK9DadTCwWJLNE+PxO1X
         77xy/jfYMHdNyIvnjE7APVlJE32L+ngX3L3AsxCIjmiKU7k/mcc5QN+/Zuzk1+Sn75Lu
         3kEUz+3gBHMg3su3A3sps4S1Nk+IYBcpij4jOFwgUY6yXXhPQVobn4UTviSZ1FTJdL0i
         0X5XQ+c1A9VeDLwMqKIHObW9TIaVVK4IFjqIEr0STT/KE/jfki6mcgNclmamx0q14Ovx
         MDgQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=to:references:message-id:content-transfer-encoding:cc:date
         :in-reply-to:from:subject:mime-version:dkim-signature;
        bh=VmhJMV0Np4v0eA65Qt+YfIQRgnxKyiiKiYRlh0slvOA=;
        b=H6nALJFMRq0e6X1fcnWMn+s4R2M/FjXH9+5UxTnZ5mYL8jeiu/qRzxOMk52gK9zghD
         /yr/04P4uUTEOhP3brFg5VFe44HGFRvoIF/LsHLDnje9jJUnPe0gXYTD+hUqtxUNUx/R
         qlpyh4DiISx5id++IfLNdhX0SCKX79C1ujMEg1NeIJpcQhtrkZG0uLKsYzD/ZEG3GzSt
         5OFGewBG8eGIq0W7xvu6Vy/4fldSJJT2wW1eu7Vpdvg13gV5fQA/FUxr2khfjYy1aKew
         LRKX/3bFHllqGwDXEIHXg4FNgqO+ugxJOs+0fJJM9VNOhgt9AozmAa3LwYUgj3sU+hjH
         f3Gw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=LQ6S9B5W;
       spf=pass (google.com: domain of nadav.amit@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=nadav.amit@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id u6sor4432386pjn.27.2019.06.11.14.59.48
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 11 Jun 2019 14:59:48 -0700 (PDT)
Received-SPF: pass (google.com: domain of nadav.amit@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=LQ6S9B5W;
       spf=pass (google.com: domain of nadav.amit@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=nadav.amit@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:subject:from:in-reply-to:date:cc
         :content-transfer-encoding:message-id:references:to;
        bh=VmhJMV0Np4v0eA65Qt+YfIQRgnxKyiiKiYRlh0slvOA=;
        b=LQ6S9B5W8JqpcomgYeh69J+lnxPke5hf5Mggah4JJqsLzyVc6eywx1w1mnyIjbJrkV
         TKJlwj29trBOgapjWXY/CwEJtFnknICLzweQa7POIAWP6MWA6iRtxllMadl1Gg8veM23
         Hbj1cw5QzMmjQ7W/9yRBBQWK432yOKDidhC6A/HvoAiQXxYfyAq2JRC49eQjH4e4ba3X
         Go6KzS3gQlxl2DhTC86CX6jOQ0U5qKvVNu/HVnnHwwnoSKMpB/BHP5aE3n+Cu7P2e8ib
         o9qxEYbwoHwdOJ5U/8PE2Yty+qXnSebVDC0KD2O/wHlwMatBFkXX+090a8PknNaE+RUC
         sQdg==
X-Google-Smtp-Source: APXvYqxo1WfiPFreJ8aXf6AXXx2DBZ7B/aFlVO28LFjxDfPf0HVgD71sPtURW2VT3NfPVcJHSDAhDQ==
X-Received: by 2002:a17:90a:2e87:: with SMTP id r7mr27551960pjd.112.1560290387872;
        Tue, 11 Jun 2019 14:59:47 -0700 (PDT)
Received: from [10.2.189.129] ([66.170.99.2])
        by smtp.gmail.com with ESMTPSA id l2sm11916525pgs.33.2019.06.11.14.59.46
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 11 Jun 2019 14:59:46 -0700 (PDT)
Content-Type: text/plain;
	charset=utf-8
Mime-Version: 1.0 (Mac OS X Mail 12.4 \(3445.104.11\))
Subject: Re: [PATCH v4 3/9] mm: Add write-protect and clean utilities for
 address space ranges
From: Nadav Amit <nadav.amit@gmail.com>
In-Reply-To: <f1a936c3-999a-f57e-6017-3315475967ad@vmwopensource.org>
Date: Tue, 11 Jun 2019 14:59:45 -0700
Cc: dri-devel@lists.freedesktop.org,
 linux-graphics-maintainer@vmware.com,
 "VMware, Inc." <pv-drivers@vmware.com>,
 LKML <linux-kernel@vger.kernel.org>,
 Thomas Hellstrom <thellstrom@vmware.com>,
 Andrew Morton <akpm@linux-foundation.org>,
 Matthew Wilcox <willy@infradead.org>,
 Will Deacon <will.deacon@arm.com>,
 Peter Zijlstra <peterz@infradead.org>,
 Rik van Riel <riel@surriel.com>,
 Minchan Kim <minchan@kernel.org>,
 Michal Hocko <mhocko@suse.com>,
 Huang Ying <ying.huang@intel.com>,
 Souptick Joarder <jrdr.linux@gmail.com>,
 =?utf-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>,
 Linux-MM <linux-mm@kvack.org>,
 Ralph Campbell <rcampbell@nvidia.com>,
 Dave Hansen <dave.hansen@intel.com>
Content-Transfer-Encoding: quoted-printable
Message-Id: <44C26893-5D42-4807-92E9-85D4C1425966@gmail.com>
References: <20190611122454.3075-1-thellstrom@vmwopensource.org>
 <20190611122454.3075-4-thellstrom@vmwopensource.org>
 <1CDAE797-4686-4041-938F-DE0456FFF451@gmail.com>
 <ac0b0ef5-8f76-5e55-2be2-f1860878841a@vmwopensource.org>
 <39CC6294-52B5-4ED7-852E-A644132DEA18@gmail.com>
 <f1a936c3-999a-f57e-6017-3315475967ad@vmwopensource.org>
To: =?utf-8?Q?=22Thomas_Hellstr=C3=B6m_=28VMware=29=22?= <thellstrom@vmwopensource.org>
X-Mailer: Apple Mail (2.3445.104.11)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

> On Jun 11, 2019, at 2:20 PM, Thomas Hellstr=C3=B6m (VMware) =
<thellstrom@vmwopensource.org> wrote:
>=20
> On 6/11/19 9:10 PM, Nadav Amit wrote:
>>> On Jun 11, 2019, at 11:26 AM, Thomas Hellstr=C3=B6m (VMware) =
<thellstrom@vmwopensource.org> wrote:
>>>=20
>>> Hi, Nadav,
>>>=20
>>> On 6/11/19 7:21 PM, Nadav Amit wrote:
>>>>> On Jun 11, 2019, at 5:24 AM, Thomas Hellstr=C3=B6m (VMware) =
<thellstrom@vmwopensource.org> wrote:
>>>>>=20
>>>>> From: Thomas Hellstrom <thellstrom@vmware.com>
>>>> [ snip ]
>>>>=20
>>>>> +/**
>>>>> + * apply_pt_wrprotect - Leaf pte callback to write-protect a pte
>>>>> + * @pte: Pointer to the pte
>>>>> + * @token: Page table token, see apply_to_pfn_range()
>>>>> + * @addr: The virtual page address
>>>>> + * @closure: Pointer to a struct pfn_range_apply embedded in a
>>>>> + * struct apply_as
>>>>> + *
>>>>> + * The function write-protects a pte and records the range in
>>>>> + * virtual address space of touched ptes for efficient range TLB =
flushes.
>>>>> + *
>>>>> + * Return: Always zero.
>>>>> + */
>>>>> +static int apply_pt_wrprotect(pte_t *pte, pgtable_t token,
>>>>> +			      unsigned long addr,
>>>>> +			      struct pfn_range_apply *closure)
>>>>> +{
>>>>> +	struct apply_as *aas =3D container_of(closure, typeof(*aas), =
base);
>>>>> +	pte_t ptent =3D *pte;
>>>>> +
>>>>> +	if (pte_write(ptent)) {
>>>>> +		pte_t old_pte =3D ptep_modify_prot_start(aas->vma, addr, =
pte);
>>>>> +
>>>>> +		ptent =3D pte_wrprotect(old_pte);
>>>>> +		ptep_modify_prot_commit(aas->vma, addr, pte, old_pte, =
ptent);
>>>>> +		aas->total++;
>>>>> +		aas->start =3D min(aas->start, addr);
>>>>> +		aas->end =3D max(aas->end, addr + PAGE_SIZE);
>>>>> +	}
>>>>> +
>>>>> +	return 0;
>>>>> +}
>>>>> +
>>>>> +/**
>>>>> + * struct apply_as_clean - Closure structure for apply_as_clean
>>>>> + * @base: struct apply_as we derive from
>>>>> + * @bitmap_pgoff: Address_space Page offset of the first bit in =
@bitmap
>>>>> + * @bitmap: Bitmap with one bit for each page offset in the =
address_space range
>>>>> + * covered.
>>>>> + * @start: Address_space page offset of first modified pte =
relative
>>>>> + * to @bitmap_pgoff
>>>>> + * @end: Address_space page offset of last modified pte relative
>>>>> + * to @bitmap_pgoff
>>>>> + */
>>>>> +struct apply_as_clean {
>>>>> +	struct apply_as base;
>>>>> +	pgoff_t bitmap_pgoff;
>>>>> +	unsigned long *bitmap;
>>>>> +	pgoff_t start;
>>>>> +	pgoff_t end;
>>>>> +};
>>>>> +
>>>>> +/**
>>>>> + * apply_pt_clean - Leaf pte callback to clean a pte
>>>>> + * @pte: Pointer to the pte
>>>>> + * @token: Page table token, see apply_to_pfn_range()
>>>>> + * @addr: The virtual page address
>>>>> + * @closure: Pointer to a struct pfn_range_apply embedded in a
>>>>> + * struct apply_as_clean
>>>>> + *
>>>>> + * The function cleans a pte and records the range in
>>>>> + * virtual address space of touched ptes for efficient TLB =
flushes.
>>>>> + * It also records dirty ptes in a bitmap representing page =
offsets
>>>>> + * in the address_space, as well as the first and last of the =
bits
>>>>> + * touched.
>>>>> + *
>>>>> + * Return: Always zero.
>>>>> + */
>>>>> +static int apply_pt_clean(pte_t *pte, pgtable_t token,
>>>>> +			  unsigned long addr,
>>>>> +			  struct pfn_range_apply *closure)
>>>>> +{
>>>>> +	struct apply_as *aas =3D container_of(closure, typeof(*aas), =
base);
>>>>> +	struct apply_as_clean *clean =3D container_of(aas, =
typeof(*clean), base);
>>>>> +	pte_t ptent =3D *pte;
>>>>> +
>>>>> +	if (pte_dirty(ptent)) {
>>>>> +		pgoff_t pgoff =3D ((addr - aas->vma->vm_start) >> =
PAGE_SHIFT) +
>>>>> +			aas->vma->vm_pgoff - clean->bitmap_pgoff;
>>>>> +		pte_t old_pte =3D ptep_modify_prot_start(aas->vma, addr, =
pte);
>>>>> +
>>>>> +		ptent =3D pte_mkclean(old_pte);
>>>>> +		ptep_modify_prot_commit(aas->vma, addr, pte, old_pte, =
ptent);
>>>>> +
>>>>> +		aas->total++;
>>>>> +		aas->start =3D min(aas->start, addr);
>>>>> +		aas->end =3D max(aas->end, addr + PAGE_SIZE);
>>>>> +
>>>>> +		__set_bit(pgoff, clean->bitmap);
>>>>> +		clean->start =3D min(clean->start, pgoff);
>>>>> +		clean->end =3D max(clean->end, pgoff + 1);
>>>>> +	}
>>>>> +
>>>>> +	return 0;
>>>> Usually, when a PTE is write-protected, or when a dirty-bit is =
cleared, the
>>>> TLB flush must be done while the page-table lock for that specific =
table is
>>>> taken (i.e., within apply_pt_clean() and apply_pt_wrprotect() in =
this case).
>>>>=20
>>>> Otherwise, in the case of apply_pt_clean() for example, another =
core might
>>>> shortly after (before the TLB flush) write to the same page whose =
PTE was
>>>> changed. The dirty-bit in such case might not be set, and the =
change get
>>>> lost.
>>> Hmm. Let's assume that was the case, we have two possible =
situations:
>>>=20
>>> A: pt_clean
>>>=20
>>> 1. That core's TLB entry is invalid. It will set the PTE dirty bit =
and continue. The dirty bit will probably remain set after the TLB =
flush.
>> I guess you mean the PTE is not cached in the TLB.
> Yes.
>>> 2. That core's TLB entry is valid. It will just continue. The dirty =
bit will remain clear after the TLB flush.
>>>=20
>>> But I fail to see how having the TLB flush within the page table =
lock would help in this case. Since the writing core will never attempt =
to take it? In any case, if such a race occurs, the corresponding bit in =
the bitmap would have been set and we've recorded that the page is =
dirty.
>> I don=E2=80=99t understand. What do you mean =E2=80=9Crecorded that =
the page is dirty=E2=80=9D?
>> IIUC, the PTE is clear in this case - you mean PG_dirty is set?
>=20
> All PTEs we touch and clean are noted in the bitmap.
>=20
>> To clarify, this code actually may work correctly on Intel CPUs, =
based on a
>> recent discussion with Dave Hansen. Apparently, most Intel CPUs set =
the
>> dirty bit in memory atomically when a page is first written.
>>=20
>> But this is a generic code and not arch-specific. My concern is that =
a
>> certain page might be written to, but would not be marked as dirty in =
either
>> the bitmap or the PTE.
>=20
> Regardless of arch, we have four cases:
> 1. Writes occuring before we scan (and possibly modify) the PTE. =
Should be handled correctly.
> 2. Writes occurning after the TLB flush. Should be handled correctly, =
unless after a TLB flush the TLB cached entry and the PTE differs on the =
dirty bit. Then we could in theory go on writing without marking the PTE =
dirty. But that would probably be an arch code bug: I mean anything =
using tlb_gather_mmu() would flush TLB outside of the page table lock, =
and if, for example, unmap_mapping_range() left the TLB entries and the =
PTES in an inconsistent state, that wouldn't be good.
> 3. Writes occuring after the PTE scan, but before the TLB flush =
without us modifying the PTE: That would be the same as a spurious TLB =
flush. It should be harmless. The write will not be picked up in the =
bitmap, but the PTE dirty bit will be set.
> 4. Writes occuring after us clearing the dirty bit and before the TLB =
flush: We will detect the write, since the bitmap bit is already set. If =
the write continues after the TLB flush, we go to 2.

Thanks for the detailed explanation. It does sound reasonable.

> Note, for archs doing software PTE_DIRTY, that would be very similar =
to softdirty, which is also doing batched TLB flushes=E2=80=A6

Somewhat similar. But AFAIK, soft-dirty allows you to do only one of two
things:

- Clear the refs ( using /proc/[pid]/clear_refs ); or
- Read the refs (using /proc/[pid]/pagemap )

This interface does not provide any atomicity like the one you try to
obtain.

