Return-Path: <SRS0=aXoD=SR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 86317C10F12
	for <linux-mm@archiver.kernel.org>; Mon, 15 Apr 2019 17:49:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4227320848
	for <linux-mm@archiver.kernel.org>; Mon, 15 Apr 2019 17:49:48 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4227320848
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=huawei.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B46636B0003; Mon, 15 Apr 2019 13:49:47 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AF5216B0006; Mon, 15 Apr 2019 13:49:47 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9E3C66B0007; Mon, 15 Apr 2019 13:49:47 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f197.google.com (mail-oi1-f197.google.com [209.85.167.197])
	by kanga.kvack.org (Postfix) with ESMTP id 735856B0003
	for <linux-mm@kvack.org>; Mon, 15 Apr 2019 13:49:47 -0400 (EDT)
Received: by mail-oi1-f197.google.com with SMTP id o132so8396252oib.5
        for <linux-mm@kvack.org>; Mon, 15 Apr 2019 10:49:47 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:mime-version:content-transfer-encoding;
        bh=hpJJrtptawVwMK73QYYab4QOYTrmhmgQtOoFEoFHBZ4=;
        b=caD6d4ykEmSQ3W6POC28thf4opFMx1QH0wVVUEP0gOafV7tqx9c6SC7scovzj50+JW
         HWbtOU3wfth8jmZ62RrFb5dGflB0nEIUgpebGi9rXuL35V6IBqeNhBgwJJEr3DWOhk4+
         V8/dO1c45Mrd+rKcdngAka6zXNGryX5yxHSU5xnMvzjNnPljAGMBa+C0SHXMBREq6AyX
         8z3Ws218rWIsQPtcRQR03Vul2rCeZnXht3RTQPdJYgsL/KyZdp9t3og4Ze952AIMPG9N
         iT5muNoVXFTiD576oau7h95AcMrsuJUOEOEEu6PZUcR2I37fs/XGDv/JSctk49zg5GQV
         DupA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jonathan.cameron@huawei.com designates 45.249.212.32 as permitted sender) smtp.mailfrom=jonathan.cameron@huawei.com
X-Gm-Message-State: APjAAAWOtXSrPEqbwWP4iS1YbhDJnXdvRchRDCv5T0WQTfrxI8HgoThY
	1Y+jX1UZlx96YiQ3tnM62uV0hjgwBLKrtI9pRrRvp1ZeqoQjcQs0+ZxI+HAESIOYCzG8yRCJCeb
	4ov5IsV2YNRwUgz7UoamdEDZ9Ym2e7XfuTcGxTA4TDfSIwptJpJsBdDNxoADVJYeY9Q==
X-Received: by 2002:a9d:6ace:: with SMTP id m14mr47275416otq.296.1555350587108;
        Mon, 15 Apr 2019 10:49:47 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwKyuAmKOF5IKiz324OLSVBgGFK4jkcKAcfTzowdflMMqQH9Aw3VQKZIXFk0YFQBpzJ0CGA
X-Received: by 2002:a9d:6ace:: with SMTP id m14mr47275363otq.296.1555350585811;
        Mon, 15 Apr 2019 10:49:45 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555350585; cv=none;
        d=google.com; s=arc-20160816;
        b=HPZZlveDA22vAVCPcLD1lsyobb52ACRpihBfTCEnmo/OAx2g+xxw+nk00j7JyXFPhY
         Z9CDA6gAklljdftm9Ix/KSOB3Gpfh9yYAZZFW9h7sOzIkbU70zeS6NErNSQREXDxYs3j
         3DGA/ETiGjJWW5rVMg+tWOKQ129chjOrE6i8ttzuTzCVeFWe9rGZp0X3UvQ7GrJlt/LD
         dvVhem7u8VM+V4kJRm4NoO8GEIIPh71ZRPgw39MD8aJrciVA8BDcRtFuGyYyFfbRJ9GG
         QVn2J7LB/FJ0h5dpw/HlNlh3dGqb1GckFj0rHQo02IO4XDm9XuZ1vM39JsJ59e3WZLxv
         Y6Sw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from;
        bh=hpJJrtptawVwMK73QYYab4QOYTrmhmgQtOoFEoFHBZ4=;
        b=uPNb1RKpKWKqCeJnZ7pL4fst3theUK1yJvco/29jXH9kIregWY17Thj+tBcJb8OO/H
         97AZYbyawFHO0IwcjEOJhzmNfV0nl9ZOCwnl183xPjQ8vbZaPO1ExoXhPRrmuLpr5kjq
         6FQ4wUhaMbuF/zvJfzTdP7hSjryDtZGW6DHAs5nzW8VTTf4lgva/cTHltcIYAa6v9QFr
         b3E16+1sGpKIQE82cVtKZweDuXMkgj8TjDRjWVLi7Q7AghKD9MjRWFVnnaOBqDWY622J
         i45vF3/u1YbK4ESFlMCfYTTI5AJva+Q0wBjFo8mXqj2vfv0cV0RCl3rf9VSoXWTAb7q/
         HcNA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jonathan.cameron@huawei.com designates 45.249.212.32 as permitted sender) smtp.mailfrom=jonathan.cameron@huawei.com
Received: from huawei.com (szxga06-in.huawei.com. [45.249.212.32])
        by mx.google.com with ESMTPS id o22si23222436otl.0.2019.04.15.10.49.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 Apr 2019 10:49:45 -0700 (PDT)
Received-SPF: pass (google.com: domain of jonathan.cameron@huawei.com designates 45.249.212.32 as permitted sender) client-ip=45.249.212.32;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jonathan.cameron@huawei.com designates 45.249.212.32 as permitted sender) smtp.mailfrom=jonathan.cameron@huawei.com
Received: from DGGEMS401-HUB.china.huawei.com (unknown [172.30.72.59])
	by Forcepoint Email with ESMTP id DB9D932B0FF3B7868F30;
	Tue, 16 Apr 2019 01:49:41 +0800 (CST)
Received: from FRA1000014316.huawei.com (100.126.230.97) by
 DGGEMS401-HUB.china.huawei.com (10.3.19.201) with Microsoft SMTP Server id
 14.3.408.0; Tue, 16 Apr 2019 01:49:31 +0800
From: Jonathan Cameron <Jonathan.Cameron@huawei.com>
To: <linux-mm@kvack.org>, <linux-acpi@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <linux-arm-kernel@lists.infradead.org>
CC: =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>, Keith Busch
	<keith.busch@intel.com>, "Rafael J . Wysocki" <rjw@rjwysocki.net>,
	<linuxarm@huawei.com>, Andrew Morton <akpm@linux-foundation.org>, "Jonathan
 Cameron" <Jonathan.Cameron@huawei.com>
Subject: [PATCH 0/4 V3] ACPI: Support generic initiator proximity domains
Date: Tue, 16 Apr 2019 01:49:03 +0800
Message-ID: <20190415174907.102307-1-Jonathan.Cameron@huawei.com>
X-Mailer: git-send-email 2.19.1
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Content-Type: text/plain
X-Originating-IP: [100.126.230.97]
X-CFilter-Loop: Reflected
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Changes since RFC V2.
* RFC dropped as now we have x86 support, so the lack of guards in in the
ACPI code etc should now be fine.
* Added x86 support.  Note this has only been tested on QEMU as I don't have
a convenient x86 NUMA machine to play with.  Note that this fitted together
rather differently form arm64 so I'm particularly interested in feedback
on the two solutions.

Since RFC V1.
* Fix incorrect interpretation of the ACPI entry noted by Keith Busch
* Use the acpica headers definitions that are now in mmotm.

It's worth noting that, to safely put a given device in a GI node, may
require changes to the existing drivers as it's not unusual to assume
you have local memory or processor core. There may be futher constraints
not yet covered by this patch.

Original cover letter...

ACPI 6.3 introduced a new entity that can be part of a NUMA proximity domain.
It may share such a domain with the existing options (memory, cpu etc) but it
may also exist on it's own.

The intent is to allow the description of the NUMA properties (particulary
via HMAT) of accelerators and other initiators of memory activity that are not
the host processor running the operating system.

This patch set introduces 'just enough' to make them work for arm64 and x86.
It should be trivial to support other architectures, I just don't suitable
NUMA systems readily available to test.

There are a few quirks that need to be considered.

1. Fall back nodes
******************

As pre ACPI 6.3 supporting operating systems do not have Generic Initiator
Proximity Domains it is possible to specify, via _PXM in DSDT that another
device is part of such a GI only node.  This currently blows up spectacularly.

Whilst we can obviously 'now' protect against such a situation (see the related
thread on PCI _PXM support and the  threadripper board identified there as
also falling into the  problem of using non existent nodes
https://patchwork.kernel.org/patch/10723311/ ), there is no way to  be sure
we will never have legacy OSes that are not protected  against this.  It would
also be 'non ideal' to fallback to  a default node as there may be a better
(non GI) node to pick  if GI nodes aren't available.

The work around is that we also have a new system wide OSC bit that allows
an operating system to 'annouce' that it supports Generic Initiators.  This
allows, the firmware to us DSDT magic to 'move' devices between the nodes
dependent on whether our new nodes are there or not.

2. New ways of assigning a proximity domain for devices
*******************************************************

Until now, the only way firmware could indicate that a particular device
(outside the 'special' set of cpus etc) was to be found in a particular
Proximity Domain by the use of _PXM in DSDT.

That is equally valid with GI domains, but we have new options. The SRAT
affinity structure includes a handle (ACPI or PCI) to identify devices
with the system and specify their proximity domain that way.  If both _PXM
and this are provided, they should give the same answer.

For now this patch set completely ignores that feature as we don't need
it to start the discussion.  It will form a follow up set at some point
(if no one else fancies doing it).

Jonathan Cameron (4):
  ACPI: Support Generic Initiator only domains
  arm64: Support Generic Initiator only domains
  x86: Support Generic Initiator only proximity domains
  ACPI: Let ACPI know we support Generic Initiator Affinity Structures

 arch/arm64/kernel/smp.c        |  8 +++++
 arch/x86/include/asm/numa.h    |  2 ++
 arch/x86/kernel/setup.c        |  1 +
 arch/x86/mm/numa.c             | 14 ++++++++
 drivers/acpi/bus.c             |  1 +
 drivers/acpi/numa.c            | 62 +++++++++++++++++++++++++++++++++-
 drivers/base/node.c            |  3 ++
 include/asm-generic/topology.h |  3 ++
 include/linux/acpi.h           |  1 +
 include/linux/nodemask.h       |  1 +
 include/linux/topology.h       |  7 ++++
 11 files changed, 102 insertions(+), 1 deletion(-)

-- 
2.19.1

