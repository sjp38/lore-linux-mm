Return-Path: <SRS0=8949=Q3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 95372C43381
	for <linux-mm@archiver.kernel.org>; Wed, 20 Feb 2019 05:21:32 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1FDDB21773
	for <linux-mm@archiver.kernel.org>; Wed, 20 Feb 2019 05:21:31 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="YtO8Ipyy"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1FDDB21773
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7ADCC8E0003; Wed, 20 Feb 2019 00:21:31 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 75C8D8E0002; Wed, 20 Feb 2019 00:21:31 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 64CE88E0003; Wed, 20 Feb 2019 00:21:31 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f198.google.com (mail-yb1-f198.google.com [209.85.219.198])
	by kanga.kvack.org (Postfix) with ESMTP id 38E398E0002
	for <linux-mm@kvack.org>; Wed, 20 Feb 2019 00:21:31 -0500 (EST)
Received: by mail-yb1-f198.google.com with SMTP id d16so2489881ybs.3
        for <linux-mm@kvack.org>; Tue, 19 Feb 2019 21:21:31 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding:dkim-signature;
        bh=pzmrlv9PbmCU4DKNJH5Ssu7mfhsm6VeIbRHKHMZn3X4=;
        b=Qx+4xDFE5nrXInOURb2tc8/vVP/0eChAQd52ZA6GlAskFnaDVcnByjr8mdoCc8LKtr
         GA4NSlza87DTG5zuIi4Q9hwf3+kOVUX4PIlSugA0uU6+ezuMwo8SRdXXhKs+8EFvL6Jm
         v9j/j6QfN6GsxLYz3UOM21xlNsGJApYsvd9C7U/g5tTZL2hpCXLvgHu5hK/5UpTErGgv
         HdyH2zLZaAfwFauFSbe3Xga2Vt7eyLxPAHo00hBcyr7YXvaiaS8r+wchjGSlPJWlz1l/
         gkQd1rPCWhwNzbGhB1FYHcJ8YcoMVSbTYmVVWqDWSEGQ9lsDEIxqRZkVuirq+I+cc9HW
         RV/A==
X-Gm-Message-State: AHQUAuYuUDu0B+kIhM5UL7oY7negEFwXKI6Lu+oJJMm7qQ3w/F07XNTE
	Jb0bDU6v04MTJj58QtvEHT3v5pshjOQ32szQ5XlVUAZb37m7yQnAhpawfZInDMZs0SCYzJkY8Vf
	POmsAL7E/ovCvrblIytB73wl2jismi88ryMHszO0vw635uI8BUCi7/bNVMtDgQpsJFg==
X-Received: by 2002:a25:a0ca:: with SMTP id i10mr26920962ybm.54.1550640090914;
        Tue, 19 Feb 2019 21:21:30 -0800 (PST)
X-Google-Smtp-Source: AHgI3IavUxNEOybqBhKlrh6fixZ58u9loEu64TQ1351Vvup4dzFjnVfBgHMgDt4Ookw7DYxHTuNS
X-Received: by 2002:a25:a0ca:: with SMTP id i10mr26920929ybm.54.1550640089891;
        Tue, 19 Feb 2019 21:21:29 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550640089; cv=none;
        d=google.com; s=arc-20160816;
        b=FDSEZfcsSEpX/YxIsVttHXHy3AEyQhuycrB8WLhzkh1x/5Q6IZvfmcj6qx1EBf/knC
         +jRjyBNEqxeHzI3jYWkVGwOUUZOgJj0s3AksfufC6U8Krw8MBhk2zhWJzENrj9mwXCVl
         xQP9y695EMb8blKzi/hkTzxQCuA+VRUPAzIoD5HjuQ9JNVmDsT73jHk9e/tW5/XG8q22
         L1wa7/in6XhOAPl2y2LQoW3B/0+OIlCXE+Ep70PqAc62lFsAUAh68+0Sh6cLk1kKHEHW
         z4tXFckP2fU7bHWWVPYj/KU/xVyQK/T7W5ntVFi5MkQ/6t8l0W6i6mwQJpIFrZk5lr1E
         Calw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:mime-version:references
         :in-reply-to:message-id:date:subject:cc:to:from;
        bh=pzmrlv9PbmCU4DKNJH5Ssu7mfhsm6VeIbRHKHMZn3X4=;
        b=klqVYNTCpKX0pRN5HxmPKt98W2FTzZ4IwKGChCRW0S8ifQ80TnzoXYthiXa1bsk1I7
         FJM0amVCb1JyaYV8u9IuB9pMhkJpdwUm1JyWN6nk96pyXgGe9jUKBOkDH79xAKhYMyE7
         eNJmb6U50HiRci7g6FIiUSJL3jKfWApmxtp9ALvnvBqc2vexOGSGWoJDCJyODfWBPywO
         KsARzIA9WmRBgK0D9gn0A318B1e5sl4EAI+wdKfmupVj/exYqZkCNGFo/pJAG3o0BWik
         p43F4v8yXJoyBZNu76sg4Prb5tVHSJW+Curvxt5YHg7q3ZGagGBonHmh6YS52IGplKDv
         +KNQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=YtO8Ipyy;
       spf=pass (google.com: domain of ziy@nvidia.com designates 216.228.121.143 as permitted sender) smtp.mailfrom=ziy@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate14.nvidia.com (hqemgate14.nvidia.com. [216.228.121.143])
        by mx.google.com with ESMTPS id 129si2029628ybz.286.2019.02.19.21.21.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Feb 2019 21:21:29 -0800 (PST)
Received-SPF: pass (google.com: domain of ziy@nvidia.com designates 216.228.121.143 as permitted sender) client-ip=216.228.121.143;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=YtO8Ipyy;
       spf=pass (google.com: domain of ziy@nvidia.com designates 216.228.121.143 as permitted sender) smtp.mailfrom=ziy@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate101.nvidia.com (Not Verified[216.228.121.13]) by hqemgate14.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5c6ce3e00000>; Tue, 19 Feb 2019 21:21:36 -0800
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate101.nvidia.com (PGP Universal service);
  Tue, 19 Feb 2019 21:21:28 -0800
X-PGP-Universal: processed;
	by hqpgpgate101.nvidia.com on Tue, 19 Feb 2019 21:21:28 -0800
Received: from [10.2.165.147] (10.124.1.5) by HQMAIL101.nvidia.com
 (172.20.187.10) with Microsoft SMTP Server (TLS) id 15.0.1395.4; Wed, 20 Feb
 2019 05:21:28 +0000
From: Zi Yan <ziy@nvidia.com>
To: Mike Kravetz <mike.kravetz@oracle.com>
CC: <linux-mm@kvack.org>, <linux-kernel@vger.kernel.org>, Dave Hansen
	<dave.hansen@linux.intel.com>, Michal Hocko <mhocko@kernel.org>, "Kirill A .
 Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton
	<akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman
	<mgorman@techsingularity.net>, John Hubbard <jhubbard@nvidia.com>, Mark
 Hairgrove <mhairgrove@nvidia.com>, Nitin Gupta <nigupta@nvidia.com>, David
 Nellans <dnellans@nvidia.com>
Subject: Re: [RFC PATCH 00/31] Generating physically contiguous memory after
 page allocation
Date: Tue, 19 Feb 2019 21:19:05 -0800
X-Mailer: MailMate (1.12.4r5594)
Message-ID: <EB22370B-C5FB-435A-A8D0-95159E403B83@nvidia.com>
In-Reply-To: <5395a183-063f-d409-b957-51a8d02854b2@oracle.com>
References: <20190215220856.29749-1-zi.yan@sent.com>
 <f4cf53a3-359b-8c66-ed15-112b3cf0f475@oracle.com>
 <FDDDB4C8-C5B5-46B0-9682-33AC063F7A46@nvidia.com>
 <5395a183-063f-d409-b957-51a8d02854b2@oracle.com>
MIME-Version: 1.0
X-Originating-IP: [10.124.1.5]
X-ClientProxiedBy: HQMAIL105.nvidia.com (172.20.187.12) To
 HQMAIL101.nvidia.com (172.20.187.10)
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: quoted-printable
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1550640096; bh=pzmrlv9PbmCU4DKNJH5Ssu7mfhsm6VeIbRHKHMZn3X4=;
	h=X-PGP-Universal:From:To:CC:Subject:Date:X-Mailer:Message-ID:
	 In-Reply-To:References:MIME-Version:X-Originating-IP:
	 X-ClientProxiedBy:Content-Type:Content-Transfer-Encoding;
	b=YtO8Ipyy+8NTyG2lzmvWUunuceEvwma2WSZKDDsfLOlzQBQ4bCiDUlu2qnHB5XtyE
	 9H2+GFzUW4sDlQkBDzuGQMfUxnHCPZI7v+T5x7CTDHRuqXJnq82qtW+r4swTdOjtEr
	 Xe45yFEJp06OXPj5tHOmqnpfMhfOtYvUFqm1TDt0irTvU6g+ixw3wmh5BqSZrJ4FJT
	 GfJa2Hy+CJ1ugwKUZJYAgAj4+VH8x248lZ/4tM4yw8rYzkySj8EEq5GqvhiTmXsabr
	 iPVtqMz4Ak2Foq9+o+99jp15LaWDeZvUioI3k1R8Qy40sYPjHDpUwQcO6DWuXFEQnb
	 Day+FiDQXvUyw==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 19 Feb 2019, at 19:18, Mike Kravetz wrote:

> On 2/19/19 6:33 PM, Zi Yan wrote:
>> On 19 Feb 2019, at 17:42, Mike Kravetz wrote:
>>
>>> On 2/15/19 2:08 PM, Zi Yan wrote:
>>>
>>> Thanks for working on this issue!
>>>
>>> I have not yet had a chance to take a look at the code.  However, I=20
>>> do have
>>> some general questions/comments on the approach.
>>
>> Thanks for replying. The code is very intrusive and has a lot of=20
>> hacks, so it is
>> OK for us to discuss the general idea first. :)
>>
>>
>>>> Patch structure
>>>> ----
>>>>
>>>> The patchset I developed to generate physically contiguous=20
>>>> memory/arbitrary
>>>> sized pages merely moves pages around. There are three components=20
>>>> in this
>>>> patchset:
>>>>
>>>> 1) a new page migration mechanism, called exchange pages, that=20
>>>> exchanges the
>>>> content of two in-use pages instead of performing two back-to-back=20
>>>> page
>>>> migration. It saves on overheads and avoids page reclaim and memory=20
>>>> compaction
>>>> in the page allocation path, although it is not strictly required=20
>>>> if enough
>>>> free memory is available in the system.
>>>>
>>>> 2) a new mechanism that utilizes both page migration and exchange=20
>>>> pages to
>>>> produce physically contiguous memory/arbitrary sized pages without=20
>>>> allocating
>>>> any new pages, unlike what khugepaged does. It works on per-VMA=20
>>>> basis, creating
>>>> physically contiguous memory out of each VMA, which is virtually=20
>>>> contiguous.
>>>> A simple range tree is used to ensure no two VMAs are overlapping=20
>>>> with each
>>>> other in the physical address space.
>>>
>>> This appears to be a new approach to generating contiguous areas. =20
>>> Previous
>>> attempts had relied on finding a contiguous area that can then be=20
>>> used for
>>> various purposes including user mappings.  Here, you take an=20
>>> existing mapping
>>> and make it contiguous.  [RFC PATCH 04/31] mm: add mem_defrag=20
>>> functionality
>>> talks about creating a (VPN, PFN) anchor pair for each vma and then=20
>>> using
>>> this pair as the base for creating a contiguous area.
>>>
>>> I'm curious, how 'fixed' is the anchor?  As you know, there could be=20
>>> a
>>> non-movable page in the PFN range.  As a result, you will not be=20
>>> able to
>>> create a contiguous area starting at that PFN.  In such a case, do=20
>>> we try
>>> another PFN?  I know this could result in much page shuffling.  I'm=20
>>> just
>>> trying to figure out how we satisfy a user who really wants a=20
>>> contiguous
>>> area.  Is there some method to keep trying?
>>
>> Good question. The anchor is determined on a per-VMA basis, which can=20
>> be changed
>> easily,
>> but in this patchiest, I used a very simple strategy =E2=80=94 making al=
l=20
>> VMAs not
>> overlapping
>> in the physical address space to get maximum overall contiguity and=20
>> not changing
>> anchors
>> even if non-moveable pages are encountered when generating physically=20
>> contiguous
>> pages.
>>
>> Basically, first VMA1 in the virtual address space has its anchor as
>> (VMA1_start_VPN, ZONE_start_PFN),
>> second VMA1 has its anchor as (VMA2_start_VPN, ZONE_start_PFN +=20
>> VMA1_size), and
>> so on.
>> This makes all VMA not overlapping in physical address space during=20
>> contiguous
>> memory
>> generation. When there is a non-moveable page, the anchor will not be=20
>> changed,
>> because
>> no matter whether we assign a new anchor or not, the contiguous pages=20
>> stops at
>> the non-moveable page. If we are trying to get a new anchor, more=20
>> effort is
>> needed to
>> avoid overlapping new anchor with existing contiguous pages. Any=20
>> overlapping will
>> nullify the existing contiguous pages.
>>
>> To satisfy a user who wants a contiguous area with N pages, the=20
>> minimal distance
>> between
>> any two non-moveable pages should be bigger than N pages in the=20
>> system memory.
>> Otherwise,
>> nothing would work. If there is such an area (PFN1, PFN1+N) in the=20
>> physical
>> address space,
>> you can set the anchor to (VPN_USER, PFN1) and use exchange_pages()=20
>> to generate
>> a contiguous
>> area with N pages. Instead, alloc_contig_pages(PFN1, PFN1+N, =E2=80=A6)=
=20
>> could also work,
>> but
>> only at page allocation time. It also requires the system has N free=20
>> pages when
>> alloc_contig_pages() are migrating the pages in (PFN1, PFN1+N) away,=20
>> or you need
>> to swap
>> pages to make the space.
>>
>> Let me know if this makes sense to you.
>>
>
> Yes, that is how I expected the implementation would work.  Thank you.
>
> Another high level question.  One of the benefits of this approach is
> that exchanging pages does not require N free pages as you describe
> above.  This assumes that the vma which we are trying to make=20
> contiguous
> is already populated.  If it is not populated, then you also need to
> have N free pages.  Correct?  If this is true, then is the expected=20
> use
> case to first populate a vma, and then try to make contiguous?  I=20
> would
> assume that if it is not populated and a request to make contiguous is
> given, we should try to allocate/populate the vma with contiguous=20
> pages
> at that time?

Yes, I assume the pages within the VMA are already populated but not=20
contiguous yet.

My approach considers memory contiguity as an on-demand resource. In=20
some phases
of an application, accelerators or RDMA controllers would=20
process/transfer data in one
or more VMAs, at which time contiguous memory can help reduce address=20
translation
overheads or lift certain constraints. And different VMAs could be=20
processed at
different program phases, thus it might be hard to get contiguous memory=20
for all
these VMAs at the allocation time using alloc_contig_pages(). My=20
approach can
help get contiguous memory later, when the demand comes.

For some cases, you definitely can use alloc_contig_pages() to give=20
users
a contiguous area at page allocation time, if you know the user is going=20
to use this
area for accelerator data processing or as a RDMA buffer and the area=20
size is fixed.

In addition, we can also use khugepaged approach, having a daemon=20
periodically
scan VMAs and use alloc_contig_pages() to convert non-contiguous pages=20
in a VMA
to contiguous pages, but it would require N free pages during the=20
conversion.

In sum, my approach complements alloc_contig_pages() and provides more=20
flexibility.
It is not trying to replaces alloc_contig_pages().


--
Best Regards,
Yan Zi

