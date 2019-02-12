Return-Path: <SRS0=CIMh=QT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1AC4CC282C4
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 22:15:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C8301222C7
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 22:15:40 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C8301222C7
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=rjwysocki.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 66B9E8E0002; Tue, 12 Feb 2019 17:15:40 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 61A6A8E0001; Tue, 12 Feb 2019 17:15:40 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5318C8E0002; Tue, 12 Feb 2019 17:15:40 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lf1-f70.google.com (mail-lf1-f70.google.com [209.85.167.70])
	by kanga.kvack.org (Postfix) with ESMTP id D818F8E0001
	for <linux-mm@kvack.org>; Tue, 12 Feb 2019 17:15:39 -0500 (EST)
Received: by mail-lf1-f70.google.com with SMTP id t198so37042lff.9
        for <linux-mm@kvack.org>; Tue, 12 Feb 2019 14:15:39 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=M+b8SOJU1+cl5JPt766rHl72qOEi8rJKWmCs5irLPJ8=;
        b=I/lPP1S2MxyYAgCkF0EdmjjAarFv5/E6PxHLCp56HXj1QqoUzPr3iCnEa4aRSzsSIr
         VSXaA25v5UMF5+8C/QcaDf39LG7iX6a/x0GIubtE9eCWVINVZoQu6H5W9cCDO1Re8YPB
         d3p1KenRkrN0SNIyVknHUJrnEJswdnv7zqCvSGaJBMmXCmzBLB1pGOCdcpWqWeFP9GUG
         x03dM1k7oyqw4PVLzEbRyShYlr04uAK8wfwCnB2l46IbqZMhIDQNlI2PhZ+ayudgSOAo
         Qg9ONhNXii8QsCqiYIFWO9ziY3zURwzW5Uf+GWK/OzXR1rDBDDAOu0rx2lThf9gECzn1
         JTOg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rjw@rjwysocki.net designates 79.96.170.134 as permitted sender) smtp.mailfrom=rjw@rjwysocki.net
X-Gm-Message-State: AHQUAublrJpgr7OqiexHQORaSkvcidey6J0IIMzpacv+lTXbMilUCzEG
	ZT0Drzd5sznQVCNfVgsGUSWODogml9LPaj018WTpeINxNGtB865YxNOHcmTc4WnCxnLSQk5Z/3s
	GEGgy9ULqUnryNF57sQlnoo/jBAKMoOnfR3Arrgh6GMhfYAnsDDMy7bWyjGHHYEEpnA==
X-Received: by 2002:ac2:54b4:: with SMTP id w20mr3997787lfk.24.1550009739288;
        Tue, 12 Feb 2019 14:15:39 -0800 (PST)
X-Google-Smtp-Source: AHgI3Ib+wqJiNrEXI722NkheasO4M2sJZj6KATTuepdKOMaGHvmIPwsj/ORQZmV1Y64NxPt2hnmi
X-Received: by 2002:ac2:54b4:: with SMTP id w20mr3997718lfk.24.1550009737548;
        Tue, 12 Feb 2019 14:15:37 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550009737; cv=none;
        d=google.com; s=arc-20160816;
        b=0aXlN0Oca5RzSjT00bGJ2w0B8ZVDRMtK+DwKVGGbyZiyre8ZGWbiVSZW3+YNm7G/C8
         0iRVnL+HNmt4vyG8LupnNCAC55DWhgi+6pP1wdN2mTLgmH59q2/qeHhbUGcKFGG0HTjN
         S/esFSOqoaIcZ/dMX93Vejugxp6QwLVXo+XvLhAHmj+qz2ApcAvuTND+YrJyBSbuF0b1
         LXPAVtIJdHT7ulilYBplGOKwmFJNaQyoXjV/SC73hr0SGtKdTPJKgXGQirGDR26pywOE
         N0IHq+XmzFHIJ4GYgyeGBg6LKcYYQFE0tmzAqY0Mxo8RnVBAtuJaNdO0AKKT9JWx3cFh
         i3Jg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=M+b8SOJU1+cl5JPt766rHl72qOEi8rJKWmCs5irLPJ8=;
        b=lW0bsw307dt7bfvp5Jm1zomgrsFz9P6V0AXEsG6SksQLkhRx7htyRZU1VoUR6UrZjY
         tpQwOUt3bAbOZjCVUIRuj5fUrOV+JqFYrKQeNISv+rZHvUj8qnH5sAKCn1FPdqSOJmZK
         hTLAtplrLZWAVZKhXB4SFpUvhGM7shQrbI1+ESRUIbCyKO4YU6Ixawq4H6/Ys00JvMX+
         NoXKn5g8qqrb2CalSZpmFZjyEuNIW7ehUuHCABIOB49t8xRShPOgKTO4yUQK4loE6TEt
         TcLx4811t1sNAiJD6TA/+8WHtc3JbYQSIToZiIGNda2wb/hz0xH2F9J0VcopuUn7pHZR
         vaEg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rjw@rjwysocki.net designates 79.96.170.134 as permitted sender) smtp.mailfrom=rjw@rjwysocki.net
Received: from cloudserver094114.home.pl (cloudserver094114.home.pl. [79.96.170.134])
        by mx.google.com with ESMTPS id q26-v6si14336132lji.163.2019.02.12.14.15.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 12 Feb 2019 14:15:37 -0800 (PST)
Received-SPF: pass (google.com: domain of rjw@rjwysocki.net designates 79.96.170.134 as permitted sender) client-ip=79.96.170.134;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rjw@rjwysocki.net designates 79.96.170.134 as permitted sender) smtp.mailfrom=rjw@rjwysocki.net
Received: from 79.184.254.36.ipv4.supernova.orange.pl (79.184.254.36) (HELO aspire.rjw.lan)
 by serwer1319399.home.pl (79.96.170.134) with SMTP (IdeaSmtpServer 0.83.183)
 id 1561d8aff315dca9; Tue, 12 Feb 2019 23:15:36 +0100
From: "Rafael J. Wysocki" <rjw@rjwysocki.net>
To: James Morse <james.morse@arm.com>
Cc: "Rafael J. Wysocki" <rafael@kernel.org>, Borislav Petkov <bp@alien8.de>, ACPI Devel Maling List <linux-acpi@vger.kernel.org>, kvmarm@lists.cs.columbia.edu, Linux ARM <linux-arm-kernel@lists.infradead.org>, Linux Memory Management List <linux-mm@kvack.org>, Marc Zyngier <marc.zyngier@arm.com>, Christoffer Dall <christoffer.dall@arm.com>, Will Deacon <will.deacon@arm.com>, Catalin Marinas <catalin.marinas@arm.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Len Brown <lenb@kernel.org>, Tony Luck <tony.luck@intel.com>, Dongjiu Geng <gengdongjiu@huawei.com>, Xie XiuQi <xiexiuqi@huawei.com>
Subject: Re: [PATCH v8 00/26] APEI in_nmi() rework and SDEI wire-up
Date: Tue, 12 Feb 2019 23:14:18 +0100
Message-ID: <2507221.Jg8xd6amJ7@aspire.rjw.lan>
In-Reply-To: <f561e55c-3560-6a5a-bd23-5d687227e257@arm.com>
References: <20190129184902.102850-1-james.morse@arm.com> <CAJZ5v0ibUO7F=+_GBbhEz4nc0jtC=UaK+cOcLCBrXd2pfc0iLg@mail.gmail.com> <f561e55c-3560-6a5a-bd23-5d687227e257@arm.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="us-ascii"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Monday, February 11, 2019 7:35:03 PM CET James Morse wrote:
> Hi Rafael,
> 
> On 11/02/2019 11:05, Rafael J. Wysocki wrote:
> > On Fri, Feb 8, 2019 at 3:13 PM James Morse <james.morse@arm.com> wrote:
> >> On 08/02/2019 11:40, Rafael J. Wysocki wrote:
> >>> On Tuesday, January 29, 2019 7:48:36 PM CET James Morse wrote:
> >>>> This series aims to wire-up arm64's fancy new software-NMI notifications
> >>>> for firmware-first RAS. These need to use the estatus-queue, which is
> >>>> also needed for notifications via emulated-SError. All of these
> >>>> things take the 'in_nmi()' path through ghes_copy_tofrom_phys(), and
> >>>> so will deadlock if they can interact, which they might.
> >>
> >>>> Known issues:
> >>>>  * ghes_copy_tofrom_phys() already takes a lock in NMI context, this
> >>>>    series moves that around, and makes sure we never try to take the
> >>>>    same lock from different NMIlike notifications. Since the switch to
> >>>>    queued spinlocks it looks like the kernel can only be 4 context's
> >>>>    deep in spinlock, which arm64 could exceed as it doesn't have a
> >>>>    single architected NMI. This would be fixed by dropping back to
> >>>>    test-and-set when the nesting gets too deep:
> >>>>  lore.kernel.org/r/1548215351-18896-1-git-send-email-longman@redhat.com
> >>>>
> >>>> * Taking an NMI from a KVM guest on arm64 with VHE leaves HCR_EL2.TGE
> >>>>   clear, meaning AT and TLBI point at the guest, and PAN/UAO are squiffy.
> >>>>   Only TLBI matters for APEI, and this is fixed by Julien's patch:
> >>>>  http://lore.kernel.org/r/1548084825-8803-2-git-send-email-julien.thierry@arm.com
> >>>>
> >>>> * Linux ignores the physical address mask, meaning it doesn't call
> >>>>   memory_failure() on all the affected pages if firmware or hypervisor
> >>>>   believe in a different page size. Easy to hit on arm64, (easy to fix too,
> >>>>   it just conflicts with this series)
> >>
> >>
> >>>> James Morse (26):
> >>>>   ACPI / APEI: Don't wait to serialise with oops messages when
> >>>>     panic()ing
> >>>>   ACPI / APEI: Remove silent flag from ghes_read_estatus()
> >>>>   ACPI / APEI: Switch estatus pool to use vmalloc memory
> >>>>   ACPI / APEI: Make hest.c manage the estatus memory pool
> >>>>   ACPI / APEI: Make estatus pool allocation a static size
> >>>>   ACPI / APEI: Don't store CPER records physical address in struct ghes
> >>>>   ACPI / APEI: Remove spurious GHES_TO_CLEAR check
> >>>>   ACPI / APEI: Don't update struct ghes' flags in read/clear estatus
> >>>>   ACPI / APEI: Generalise the estatus queue's notify code
> >>>>   ACPI / APEI: Don't allow ghes_ack_error() to mask earlier errors
> >>>>   ACPI / APEI: Move NOTIFY_SEA between the estatus-queue and NOTIFY_NMI
> >>>>   ACPI / APEI: Switch NOTIFY_SEA to use the estatus queue
> >>>>   KVM: arm/arm64: Add kvm_ras.h to collect kvm specific RAS plumbing
> >>>>   arm64: KVM/mm: Move SEA handling behind a single 'claim' interface
> >>>>   ACPI / APEI: Move locking to the notification helper
> >>>>   ACPI / APEI: Let the notification helper specify the fixmap slot
> >>>>   ACPI / APEI: Pass ghes and estatus separately to avoid a later copy
> >>>>   ACPI / APEI: Make GHES estatus header validation more user friendly
> >>>>   ACPI / APEI: Split ghes_read_estatus() to allow a peek at the CPER
> >>>>     length
> >>>>   ACPI / APEI: Only use queued estatus entry during
> >>>>     in_nmi_queue_one_entry()
> >>>>   ACPI / APEI: Use separate fixmap pages for arm64 NMI-like
> >>>>     notifications
> >>>>   mm/memory-failure: Add memory_failure_queue_kick()
> >>>>   ACPI / APEI: Kick the memory_failure() queue for synchronous errors
> >>>>   arm64: acpi: Make apei_claim_sea() synchronise with APEI's irq work
> >>>>   firmware: arm_sdei: Add ACPI GHES registration helper
> >>>>   ACPI / APEI: Add support for the SDEI GHES Notification type
> >>
> >>
> >>> I can apply patches in this series up to and including patch [21/26].
> >>>
> >>> Do you want me to do that?
> >>
> >> 9-12, 17-19, 21 are missing any review/ack tags, so I wouldn't ask, but as
> >> you're offering, yes please!
> >>
> >>
> >>> Patch [22/26] requires an ACK from mm people.
> >>>
> >>> Patch [23/26] has a problem that randconfig can generate a configuration
> >>> in which memory_failure_queue_kick() is not present, so it is necessary
> >>> to add a CONFIG_MEMORY_FAILURE dependency somewhere for things to
> >>> work (or define an empty stub for that function in case the symbol is
> >>> not set).
> >>
> >> Damn-it! Thanks, I was just trying to work that report out...
> >>
> >>
> >>> If patches [24-26/26] don't depend on the previous two, I can try to
> >>> apply them either, so please let me know.
> >>
> >> 22-24 depend on each other. Merging 24 without the other two is no-improvement,
> >> so I'd like them to be kept together.
> >>
> >> 25-26 don't depend on 22-24, but came later so that they weren't affected by the
> >> same race.
> >> (note to self: describe that in the cover letter next time.)
> >>
> >>
> >> If I apply the tag's and Boris' changes and post a tested v9 as 1-21, 25-26, is
> >> that easier, or does it cause extra work?
> > 
> > Actually, I went ahead and applied them, since I had the 1-21 ready anyway.
> 
> > I applied the Boris' fixups manually which led to a bit of rebasing,
> > so please check my linux-next branch.
> 
> Looks okay to me, and I ran your branch through the POLL/SEA/SDEI tests I've
> been doing for each version so far.

Thanks for the confirmation!

