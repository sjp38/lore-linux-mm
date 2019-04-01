Return-Path: <SRS0=sWz3=SD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CD8C9C43381
	for <linux-mm@archiver.kernel.org>; Mon,  1 Apr 2019 15:36:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4408520880
	for <linux-mm@archiver.kernel.org>; Mon,  1 Apr 2019 15:36:59 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4408520880
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=huawei.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CE3B76B0005; Mon,  1 Apr 2019 11:36:58 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C91726B0008; Mon,  1 Apr 2019 11:36:58 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B816B6B000A; Mon,  1 Apr 2019 11:36:58 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f198.google.com (mail-oi1-f198.google.com [209.85.167.198])
	by kanga.kvack.org (Postfix) with ESMTP id 8DE936B0005
	for <linux-mm@kvack.org>; Mon,  1 Apr 2019 11:36:58 -0400 (EDT)
Received: by mail-oi1-f198.google.com with SMTP id w10so3411176oie.1
        for <linux-mm@kvack.org>; Mon, 01 Apr 2019 08:36:58 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:mime-version:content-transfer-encoding;
        bh=Yl60sfy6vyQCDzzSBdC9XVYQbpu2Hg/cYdIWAwEPKQM=;
        b=a2+VKoeKS/5ofO53sseDJ+ZRpIdGya5R/dAIkNwM0UrQnCMNvU6GQwCq9xP6xHeC/E
         IlQX34w3nMmFeJ8fghRCI/H72gFB6Q6HPt6SyVL2cZvHVgH1+/TnYfrbeoQS6XKMImf4
         MG+F2nfyaklhY/mc2bcsJW77VgCkptLg8IESev9g7FiUrhdH4Og1sDkBZxhw3xU01dkg
         q7dfio0E71BtIHsWBNxZM5c+gE9qN4j62Ik1exZWda5iMj8DrrPZ9obr1VbD2IuczQqA
         XkYU20esRk3xL5/PIREDjEKywTF9ieXPGidDiKCCbQioQl5BMWjLeK4hpvwNmOuu4S8c
         5eWg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jonathan.cameron@huawei.com designates 45.249.212.191 as permitted sender) smtp.mailfrom=jonathan.cameron@huawei.com
X-Gm-Message-State: APjAAAWt9sx0Z66s1Lb1D0yWm826+3CFfkuz0TX7Z3EnpNKOS/ZqBysO
	E5OMX9WBlYYUKurDHMnN8sZA0XMcMKb9SFeKt1vsM4eup31aD8wc9gqKkCO+SdKfxJsB6aRK6my
	orwyUGmA4WGQas5++F+nWqi0P2CKj4FNWcP1wJMHAtO2MJgGtEYAAY7TuWPYnOM+r3Q==
X-Received: by 2002:a05:6830:1310:: with SMTP id p16mr36320963otq.110.1554133018159;
        Mon, 01 Apr 2019 08:36:58 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzCUZVY9WjheN8xYgcmgP9gLty0CrAj1yDXDpSoXiSGCQvn0Jn/QUoogGuxT+HLt8IZa9IX
X-Received: by 2002:a05:6830:1310:: with SMTP id p16mr36320894otq.110.1554133017157;
        Mon, 01 Apr 2019 08:36:57 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554133017; cv=none;
        d=google.com; s=arc-20160816;
        b=Dilhj4d3nD0FNLfHEgZRs7vE9ukXNPPJUn542bTZjN93zplrWtHWlL3FUl8obGw1bi
         PHxK8Gk29oxovKpIGS++Ekd3F4Sc2xhDY4gK53gQqVD0LWDSEn2ANCKmIRLT1jPaRh8Q
         nl91v/rEqQdPdArm/5wJdAQ5xnJZz793VUY282WLfVuNZGqEsHgRX2aN1dnb9x+ubIoM
         jYI0GY+iWDNWuepJ9aUZwv0RGyUu0sSqijTgtQ9GxZ1rZM1/2u9qm65WuE+W9GKnkUla
         S8ZYbYgwJltxFcfMmEXzx3MJqRVLiTHHmvwYNiS2hHv416//IMxxHHEMUv4qEhOQGAL8
         7W2Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from;
        bh=Yl60sfy6vyQCDzzSBdC9XVYQbpu2Hg/cYdIWAwEPKQM=;
        b=L3cqGXi8jEfopM5120JexfyR0WLUSYPc2SJviOUeFpHJcriCsJIVQ0PfUW99EZTzgn
         cmVMqyxEVvbQz4f9Mp0FnMbkcm7YFR3yns48VC2wZ5E/XIZNJpA0N2p0srzTjL6IwRTz
         UeVCOvzV6eiA2kknUY3XYNT/J7tItzeonwZk5A3S99KEKbY89PXiapSNM9Ay2zazL5XI
         mo2srzuCmarClTxvNj0Ufn1jC1LZ/Im4r86HXA4OG0GjMGD37zksoZN7PezV+K9i8yIi
         J474SklK0wRdBLanKHtsemtDjOGyMpsTaVW6Emc3qzv//MA1HTKwe7EdyKTi8gxAUxgA
         47Yg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jonathan.cameron@huawei.com designates 45.249.212.191 as permitted sender) smtp.mailfrom=jonathan.cameron@huawei.com
Received: from huawei.com (szxga05-in.huawei.com. [45.249.212.191])
        by mx.google.com with ESMTPS id u4si2009464otb.260.2019.04.01.08.36.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 01 Apr 2019 08:36:57 -0700 (PDT)
Received-SPF: pass (google.com: domain of jonathan.cameron@huawei.com designates 45.249.212.191 as permitted sender) client-ip=45.249.212.191;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jonathan.cameron@huawei.com designates 45.249.212.191 as permitted sender) smtp.mailfrom=jonathan.cameron@huawei.com
Received: from DGGEMS414-HUB.china.huawei.com (unknown [10.3.19.214])
	by Forcepoint Email with ESMTP id 557B08508042D64384B8;
	Mon,  1 Apr 2019 23:36:51 +0800 (CST)
Received: from FRA1000014316.huawei.com (100.126.230.97) by
 DGGEMS414-HUB.china.huawei.com (10.3.19.214) with Microsoft SMTP Server id
 14.3.408.0; Mon, 1 Apr 2019 23:36:44 +0800
From: Jonathan Cameron <Jonathan.Cameron@huawei.com>
To: <linux-mm@kvack.org>, <linux-acpi@vger.kernel.org>,
	<linux-arm-kernel@lists.infradead.org>
CC: <rjw@rjwysocki.net>, <keith.busch@intel.com>, <linuxarm@huawei.com>,
	<jglisse@redhat.com>, Jonathan Cameron <Jonathan.Cameron@huawei.com>
Subject: [RFC PATCH v2 0/3] ACPI: Support generic initiator proximity domains
Date: Mon, 1 Apr 2019 23:36:00 +0800
Message-ID: <20190401153603.67775-1-Jonathan.Cameron@huawei.com>
X-Mailer: git-send-email 2.19.1
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Content-Type: text/plain
X-Originating-IP: [100.126.230.97]
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Changes since RFC V1.
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

This patch set introduces 'just enough' to make them work for arm64.
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

Jonathan Cameron (3):
  ACPI: Support Generic Initiator only domains
  arm64: Support Generic Initiator only domains
  ACPI: Let ACPI know we support Generic Initiator Affinity Structures

 arch/arm64/kernel/smp.c        |  8 +++++
 drivers/acpi/bus.c             |  1 +
 drivers/acpi/numa.c            | 62 +++++++++++++++++++++++++++++++++-
 drivers/base/node.c            |  3 ++
 include/asm-generic/topology.h |  3 ++
 include/linux/acpi.h           |  1 +
 include/linux/nodemask.h       |  1 +
 include/linux/topology.h       |  7 ++++
 8 files changed, 85 insertions(+), 1 deletion(-)

-- 
2.18.0

