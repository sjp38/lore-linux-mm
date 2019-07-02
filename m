Return-Path: <SRS0=T9E7=U7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6A7A6C06508
	for <linux-mm@archiver.kernel.org>; Tue,  2 Jul 2019 03:37:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2D3B42146F
	for <linux-mm@archiver.kernel.org>; Tue,  2 Jul 2019 03:37:09 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2D3B42146F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BDAC46B0005; Mon,  1 Jul 2019 23:37:08 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B89B58E0003; Mon,  1 Jul 2019 23:37:08 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A79D18E0002; Mon,  1 Jul 2019 23:37:08 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 568086B0005
	for <linux-mm@kvack.org>; Mon,  1 Jul 2019 23:37:08 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id o13so18673964edt.4
        for <linux-mm@kvack.org>; Mon, 01 Jul 2019 20:37:08 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:subject
         :to:cc:references:message-id:date:user-agent:mime-version
         :in-reply-to:content-language:content-transfer-encoding;
        bh=yOnrSKHpq7YrWY8+fjIlfOy6xxS79LZ26qOncoP3LBQ=;
        b=NxKDEh+CbrXdckxyS7kQlZHbH8oZCE3MYNP/LNx5eEcUtrzdIujR5o/GL8d14TvIFg
         Jvsls6Zm0QCnVQ2a7MXl3isjkhBah+eFyZyLaKVeruc3TIikj1e0ZIE0Mo4Nxs6ChImO
         GIcM0mBAHckH9ve7Sz2u0NkYhGiS/QJiSpPfWdyNBWLAdHCgm0axV4pNMG2uGDRgKQDc
         gecxMv7Zi/UchlL9JYJbxKl334+wV5EIX29uTHhsubz3EjtA1efgnIEixrETim7dR1fz
         V/6Y7dDXTqMCclI00O2JCtS51K8S3fr4FGJLx+0XVqShtP6dcuqqPG6oQJGwDUn6DzUk
         yqBQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
X-Gm-Message-State: APjAAAWwYMy+n2SjWKxroW3KTVwY6so1ohWbkYerCBcjWwGyB3CotTie
	HjJklacNVcPWzlHHyeIpltwD7Sbornj8EzV+QDko6PcZ+217koiiHqJ0mVmfNvHL1jZW0ag+eB+
	W3m8T0Hoos1Hz4c1CBfHOKGz9yVGNqtVPPBl2g3EqBdisy+W5ALkqC4gvL44Zs4nD5Q==
X-Received: by 2002:a50:fd0c:: with SMTP id i12mr34424670eds.55.1562038627890;
        Mon, 01 Jul 2019 20:37:07 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzd/WmQ87K/BxoGGnjJHSek+LihdL/nrK7VPYuTrUwQeUzRYJRI4BJclIIcubS0Kt6hnatE
X-Received: by 2002:a50:fd0c:: with SMTP id i12mr34424633eds.55.1562038627048;
        Mon, 01 Jul 2019 20:37:07 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562038627; cv=none;
        d=google.com; s=arc-20160816;
        b=KqKRyJlN8hYH7yiusRqd6c3VfRpivP11mMnV+MPJeLD0Wv/BIwFAKWfiaHbVrLungC
         fi3aoK/zqR84PLYMhQIqXk7TBLAxalb0hRrFrbARtqiLkRPdBRkTt0jeH0w8XxM44jcT
         IRi3Z+jUTSnPGonuF/+bfCZs8py5fjpv2xvMO3pMzwzejcukKkmwcqSD+3YMTpEslBUd
         2vOfknJtBvobxWluCmXpGzDrboIEViDvhJF5Sv5reM9PUwtBbmVqT0zTfVMDqvkbcQUi
         YbG1+eMouq1OpnDhaTykJ13keRhycCdFTZXSHYNssifYwkuEFwCYr/C55/+9mio/4l5p
         I3xA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:references:cc:to:subject:from;
        bh=yOnrSKHpq7YrWY8+fjIlfOy6xxS79LZ26qOncoP3LBQ=;
        b=gKI82bhEBKF1pATgDIehxDHHH5kBnLcJ1OkH39m4cL6x/IXTAfiwQExoouYl+sHuin
         SCjIZ7o/SqVY4JEIPRcj6b6eUWUyg1y9BraO6oxwie/7yHTqJOwoQ4eV4g4MoBGz4f+d
         wu09zCY2Igr+pjSEfZL3+ITEYSROPaIjo/HJLoR774BUEx6Wj4Akw8L/IgrXE5he2yCP
         YgtlVznhourXYoZl/LxkyxpmyeASHQkIr/f2JHU/04DQOUvoixoC566P9Rz41b47vo/b
         +7KGbLM2HzmUm5qwQmJ14GLivp8qJHdrC1AMhfRzxNm5BmkuWvpHyEAEiR3kQMMAETaL
         RwZA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id e2si7938686ejb.399.2019.07.01.20.37.05
        for <linux-mm@kvack.org>;
        Mon, 01 Jul 2019 20:37:06 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id B7BBD28;
	Mon,  1 Jul 2019 20:37:04 -0700 (PDT)
Received: from [10.163.1.231] (unknown [10.163.1.231])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 9F2973F703;
	Mon,  1 Jul 2019 20:37:01 -0700 (PDT)
From: Anshuman Khandual <anshuman.khandual@arm.com>
Subject: Re: [RFC 1/2] arm64/mm: Change THP helpers to comply with generic MM
 semantics
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: linux-mm@kvack.org, Will Deacon <will@kernel.org>,
 Mark Rutland <mark.rutland@arm.com>, Marc Zyngier <marc.zyngier@arm.com>,
 Suzuki Poulose <suzuki.poulose@arm.com>,
 linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
 Andrea Arcangeli <aarcange@redhat.com>
References: <1561639696-16361-1-git-send-email-anshuman.khandual@arm.com>
 <1561639696-16361-2-git-send-email-anshuman.khandual@arm.com>
 <20190628102003.GA56463@arrakis.emea.arm.com>
Message-ID: <82237e21-1f14-ab6e-0f80-9706141e2172@arm.com>
Date: Tue, 2 Jul 2019 09:07:28 +0530
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:52.0) Gecko/20100101
 Thunderbird/52.9.1
MIME-Version: 1.0
In-Reply-To: <20190628102003.GA56463@arrakis.emea.arm.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


On 06/28/2019 03:50 PM, Catalin Marinas wrote:
> Hi Anshuman,

Hello Catalin,

> 
> On Thu, Jun 27, 2019 at 06:18:15PM +0530, Anshuman Khandual wrote:
>> pmd_present() and pmd_trans_huge() are expected to behave in the following
>> manner during various phases of a given PMD. It is derived from a previous
>> detailed discussion on this topic [1] and present THP documentation [2].
>>
>> pmd_present(pmd):
>>
>> - Returns true if pmd refers to system RAM with a valid pmd_page(pmd)
>> - Returns false if pmd does not refer to system RAM - Invalid pmd_page(pmd)
>>
>> pmd_trans_huge(pmd):
>>
>> - Returns true if pmd refers to system RAM and is a trans huge mapping
>>
>> -------------------------------------------------------------------------
>> |	PMD states	|	pmd_present	|	pmd_trans_huge	|
>> -------------------------------------------------------------------------
>> |	Mapped		|	Yes		|	Yes		|
>> -------------------------------------------------------------------------
>> |	Splitting	|	Yes		|	Yes		|
>> -------------------------------------------------------------------------
>> |	Migration/Swap	|	No		|	No		|
>> -------------------------------------------------------------------------
> 
> Before we actually start fixing this, I would strongly suggest that you
> add a boot selftest (see lib/Kconfig.debug for other similar cases)
> which checks the consistency of the page table macros w.r.t. the
> expected mm semantics. Once the mm maintainers agreed with the
> semantics, it will really help architecture maintainers in implementing
> them correctly.

Sure and it will help all architectures to be in sync wrt semantics.

> 
> You wouldn't need actual page tables, just things like assertions on
> pmd_trans_huge(pmd_mkhuge(pmd)) == true. You could go further and have
> checks on pmdp_invalidate(&dummy_vma, dummy_addr, &dummy_pmd) with the
> dummy_* variables on the stack.

Hmm. I guess macros which operate directly on a page table entry will be
okay but the ones which check on specific states for VMA or MM might be
bit tricky. Try to emulate VMA/MM states while on stack ?. But sure, will
explore adding such a test.

> 
>> The problem:
>>
>> PMD is first invalidated with pmdp_invalidate() before it's splitting. This
>> invalidation clears PMD_SECT_VALID as below.
>>
>> PMD Split -> pmdp_invalidate() -> pmd_mknotpresent -> Clears PMD_SECT_VALID
>>
>> Once PMD_SECT_VALID gets cleared, it results in pmd_present() return false
>> on the PMD entry.
> 
> I think that's an inconsistency in the expected semantics here. Do you
> mean that pmd_present(pmd_mknotpresent(pmd)) should be true? If not, do

Actually that is true (more so if we are using generic pmdp_invalidate). Else
in general pmd_present(pmdp_invalidate(pmd)) needs to be true to successfully
represent a splitting THP. That is what Andrea explained back on this thread
(https://lkml.org/lkml/2018/10/17/231).

Extracting relevant sections from that thread -

"pmd_present never meant the real present bit in the pte was set, it just means
the pmd points to RAM. It means it doesn't point to swap or migration entry and
you can do pmd_to_page and it works fine."

"The clear of the real present bit during pmd (virtual) splitting is done with
pmdp_invalidate, that is created specifically to keeps pmd_trans_huge=true,
pmd_present=true despite the present bit is not set. So you could imagine
_PAGE_PSE as the real present bit."

pmd_present() and pmd_mknotpresent() are not exact inverse.

Problem is all platforms using generic pmdp_invalidate() calls pmd_mknotpresent()
which invariably across platforms remove the valid or present bit from the entry.
The point to note here is that pmd_mknotpresent() invalidates the entry from MMU
point of view but pmd_present() does not check for a MMU valid PMD entry. Hence
pmd_present(pmd_mknotpresent(pmd)) can still be true.

In absence of a positive section mapping bit on arm64, PTE_SPECIAL is being set
temporarily to remember that it was a mapped PMD which got invalidated recently
but which still points to memory. Hence pmd_present() must evaluate true.

pmd_mknotpresent() does not make !pmd_present() it just invalidates the entry.

> we need to implement our own pmdp_invalidate() or change the generic one
> to set a "special" bit instead of just a pmd_mknotpresent?

Though arm64 can subscribe __HAVE_ARCH_PMDP_INVALIDATE and implement it's own
pmdp_invalidate() in order to not call pmd_mknotpresent() and instead operate
on the invalid and special bits directly. But its not going to alter relevant
semantics here. AFAICS it might be bit better as it saves pmd_mknotpresent()
from putting in that special bit in there which it is not supposed do.

IFAICS there is no compelling reason for generic pmdp_invalidate() to change
either. It calls pmd_mknotpresent() which invalidates the entry through valid
or present bit and platforms which have dedicated huge page bit can still test
positive for pmd_present() after it's invalidation. It works for such platforms.
Platform specific override is required when invalidation via pmd_mknotpresent()
is not enough.

> 
>> +static inline int pmd_present(pmd_t pmd)
>> +{
>> +	if (pte_present(pmd_pte(pmd)))
>> +		return 1;
>> +
>> +	return pte_special(pmd_pte(pmd));
>> +}
> [...]
>> +static inline pmd_t pmd_mknotpresent(pmd_t pmd)
>> +{
>> +	pmd = pte_pmd(pte_mkspecial(pmd_pte(pmd)));
>> +	return __pmd(pmd_val(pmd) & ~PMD_SECT_VALID);
>> +}
> 
> I'm not sure I agree with the semantics here where pmd_mknotpresent()
> does not actually make pmd_present() == false.

As Andrea explained, pmd_present() does not check validity of the PMD entry
from MMU perspective but the presence of a valid pmd_page() which still refers
to a valid struct page in the memory. It is irrespective of whether the entry
in itself is valid for MMU walk or not.

+ Cc: Andrea Arcangeli <aarcange@redhat.com>

I have added Andrea on this thread if he would like to add something.

- Anshuman

