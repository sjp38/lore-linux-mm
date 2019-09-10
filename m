Return-Path: <SRS0=JR82=XF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 168D7C49ED6
	for <linux-mm@archiver.kernel.org>; Tue, 10 Sep 2019 09:21:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9D6B22084D
	for <linux-mm@archiver.kernel.org>; Tue, 10 Sep 2019 09:21:18 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="jKloMCTV"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9D6B22084D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 23CC46B0007; Tue, 10 Sep 2019 05:21:18 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1ED736B0008; Tue, 10 Sep 2019 05:21:18 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0DCFC6B000C; Tue, 10 Sep 2019 05:21:18 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0219.hostedemail.com [216.40.44.219])
	by kanga.kvack.org (Postfix) with ESMTP id E014C6B0007
	for <linux-mm@kvack.org>; Tue, 10 Sep 2019 05:21:17 -0400 (EDT)
Received: from smtpin03.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id A24D18243768
	for <linux-mm@kvack.org>; Tue, 10 Sep 2019 09:21:17 +0000 (UTC)
X-FDA: 75918467394.03.desk67_28483d2095b3d
X-HE-Tag: desk67_28483d2095b3d
X-Filterd-Recvd-Size: 7174
Received: from mail-ot1-f66.google.com (mail-ot1-f66.google.com [209.85.210.66])
	by imf28.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 10 Sep 2019 09:21:16 +0000 (UTC)
Received: by mail-ot1-f66.google.com with SMTP id z26so8168473oto.1
        for <linux-mm@kvack.org>; Tue, 10 Sep 2019 02:21:16 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=V15g9krwElh5s7ubtVRB+OPlWr+bh/CCGHQMHIst0mg=;
        b=jKloMCTV2Hfo5rjrHrNVD5uu9OsubyMBqmOMrtzEZfjnQOlY84UlHGoemFPHuW0Uvc
         Xy8b6X22PTLv00Eoe1bUrISeP6U+hNgOdhVko6Pd80qoqp3DWIuYIetNoD/UWMAyMU+/
         oYgPh3vLlik4dolpS7iRuxLN2Aim0L7oI/ICaabvCPp/8keooUr7tdfAhVB1FGEWv+Xs
         x5yZcXi9qc6v6wZbKmXk5zgODl31w260Ghz1lF17cmDNkcoJ03wwGNKdvsuMgpFA+R0Q
         WVA8+7eLnANoehlKlA6eX83Ks+RTA02g5nvaXLf+xRw0z0PvS/qBb/OsZUgadEH7uoyr
         TTcg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=V15g9krwElh5s7ubtVRB+OPlWr+bh/CCGHQMHIst0mg=;
        b=JtH/vW3E/v6Cr4LU8akJXjrBt5ezx6nUuBlwvmlaaCmPanFr74PeyJ5KeQgUJPeUno
         RUYPtEWNjtqbrT9Pp/11WJ8xcdEFGXzcVcylGSe5wjt/FWcQksE5gIph4ro9JD7b+EcJ
         8iqDCtMSpjW9qYGdG7KtLUTX8M07SzMLULgNgRPPxPto+x8wL+ngre7q83IKFo2pfaRz
         5k6JJEtsExJwR4rqPma593+inDdo56+cXFi48LrHZ3RXBRbi/yyfUb/EUZdJpwqlyOa0
         NBSSzWdBGBj1d2pqfYJGMxrK2LNb4rFPlHIr+8EvxWAYQfBnGGhZi7rAHkH36pRfYcbf
         UQNw==
X-Gm-Message-State: APjAAAVGS0tngro4uE90DKS29uSA1HXQPl3eGhQHtHW47S6wUDUk3ALN
	f33rRC+6yb6avOvQwI4FohtgrAHqYPLoIFT3+S8WiA==
X-Google-Smtp-Source: APXvYqy2s1HOVT5KWkC7vc1cJBH9IgMcXfX2UD8wgbY4zwDCPPr5Lsujug0iHzMmDGj5UqgT8qeL3ITtDPK3I3GKhmI=
X-Received: by 2002:a9d:2642:: with SMTP id a60mr23742841otb.247.1568107275846;
 Tue, 10 Sep 2019 02:21:15 -0700 (PDT)
MIME-Version: 1.0
References: <20190906081027.15477-1-t-fukasawa@vx.jp.nec.com>
 <b7732a55-4a10-2c1d-c2f5-ca38ee60964d@redhat.com> <e762ee45-43e3-975a-ad19-065f07d1440f@vx.jp.nec.com>
 <40a1ce2e-1384-b869-97d0-7195b5b47de0@redhat.com> <6a99e003-e1ab-b9e8-7b25-bc5605ab0eb2@vx.jp.nec.com>
 <e4e54258-e83b-cf0b-b66e-9874be6b5122@redhat.com> <f9b10653-949b-64a6-6539-a32bd980edb9@redhat.com>
 <CAPcyv4gA4mcDEPeCFokn_jy5gX62cK0U40EzL7M8c0iDO7U7bg@mail.gmail.com> <c6198acd-8ff7-c40c-cb4e-f0f12f841b38@redhat.com>
In-Reply-To: <c6198acd-8ff7-c40c-cb4e-f0f12f841b38@redhat.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Tue, 10 Sep 2019 02:21:04 -0700
Message-ID: <CAPcyv4ioWGySF36Urzza7RrRBiP=-ivBmnt0YJF=jOPVAXZEnw@mail.gmail.com>
Subject: Re: [RFC PATCH v2] mm: initialize struct pages reserved by
 ZONE_DEVICE driver.
To: David Hildenbrand <david@redhat.com>
Cc: Toshiki Fukasawa <t-fukasawa@vx.jp.nec.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, 
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, 
	"akpm@linux-foundation.org" <akpm@linux-foundation.org>, "mhocko@kernel.org" <mhocko@kernel.org>, 
	"adobriyan@gmail.com" <adobriyan@gmail.com>, "hch@lst.de" <hch@lst.de>, 
	"longman@redhat.com" <longman@redhat.com>, "sfr@canb.auug.org.au" <sfr@canb.auug.org.au>, 
	"mst@redhat.com" <mst@redhat.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, 
	Junichi Nomura <j-nomura@ce.jp.nec.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Sep 9, 2019 at 5:06 AM David Hildenbrand <david@redhat.com> wrote:
>
> On 09.09.19 13:53, Dan Williams wrote:
> > On Mon, Sep 9, 2019 at 1:11 AM David Hildenbrand <david@redhat.com> wrote:
> > [..]
> >>>> It seems that SECTION_IS_ONLINE and SECTION_MARKED_PRESENT can be used to
> >>>> distinguish uninitialized struct pages if we can apply them to ZONE_DEVICE,
> >>>> but that is no longer necessary with this approach.
> >>>
> >>> Let's take a step back here to understand the issues I am aware of. I
> >>> think we should solve this for good now:
> >>>
> >>> A PFN walker takes a look at a random PFN at a random point in time. It
> >>> finds a PFN with SECTION_MARKED_PRESENT && !SECTION_IS_ONLINE. The
> >>> options are:
> >>>
> >>> 1. It is buddy memory (add_memory()) that has not been online yet. The
> >>> memmap contains garbage. Don't access.
> >>>
> >>> 2. It is ZONE_DEVICE memory with a valid memmap. Access it.
> >>>
> >>> 3. It is ZONE_DEVICE memory with an invalid memmap, because the section
> >>> is only partially present: E.g., device starts at offset 64MB within a
> >>> section or the device ends at offset 64MB within a section. Don't access it.
> >>>
> >>> 4. It is ZONE_DEVICE memory with an invalid memmap, because the memmap
> >>> was not initialized yet. memmap_init_zone_device() did not yet succeed
> >>> after dropping the mem_hotplug lock in mm/memremap.c. Don't access it.
> >>>
> >>> 5. It is reserved ZONE_DEVICE memory ("pages mapped, but reserved for
> >>> driver") with an invalid memmap. Don't access it.
> >>>
> >>> I can see that your patch tries to make #5 vanish by initializing the
> >>> memmap, fair enough. #3 and #4 can't be detected. The PFN walker could
> >>> still stumble over uninitialized memmaps.
> >>>
> >>
> >> FWIW, I thinkg having something like pfn_zone_device(), similarly
> >> implemented like pfn_zone_device_reserved() could be one solution to
> >> most issues.
> >
> > I've been thinking of a replacement for PTE_DEVMAP with section-level,
> > or sub-section level flags. The section-level flag would still require
> > a call to get_dev_pagemap() to validate that the pfn is not section in
> > the subsection case which seems to be entirely too much overhead. If
> > ZONE_DEVICE is to be a first class citizen in pfn walkers I think it
> > would be worth the cost to double the size of subsection_map and to
> > identify whether a sub-section is ZONE_DEVICE, or not.
> >
> > Thoughts?
> >
>
> I thought about this last week and came up with something like
>
> 1. Convert SECTION_IS_ONLINE to SECTION IS_ACTIVE
>
> 2. Make pfn_to_online_page() also check that it's not ZONE_DEVICE.
> Online pfns are limited to !ZONE_DEVICE.
>
> 3. Extend subsection_map to an additional active_map
>
> 4. Set SECTION IS_ACTIVE *iff* the whole active_map is set. This keeps
> most accesses of pfn_to_online_page() fast. If !SECTION IS_ACTIVE, check
> the active_map.
>
> 5. Set sub-sections active/unactive in
> move_pfn_range_to_zone()/remove_pfn_range_from_zone() - see "[PATCH v4
> 0/8] mm/memory_hotplug: Shrink zones before removing memory" for the
> latter.
>
> 6. Set boot memory properly active (this is a tricky bit :/ ).
>
> However, it turned out too complex for my taste (and limited time to
> spend on this), so I abandoned that idea for now. If somebody wants to
> pick that up, fine.
>

That seems to solve the pfn walk case but it would not address the
need for PTE_DEVMAP or speed up the other places that want an
efficient way to determine if it's worthwhile to call
get_dev_pagemap().

