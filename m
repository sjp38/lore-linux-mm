Return-Path: <SRS0=Z+ZU=Q2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A3595C43381
	for <linux-mm@archiver.kernel.org>; Tue, 19 Feb 2019 06:17:20 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 474D8217D7
	for <linux-mm@archiver.kernel.org>; Tue, 19 Feb 2019 06:17:20 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 474D8217D7
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AAAE98E0003; Tue, 19 Feb 2019 01:17:19 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A59E98E0002; Tue, 19 Feb 2019 01:17:19 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 94A3C8E0003; Tue, 19 Feb 2019 01:17:19 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 3B01F8E0002
	for <linux-mm@kvack.org>; Tue, 19 Feb 2019 01:17:19 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id b3so8081353edi.0
        for <linux-mm@kvack.org>; Mon, 18 Feb 2019 22:17:19 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=WuBBpiawBTW3ikxXPnSeC2+iCdDq3+vlMxJlDEHi9y8=;
        b=omfeCqDQ33e0us3vkBHKFas3/DV9OGnaacaz1mpiFI5uiQ5wt3U4YKP2dh0VD1G92j
         BcAYFGjnLFRc9UI0IABRSqeU8M6aHqaUdXV21mEIybERi7lqKEzl7lQGj/+9/IETy7KN
         +6WuLYhgIiPEplseUyed2RZRIwfpf2IQgavdYtqCjOPXiAFSu33xbZbvshEiNbL5yg9G
         I1tqroQrEeYzCguflGAb3uD4SjjOsf/tlcGcRP7CYtYD7OELM1ffgjCLH9ZBqWSnQA5i
         qi3yXr5I7bTo5QwJgZeg6/1Oc4m1h5d1ffHrpM5c6juEdcvPpZT4ql6+kE6aZcNHZTr2
         zS5A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
X-Gm-Message-State: AHQUAuZFlGksmXiKPOVAx09kbwcx+aKQw6p/N9yccZdfDv15jKTpIk2L
	pJxx/dQE2Wwj8gAqgL8//VmBu4u1xbuZv5Bw70Few3PYXyBeq20kzr/rcr9Yor+MJGcoRvpKUcI
	/mqV46lS75SXA5GLlEHttHXOgS1vs/uKtIKciozSgmQwdk8la1RigzX8QeZoQkStaMg==
X-Received: by 2002:a50:b699:: with SMTP id d25mr18995108ede.110.1550557038770;
        Mon, 18 Feb 2019 22:17:18 -0800 (PST)
X-Google-Smtp-Source: AHgI3Ibm4CpcLhlKZ5dvKs+dq0kNQns5Fegpm0igITxWilRT9frgyb96D4mIjrvFf8kkVP+dPD05
X-Received: by 2002:a50:b699:: with SMTP id d25mr18995045ede.110.1550557037900;
        Mon, 18 Feb 2019 22:17:17 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550557037; cv=none;
        d=google.com; s=arc-20160816;
        b=nHAQOmWLfNKHnbniHH6EfcJbi2xmQTnAyuX/nPezomA3Ncy1L7X4FMCT57J3h81iUf
         W2Wy+5af98fVxV6PoTrwKMtJ7yxDTXrVGWwPpyu/n30lEgivUoyMssya+Ywer81nTaP6
         G1G3fTrZa1EkuWfYU9s5DE3OoWJuMXY1D+MPkpYpapbYUVS+uOybix2UBCenAX9nYTUm
         rX9TYww+PQvEZfH+Fx2F55IHPcnZfEwjwPklgP4Cl9GpPCwc/WoZp2CKKNgmagq+agGJ
         RfnbieNiOkAOsLbUqI7c5sZue1FUt2H9Ouk3j3/xiQT8B/6ZO3NmzCUpEZ0YCrRYH91j
         d+pw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=WuBBpiawBTW3ikxXPnSeC2+iCdDq3+vlMxJlDEHi9y8=;
        b=wHGlhw5+fdFaUP1iNPWqICJ7eqnZ0brXeTHn/I6UEwiC8/seau3lQ/q6cdnuXXLkpa
         JWvuW5wTR/lKSmsPfdN6ItPOHjerpQRgwXSztrZOfnPHuYv/pICH9CjEnPcB9BfqAQ2h
         2q3cyWdeNqX0hc5FhLJfwkEFJBOUeTtLw340MAF6+irXZ4tWWToKFo+7E0XLetIci1Cu
         1h/pAnKEtQSsdf9t8a6+NlXO3/s590WkXHitPTmzeJDbD7yEaqbrC51vgxTbIytoB4JP
         9YKrQwwotdxe75Tt4Wxp+seF34BTzyrEUIY6uwRN9CMFSL4iIhwN5FdNULNt4WCOfjpA
         HTbQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id g18si1722595ejt.134.2019.02.18.22.17.17
        for <linux-mm@kvack.org>;
        Mon, 18 Feb 2019 22:17:17 -0800 (PST)
Received-SPF: pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id DFFB1EBD;
	Mon, 18 Feb 2019 22:17:15 -0800 (PST)
Received: from [10.162.40.139] (p8cg001049571a15.blr.arm.com [10.162.40.139])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 3CF8E3F575;
	Mon, 18 Feb 2019 22:17:09 -0800 (PST)
Subject: Re: [PATCH v2 1/3] arm64: mm: use appropriate ctors for page tables
To: Yu Zhao <yuzhao@google.com>
Cc: Catalin Marinas <catalin.marinas@arm.com>,
 Will Deacon <will.deacon@arm.com>,
 "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>,
 Andrew Morton <akpm@linux-foundation.org>, Nick Piggin <npiggin@gmail.com>,
 Peter Zijlstra <peterz@infradead.org>,
 Joel Fernandes <joel@joelfernandes.org>,
 "Kirill A . Shutemov" <kirill@shutemov.name>,
 Mark Rutland <mark.rutland@arm.com>,
 Ard Biesheuvel <ard.biesheuvel@linaro.org>,
 Chintan Pandya <cpandya@codeaurora.org>, Jun Yao <yaojun8558363@gmail.com>,
 Laura Abbott <labbott@redhat.com>, linux-arm-kernel@lists.infradead.org,
 linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org,
 linux-mm@kvack.org, Matthew Wilcox <willy@infradead.org>
References: <20190214211642.2200-1-yuzhao@google.com>
 <20190218231319.178224-1-yuzhao@google.com>
 <863acc9a-53fb-86ad-4521-828ee8d9c222@arm.com>
 <20190219053205.GA124985@google.com>
From: Anshuman Khandual <anshuman.khandual@arm.com>
Message-ID: <8f9b0bfb-b787-fa3e-7322-73a56a618aa8@arm.com>
Date: Tue, 19 Feb 2019 11:47:12 +0530
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:52.0) Gecko/20100101
 Thunderbird/52.9.1
MIME-Version: 1.0
In-Reply-To: <20190219053205.GA124985@google.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

+ Matthew Wilcox

On 02/19/2019 11:02 AM, Yu Zhao wrote:
> On Tue, Feb 19, 2019 at 09:51:01AM +0530, Anshuman Khandual wrote:
>>
>>
>> On 02/19/2019 04:43 AM, Yu Zhao wrote:
>>> For pte page, use pgtable_page_ctor(); for pmd page, use
>>> pgtable_pmd_page_ctor() if not folded; and for the rest (pud,
>>> p4d and pgd), don't use any.
>> pgtable_page_ctor()/dtor() is not optional for any level page table page
>> as it determines the struct page state and zone statistics.
> 
> This is not true. pgtable_page_ctor() is only meant for user pte
> page. The name isn't perfect (we named it this way before we had
> split pmd page table lock, and never bothered to change it).
> 
> The commit cccd843f54be ("mm: mark pages in use for page tables")
> clearly states so:
>   Note that only pages currently accounted as NR_PAGETABLES are
>   tracked as PageTable; this does not include pgd/p4d/pud/pmd pages.

I think the commit is the following one and it does say so. But what is
the rationale of tagging only PTE page as PageTable and updating the zone
stat but not doing so for higher level page table pages ? Are not they
used as page table pages ? Should not they count towards NR_PAGETABLE ?

1d40a5ea01d53251c ("mm: mark pages in use for page tables")
> 
> I'm sure if we go back further, we can find similar stories: we
> don't set PageTable on page tables other than pte; and we don't
> account page tables other than pte. I don't have any objection if
> you want change these two. But please make sure they are consistent
> across all archs.

pgtable_page_ctor/dtor() use across arch is not consistent and there is a need
for generalization which has been already acknowledged earlier. But for now we
can atleast fix this on arm64.

https://lore.kernel.org/lkml/1547619692-7946-1-git-send-email-anshuman.khandual@arm.com/

> 
>> We should not skip it for any page table page.
> 
> In fact, calling it on pmd/pud/p4d is peculiar, and may even be
> considered wrong. AFAIK, no other arch does so.

Why would it be considered wrong ? IIUC archs have their own understanding
of this and there are different implementations. But doing something for
PTE page and skipping for others is plain inconsistent.

> 
>> As stated before pgtable_pmd_page_ctor() is not a replacement for
>> pgtable_page_ctor().
> 
> pgtable_pmd_page_ctor() must be used on user pmd. For kernel pmd,
> it's okay to use pgtable_page_ctor() instead only because kernel
> doesn't have thp.

The only extra thing to be done for THP is initializing page->pmd_huge_pte
apart from calling pgtable_page_ctor(). Right not it just works on arm64
may be because page->pmd_huge_pte never gets accessed before it's init and
no path checks for it when not THP. Its better to init/reset pmd_huge_pte.

