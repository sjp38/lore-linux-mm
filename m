Return-Path: <SRS0=cVar=VV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F12A2C7618F
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 20:12:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A573A20665
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 20:12:06 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="nMkbt/qr"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A573A20665
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3DBA26B0005; Wed, 24 Jul 2019 16:12:06 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 38BDA6B0006; Wed, 24 Jul 2019 16:12:06 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 254E98E0002; Wed, 24 Jul 2019 16:12:06 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f69.google.com (mail-ot1-f69.google.com [209.85.210.69])
	by kanga.kvack.org (Postfix) with ESMTP id F12436B0005
	for <linux-mm@kvack.org>; Wed, 24 Jul 2019 16:12:05 -0400 (EDT)
Received: by mail-ot1-f69.google.com with SMTP id x18so26226076otp.9
        for <linux-mm@kvack.org>; Wed, 24 Jul 2019 13:12:05 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=+PNL04KYvInZXteiwuvvVomp7psYL1Kl+T8ycx6EmRk=;
        b=pcxvxiq5xvdpbwxPniEy4ASPNsk68sMGCJD9NASL27XybBYk3+4DpeRmeifxTSsPzZ
         pqBbu3od+kSdjNKBVOcnIHPESFvTaDD/S8uFtC5y1hOlYE3Y1Cg81493xIXdaWw15tDF
         ANtC0JtM0s7evO8o1bksTiVxYdbLW8AHKeGOX/1Bt/e4ZglkJz51eC0Q5jOVGWNZjpyT
         Ai7QvphczDmoSLskZ/EEe+sBR3T0Yx0WQNRDF3ZEroTDjLz7K4oqRsOnExAgXeR11zsA
         XIRT421qiripsRcGOi3hTsVi3cN5PyZt0wDEnaXWaNYZgqMhJzvj0gbg01ScQFvVf6LU
         s38g==
X-Gm-Message-State: APjAAAU5JGhgvmrNj94t6vbAllq9mtdcVJ7FLDdDCE77vffZglLFEDci
	lOlAdvUYP8xkkC8bQcs6VPmq/3ZRQN56q49u1K6aVhYy09pPZ9Fs/jhy1Ji9hMH5K4oaEw5+a6c
	4/kl+JmvulHHIhKY1Uee6J2gP1KpuN0eLW5zPWVSYo66vrxFn3/TSSQJI0K2i+Hkywg==
X-Received: by 2002:a9d:6a92:: with SMTP id l18mr59634006otq.294.1563999125581;
        Wed, 24 Jul 2019 13:12:05 -0700 (PDT)
X-Received: by 2002:a9d:6a92:: with SMTP id l18mr59633973otq.294.1563999124971;
        Wed, 24 Jul 2019 13:12:04 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563999124; cv=none;
        d=google.com; s=arc-20160816;
        b=HgLKY4KnUguKuX4l5usFT3D0UhJ2VUJ+KSdztQVytRiowfTFvsFr+6SUKpxeIVX7Bo
         WYoogqx0p8Dw7BWDVbD2//IKWVbETVE9pkkZkdyOOE+3S8+OUncA7z0oQ6fe4b/xa8Xt
         DkexoIzDiwWaN3btyPH/wVTPgcqYnCy1GuRTEILE5Ph5R2uRsRZ7g7Yb9hleu5+dc6R2
         xHMqE6pBqWNV2EcEtgb80ZVffXVZ9UA5vkXSVPReiYNgmZqcrTKr+bdUqwLvhjtGxTC9
         Wm1ph3atV6m0+RLvT0cxwsJrM2nVW0c/mm7WelUmG2Z4AjN41FAOZhhNLcW3x5vDzsJr
         rJQg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=+PNL04KYvInZXteiwuvvVomp7psYL1Kl+T8ycx6EmRk=;
        b=uH5x08/fZ01WTAys7KwHb8T/wVLhm5b0z6ivmJH0jfuXc0rxpmMpqcaqz2q9Vz+V/W
         eURf/TLIpXVnu7eYRqtVdTtzKYlrsLtB7V/mpzaKYXi8aT/NvtZgWLmjONy4O10IdgoK
         HMBchpSzQ+ftffhw2JNX7lUWI0ulAMYkikIQw6G27kNccTVPCOgVHBoRHyWrrHpsXD3z
         cpZuoXENA0cRmDJWERHT/ymnupBHEVJpe050+7bt7BEM4jDf2yWqpLxLfLyxo30Ki7R3
         IxLjF6rTMPkHhHPz63JtaYovOE2lPr4GSlaqJISN8eW+CxGWIBpjvWUcqZM3qMXW6uvs
         JoWA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b="nMkbt/qr";
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l1sor23967041otk.47.2019.07.24.13.12.04
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 24 Jul 2019 13:12:04 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b="nMkbt/qr";
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=+PNL04KYvInZXteiwuvvVomp7psYL1Kl+T8ycx6EmRk=;
        b=nMkbt/qriVy9O40AoW5FYNfDVr8RyGGaYJ40joGq40jdmhquOlREtNDZ/xeGpk9EHD
         gXIrt4W1XVVNC6/Rd2cAvNqLFpGVzBldC5FrJdtpyV4dVO8ZxSE8mfwUvBpjKm1jzl17
         krrSZj+MzqvjS3VrNAzKy8wM81/5FUxqLeDnL3zJG6EW31/OdglL16Ms8Uggn9Qz2FUQ
         y4aYlFANRwJZE2ZsU9dZEqXS7iUWtbd/J+qYJcO23brfsDmTeNV2Rw9ByujWw5xbW40z
         0ldixykjhsbNKz/35tArF46weN+pr4TRfpajnHEBiwS7hXFUaIYfGGIyG3ZPouMGNZhX
         vamQ==
X-Google-Smtp-Source: APXvYqyVnJ52FSRiRxNb5fXzbbBT2vQjm4rcB9LwDsWmIAgcWVuBgRfFtQALre7fkjgKI2r2zo6w17KkSkKZppNPmvs=
X-Received: by 2002:a9d:7b48:: with SMTP id f8mr36294684oto.207.1563999124513;
 Wed, 24 Jul 2019 13:12:04 -0700 (PDT)
MIME-Version: 1.0
References: <20190625075227.15193-1-osalvador@suse.de> <20190625075227.15193-3-osalvador@suse.de>
In-Reply-To: <20190625075227.15193-3-osalvador@suse.de>
From: Dan Williams <dan.j.williams@intel.com>
Date: Wed, 24 Jul 2019 13:11:52 -0700
Message-ID: <CAPcyv4hvu+wp4tJJNW70jp2G_rNabyvzGMvDTS3PzkDCAFztYg@mail.gmail.com>
Subject: Re: [PATCH v2 2/5] mm,memory_hotplug: Introduce MHP_VMEMMAP_FLAGS
To: Oscar Salvador <osalvador@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, 
	Pavel Tatashin <pasha.tatashin@soleen.com>, Jonathan Cameron <Jonathan.Cameron@huawei.com>, 
	David Hildenbrand <david@redhat.com>, Anshuman Khandual <anshuman.khandual@arm.com>, 
	Vlastimil Babka <vbabka@suse.cz>, Linux MM <linux-mm@kvack.org>, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jun 25, 2019 at 12:53 AM Oscar Salvador <osalvador@suse.de> wrote:
>
> This patch introduces MHP_MEMMAP_DEVICE and MHP_MEMMAP_MEMBLOCK flags,
> and prepares the callers that add memory to take a "flags" parameter.
> This "flags" parameter will be evaluated later on in Patch#3
> to init mhp_restrictions struct.
>
> The callers are:
>
> add_memory
> __add_memory
> add_memory_resource
>
> Unfortunately, we do not have a single entry point to add memory, as depending
> on the requisites of the caller, they want to hook up in different places,
> (e.g: Xen reserve_additional_memory()), so we have to spread the parameter
> in the three callers.
>
> The flags are either MHP_MEMMAP_DEVICE or MHP_MEMMAP_MEMBLOCK, and only differ
> in the way they allocate vmemmap pages within the memory blocks.
>
> MHP_MEMMAP_MEMBLOCK:
>         - With this flag, we will allocate vmemmap pages in each memory block.
>           This means that if we hot-add a range that spans multiple memory blocks,
>           we will use the beginning of each memory block for the vmemmap pages.
>           This strategy is good for cases where the caller wants the flexiblity
>           to hot-remove memory in a different granularity than when it was added.
>
>           E.g:
>                 We allocate a range (x,y], that spans 3 memory blocks, and given
>                 memory block size = 128MB.
>                 [memblock#0  ]
>                 [0 - 511 pfns      ] - vmemmaps for section#0
>                 [512 - 32767 pfns  ] - normal memory
>
>                 [memblock#1 ]
>                 [32768 - 33279 pfns] - vmemmaps for section#1
>                 [33280 - 65535 pfns] - normal memory
>
>                 [memblock#2 ]
>                 [65536 - 66047 pfns] - vmemmap for section#2
>                 [66048 - 98304 pfns] - normal memory
>
> MHP_MEMMAP_DEVICE:
>         - With this flag, we will store all vmemmap pages at the beginning of
>           hot-added memory.
>
>           E.g:
>                 We allocate a range (x,y], that spans 3 memory blocks, and given
>                 memory block size = 128MB.
>                 [memblock #0 ]
>                 [0 - 1533 pfns    ] - vmemmap for section#{0-2}
>                 [1534 - 98304 pfns] - normal memory
>
> When using larger memory blocks (1GB or 2GB), the principle is the same.
>
> Of course, MHP_MEMMAP_DEVICE is nicer when it comes to have a large contigous
> area, while MHP_MEMMAP_MEMBLOCK allows us to have flexibility when removing the
> memory.

Concept and patch looks good to me, but I don't quite like the
proliferation of the _DEVICE naming, in theory it need not necessarily
be ZONE_DEVICE that is the only user of that flag. I also think it
might be useful to assign a flag for the default 'allocate from RAM'
case, just so the code is explicit. So, how about:

MHP_MEMMAP_PAGE_ALLOC
MHP_MEMMAP_MEMBLOCK
MHP_MEMMAP_RESERVED

...for the 3 cases?

Other than that, feel free to add:

Reviewed-by: Dan Williams <dan.j.williams@intel.com>

