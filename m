Return-Path: <SRS0=BJvi=SH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D3E7CC282CE
	for <linux-mm@archiver.kernel.org>; Fri,  5 Apr 2019 17:40:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8C879206BA
	for <linux-mm@archiver.kernel.org>; Fri,  5 Apr 2019 17:40:13 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8C879206BA
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=huawei.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 373B86B000C; Fri,  5 Apr 2019 13:40:13 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2FB7B6B000D; Fri,  5 Apr 2019 13:40:13 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 19BC06B0010; Fri,  5 Apr 2019 13:40:13 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f200.google.com (mail-oi1-f200.google.com [209.85.167.200])
	by kanga.kvack.org (Postfix) with ESMTP id D9D286B000C
	for <linux-mm@kvack.org>; Fri,  5 Apr 2019 13:40:12 -0400 (EDT)
Received: by mail-oi1-f200.google.com with SMTP id j202so3099055oih.23
        for <linux-mm@kvack.org>; Fri, 05 Apr 2019 10:40:12 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:in-reply-to:references:organization
         :mime-version:content-transfer-encoding;
        bh=BpO4370WNaaJASLfNyN4ryA5ojgSAZR0v0A3FCM5hfo=;
        b=UZPor4124rWM3W5K2xuWhhN+q1HubfqEiY8Vb5ytiTRzTDiPXzPSIe0YVk9/j9zgOi
         IOrHDlubxpk2qm/2MvEKf1/nUIXVLRl1mqfp29nOi7PYNR2Jz+OJwVvSE3ZC17eFxXL1
         VhezEJf6Yn9SQYOysVg/Ij5TdIINP7fXkc3LtPsyC0sEuf4Hoxzs31rhgtmJl/n3e2dz
         2Ffr15rH5utosh3RkkKSP1xvggaLegPifUNKoJokWZPKNyReuGLJlIzkPkKegp5fv+hI
         A6DNjFj/LW0p7C/mcEzhjCNgyGVAIKCbRYIUoJ59UelLYJsG+6d8jjdnIc5VIcwb9Ghp
         A1tA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jonathan.cameron@huawei.com designates 45.249.212.32 as permitted sender) smtp.mailfrom=jonathan.cameron@huawei.com
X-Gm-Message-State: APjAAAURa2zjVWsCF6DKZOPzccR1i2myXglASEjbnIDE5twGbU+k7NSG
	/mc0vG8NJaoCpMEyCToTcuzrqC57+emRLlUX6UVqeFbzy77rXHGcFY7yzB7B3EaQLNELvfPkfF0
	llMAOzmVULa4tFE/VTcgK8bbJsLG1q4rGETyYMW3pWQj0R9DwQwftLQv5aS349qZe0w==
X-Received: by 2002:a05:6830:1342:: with SMTP id r2mr10028224otq.105.1554486012551;
        Fri, 05 Apr 2019 10:40:12 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwz52NalfdyTkf4/FPEZbv5uZ3MKQIx2+UnA5b37KihIcoYRCWXTYYbSowg7hbqMZ9+Yg1l
X-Received: by 2002:a05:6830:1342:: with SMTP id r2mr10028147otq.105.1554486011332;
        Fri, 05 Apr 2019 10:40:11 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554486011; cv=none;
        d=google.com; s=arc-20160816;
        b=mmLfrOTx3Jkd35OQjCAzfVOW3QdmH2qtfGiRmxIJCoUeOaKtw1VH7CGZYWUrPL6ylf
         19Pe+X7G90vLHoWgZG3Aphpfd+JcHm7ckHOCKjqK8Cskuw1C2nIXE8VpxMl6CqxCZ0sI
         SW5nLOmMs8xJPcN6dMZKIhDTR5DKnBzwcyIg4uOJEasmb1yys6iirqjj/2vW12siQRW4
         OjIYB/II9XEj4nw7w/v8kkJ4hQ1RjidmoWKPj+mYvdkQohLM5mMIl4L/9EJno+rBL6EF
         WHcg10QAmjhlUyyy1uvhee6EpchlpKSXVv8FYqwJ2rgeBzh3njq4KCRhUfT70kQTJWWV
         oTZA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:organization:references
         :in-reply-to:message-id:subject:cc:to:from:date;
        bh=BpO4370WNaaJASLfNyN4ryA5ojgSAZR0v0A3FCM5hfo=;
        b=ZW7aofe7vvGtvILcVZqRlK0rvrwBFJW4Y4E3rXEnAeOjRXslUyA+us0CNKitB1sS1E
         sp59XnExBW/jKoz+bwLIeK6RlPNAdjVOHXn8ea5aTpRgk//7wkiwV+4Rrei4Ps4kx6ku
         D3JU+kU1gfw6LzVmPcXqDUgcEwRUGzjT0PxhdWPfjS9SXWNs0v40z0UzcMoi3T/hjePv
         51sK+utPhcV64HZXf+vHDHNohUWgL9bFdqvtWH4uIR5aIeBVrZBFXhn59DSyWfGhuiBM
         BDSPKfp0d/pM+E++7m0hat8RIxflEJhZjdxYOCqddM0tDrkQlsA+3oU1B74bthFcTZB/
         XOeA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jonathan.cameron@huawei.com designates 45.249.212.32 as permitted sender) smtp.mailfrom=jonathan.cameron@huawei.com
Received: from huawei.com (szxga06-in.huawei.com. [45.249.212.32])
        by mx.google.com with ESMTPS id f2si10020294otp.232.2019.04.05.10.40.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 05 Apr 2019 10:40:11 -0700 (PDT)
Received-SPF: pass (google.com: domain of jonathan.cameron@huawei.com designates 45.249.212.32 as permitted sender) client-ip=45.249.212.32;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jonathan.cameron@huawei.com designates 45.249.212.32 as permitted sender) smtp.mailfrom=jonathan.cameron@huawei.com
Received: from DGGEMS408-HUB.china.huawei.com (unknown [172.30.72.60])
	by Forcepoint Email with ESMTP id A61415B06BD25B8608BE;
	Sat,  6 Apr 2019 01:40:05 +0800 (CST)
Received: from localhost (10.202.226.61) by DGGEMS408-HUB.china.huawei.com
 (10.3.19.208) with Microsoft SMTP Server id 14.3.408.0; Sat, 6 Apr 2019
 01:39:56 +0800
Date: Fri, 5 Apr 2019 18:39:45 +0100
From: Jonathan Cameron <jonathan.cameron@huawei.com>
To: Dan Williams <dan.j.williams@intel.com>
CC: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "Rafael J.
 Wysocki" <rjw@rjwysocki.net>, Len Brown <lenb@kernel.org>, Keith Busch
	<keith.busch@intel.com>, Vishal L Verma <vishal.l.verma@intel.com>, X86 ML
	<x86@kernel.org>, Linux MM <linux-mm@kvack.org>, linux-nvdimm
	<linux-nvdimm@lists.01.org>, <linuxarm@huawei.com>
Subject: Re: [RFC PATCH 4/5] acpi/hmat: Register special purpose memory as a
 device
Message-ID: <20190405183945.0000155f@huawei.com>
In-Reply-To: <CAPcyv4hxBFcJKbVVgNiE4UYXZS4XY9hfE8W9mN+VrcWS9AvJLw@mail.gmail.com>
References: <155440490809.3190322.15060922240602775809.stgit@dwillia2-desk3.amr.corp.intel.com>
	<155440492988.3190322.4475460421334178449.stgit@dwillia2-desk3.amr.corp.intel.com>
	<20190405121857.0000718a@huawei.com>
	<CAPcyv4hpKkWm0x2jecvmtLNgmwUnAZn3jM_9sKyBAUFaRLj=cQ@mail.gmail.com>
	<20190405172342.00006a56@huawei.com>
	<CAPcyv4hxBFcJKbVVgNiE4UYXZS4XY9hfE8W9mN+VrcWS9AvJLw@mail.gmail.com>
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

On Fri, 5 Apr 2019 09:56:22 -0700
Dan Williams <dan.j.williams@intel.com> wrote:

> On Fri, Apr 5, 2019 at 9:24 AM Jonathan Cameron
> <jonathan.cameron@huawei.com> wrote:
> >
> > On Fri, 5 Apr 2019 08:43:03 -0700
> > Dan Williams <dan.j.williams@intel.com> wrote:
> >  
> > > On Fri, Apr 5, 2019 at 4:19 AM Jonathan Cameron
> > > <jonathan.cameron@huawei.com> wrote:  
> > > >
> > > > On Thu, 4 Apr 2019 12:08:49 -0700
> > > > Dan Williams <dan.j.williams@intel.com> wrote:
> > > >  
> > > > > Memory that has been tagged EFI_SPECIAL_PURPOSE, and has performance
> > > > > properties described by the ACPI HMAT is expected to have an application
> > > > > specific consumer.
> > > > >
> > > > > Those consumers may want 100% of the memory capacity to be reserved from
> > > > > any usage by the kernel. By default, with this enabling, a platform
> > > > > device is created to represent this differentiated resource.
> > > > >
> > > > > A follow on change arranges for device-dax to claim these devices by
> > > > > default and provide an mmap interface for the target application.
> > > > > However, if the administrator prefers that some or all of the special
> > > > > purpose memory is made available to the core-mm the device-dax hotplug
> > > > > facility can be used to online the memory with its own numa node.
> > > > >
> > > > > Cc: "Rafael J. Wysocki" <rjw@rjwysocki.net>
> > > > > Cc: Len Brown <lenb@kernel.org>
> > > > > Cc: Keith Busch <keith.busch@intel.com>
> > > > > Cc: Jonathan Cameron <Jonathan.Cameron@huawei.com>
> > > > > Signed-off-by: Dan Williams <dan.j.williams@intel.com>  
> > > >
> > > > Hi Dan,
> > > >
> > > > Great to see you getting this discussion going so fast and in
> > > > general the approach makes sense to me.
> > > >
> > > > I'm a little confused why HMAT has anything to do with this.
> > > > SPM is defined either via the attribute in SRAT SPA entries,
> > > > EF_MEMORY_SP or via the EFI memory map.
> > > >
> > > > Whether it is in HMAT or not isn't all that relevant.
> > > > Back in the days of the reservation hint (so before yesterday :)
> > > > it was relevant obviously but that's no longer true.
> > > >
> > > > So what am I missing?  
> > >
> > > It's a good question, and an assumption I should have explicitly
> > > declared in the changelog. The problem with EFI_MEMORY_SP is the same
> > > as the problem with the EfiPersistentMemory type, it isn't precise
> > > enough on its own for the kernel to delineate 'type' or
> > > device/replaceable-unit boundaries. For example, I expect one
> > > EFI_MEMORY_SP range of a specific type may be contiguous with another
> > > range of a different type. Similar to the NFIT there is no requirement
> > > in the specification that platform firmware inject multiple range
> > > entries. Instead that precision is left to the SRAT + HMAT, or the
> > > NFIT in the case of PMEM.  
> >
> > Absolutely, as long as they are all SPM, they could be anywhere in
> > the system.
> >  
> > >
> > > Conversely, and thinking through this a bit more, if a memory range is
> > > "special", but the platform fails to enumerate it in HMAT I think
> > > Linux should scream loudly that the firmware is broken and leave the
> > > range alone. The "scream loudly" piece is missing in the current set,
> > > but the "leave the range alone" functionality is included.  
> >
> > I am certainly keen on screaming if the various entries are inconsistent
> > but am not sure they necessarily are here.
> >
> > So there are a couple of ways we could get an SPM range defined.
> > The key thing here is that firmware should be attempting to describe
> > what it has to some degree somewhere.  If not it won't get a good
> > result ;)  So if there is no SRAT then you are on your own. SCREAM!
> >
> > 1. Directly in the memory map.  If there is no other information then
> >    tough luck the kernel can only sensibly handle it as one device.
> >    Or not at all, which seems like a reasonable decision to me.
> >    SCREAM
> >
> > 2. In memory map + a proximity domain entry in SRAT.  Given memory
> >    with different characteristics should be in different proximity
> >    domains anyway - this should be fairly precise. The slight snag
> >    here is that the fine grained nature of SRAT is actually a side
> >    effect of HMAT, so not sure well platforms have traditional
> >    describe their more subtle differences.
> >
> > 3. In NFIT as NFIT SPA carries the memory attribute.  Not sure if
> >    we should scream if this disagrees with the memory map.
> >
> > 4. In HMAT?  Now this changed in ACPI 6.3 to clean up the 'messy'
> >    prior relationship between it and SRAT.  Now HMAT no longer has
> >    memory address ranges as you observed.  That means, to describe
> >    properties of memory, it has to use the proximity domains of
> >    SRAT.  It provides lots of additional info about those domains
> >    but it is SRAT that defines them.
> >
> > So I would argue that HMAT itself doesn't tell us anything useful.
> > SRAT certainly does though so I think this should be coming from
> > SRAT (or NFIT as that also defines the required precision)  
> 
> I agree, yes, SRAT by itself is sufficient for this "precision"
> concern. However, do we, core Linux developers, really want to
> encourage platform vendors that they can ignore deploying HMAT data
> and get Linux to honor that sub-case for EFI_MEMORY_SP? My personal
> experience is that platform firmware will take advantage of almost any
> opportunity to minimize the data it provides to the OS. The only hard
> lever Linux has to encourage platform firmware to give complete data
> is to decline to support configurations that have incomplete data.
> 

If we decide as a community that this is the way we want to go, I'm
happy to politely point it out to our firmware people (who are a more
proactive group on detailed system descriptions than many!)

If we make this a clearly stated policy, perhaps via some comments
in the code or Documentation/ that that would be even better
and avoid people taking the 'but you could support my firmware'
line in the future.

I'll see if I can reach out to other OS vendors as well so we
can present a unified front on this (perhaps after a few days, just
in case we have any dissenting voices here!)

Thanks,

Jonathan

