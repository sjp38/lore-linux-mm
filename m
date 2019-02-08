Return-Path: <SRS0=ikTF=QP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DF14CC169C4
	for <linux-mm@archiver.kernel.org>; Fri,  8 Feb 2019 06:31:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A60802147C
	for <linux-mm@archiver.kernel.org>; Fri,  8 Feb 2019 06:31:37 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A60802147C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 304B58E0079; Fri,  8 Feb 2019 01:31:37 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 28D978E0002; Fri,  8 Feb 2019 01:31:37 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1564F8E0079; Fri,  8 Feb 2019 01:31:37 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id AAEEB8E0002
	for <linux-mm@kvack.org>; Fri,  8 Feb 2019 01:31:36 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id i55so944491ede.14
        for <linux-mm@kvack.org>; Thu, 07 Feb 2019 22:31:36 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=6y72N6yu8xcyYnLmWUF++44VZg30GVJNFnTIzoKI/es=;
        b=DJOfvmHj3K6L1I9o7nKiOdp65m6OwOtVf2iivqmioyO3LiyWWgXD0MN5KNSwYfQGL1
         oRhZ/UgQDU854Zw3pyw+xSLAlQEKtOWV+2qCYr+W9Sd7KRaTA5qK7GxNgbwO1OCmCnKN
         TdGV4Y7N4tdbx7IfPs5HJvFXifWJtsfMlbiFc6z0RMyU+TDLACR0WqfTV5hKCSvsggAl
         TDPeGcpbzCozPu9/0WQPh6Mue01cSQ3KoPrRUyDcjj7EvpImp7wk6rLkXBDKYFyUPAll
         GDfnYYk3cZn87EebLvA/q9PPDZE3n+WiRRpaR8WE8f74rd6eEDEW59d42BLtO407v/lO
         K7ug==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
X-Gm-Message-State: AHQUAubywca8ahJmWb8bx4riMYEQuVfO3MVyQgb3cHuFk80Eq9a4oECH
	BiL4zhiyBT0HeBQnr4goec9LKTyoB6uWwI5UMfHGJJzbUR/xAO8/5X1VcAILH5ds6WXc06/D0W6
	3ed+B+YHpcZ5IiSKjl6VCYySg6UzRggEHMtLcDl3UNMTDcinbtUr/i1N/wuG/KIkLZQ==
X-Received: by 2002:a05:6402:1295:: with SMTP id w21mr9354530edv.293.1549607496141;
        Thu, 07 Feb 2019 22:31:36 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZa6kfaJflRaRpsdRWyjq0TGa0xduWXrU6YLDzAK86lubpKjLdXM2FXmcq7GB9SqJKAANyw
X-Received: by 2002:a05:6402:1295:: with SMTP id w21mr9354475edv.293.1549607494969;
        Thu, 07 Feb 2019 22:31:34 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549607494; cv=none;
        d=google.com; s=arc-20160816;
        b=K/hJiVbFfXZgWlQZ+MItbG5XsjJLZnNkSTGE+k2SNgPP5U6nmZ6cCe1ZbzGwkMfjrE
         QCQQTlPGlFPa65Mz6WpBtQF712I/Jr+DqxMy1ldl2Qj4bgONT42l/ZPd/oAAxv8iY11m
         xH/QRBWEMixgzQQN+lkzwcbg0Pfw0yTrNoYfRQjxzo6EJIGykIfUaepDRsLxE8Z91PzR
         RehNanhfS7PI4vGMbIbx0wSyKPgC5GpciXJd5DFwVajeuKuujV6dHZy8HIWkuRPJ5wMH
         MgUmGxiiu2fNE7OFaSs1Lgf2zL9JZLMCiJ2G4gvTZC5CzIRVuqMnKcBhgrrgxRAl9f9D
         PU+Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=6y72N6yu8xcyYnLmWUF++44VZg30GVJNFnTIzoKI/es=;
        b=JZRarGV22gOIDl1eeI6GikyoySd//eTzNiwHeN2ohue2plZhYDpEU8+8465t3SQz1S
         Yv0gel6gno5sI3wp6YoS5MdEuFmNLgx/+tJomQHlKRcJznvi29fN6iauL33G5tAxhvcr
         Q4jk1ei36Ilo27+/mj+7XCYxcfZnQnnpwnMFm+8ZTqer9WiDDQUVGJddvluBzWDx9zwN
         GmXCuqcJHQsCgKCxkFZaL8LrBZQZMZ9kfzy2FwcFZEm8/s+5uoFM7QJdVxDRiJEUZHko
         Bioxxkj8jedivrnBe4zF1zZaA9vqblDrzGWlY5cVOqleZW9d4um7Ph6xyN34ZSZjSEge
         HCHw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id o21si758370edc.54.2019.02.07.22.31.34
        for <linux-mm@kvack.org>;
        Thu, 07 Feb 2019 22:31:34 -0800 (PST)
Received-SPF: pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 69734EBD;
	Thu,  7 Feb 2019 22:31:33 -0800 (PST)
Received: from [10.162.40.126] (p8cg001049571a15.blr.arm.com [10.162.40.126])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id C2D753F719;
	Thu,  7 Feb 2019 22:31:30 -0800 (PST)
Subject: Re: [LSF/MM TOPIC] Non standard size THP
To: Matthew Wilcox <willy@infradead.org>
Cc: lsf-pc@lists.linux-foundation.org, "linux-mm@kvack.org"
 <linux-mm@kvack.org>,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
 Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>,
 "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>,
 Vlastimil Babka <vbabka@suse.cz>, linux-fsdevel@vger.kernel.org
References: <dcb0b2cf-ba5c-e6ef-0b05-c6006227b6a9@arm.com>
 <20190208042448.GB21860@bombadil.infradead.org>
From: Anshuman Khandual <anshuman.khandual@arm.com>
Message-ID: <a563592f-c01c-8dee-d743-6a1eb0b3f9d9@arm.com>
Date: Fri, 8 Feb 2019 12:01:28 +0530
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:52.0) Gecko/20100101
 Thunderbird/52.9.1
MIME-Version: 1.0
In-Reply-To: <20190208042448.GB21860@bombadil.infradead.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 02/08/2019 09:54 AM, Matthew Wilcox wrote:
> On Fri, Feb 08, 2019 at 07:43:57AM +0530, Anshuman Khandual wrote:
>> How non-standard huge pages can be supported for THP
>>
>> 	- THP starts recognizing non standard huge page (exported by arch) like HPAGE_CONT_(PMD|PTE)_SIZE
>> 	- THP starts operating for either on HPAGE_PMD_SIZE or HPAGE_CONT_PMD_SIZE or HPAGE_CONT_PTE_SIZE
>> 	- set_pmd_at() only recognizes HPAGE_PMD_SIZE hence replace set_pmd_at() with set_huge_pmd_at()
>> 	- set_huge_pmd_at() could differentiate between HPAGE_PMD_SIZE or HPAGE_CONT_PMD_SIZE
>> 	- In case for HPAGE_CONT_PTE_SIZE extend page table walker till PTE level
>> 	- Use set_huge_pte_at() which can operate on multiple contiguous PTE bits
> 
> I think your proposed solution reflects thinking like a hardware person
> rather than like a software person.  Or maybe like an MM person rather
> than a FS person.  I see the same problem with Kirill's solutions ;-)

You might be right on this :) I was trying to derive a solution based on
all existing semantics with limited code addition rather than inventing
something completely different.

> 
> Perhaps you don't realise that using larger pages when appropriate
> would also benefit filesystems as well as CPUs.  You didn't include
> linux-fsdevel on this submission, so that's a plausible explanation.

Yes that was an omission. Thanks for adding linux-fsdevel to the thread.

> 
> The XArray currently supports arbitrary power-of-two-naturally-aligned
> page sizes, and conveniently so does the page allocator [1].  The problem
> is that various bits of the MM have a very fixed mindset that pages are
> PTE, PMD or PUD in size.

I agree. But in general it works as allocated page with required order do
reside in one of these levels in the page table.

> 
> We should enhance routines like vmf_insert_page() to handle
> arbitrary sized pages rather than having separate vmf_insert_pfn()
> and vmf_insert_pfn_pmd().  We probably need to enhance the set_pxx_at()
> API to pass in an order, rather than explicitly naming pte/pmd/pud/...

I agree. set_huge_pte_at() actually does that to some extent on ARM64.
But thats just for HugeTLB.

> 
> First, though, we need to actually get arbitrary sized pages handled
> correctly in the page cache.  So if anyone's interested in talking about
> this, but hasn't been reviewing or commenting on the patches I've been
> sending to make this happen, I'm going to seriously question their actual
> commitment to wanting this to happen, rather than wanting a nice holiday
> in Puerto Rico.
> 
> Sorry to be so blunt about this, but I've only had review from Kirill,
> which makes me think that nobody else actually cares about getting
> this fixed.

To be honest I have not been following your work in this regard. I started
looking into this problem late last year and my goal has been more focused 
towards a THP solution for intermediate page table level sized huge pages.

But I agree to your point that there should be an wider solution which can
make generic MM deal with page sizes of any order rather than page table
level ones like PTE/PMD/PUD etc.

> 
> [1] Support for arbitrary sized and aligned entries is in progress for
> the XArray, but I don't think there's any appetite for changing the buddy
> allocator to let us allocate "pages" that are an arbitrary extent in size.
> 
> 

