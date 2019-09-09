Return-Path: <SRS0=8wNw=XE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 24FA1C433EF
	for <linux-mm@archiver.kernel.org>; Mon,  9 Sep 2019 11:53:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DE51A21920
	for <linux-mm@archiver.kernel.org>; Mon,  9 Sep 2019 11:53:47 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="mz4MBWiu"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DE51A21920
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DCB856B0005; Mon,  9 Sep 2019 07:53:46 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D7B2D6B0006; Mon,  9 Sep 2019 07:53:46 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C905F6B0007; Mon,  9 Sep 2019 07:53:46 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0240.hostedemail.com [216.40.44.240])
	by kanga.kvack.org (Postfix) with ESMTP id A82886B0005
	for <linux-mm@kvack.org>; Mon,  9 Sep 2019 07:53:46 -0400 (EDT)
Received: from smtpin28.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id 19D98824CA3F
	for <linux-mm@kvack.org>; Mon,  9 Sep 2019 11:53:46 +0000 (UTC)
X-FDA: 75915222852.28.brass30_3b8224a38802
X-HE-Tag: brass30_3b8224a38802
X-Filterd-Recvd-Size: 5683
Received: from mail-oi1-f196.google.com (mail-oi1-f196.google.com [209.85.167.196])
	by imf27.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon,  9 Sep 2019 11:53:45 +0000 (UTC)
Received: by mail-oi1-f196.google.com with SMTP id v7so10240856oib.4
        for <linux-mm@kvack.org>; Mon, 09 Sep 2019 04:53:45 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=ycSCbtpblwJD3MpI8N6ImHg84InwzDYLHFYqOZ8niWY=;
        b=mz4MBWiu4fN9MF7a/rAaPguBBR4GIwROCt/bPq/ftvjbFNlUohn4A+aX2JuFVp8nhE
         LgjSh23msmWNDMpkK3M04q3kajzcWmF+YY7dnghYFjdplKklAbyZAJHFQCnQcoljLYZr
         glZE6kc3dW8xL2jsOTeR4InXSCB726pZFI9hSEw/vbj4NkxP9OdvCBvQZPu8Ve+OQ9d2
         oArur1zB+gEzQgZv2UGF3/6XDlFQUPlHYn0oB+Kv8AAlnIq8leJFSVmyrOHrmycIKywh
         7RuBgbmXYFtBIb0WivkB14XAsAxBVoRNn5/SgaIA4vOGJq+5qO/2POs73WMzBuciPBqf
         wtOw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=ycSCbtpblwJD3MpI8N6ImHg84InwzDYLHFYqOZ8niWY=;
        b=URLsg6VtLH27h7tvmwecVE2zqFAa/3aFd7PMrEX10koENxe5uCfO374MhFIFXmZELl
         tqj1qXbnCiXm+tTSvARlKInw9zgSXA0hNzcbX+NZNNyWS3S1dzDS4mgx0IiNU6FNdOr1
         AIv0OQXrrMEMiCWtg5RAkbK3ly0opVhQk5n45Hua/emDUMen/L/ozZPAIupsSHUi8Gwt
         5DjhZmhAM1FnxTjVQ8zbz0OgBVp9BDPr3SD8grPCGNHbVDzfj4IrqwgVlDvZiXdIk9tj
         dSIxc8qDXgZRpIZ16F5fffWxgfSxO0CzFlrWKbenOQ1pkT1vjApf47geNRkFX7JHnf3T
         7LXg==
X-Gm-Message-State: APjAAAXG4HgdXOMtSDPcoF+aWmW6WHhiAR8ShU+aexTDdPRJDXkvhl+d
	BFGr4aHuXUu32WcGIkIr/KfQ7oEp0sP5tu88pVRaDQ==
X-Google-Smtp-Source: APXvYqwrT1eCBweLj5k+A+JU3QKLfGH+67wPQLvMlZaOKJJETfTmHgD3lUkF7MQS2lqwaC5MLUaCG334nbzuW3KyYa0=
X-Received: by 2002:aca:be43:: with SMTP id o64mr17395031oif.149.1568030024545;
 Mon, 09 Sep 2019 04:53:44 -0700 (PDT)
MIME-Version: 1.0
References: <20190906081027.15477-1-t-fukasawa@vx.jp.nec.com>
 <b7732a55-4a10-2c1d-c2f5-ca38ee60964d@redhat.com> <e762ee45-43e3-975a-ad19-065f07d1440f@vx.jp.nec.com>
 <40a1ce2e-1384-b869-97d0-7195b5b47de0@redhat.com> <6a99e003-e1ab-b9e8-7b25-bc5605ab0eb2@vx.jp.nec.com>
 <e4e54258-e83b-cf0b-b66e-9874be6b5122@redhat.com> <f9b10653-949b-64a6-6539-a32bd980edb9@redhat.com>
In-Reply-To: <f9b10653-949b-64a6-6539-a32bd980edb9@redhat.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Mon, 9 Sep 2019 04:53:33 -0700
Message-ID: <CAPcyv4gA4mcDEPeCFokn_jy5gX62cK0U40EzL7M8c0iDO7U7bg@mail.gmail.com>
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

On Mon, Sep 9, 2019 at 1:11 AM David Hildenbrand <david@redhat.com> wrote:
[..]
> >> It seems that SECTION_IS_ONLINE and SECTION_MARKED_PRESENT can be used to
> >> distinguish uninitialized struct pages if we can apply them to ZONE_DEVICE,
> >> but that is no longer necessary with this approach.
> >
> > Let's take a step back here to understand the issues I am aware of. I
> > think we should solve this for good now:
> >
> > A PFN walker takes a look at a random PFN at a random point in time. It
> > finds a PFN with SECTION_MARKED_PRESENT && !SECTION_IS_ONLINE. The
> > options are:
> >
> > 1. It is buddy memory (add_memory()) that has not been online yet. The
> > memmap contains garbage. Don't access.
> >
> > 2. It is ZONE_DEVICE memory with a valid memmap. Access it.
> >
> > 3. It is ZONE_DEVICE memory with an invalid memmap, because the section
> > is only partially present: E.g., device starts at offset 64MB within a
> > section or the device ends at offset 64MB within a section. Don't access it.
> >
> > 4. It is ZONE_DEVICE memory with an invalid memmap, because the memmap
> > was not initialized yet. memmap_init_zone_device() did not yet succeed
> > after dropping the mem_hotplug lock in mm/memremap.c. Don't access it.
> >
> > 5. It is reserved ZONE_DEVICE memory ("pages mapped, but reserved for
> > driver") with an invalid memmap. Don't access it.
> >
> > I can see that your patch tries to make #5 vanish by initializing the
> > memmap, fair enough. #3 and #4 can't be detected. The PFN walker could
> > still stumble over uninitialized memmaps.
> >
>
> FWIW, I thinkg having something like pfn_zone_device(), similarly
> implemented like pfn_zone_device_reserved() could be one solution to
> most issues.

I've been thinking of a replacement for PTE_DEVMAP with section-level,
or sub-section level flags. The section-level flag would still require
a call to get_dev_pagemap() to validate that the pfn is not section in
the subsection case which seems to be entirely too much overhead. If
ZONE_DEVICE is to be a first class citizen in pfn walkers I think it
would be worth the cost to double the size of subsection_map and to
identify whether a sub-section is ZONE_DEVICE, or not.

Thoughts?

