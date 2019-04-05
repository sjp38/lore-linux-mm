Return-Path: <SRS0=BJvi=SH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 66471C282DA
	for <linux-mm@archiver.kernel.org>; Fri,  5 Apr 2019 16:24:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1FB4320700
	for <linux-mm@archiver.kernel.org>; Fri,  5 Apr 2019 16:24:04 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1FB4320700
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=huawei.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AFE0F6B0008; Fri,  5 Apr 2019 12:24:03 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AAE1B6B000C; Fri,  5 Apr 2019 12:24:03 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 99DD06B000D; Fri,  5 Apr 2019 12:24:03 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f71.google.com (mail-ot1-f71.google.com [209.85.210.71])
	by kanga.kvack.org (Postfix) with ESMTP id 67F906B0008
	for <linux-mm@kvack.org>; Fri,  5 Apr 2019 12:24:03 -0400 (EDT)
Received: by mail-ot1-f71.google.com with SMTP id 70so3267918otn.15
        for <linux-mm@kvack.org>; Fri, 05 Apr 2019 09:24:03 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:in-reply-to:references:organization
         :mime-version:content-transfer-encoding;
        bh=/RqIw29E0czGIt1841+Dfl3vym7fqjjfoyPJmpGE5Hw=;
        b=ZB6L3xd2l2A+MbSWsGLyPS5+/UFYH7FZR+YVuQziAmlNUW/TmjCQBn2qvy3hC64CuE
         T5t2mynr8najac4Iac076rruTs3jbKNljSUfxiH7BdyW/b6m6lQVuRnHrD2HwPXp4yQK
         qG9bVMIfq3t+q0l2tmOx6+4apcGjJmzWVJAwK7oaAnYv8EaQqfMaU/0MFkm6bhMH/8w/
         Lu/gPB9Et07i4FEXSAds5WKgCmEjoYP9sxArb6eA1YI+GT7gTJz9IQbP/BQT2J7Opfdv
         ZTVnw0GOMxqSPdURvr2aih7xVWnVb2wz42UlNwmGrDwFtEiG7sPZtarIXWIvc6PRsYCL
         kxxg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jonathan.cameron@huawei.com designates 45.249.212.35 as permitted sender) smtp.mailfrom=jonathan.cameron@huawei.com
X-Gm-Message-State: APjAAAWRruBTClWfLAFs3VyCjnwRtW7085uubwSc6ymEhEKl5j2sk9gQ
	1uMLOJAN7LP+TD/5U7tKG7zKApJFWhyTDU4vzp+cD2vRv/dXUEoDkAblrUBAx0M1Qlqm+cTO4st
	5USjs3QL62YhSRAA/mD2Na6ZXZzKEfeZ9sP4XXNlKu/Sy4NAUPIiEjLQ0x2l1gjPyEQ==
X-Received: by 2002:a9d:57c4:: with SMTP id q4mr8862837oti.151.1554481443052;
        Fri, 05 Apr 2019 09:24:03 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwD1Xmij9f+fALUNW5lK6g8Fp4i0Tz+lU38HkPrGM06Ttbgbw8+AwVDz8VQGUdn79cbtr9+
X-Received: by 2002:a9d:57c4:: with SMTP id q4mr8862779oti.151.1554481442145;
        Fri, 05 Apr 2019 09:24:02 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554481442; cv=none;
        d=google.com; s=arc-20160816;
        b=DnKtK9ApcHqfbP06ci2PelcYjj192DZEqgxLgv2GUlBXvMKz2aJI3EYmnR4quCQIiz
         A4MFPPTmN6fd9Z7RXsx6ioaPXjrZa/GIFpv44kTgNietYS/uEta+k0H+HKTJwes94F48
         sT5izz/DuFStp5f/E64b4hlpxZTIpsVL2RLrB9HdGYwm3GSxzVdY/Iqn3VsDOQDNqSWV
         iIJptkemSnwgA1fTeUxW7UvDCW7dK9EkEB10g6RRou8V8ih1t7Mc66RJA+0Ka9CG4zEy
         BIv7xWLl/SXErkN+sFHJru214mhuzLYqeaz65z4yYlRd0De6ZU1ySN2Upq37riRoruXu
         YH8Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:organization:references
         :in-reply-to:message-id:subject:cc:to:from:date;
        bh=/RqIw29E0czGIt1841+Dfl3vym7fqjjfoyPJmpGE5Hw=;
        b=h59X9t2/veX/4T5z5yxI3CDhcv/lxaQmgMfEES4p/CkK6A3tqeZ9Q3xhCZ5hISw4sb
         oAzXBU780/ebY+tes4Vwnuhmsn/eE2lGfqe1O6fHlRJDdKcocMzuupznyD1czgdGg3rH
         xerXn0BS/YYIXiYHG4Oy8LzTb7s36LtBqFUZNPu3zYa+Q/zZ7U3BF+EVhEqy6stlSDbz
         MiSpmBsXy9RKvPYdDtyQ8LFd6RYgom3/hgHaQt5DDuR7Gz5F9BxCO6Jlld7KcPo5whYY
         Lv5gCK80ut6cEERan6zax8TV2ZDIa0R+nyd9qktXaBARsVVktkzPJPg5Dny21n/VpYcG
         eENA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jonathan.cameron@huawei.com designates 45.249.212.35 as permitted sender) smtp.mailfrom=jonathan.cameron@huawei.com
Received: from huawei.com (szxga07-in.huawei.com. [45.249.212.35])
        by mx.google.com with ESMTPS id o64si9723381oig.100.2019.04.05.09.24.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 05 Apr 2019 09:24:02 -0700 (PDT)
Received-SPF: pass (google.com: domain of jonathan.cameron@huawei.com designates 45.249.212.35 as permitted sender) client-ip=45.249.212.35;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jonathan.cameron@huawei.com designates 45.249.212.35 as permitted sender) smtp.mailfrom=jonathan.cameron@huawei.com
Received: from DGGEMS408-HUB.china.huawei.com (unknown [172.30.72.60])
	by Forcepoint Email with ESMTP id 871727FFD3959E33668B;
	Sat,  6 Apr 2019 00:23:56 +0800 (CST)
Received: from localhost (10.202.226.61) by DGGEMS408-HUB.china.huawei.com
 (10.3.19.208) with Microsoft SMTP Server id 14.3.408.0; Sat, 6 Apr 2019
 00:23:55 +0800
Date: Fri, 5 Apr 2019 17:23:42 +0100
From: Jonathan Cameron <jonathan.cameron@huawei.com>
To: Dan Williams <dan.j.williams@intel.com>
CC: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "Rafael J.
 Wysocki" <rjw@rjwysocki.net>, Len Brown <lenb@kernel.org>, Keith Busch
	<keith.busch@intel.com>, Vishal L Verma <vishal.l.verma@intel.com>, X86 ML
	<x86@kernel.org>, Linux MM <linux-mm@kvack.org>, linux-nvdimm
	<linux-nvdimm@lists.01.org>
Subject: Re: [RFC PATCH 4/5] acpi/hmat: Register special purpose memory as a
 device
Message-ID: <20190405172342.00006a56@huawei.com>
In-Reply-To: <CAPcyv4hpKkWm0x2jecvmtLNgmwUnAZn3jM_9sKyBAUFaRLj=cQ@mail.gmail.com>
References: <155440490809.3190322.15060922240602775809.stgit@dwillia2-desk3.amr.corp.intel.com>
	<155440492988.3190322.4475460421334178449.stgit@dwillia2-desk3.amr.corp.intel.com>
	<20190405121857.0000718a@huawei.com>
	<CAPcyv4hpKkWm0x2jecvmtLNgmwUnAZn3jM_9sKyBAUFaRLj=cQ@mail.gmail.com>
Organization: Huawei
X-Mailer: Claws Mail 3.17.3 (GTK+ 2.24.32; i686-w64-mingw32)
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
X-Originating-IP: [10.202.226.61]
X-CFilter-Loop: Reflected
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 5 Apr 2019 08:43:03 -0700
Dan Williams <dan.j.williams@intel.com> wrote:

> On Fri, Apr 5, 2019 at 4:19 AM Jonathan Cameron
> <jonathan.cameron@huawei.com> wrote:
> >
> > On Thu, 4 Apr 2019 12:08:49 -0700
> > Dan Williams <dan.j.williams@intel.com> wrote:
> >  
> > > Memory that has been tagged EFI_SPECIAL_PURPOSE, and has performance
> > > properties described by the ACPI HMAT is expected to have an application
> > > specific consumer.
> > >
> > > Those consumers may want 100% of the memory capacity to be reserved from
> > > any usage by the kernel. By default, with this enabling, a platform
> > > device is created to represent this differentiated resource.
> > >
> > > A follow on change arranges for device-dax to claim these devices by
> > > default and provide an mmap interface for the target application.
> > > However, if the administrator prefers that some or all of the special
> > > purpose memory is made available to the core-mm the device-dax hotplug
> > > facility can be used to online the memory with its own numa node.
> > >
> > > Cc: "Rafael J. Wysocki" <rjw@rjwysocki.net>
> > > Cc: Len Brown <lenb@kernel.org>
> > > Cc: Keith Busch <keith.busch@intel.com>
> > > Cc: Jonathan Cameron <Jonathan.Cameron@huawei.com>
> > > Signed-off-by: Dan Williams <dan.j.williams@intel.com>  
> >
> > Hi Dan,
> >
> > Great to see you getting this discussion going so fast and in
> > general the approach makes sense to me.
> >
> > I'm a little confused why HMAT has anything to do with this.
> > SPM is defined either via the attribute in SRAT SPA entries,
> > EF_MEMORY_SP or via the EFI memory map.
> >
> > Whether it is in HMAT or not isn't all that relevant.
> > Back in the days of the reservation hint (so before yesterday :)
> > it was relevant obviously but that's no longer true.
> >
> > So what am I missing?  
> 
> It's a good question, and an assumption I should have explicitly
> declared in the changelog. The problem with EFI_MEMORY_SP is the same
> as the problem with the EfiPersistentMemory type, it isn't precise
> enough on its own for the kernel to delineate 'type' or
> device/replaceable-unit boundaries. For example, I expect one
> EFI_MEMORY_SP range of a specific type may be contiguous with another
> range of a different type. Similar to the NFIT there is no requirement
> in the specification that platform firmware inject multiple range
> entries. Instead that precision is left to the SRAT + HMAT, or the
> NFIT in the case of PMEM.

Absolutely, as long as they are all SPM, they could be anywhere in
the system.

> 
> Conversely, and thinking through this a bit more, if a memory range is
> "special", but the platform fails to enumerate it in HMAT I think
> Linux should scream loudly that the firmware is broken and leave the
> range alone. The "scream loudly" piece is missing in the current set,
> but the "leave the range alone" functionality is included.

I am certainly keen on screaming if the various entries are inconsistent
but am not sure they necessarily are here.

So there are a couple of ways we could get an SPM range defined.
The key thing here is that firmware should be attempting to describe
what it has to some degree somewhere.  If not it won't get a good
result ;)  So if there is no SRAT then you are on your own. SCREAM!

1. Directly in the memory map.  If there is no other information then
   tough luck the kernel can only sensibly handle it as one device.
   Or not at all, which seems like a reasonable decision to me.
   SCREAM

2. In memory map + a proximity domain entry in SRAT.  Given memory
   with different characteristics should be in different proximity
   domains anyway - this should be fairly precise. The slight snag
   here is that the fine grained nature of SRAT is actually a side
   effect of HMAT, so not sure well platforms have traditional
   describe their more subtle differences.

3. In NFIT as NFIT SPA carries the memory attribute.  Not sure if
   we should scream if this disagrees with the memory map.

4. In HMAT?  Now this changed in ACPI 6.3 to clean up the 'messy'
   prior relationship between it and SRAT.  Now HMAT no longer has
   memory address ranges as you observed.  That means, to describe
   properties of memory, it has to use the proximity domains of
   SRAT.  It provides lots of additional info about those domains
   but it is SRAT that defines them.

So I would argue that HMAT itself doesn't tell us anything useful.
SRAT certainly does though so I think this should be coming from
SRAT (or NFIT as that also defines the required precision)

Jonathan



