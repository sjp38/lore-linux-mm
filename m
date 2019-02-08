Return-Path: <SRS0=ikTF=QP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C864CC282C2
	for <linux-mm@archiver.kernel.org>; Fri,  8 Feb 2019 02:14:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8854821907
	for <linux-mm@archiver.kernel.org>; Fri,  8 Feb 2019 02:14:07 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8854821907
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 218948E006F; Thu,  7 Feb 2019 21:14:07 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1CABB8E0002; Thu,  7 Feb 2019 21:14:07 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0DF0A8E006F; Thu,  7 Feb 2019 21:14:07 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id ADE858E0002
	for <linux-mm@kvack.org>; Thu,  7 Feb 2019 21:14:06 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id f17so728199edm.20
        for <linux-mm@kvack.org>; Thu, 07 Feb 2019 18:14:06 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:subject
         :to:cc:message-id:date:user-agent:mime-version:content-language
         :content-transfer-encoding;
        bh=RkIJ4uJk2W1n2+qQpIPDMgBEfhdLzOI7pFy9JujSTWY=;
        b=Y/SqoelJhX1yTQZVrIOpiTi2FZR9fY4t2R2K49gBRB0lAcfpA4Yg9w8uC3qBvmpE23
         cVH2XctVO+CfkItZhbsWvg5hcP005oHpBoV4WmRwHF3Bir+SyKRb/ray3JT7m+LBr78D
         mltcE3vTRgP7MIq5ImkSmvssVISVO8Q0zyYifBK61/OLVG9XIN9HEt5RbfXJWXB0Wsvi
         dZNSzn43Ab6LQpu2S1h3GFj1eP9MgRvKt9yiVbIaLaESxpYRzLHpwObZ3oqhgqcihQbf
         Ic9Dd0EaUlxyBwvwoe0w3ar0WA1CLqDCeHRYUE/4BXwHzxsi1yKaQXLy5aSu0zKZH3Lz
         5WRQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
X-Gm-Message-State: AHQUAuZhjqX1mHN9UzLgLxoAsrbsIifLb4IncYm+WeT77p0Sxw8KDFzs
	KNfPo4net3fHZJZbNLktIUCipEVmU+moEV71IAoCyCLDFJ2Llk3EeGuyhZcRLNbiyrb3KBs4LvL
	SZ6q5i9AKxavwB166qnStdK2cMCmrNQZWX2ZJgE7WyYQkKZpLpNe1e/SL/3HLfOc+1A==
X-Received: by 2002:a17:906:3ed0:: with SMTP id d16mr3736114ejj.138.1549592046087;
        Thu, 07 Feb 2019 18:14:06 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYC/5sgLYmS0SFoIkxXel6KarMfaRIomqP63h5fyu9QAP11U4WqOy05ZipsetyYi1Zxip1U
X-Received: by 2002:a17:906:3ed0:: with SMTP id d16mr3736062ejj.138.1549592044884;
        Thu, 07 Feb 2019 18:14:04 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549592044; cv=none;
        d=google.com; s=arc-20160816;
        b=Xa5D7i3SpPxu86Fi7NLl7m4hws5cQ1Hn4VC/X+kIEEV70AeyLHKlU4E+pgXte1CGRf
         f3k0HXcsI8Hr3qXtq0txo5WTxYhz/j0Ah/mOeIPUOaX8THC+vpIKPMD+PbNmvj/N9oy2
         uEwMCMEkUJwqv2BChh5MeSO67kcEEg1RA8RRvK2soIGZH+AOYeIWFSx5pB//hxv7OIOY
         aEVTowy2o78xPql6Zv1n/4RGrdmyis5NMk/aD2mOBMjJQoEyFXQPnTepIFI/8yAr/NdB
         +IkQh6x9ILn+OABSuycrM4tfHeCxOdwRadlOEhLBc0Q78XmF0IPtMWCsW4Y+1Ej35r9D
         g15A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:mime-version:user-agent
         :date:message-id:cc:to:subject:from;
        bh=RkIJ4uJk2W1n2+qQpIPDMgBEfhdLzOI7pFy9JujSTWY=;
        b=JhgtntfNhwWFDD2l+ahVlCiNqB94Bi07R2UI/OlF2SXUkYZKblOInRh2VAPYJG2U0M
         jdhn9nX6EC+y7QqKg53FemZ9uMF3n/T7xK9uPuHCV/yxjjvx7G9ryJF3j+tNn/lHuvPg
         EiSCd7IWbxg7N4byW5q8FL4y5uG+KWwzyT80QWnJ9sOK6d+deFWtJ0H2MesPi+O3DWkz
         sQTsAndk16UTD6C0ks4Ih1CngASLdOWLMGOXrqVmbndy7sgXUoz6E66SZC4ZW4oe0dYC
         Ije+ZM0eQPH7l+AEGQU3F/TewnNC/4LiuN9ge/ZPsriCuLG5MvnNYi1f8L03tfRhqKT/
         Xd3g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id v13si422289edq.180.2019.02.07.18.14.04
        for <linux-mm@kvack.org>;
        Thu, 07 Feb 2019 18:14:04 -0800 (PST)
Received-SPF: pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 53A53EBD;
	Thu,  7 Feb 2019 18:14:03 -0800 (PST)
Received: from [10.162.40.126] (p8cg001049571a15.blr.arm.com [10.162.40.126])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id C899D3F675;
	Thu,  7 Feb 2019 18:14:00 -0800 (PST)
From: Anshuman Khandual <anshuman.khandual@arm.com>
Subject: [LSF/MM TOPIC] Non standard size THP
To: lsf-pc@lists.linux-foundation.org, "linux-mm@kvack.org"
 <linux-mm@kvack.org>,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>,
 Michal Hocko <mhocko@kernel.org>,
 "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>,
 Vlastimil Babka <vbabka@suse.cz>
Message-ID: <dcb0b2cf-ba5c-e6ef-0b05-c6006227b6a9@arm.com>
Date: Fri, 8 Feb 2019 07:43:57 +0530
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:52.0) Gecko/20100101
 Thunderbird/52.9.1
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hello,

THP is currently supported for

- PMD level pages (anon and file)
- PUD level pages (file - DAX file system)

THP is a single entry mapping at standard page table levels (either PMD or PUD)

But architectures like ARM64 supports non-standard page table level huge pages
with contiguous bits.

- These are created as multiple entries at either PTE or PMD level
- These multiple entries carry pages which are physically contiguous
- A special PTE bit (PTE_CONT) is set indicating single entry to be contiguous

These multiple contiguous entries create a huge page size which is different
than standard PMD/PUD level but they provide benefits of huge memory like
less number of faults, bigger TLB coverage, less TLB miss etc.

Currently they are used as HugeTLB pages because

	- HugeTLB page sizes is carried in the VMA
	- Page table walker can operate on multiple PTE or PMD entries given its size in VMA
	- Irrespective of HugeTLB page size its operated with set_huge_pte_at() at any level
	- set_huge_pte_at() is arch specific which knows how to encode multiple consecutive entries
	
But not as THP huge pages because

	- THP size is not encoded any where like VMA
	- Page table walker expects it to be either at PUD (HPAGE_PUD_SIZE) or at PMD (HPAGE_PMD_SIZE)
	- Page table operates directly with set_pmd_at() or set_pud_at()
	- Direct faulted or promoted huge pages is verified with [pmd|pud]_trans_huge()

How non-standard huge pages can be supported for THP

	- THP starts recognizing non standard huge page (exported by arch) like HPAGE_CONT_(PMD|PTE)_SIZE
	- THP starts operating for either on HPAGE_PMD_SIZE or HPAGE_CONT_PMD_SIZE or HPAGE_CONT_PTE_SIZE
	- set_pmd_at() only recognizes HPAGE_PMD_SIZE hence replace set_pmd_at() with set_huge_pmd_at()
	- set_huge_pmd_at() could differentiate between HPAGE_PMD_SIZE or HPAGE_CONT_PMD_SIZE
	- In case for HPAGE_CONT_PTE_SIZE extend page table walker till PTE level
	- Use set_huge_pte_at() which can operate on multiple contiguous PTE bits

Kirill Shutemov proposed re-working the page table traversal during last year's
LSFMM. A recursive page table walk just with level information would allow us to
introduce artificial or non-standard page table levels for contiguous bit huge
page support.

https://lwn.net/Articles/753267/

Here is the matrix for contiguous PTE and PMD sizes for various base page size
configurations on ARM64. Promoting or faulting pages at contiguous PTE level is
much more likely than PMD level which are more difficult to allocate at run time.
    
            CONT PTE    PMD    CONT PMD
            --------    ---    --------
    4K:        64K      2M        32M
    16K:        2M     32M         1G
    64K:        2M    512M        16G

Having support for contiguous PTE size based THP size will help many workloads utilize
THP benefits. I understand there would be much more fine grained details which need to
be sorted out and difficulties to be overcome but its worth starting a discussion on this
front which can really benefit workloads.

- Anshuman

