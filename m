Return-Path: <SRS0=8949=Q3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5E277C43381
	for <linux-mm@archiver.kernel.org>; Wed, 20 Feb 2019 02:33:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D112221773
	for <linux-mm@archiver.kernel.org>; Wed, 20 Feb 2019 02:33:39 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="YeTT7dsq"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D112221773
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2FD458E0003; Tue, 19 Feb 2019 21:33:39 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2AAD08E0002; Tue, 19 Feb 2019 21:33:39 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 14D048E0003; Tue, 19 Feb 2019 21:33:39 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f70.google.com (mail-yw1-f70.google.com [209.85.161.70])
	by kanga.kvack.org (Postfix) with ESMTP id D84E88E0002
	for <linux-mm@kvack.org>; Tue, 19 Feb 2019 21:33:38 -0500 (EST)
Received: by mail-yw1-f70.google.com with SMTP id c67so14395365ywe.5
        for <linux-mm@kvack.org>; Tue, 19 Feb 2019 18:33:38 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding:dkim-signature;
        bh=l8yJ4E9Gd0N6lJ+NedKrddnw4p9+bSj8oBtj6wXakR4=;
        b=dzRjv449tYe+8ER/p9BtV7tCTyylU7wDmIth640mmZbvexCAsiD6p4GEu+G0AtNfeg
         ayUyuwY7jpEpQll5Up0wSYWzuIzFKYHDeqq+5kMX8XScp9lvxUFVt8LHYRQjI80S/yPl
         4VtO/vbAvMWjSS37+rK2jdrJCTbeRB/xkFYb5Q3CqU4yepVsH6YyXh29W2hGQweRgy94
         MoCA/TUXndb67wuP80Q86ik8D/JT5QVtDmQ+bt8lVj47IGMcywHTPbM8vP/N+2CW+5Ww
         NVzsLNoOOS90Mii0BJ9IGoP6H9B8tGNQwvfrActkLqe2eyeC6LFq8QgHw2EG4Aw6GIWb
         8gvg==
X-Gm-Message-State: AHQUAuZ7jScz+uPX4rphDvJVDY/Z6ReBdhR6Pi7/llaFC7aLZA//d3DJ
	Qbtfyqb2Pi8r5jvl63pWYgfMFHO6FmMWcvnWY3uQwsGodieYVLWdpA4W0V9lyjZQMW9YxBZ5eci
	SYM3LVJNQCklPdXYgGyDORW5pLlqdkN8RICP4DT1JYIbCU6L9Qw4OAIquKWFYzi98yA==
X-Received: by 2002:a0d:cc89:: with SMTP id o131mr26351121ywd.144.1550630018526;
        Tue, 19 Feb 2019 18:33:38 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYx6X7FdFyZdMCwmpWyj9sVppC+71N93yV3hvxNqyd3gnRTvLMnbe7olKcoqHnMnF9rzPTl
X-Received: by 2002:a0d:cc89:: with SMTP id o131mr26351071ywd.144.1550630017645;
        Tue, 19 Feb 2019 18:33:37 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550630017; cv=none;
        d=google.com; s=arc-20160816;
        b=Xke02/qLOoDbNTgOBfK/qFOgcvHYFjdQpL0xOAWtEdSD0lLAKzH3+PmlxtUI6zhTIM
         CofVvOGtVZR4wIr45UvbWGk1yH2FBirWJH2XkhYEa1uSywJxvdi3M0OUExKy7iPRNzKr
         9LNNFKwHysgLtwoVCWdcT3uEun8u1YLp50kMeTkhyOC9AazW+9DXKdSj2it8Nw3GSQ3v
         2SEk7u37WdDpc4E5pGj/LtQ7cUv8TVcqEdFhDGmj+TTDUBijGJiggw4SPSO3FKbiTDzj
         em5vOgSxeAtGF9PiT+jrwu/pjj2f6MFtGYiBRG3MKZeiHzl+MA03QwqnfZhTv4iwtaT0
         5jGw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:mime-version:references
         :in-reply-to:message-id:date:subject:cc:to:from;
        bh=l8yJ4E9Gd0N6lJ+NedKrddnw4p9+bSj8oBtj6wXakR4=;
        b=vRc/IZ9T7WJ4jyNPxowNmA24yTl0zgGh9EJeX4wymWWKf+cYXoBQQm8mw3MPgl7kDg
         T6a0mayBqbsqW+lsShPLwb+jv840z9FT3dxVE9sjk/n+zjVQziwk3iwxLaHf6USmdrci
         m20wx1jw+O7NSlCnVIxOBFe5v/zA/IS2GaVsh3FtUH4nTOI+I9WqGkN9tgRWQoiG4R9M
         iniFKPhJ9krTCwb8Duhhzx5hxW8v69knO4cfabV1wVFg8U+27CcuYUJwOoeLqBxObDq5
         ICJJc53nXJI23ATaG3zA6rnPKXPa+tYuPXJSpkbIOrOQfwm8WHbskcOAjXrvDmjKrGyt
         1kmg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=YeTT7dsq;
       spf=pass (google.com: domain of ziy@nvidia.com designates 216.228.121.65 as permitted sender) smtp.mailfrom=ziy@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate16.nvidia.com (hqemgate16.nvidia.com. [216.228.121.65])
        by mx.google.com with ESMTPS id c184si10579767ywd.212.2019.02.19.18.33.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Feb 2019 18:33:37 -0800 (PST)
Received-SPF: pass (google.com: domain of ziy@nvidia.com designates 216.228.121.65 as permitted sender) client-ip=216.228.121.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=YeTT7dsq;
       spf=pass (google.com: domain of ziy@nvidia.com designates 216.228.121.65 as permitted sender) smtp.mailfrom=ziy@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate101.nvidia.com (Not Verified[216.228.121.13]) by hqemgate16.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5c6cbc860000>; Tue, 19 Feb 2019 18:33:42 -0800
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate101.nvidia.com (PGP Universal service);
  Tue, 19 Feb 2019 18:33:36 -0800
X-PGP-Universal: processed;
	by hqpgpgate101.nvidia.com on Tue, 19 Feb 2019 18:33:36 -0800
Received: from [10.2.173.71] (172.20.13.39) by HQMAIL101.nvidia.com
 (172.20.187.10) with Microsoft SMTP Server (TLS) id 15.0.1395.4; Wed, 20 Feb
 2019 02:33:35 +0000
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
Date: Tue, 19 Feb 2019 18:33:35 -0800
X-Mailer: MailMate (1.12.4r5594)
Message-ID: <FDDDB4C8-C5B5-46B0-9682-33AC063F7A46@nvidia.com>
In-Reply-To: <f4cf53a3-359b-8c66-ed15-112b3cf0f475@oracle.com>
References: <20190215220856.29749-1-zi.yan@sent.com>
 <f4cf53a3-359b-8c66-ed15-112b3cf0f475@oracle.com>
MIME-Version: 1.0
X-Originating-IP: [172.20.13.39]
X-ClientProxiedBy: HQMAIL103.nvidia.com (172.20.187.11) To
 HQMAIL101.nvidia.com (172.20.187.10)
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: quoted-printable
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1550630022; bh=l8yJ4E9Gd0N6lJ+NedKrddnw4p9+bSj8oBtj6wXakR4=;
	h=X-PGP-Universal:From:To:CC:Subject:Date:X-Mailer:Message-ID:
	 In-Reply-To:References:MIME-Version:X-Originating-IP:
	 X-ClientProxiedBy:Content-Type:Content-Transfer-Encoding;
	b=YeTT7dsqrxdOlG7U3ElpvLQar1W0yp4b0LPVU3EaXdmcu56b8WJocffDvHBE85mhg
	 ADcEfFHLjTk7d69jU3S/tFDWmyfrfNWlMilYKwHv+CEINY0Jgn8ThNt2r7qV0UwmfM
	 nxqtIJFI66ZPOUFr5S2n6eAogaLSgTztRmecHD2dHEo73OiAhzq8dGLSe6KRiT2sWs
	 stlIpRJzpu15unEUOKkcXoByd/dfTKJv7I3dHzelhJXHoxZ6a7mxHT1zwlJxz6g98u
	 TFewHzbeS0JSTLZ+OypZ1NVVEjqdPvYiHWGM8V0q2GGLnPNN9k9mw2NVTz1NwsjFwg
	 I56qbsJ0xCSkA==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 19 Feb 2019, at 17:42, Mike Kravetz wrote:

> On 2/15/19 2:08 PM, Zi Yan wrote:
>
> Thanks for working on this issue!
>
> I have not yet had a chance to take a look at the code.  However, I do=20
> have
> some general questions/comments on the approach.

Thanks for replying. The code is very intrusive and has a lot of hacks,=20
so it is
OK for us to discuss the general idea first. :)


>> Patch structure
>> ----
>>
>> The patchset I developed to generate physically contiguous=20
>> memory/arbitrary
>> sized pages merely moves pages around. There are three components in=20
>> this
>> patchset:
>>
>> 1) a new page migration mechanism, called exchange pages, that=20
>> exchanges the
>> content of two in-use pages instead of performing two back-to-back=20
>> page
>> migration. It saves on overheads and avoids page reclaim and memory=20
>> compaction
>> in the page allocation path, although it is not strictly required if=20
>> enough
>> free memory is available in the system.
>>
>> 2) a new mechanism that utilizes both page migration and exchange=20
>> pages to
>> produce physically contiguous memory/arbitrary sized pages without=20
>> allocating
>> any new pages, unlike what khugepaged does. It works on per-VMA=20
>> basis, creating
>> physically contiguous memory out of each VMA, which is virtually=20
>> contiguous.
>> A simple range tree is used to ensure no two VMAs are overlapping=20
>> with each
>> other in the physical address space.
>
> This appears to be a new approach to generating contiguous areas. =20
> Previous
> attempts had relied on finding a contiguous area that can then be used=20
> for
> various purposes including user mappings.  Here, you take an existing=20
> mapping
> and make it contiguous.  [RFC PATCH 04/31] mm: add mem_defrag=20
> functionality
> talks about creating a (VPN, PFN) anchor pair for each vma and then=20
> using
> this pair as the base for creating a contiguous area.
>
> I'm curious, how 'fixed' is the anchor?  As you know, there could be a
> non-movable page in the PFN range.  As a result, you will not be able=20
> to
> create a contiguous area starting at that PFN.  In such a case, do we=20
> try
> another PFN?  I know this could result in much page shuffling.  I'm=20
> just
> trying to figure out how we satisfy a user who really wants a=20
> contiguous
> area.  Is there some method to keep trying?

Good question. The anchor is determined on a per-VMA basis, which can be=20
changed easily,
but in this patchiest, I used a very simple strategy =E2=80=94 making all V=
MAs=20
not overlapping
in the physical address space to get maximum overall contiguity and not=20
changing anchors
even if non-moveable pages are encountered when generating physically=20
contiguous pages.

Basically, first VMA1 in the virtual address space has its anchor as=20
(VMA1_start_VPN, ZONE_start_PFN),
second VMA1 has its anchor as (VMA2_start_VPN, ZONE_start_PFN +=20
VMA1_size), and so on.
This makes all VMA not overlapping in physical address space during=20
contiguous memory
generation. When there is a non-moveable page, the anchor will not be=20
changed, because
no matter whether we assign a new anchor or not, the contiguous pages=20
stops at
the non-moveable page. If we are trying to get a new anchor, more effort=20
is needed to
avoid overlapping new anchor with existing contiguous pages. Any=20
overlapping will
nullify the existing contiguous pages.

To satisfy a user who wants a contiguous area with N pages, the minimal=20
distance between
any two non-moveable pages should be bigger than N pages in the system=20
memory. Otherwise,
nothing would work. If there is such an area (PFN1, PFN1+N) in the=20
physical address space,
you can set the anchor to (VPN_USER, PFN1) and use exchange_pages() to=20
generate a contiguous
area with N pages. Instead, alloc_contig_pages(PFN1, PFN1+N, =E2=80=A6) cou=
ld=20
also work, but
only at page allocation time. It also requires the system has N free=20
pages when
alloc_contig_pages() are migrating the pages in (PFN1, PFN1+N) away, or=20
you need to swap
pages to make the space.

Let me know if this makes sense to you.

--
Best Regards,
Yan Zi

