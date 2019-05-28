Return-Path: <SRS0=UfqE=T4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 70E23C04E84
	for <linux-mm@archiver.kernel.org>; Tue, 28 May 2019 11:32:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 419C72081C
	for <linux-mm@archiver.kernel.org>; Tue, 28 May 2019 11:32:25 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 419C72081C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=huawei.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id ADDD76B026C; Tue, 28 May 2019 07:32:24 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A67BA6B026E; Tue, 28 May 2019 07:32:24 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8E07F6B026F; Tue, 28 May 2019 07:32:24 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f198.google.com (mail-oi1-f198.google.com [209.85.167.198])
	by kanga.kvack.org (Postfix) with ESMTP id 62B756B026C
	for <linux-mm@kvack.org>; Tue, 28 May 2019 07:32:24 -0400 (EDT)
Received: by mail-oi1-f198.google.com with SMTP id r78so6198314oie.8
        for <linux-mm@kvack.org>; Tue, 28 May 2019 04:32:24 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:in-reply-to:references:organization
         :mime-version:content-transfer-encoding;
        bh=j4rLqsv0oVYqOpu+UiPxgG5DIk8iWlhw2EOlR7uoIf8=;
        b=kJWvt7VV7VbUqt2/0/FFpWH/aybIJo/4C4QmWMwe/gYzpb96pfFSVWRopGKfw71Bo4
         HYEdrvvltQOtnbPpGvyC9+FIE4Y8atNOn3J93GXZJRo1/LSQWZSSZED5qOd9k9NRhaW1
         U9+TIbsR00euQGiEZXI8xqaCB+tJeTTZZ9qlnZXC6588a4Wnme8ojE459atsTpSftU1L
         OGnMhz0NwKrZbwDsWq2RnCaG0ATI8nh8XFxZ1MUnZpU4/k2/g4Bjvo3TlEaDmWQPusn6
         BlVT7LV97wmWuAepbK84evO8jSts+rWLzt3ze+Q+BZFy7XRQhtcw+Hw7V0MNqIoE8EJO
         p3Ig==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jonathan.cameron@huawei.com designates 45.249.212.32 as permitted sender) smtp.mailfrom=jonathan.cameron@huawei.com
X-Gm-Message-State: APjAAAXocSHcg4U+jFCezGWc39qhk8COyGStoS2sAQvVAcTAcYd6GKsd
	4fmclI4sIlvoBsSJP4t9SSTqRMg6jvhRTSwYJqdKRZW+HISSlnirtC9qF6ceqf9MKK91Z7E9CMI
	Rzre1jVM2YjtaALybvbel/pQSGd+C1Jq9qromlMSk9JWkZuIn/9Asi+Jx6xtrm5D2gA==
X-Received: by 2002:a9d:5902:: with SMTP id t2mr123094oth.147.1559043144108;
        Tue, 28 May 2019 04:32:24 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw2Syn5RPHRLFdLgCXHCIKEFKVv0rGNoI8JCdqvYQu5Hs4iiYQBlMK5v/BnySOBpG7m1x/s
X-Received: by 2002:a9d:5902:: with SMTP id t2mr123055oth.147.1559043143231;
        Tue, 28 May 2019 04:32:23 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559043143; cv=none;
        d=google.com; s=arc-20160816;
        b=nyibmIXyI8/Z74YgxRZ7OOOs9ju9Md8uQbsJsNmptt19Q0SppGyCsQ1xPl2rPbPEau
         PSZ6BncG8Rc/I5VrkVpavLcKTlI4x5eqAQNdyKsy7qOyGDobmxz3pOQmwZDvl0UjOWsH
         /yQWRUK5tJSAhN1DkgykkVK/LPT32jHOoVZrWPqSOQYFyFU88VNP/3L2zJ+CT5ceaIuU
         sMuR1fBRbIZZVQu+/7L8YMHFDPbuZni7RM4yrzLOa9sv14ivsY7QXLExIgDXUJwCBH/u
         EKoohml0OA2NZHD9Ho/AVKI6Kmwr8gDm4i124x2YY8QHpOMPDiTd6jKhTbIIZ6aN6cGy
         jngA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:organization:references
         :in-reply-to:message-id:subject:cc:to:from:date;
        bh=j4rLqsv0oVYqOpu+UiPxgG5DIk8iWlhw2EOlR7uoIf8=;
        b=qIjY4bO/3Lm8+uhCd7z0IP6Ttc1ZiPlYS0zH3DHGqs+OR4yZ+O8oP/d+tmXvPyy8WL
         3A9hOTkTN0ZZaDERzo6BChLQNARqgicSOL5P+adJynQL8IarYHk4/HI+PQsftsuREPsC
         FVFE77mrog9AGSFqdhTLV4qDWGWX1qFxnzsk68fA02iSvm9iewRLPcVt+QTz/3tI73a/
         1bAFQyfdyQldR/dhNbzOYOj4URZyI3CX3HdrRKWL9+m5XX/qnhLm88Gl7zQyIjgkaVIP
         OE4auqOP8OTuLxCZ4brY07azVHWv5p2Mtu6/hO25CQQZtaU/chIwqDcEAkBJng7aAJ2R
         PMXA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jonathan.cameron@huawei.com designates 45.249.212.32 as permitted sender) smtp.mailfrom=jonathan.cameron@huawei.com
Received: from huawei.com (szxga06-in.huawei.com. [45.249.212.32])
        by mx.google.com with ESMTPS id b7si7695348otf.83.2019.05.28.04.32.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 28 May 2019 04:32:23 -0700 (PDT)
Received-SPF: pass (google.com: domain of jonathan.cameron@huawei.com designates 45.249.212.32 as permitted sender) client-ip=45.249.212.32;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jonathan.cameron@huawei.com designates 45.249.212.32 as permitted sender) smtp.mailfrom=jonathan.cameron@huawei.com
Received: from DGGEMS406-HUB.china.huawei.com (unknown [172.30.72.60])
	by Forcepoint Email with ESMTP id 66B21B82AD9FDEAAE061;
	Tue, 28 May 2019 19:32:19 +0800 (CST)
Received: from localhost (10.202.226.61) by DGGEMS406-HUB.china.huawei.com
 (10.3.19.206) with Microsoft SMTP Server id 14.3.439.0; Tue, 28 May 2019
 19:32:09 +0800
Date: Tue, 28 May 2019 12:31:58 +0100
From: Jonathan Cameron <jonathan.cameron@huawei.com>
To: <linux-mm@kvack.org>, <linux-acpi@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <linux-arm-kernel@lists.infradead.org>
CC: =?ISO-8859-1?Q?J=E9r=F4me?= Glisse <jglisse@redhat.com>, Keith Busch
	<keith.busch@intel.com>, "Rafael J . Wysocki" <rjw@rjwysocki.net>,
	<linuxarm@huawei.com>, Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 0/4 V3] ACPI: Support generic initiator proximity
 domains
Message-ID: <20190528123158.0000167a@huawei.com>
In-Reply-To: <20190415174907.102307-1-Jonathan.Cameron@huawei.com>
References: <20190415174907.102307-1-Jonathan.Cameron@huawei.com>
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

Hi All,

Anyone had a change to take a look at this?

Thanks,

Jonathan

On Tue, 16 Apr 2019 01:49:03 +0800
Jonathan Cameron <Jonathan.Cameron@huawei.com> wrote:

> Changes since RFC V2.
> * RFC dropped as now we have x86 support, so the lack of guards in in the
> ACPI code etc should now be fine.
> * Added x86 support.  Note this has only been tested on QEMU as I don't have
> a convenient x86 NUMA machine to play with.  Note that this fitted together
> rather differently form arm64 so I'm particularly interested in feedback
> on the two solutions.
> 
> Since RFC V1.
> * Fix incorrect interpretation of the ACPI entry noted by Keith Busch
> * Use the acpica headers definitions that are now in mmotm.
> 
> It's worth noting that, to safely put a given device in a GI node, may
> require changes to the existing drivers as it's not unusual to assume
> you have local memory or processor core. There may be futher constraints
> not yet covered by this patch.
> 
> Original cover letter...
> 
> ACPI 6.3 introduced a new entity that can be part of a NUMA proximity domain.
> It may share such a domain with the existing options (memory, cpu etc) but it
> may also exist on it's own.
> 
> The intent is to allow the description of the NUMA properties (particulary
> via HMAT) of accelerators and other initiators of memory activity that are not
> the host processor running the operating system.
> 
> This patch set introduces 'just enough' to make them work for arm64 and x86.
> It should be trivial to support other architectures, I just don't suitable
> NUMA systems readily available to test.
> 
> There are a few quirks that need to be considered.
> 
> 1. Fall back nodes
> ******************
> 
> As pre ACPI 6.3 supporting operating systems do not have Generic Initiator
> Proximity Domains it is possible to specify, via _PXM in DSDT that another
> device is part of such a GI only node.  This currently blows up spectacularly.
> 
> Whilst we can obviously 'now' protect against such a situation (see the related
> thread on PCI _PXM support and the  threadripper board identified there as
> also falling into the  problem of using non existent nodes
> https://patchwork.kernel.org/patch/10723311/ ), there is no way to  be sure
> we will never have legacy OSes that are not protected  against this.  It would
> also be 'non ideal' to fallback to  a default node as there may be a better
> (non GI) node to pick  if GI nodes aren't available.
> 
> The work around is that we also have a new system wide OSC bit that allows
> an operating system to 'annouce' that it supports Generic Initiators.  This
> allows, the firmware to us DSDT magic to 'move' devices between the nodes
> dependent on whether our new nodes are there or not.
> 
> 2. New ways of assigning a proximity domain for devices
> *******************************************************
> 
> Until now, the only way firmware could indicate that a particular device
> (outside the 'special' set of cpus etc) was to be found in a particular
> Proximity Domain by the use of _PXM in DSDT.
> 
> That is equally valid with GI domains, but we have new options. The SRAT
> affinity structure includes a handle (ACPI or PCI) to identify devices
> with the system and specify their proximity domain that way.  If both _PXM
> and this are provided, they should give the same answer.
> 
> For now this patch set completely ignores that feature as we don't need
> it to start the discussion.  It will form a follow up set at some point
> (if no one else fancies doing it).
> 
> Jonathan Cameron (4):
>   ACPI: Support Generic Initiator only domains
>   arm64: Support Generic Initiator only domains
>   x86: Support Generic Initiator only proximity domains
>   ACPI: Let ACPI know we support Generic Initiator Affinity Structures
> 
>  arch/arm64/kernel/smp.c        |  8 +++++
>  arch/x86/include/asm/numa.h    |  2 ++
>  arch/x86/kernel/setup.c        |  1 +
>  arch/x86/mm/numa.c             | 14 ++++++++
>  drivers/acpi/bus.c             |  1 +
>  drivers/acpi/numa.c            | 62 +++++++++++++++++++++++++++++++++-
>  drivers/base/node.c            |  3 ++
>  include/asm-generic/topology.h |  3 ++
>  include/linux/acpi.h           |  1 +
>  include/linux/nodemask.h       |  1 +
>  include/linux/topology.h       |  7 ++++
>  11 files changed, 102 insertions(+), 1 deletion(-)
> 


