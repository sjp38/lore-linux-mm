Return-Path: <SRS0=nbyn=UY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 68A72C48BD6
	for <linux-mm@archiver.kernel.org>; Tue, 25 Jun 2019 09:20:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3A5FE208CA
	for <linux-mm@archiver.kernel.org>; Tue, 25 Jun 2019 09:20:31 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3A5FE208CA
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=huawei.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C263F6B0003; Tue, 25 Jun 2019 05:20:30 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BD7238E0003; Tue, 25 Jun 2019 05:20:30 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AA0738E0002; Tue, 25 Jun 2019 05:20:30 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f199.google.com (mail-oi1-f199.google.com [209.85.167.199])
	by kanga.kvack.org (Postfix) with ESMTP id 7ECC66B0003
	for <linux-mm@kvack.org>; Tue, 25 Jun 2019 05:20:30 -0400 (EDT)
Received: by mail-oi1-f199.google.com with SMTP id w123so6635913oie.21
        for <linux-mm@kvack.org>; Tue, 25 Jun 2019 02:20:30 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:in-reply-to:references:organization
         :mime-version:content-transfer-encoding;
        bh=OID8ZilABlh/nYgDkfmwEF6XFPRSfv6i1rNj+RF+gEA=;
        b=JMkug10L4eIGKiVPzWicMob7ZISagK0rggh44N+Q3H/NRCv0Btm1KJrDM586mp45S5
         B4FMKvpmNVY3CyHw3GN8WTCqYglqHh91gzat/gB22nBCfGZaW/mgbEZJbtT5lF/iMrNp
         TuuxeASewg78G2ukrKJYrZew7zYI3tEGWg1F23bi7Ge3KjNY89N/PVXV6M3Wgdj72VDN
         eI0r5LXTmYZvB+/m+uE6Cv02ntJYne5WqRATc7BrEaVoudd9wScSUOhemWuS107ZsG5G
         mHM/4dyNUYx+vL+qXUvAWjsRuHyshIWKT9/Ivg5S5vb3FIDTmF8pbDpczZ074TL//Tln
         gq1g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jonathan.cameron@huawei.com designates 45.249.212.32 as permitted sender) smtp.mailfrom=jonathan.cameron@huawei.com
X-Gm-Message-State: APjAAAVsYMaewT4fs04AEpTJmEVYg9Immxl5BZJkTjn0o9PRvwh1y5UV
	tUv13LYl8+orL+wxT/FnTU+RiRA6feyaVJIzsoMleRQaRXwTpVufUvPJz507vMq0Xo1CIubAoIx
	DuckKHd2hVKwY0638CtZQ7RaXEb4YO8foscsPNyE3w9IdDRiFvyzdbabisXxA91cTIw==
X-Received: by 2002:a9d:6e01:: with SMTP id e1mr76672394otr.220.1561454430216;
        Tue, 25 Jun 2019 02:20:30 -0700 (PDT)
X-Google-Smtp-Source: APXvYqymipsRXz0TUast6pxhFdqbU5ZNmpWDjCHojzdoMRvV1C3/wx1INz6Tcxml1cnPgiH8M50j
X-Received: by 2002:a9d:6e01:: with SMTP id e1mr76672360otr.220.1561454429311;
        Tue, 25 Jun 2019 02:20:29 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561454429; cv=none;
        d=google.com; s=arc-20160816;
        b=kYq3dk8UMrLv/Xr5obff0hnobHcPo3EcIe0EyR0NQF6e+5wwrmd54RYHR9hcgTjCSX
         0MGKepTLouPnKQm2HCvJFhd/FTpr7G/x1ugfH9u8f7CzfThgDtG/eQOaktuTEfj/eyMo
         /ex0WvWMXYV95082oAmSN7nM0pOtvW8Uc+UjjVNANB813Z4LXkfjT/P2lsnZdLpFFkhb
         L/W8Ut8V9wxSsC8PwLm4ur15VG8ZyRHj/vu8uaKnJ4UT6RJB7k47Aup7abuVcWvBaSf6
         lcPos8mhf+zD9RYIYBx1+FFKwReUPiY0UtFXKvHqCCpu3HV5PsSmRMpLTLHZaEAhINKd
         4JaQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:organization:references
         :in-reply-to:message-id:subject:cc:to:from:date;
        bh=OID8ZilABlh/nYgDkfmwEF6XFPRSfv6i1rNj+RF+gEA=;
        b=S94GzWLwxlgrI4Rwc2sz0nol39De7SIp0JNCkbjtfUUIQG6np//IAvWEFuw7ezanEF
         738k4SC9XXUrdpv3yh8dW1WpEexyLllUICucn+fEuy30ul8KlPkiVNK1dl1p2+I0UUfP
         ukXUUSWXsYzNxFPRiX9MjTUrdCMHk305qbtrNmbeTof8rYHtEc8ZqqZwm6Y0PWQlAfNa
         U9DrZTIgOCzUM4fofnYLvKpU6fGzsZRF57OcBWurjO/c5seC1qmHgCCFohMZKfT8T9OU
         dVz0hxcLfwV36N8cnWfwk3Ih6lVLGBx0hoKULoZYmVgfyEk/I8zk1yUqyfEEvGiE165Y
         6FMg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jonathan.cameron@huawei.com designates 45.249.212.32 as permitted sender) smtp.mailfrom=jonathan.cameron@huawei.com
Received: from huawei.com (szxga06-in.huawei.com. [45.249.212.32])
        by mx.google.com with ESMTPS id i193si8051432oib.249.2019.06.25.02.20.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Jun 2019 02:20:29 -0700 (PDT)
Received-SPF: pass (google.com: domain of jonathan.cameron@huawei.com designates 45.249.212.32 as permitted sender) client-ip=45.249.212.32;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jonathan.cameron@huawei.com designates 45.249.212.32 as permitted sender) smtp.mailfrom=jonathan.cameron@huawei.com
Received: from DGGEMS402-HUB.china.huawei.com (unknown [172.30.72.60])
	by Forcepoint Email with ESMTP id EA2B26ACADE6F2562ACA;
	Tue, 25 Jun 2019 17:20:23 +0800 (CST)
Received: from localhost (10.202.226.61) by DGGEMS402-HUB.china.huawei.com
 (10.3.19.202) with Microsoft SMTP Server id 14.3.439.0; Tue, 25 Jun 2019
 17:20:15 +0800
Date: Tue, 25 Jun 2019 10:20:05 +0100
From: Jonathan Cameron <jonathan.cameron@huawei.com>
To: <linux-mm@kvack.org>, <linux-acpi@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <linux-arm-kernel@lists.infradead.org>
CC: Keith Busch <keith.busch@intel.com>, =?ISO-8859-1?Q?J=E9r=F4me?= Glisse
	<jglisse@redhat.com>, "Rafael J . Wysocki" <rjw@rjwysocki.net>,
	<linuxarm@huawei.com>, Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 0/4 V3] ACPI: Support generic initiator proximity
 domains
Message-ID: <20190625102005.00007ea2@huawei.com>
In-Reply-To: <20190528123158.0000167a@huawei.com>
References: <20190415174907.102307-1-Jonathan.Cameron@huawei.com>
	<20190528123158.0000167a@huawei.com>
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

On Tue, 28 May 2019 12:31:58 +0100
Jonathan Cameron <jonathan.cameron@huawei.com> wrote:
Hi All,

This is your periodic Generic Initiator reminder service.  I'm still looking
for review on all aspects of this series.

* ACPI for the table parsing code.
* ARM64 for the architecture handling
* x86 for the architecture handling.
* Generic MM for the overall approach. In some sense it's not mm related in
  of itself (as otherwise they wouldn't be Generic Initiator domains) but
  it does result in different NUMA policy decisions from the current status
  hence mm input would be great.

Any suggestions on people to add to the CC list to try and make some progress
on this welcome as well.

If I don't hear anything I'll do a rebase post the coming merge window and
resend.

Thanks,

Jonathan

> Hi All,
> 
> Anyone had a change to take a look at this?
> 
> Thanks,
> 
> Jonathan
> 
> On Tue, 16 Apr 2019 01:49:03 +0800
> Jonathan Cameron <Jonathan.Cameron@huawei.com> wrote:
> 
> > Changes since RFC V2.
> > * RFC dropped as now we have x86 support, so the lack of guards in in the
> > ACPI code etc should now be fine.
> > * Added x86 support.  Note this has only been tested on QEMU as I don't have
> > a convenient x86 NUMA machine to play with.  Note that this fitted together
> > rather differently form arm64 so I'm particularly interested in feedback
> > on the two solutions.
> > 
> > Since RFC V1.
> > * Fix incorrect interpretation of the ACPI entry noted by Keith Busch
> > * Use the acpica headers definitions that are now in mmotm.
> > 
> > It's worth noting that, to safely put a given device in a GI node, may
> > require changes to the existing drivers as it's not unusual to assume
> > you have local memory or processor core. There may be futher constraints
> > not yet covered by this patch.
> > 
> > Original cover letter...
> > 
> > ACPI 6.3 introduced a new entity that can be part of a NUMA proximity domain.
> > It may share such a domain with the existing options (memory, cpu etc) but it
> > may also exist on it's own.
> > 
> > The intent is to allow the description of the NUMA properties (particulary
> > via HMAT) of accelerators and other initiators of memory activity that are not
> > the host processor running the operating system.
> > 
> > This patch set introduces 'just enough' to make them work for arm64 and x86.
> > It should be trivial to support other architectures, I just don't suitable
> > NUMA systems readily available to test.
> > 
> > There are a few quirks that need to be considered.
> > 
> > 1. Fall back nodes
> > ******************
> > 
> > As pre ACPI 6.3 supporting operating systems do not have Generic Initiator
> > Proximity Domains it is possible to specify, via _PXM in DSDT that another
> > device is part of such a GI only node.  This currently blows up spectacularly.
> > 
> > Whilst we can obviously 'now' protect against such a situation (see the related
> > thread on PCI _PXM support and the  threadripper board identified there as
> > also falling into the  problem of using non existent nodes
> > https://patchwork.kernel.org/patch/10723311/ ), there is no way to  be sure
> > we will never have legacy OSes that are not protected  against this.  It would
> > also be 'non ideal' to fallback to  a default node as there may be a better
> > (non GI) node to pick  if GI nodes aren't available.
> > 
> > The work around is that we also have a new system wide OSC bit that allows
> > an operating system to 'annouce' that it supports Generic Initiators.  This
> > allows, the firmware to us DSDT magic to 'move' devices between the nodes
> > dependent on whether our new nodes are there or not.
> > 
> > 2. New ways of assigning a proximity domain for devices
> > *******************************************************
> > 
> > Until now, the only way firmware could indicate that a particular device
> > (outside the 'special' set of cpus etc) was to be found in a particular
> > Proximity Domain by the use of _PXM in DSDT.
> > 
> > That is equally valid with GI domains, but we have new options. The SRAT
> > affinity structure includes a handle (ACPI or PCI) to identify devices
> > with the system and specify their proximity domain that way.  If both _PXM
> > and this are provided, they should give the same answer.
> > 
> > For now this patch set completely ignores that feature as we don't need
> > it to start the discussion.  It will form a follow up set at some point
> > (if no one else fancies doing it).
> > 
> > Jonathan Cameron (4):
> >   ACPI: Support Generic Initiator only domains
> >   arm64: Support Generic Initiator only domains
> >   x86: Support Generic Initiator only proximity domains
> >   ACPI: Let ACPI know we support Generic Initiator Affinity Structures
> > 
> >  arch/arm64/kernel/smp.c        |  8 +++++
> >  arch/x86/include/asm/numa.h    |  2 ++
> >  arch/x86/kernel/setup.c        |  1 +
> >  arch/x86/mm/numa.c             | 14 ++++++++
> >  drivers/acpi/bus.c             |  1 +
> >  drivers/acpi/numa.c            | 62 +++++++++++++++++++++++++++++++++-
> >  drivers/base/node.c            |  3 ++
> >  include/asm-generic/topology.h |  3 ++
> >  include/linux/acpi.h           |  1 +
> >  include/linux/nodemask.h       |  1 +
> >  include/linux/topology.h       |  7 ++++
> >  11 files changed, 102 insertions(+), 1 deletion(-)
> >   
> 
> 
> 
> _______________________________________________
> linux-arm-kernel mailing list
> linux-arm-kernel@lists.infradead.org
> http://lists.infradead.org/mailman/listinfo/linux-arm-kernel


