Return-Path: <SRS0=SgWF=Q5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_PASS,URIBL_BLOCKED autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 37252C10F00
	for <linux-mm@archiver.kernel.org>; Fri, 22 Feb 2019 03:59:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DCA6D20684
	for <linux-mm@archiver.kernel.org>; Fri, 22 Feb 2019 03:59:04 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="ygCqCFny"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DCA6D20684
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 76B8E8E00E9; Thu, 21 Feb 2019 22:59:04 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6F0648E00E7; Thu, 21 Feb 2019 22:59:04 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 592F18E00E9; Thu, 21 Feb 2019 22:59:04 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f199.google.com (mail-oi1-f199.google.com [209.85.167.199])
	by kanga.kvack.org (Postfix) with ESMTP id 29DF28E00E7
	for <linux-mm@kvack.org>; Thu, 21 Feb 2019 22:59:04 -0500 (EST)
Received: by mail-oi1-f199.google.com with SMTP id r62so381706oig.14
        for <linux-mm@kvack.org>; Thu, 21 Feb 2019 19:59:04 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=5gRCZQed2GgtoNqI7unw3B/0pzNIdbxo5u3Ey/lkKQ8=;
        b=aVlp1D3ksAMoekp9eGlEaO9sxu+HBwTLKXKUKqSOmfU0DXLBW8381/SRM9yu7PxaxD
         7hTLM1DkOQcIQkIWJKVFC8GMAEHFWAksFvaB+SQTlMD64OxWXRYRMKo+Ywn/4oKERQ3D
         6la2VFpmJh4kwxGJDEmxfnp9OCa18TY+rNTGbf+jA/388daLjGPNTj4IntGNkMQ1kTsy
         Uj72IKDUQ3fNB2C8/AiRccd/2IkYRDubA6xMVhstmgW12/m9mFcdwdL7S6ZGPvylAzf0
         kbo2OAF9XxC1jktl3PLUpnHkOr2GqJFCuuWCVbki7Bdd9nQIdjO/aGwgnMPNxeGBRDCx
         zBpA==
X-Gm-Message-State: AHQUAuY01tYvLAngW2hgyougdYrrZr20asvOUfhmkg5cp6z2NM2Bup+O
	knhPjMkP7XhCbuETwcAHJYi7r68jMxF79EPI19e8PEe1qA4k49aE7oW8IkOfoi0Yx7w2PVdYjDh
	QFq9PVKa+kJFXOqXPJ8ClnlAY26hthrxV3mIZkZzYtdo9RYZQ109cgjP/mWJLClpRSe1V05hyrP
	Vx9IzZv3ozvaDdvYinR/waMQke6y4dJi1KWrFS+/fNupZLPmggGeNwGd/8zGLqrl0dG9UyQ4hJZ
	qJcIOnmMvzFBWbfrNGDiGHTJ2x3h7cLDVbKYsxtEmRAlkkjUTA+73UN/Plu9mZcHsyIji0v/KqR
	uhgvjwN6hPBpvofYr8rgaZpcPu2n8kGGDtxSkFV2DbcXIxawtQJ91Sqv7C2uxesRO6jUIRRfNSW
	2
X-Received: by 2002:a9d:7f8d:: with SMTP id t13mr1317020otp.92.1550807943773;
        Thu, 21 Feb 2019 19:59:03 -0800 (PST)
X-Received: by 2002:a9d:7f8d:: with SMTP id t13mr1316990otp.92.1550807942807;
        Thu, 21 Feb 2019 19:59:02 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550807942; cv=none;
        d=google.com; s=arc-20160816;
        b=BJjQeuLaib9z7DoDbvO4z8XYFJoIgjHippPEKwSgoadXJjPC8Ix7kNjsALGOslV99I
         OBS/sxKJXm6odaeA7X8CNuZ1yzCC3LQLx+ZNCxmCIgMYCww5nLMZ8grIkMzHnUQAMWHF
         CodOM7t9D+IRTn0JfL98+h+dRMT9rQCKU168NE6EQCkfqj6Ya7t3OVJnkc1teE7fhrAQ
         yuOYqUlzd/r7Rksv5l3/gVQ4ZHFLyMtp1dU1M0/V/RfZzjD3XifwAgXP0YiTptTBRQQz
         iWOqETSJ6Op0/k1PmYDyyZjlVtSQoYUeBrBwoN71VW6SX0GNKAN21LNhOMRlm0aY517K
         LXHw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=5gRCZQed2GgtoNqI7unw3B/0pzNIdbxo5u3Ey/lkKQ8=;
        b=XF3orVza8tHMAdkMbZoH6st0KoWSaQBPOA8g00tSfGb1ebLI7yV8q7/OMQxu7aOitz
         lP1IN3sB7RQJk4AWoPMhiCws4dYm1Vtza8PeumMql0fw0JTKmx4D/xKaz/RUKaceUoVP
         rR30/PHB04mvABTDIgoPo/KU7aVrPD729dXhHlTWujwz3Gcs7CKQprUVPlFw4JhI3+Rx
         hQoHnv35GpqxrayhUWP1jOTOIweousfG8U79q2/rBBOs7Y3RA8+/+54pgHDB6iXKh8TH
         4ZovUpNUb0ej4M66zCgqYU69+hXo4h5q+kDdErGSUbuwzjTH20HXErKYO1q9bB6mT+3l
         ALuw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=ygCqCFny;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y9sor151215oig.53.2019.02.21.19.59.02
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 21 Feb 2019 19:59:02 -0800 (PST)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=ygCqCFny;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=5gRCZQed2GgtoNqI7unw3B/0pzNIdbxo5u3Ey/lkKQ8=;
        b=ygCqCFny5vhMw3l3f82xU7dA/0HvWP6VDx4wdV2qHmtXsyhl829cYc6prJ43Fk9d+e
         vLN/EA5z8rI5Ydxc6v6NwgqACSPtqwZhn26GcBYkJ9R/3a4meo4bD1VG0C5N2/vbb5eZ
         FxtktJSuhFYnJvi5KHw5YDpF8ym7JTkvUwqtSVMaBVIJzkh+VcuxUcNDJk1eQtRrdvPH
         9WwykWTgaaLltK+mkwxfe5t1+PAOwCVCn2cTITjPiutidvrCEblIgcs/mZuikN0vzapr
         bh++A6CQgsM+P1CTe2Ril6afwE0jTzyWpdP8G33PE9OimVO5Bv0htO576AoLYgcy3faB
         8Y8Q==
X-Google-Smtp-Source: AHgI3IYa/5jxncrdh7IMyPPa5GQx1xP4Mpt5MZZpI+YqkDRxJ6RItcKLaNgKuTiMJGo0FO0qFr7P5ob7rzjwcZ7J1V8=
X-Received: by 2002:aca:3906:: with SMTP id g6mr1284282oia.149.1550807942340;
 Thu, 21 Feb 2019 19:59:02 -0800 (PST)
MIME-Version: 1.0
References: <155000668075.348031.9371497273408112600.stgit@dwillia2-desk3.amr.corp.intel.com>
 <155000671719.348031.2347363160141119237.stgit@dwillia2-desk3.amr.corp.intel.com>
 <x49ftsgsnzp.fsf@segfault.boston.devel.redhat.com>
In-Reply-To: <x49ftsgsnzp.fsf@segfault.boston.devel.redhat.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Thu, 21 Feb 2019 19:58:51 -0800
Message-ID: <CAPcyv4h9s1jYROGqkMfKk0MNBUedP=vQ1nJObLRwFiTB405nOg@mail.gmail.com>
Subject: Re: [PATCH 7/7] libnvdimm/pfn: Fix 'start_pad' implementation
To: Jeff Moyer <jmoyer@redhat.com>
Cc: linux-nvdimm <linux-nvdimm@lists.01.org>, stable <stable@vger.kernel.org>, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Vishal L Verma <vishal.l.verma@intel.com>, 
	linux-fsdevel <linux-fsdevel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

[ add linux-mm ]


On Thu, Feb 21, 2019 at 3:47 PM Jeff Moyer <jmoyer@redhat.com> wrote:
>
> Hi, Dan,
>
> Thanks for the comprehensive write-up.  Comments below.
>
> Dan Williams <dan.j.williams@intel.com> writes:
>
> > In the beginning the pmem driver simply passed the persistent memory
> > resource range to memremap and was done. With the introduction of
> > devm_memremap_pages() and vmem_altmap the implementation needed to
> > contend with metadata at the start of the resource to indicate whether
> > the vmemmap is located in System RAM or Persistent Memory, and reserve
> > vmemmap capacity in pmem for the latter case.
> >
> > The indication of metadata space was communicated in the
> > nd_pfn->data_offset property and it was defined to be identical to the
> > pmem_device->data_offset property, i.e. relative to the raw resource
> > base of the namespace. Up until this point in the driver's development
> > pmem_device->phys_addr == __pa(pmem_device->virt_addr). This
> > implementation was fine up until the discovery of platforms with
> > physical address layouts that mapped Persistent Memory and System RAM to
> > the same Linux memory hotplug section (128MB span).
> >
> > The nd_pfn->start_pad and nd_pfn->end_trunc properties were introduced
> > to pad and truncate the capacity to fit within an exclusive Linux
> > memory hotplug section span, and it was at this point where the
> > ->start_pad definition did not comprehend the pmem_device->phys_addr to
> > pmem_device->virt_addr relationship. Platforms in the wild typically
> > only collided 'System RAM' at the end of the Persistent Memory range so
> > ->start_pad was often zero.
> >
> > Lately Linux has encountered platforms that collide Persistent Memory
> > regions between each other, specifically cases where ->start_pad needed
> > to be non-zero. This lead to commit ae86cbfef381 "libnvdimm, pfn: Pad
> > pfn namespaces relative to other regions". That commit allowed
> > namespaces to be mapped with devm_memremap_pages(). However dax
> > operations on those configurations currently fail if attempted within the
> > ->start_pad range because pmem_device->data_offset was still relative to
> > raw resource base not relative to the section aligned resource range
> > mapped by devm_memremap_pages().
> >
> > Luckily __bdev_dax_supported() caught these failures and simply disabled
> > dax.
>
> Let me make sure I understand the current state of things.  Assume a
> machine with two persistent memory ranges overlapping the same hotplug
> memory section.  Let's take the example from the ndctl github issue[1]:
>
> 187c000000-967bffffff : Persistent Memory
>
> /sys/bus/nd/devices/region0/resource: 0x187c000000
> /sys/bus/nd/devices/region1/resource: 0x577c000000
>
> Create a namespace in region1.  That namespace will have a start_pad of
> 64MiB.  The problem is that, while the correct offset was specified when
> laying out the struct pages (via arch_add_memory), the data_offset for
> the pmem block device itself does not take the start_pad into account
> (despite the comment in the nd_pfn_sb data structure!).

Unfortunately, yes.

> As a result,
> the block device starts at the beginning of the address range, but
> struct pages only exist for the address space starting 64MiB into the
> range.  __bdev_dax_supported fails, because it tries to perform a
> direct_access call on sector 0, and there's no pgmap for the address
> corresponding to that sector.
>
> So, we can't simply make the code correct (by adding the start_pad to
> pmem->data_offset) without bumping the superblock version, because that
> would change the size of the block device, and the location of data on
> that block device would all be off by 64MiB (and you'd lose the first
> 64MiB).  Mass hysteria.

Correct. Systems with this bug are working fine without DAX because
everything is aligned in that case. We can't change the interpretation
of the fields to make DAX work without losing access to existing data
at the proper offsets through the non-DAX path.

> > However, to fix this situation a non-backwards compatible change
> > needs to be made to the interpretation of the nd_pfn info-block.
> > ->start_pad needs to be accounted in ->map.map_offset (formerly
> > ->data_offset), and ->map.map_base (formerly ->phys_addr) needs to be
> > adjusted to the section aligned resource base used to establish
> > ->map.map formerly (formerly ->virt_addr).
> >
> > The guiding principles of the info-block compatibility fixup is to
> > maintain the interpretation of ->data_offset for implementations like
> > the EFI driver that only care about data_access not dax, but cause older
> > Linux implementations that care about the mode and dax to fail to parse
> > the new info-block.
>
> What if the core mm grew support for hotplug on sub-section boundaries?
> Would't that fix this problem (and others)?

Yes, I think it would, and I had patches along these lines [2]. Last
time I looked at this I was asked by core-mm folks to await some
general refactoring of hotplug [3], and I wasn't proud about some of
the hacks I used to make it work. In general I'm less confident about
being able to get sub-section-hotplug over the goal line (core-mm
resistance to hotplug complexity) vs the local hacks in nvdimm to deal
with this breakage.

Local hacks are always a sad choice, but I think leaving these
configurations stranded for another kernel cycle is not tenable. It
wasn't until the github issue did I realize that the problem was
happening in the wild on NVDIMM-N platforms.

[2]: https://lore.kernel.org/lkml/148964440651.19438.2288075389153762985.stgit@dwillia2-desk3.amr.corp.intel.com/
[3]: https://lore.kernel.org/lkml/20170319163531.GA25835@dhcp22.suse.cz/

>
> -Jeff
>
> [1] https://github.com/pmem/ndctl/issues/76

