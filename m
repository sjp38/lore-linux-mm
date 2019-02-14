Return-Path: <SRS0=uhAD=QV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7CBF9C43381
	for <linux-mm@archiver.kernel.org>; Thu, 14 Feb 2019 17:10:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 36FC4222D7
	for <linux-mm@archiver.kernel.org>; Thu, 14 Feb 2019 17:10:41 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 36FC4222D7
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0B4AA8E0003; Thu, 14 Feb 2019 12:10:41 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 063B78E0001; Thu, 14 Feb 2019 12:10:41 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EBC838E0003; Thu, 14 Feb 2019 12:10:40 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id ABDE28E0001
	for <linux-mm@kvack.org>; Thu, 14 Feb 2019 12:10:40 -0500 (EST)
Received: by mail-pl1-f199.google.com with SMTP id b24so4741703pls.11
        for <linux-mm@kvack.org>; Thu, 14 Feb 2019 09:10:40 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id;
        bh=aAfl4dS5AoUlguQ06daS7InlD2mgNefIJaWvl5vgoko=;
        b=ULpd/+vExULneJaf5IkIyjSEBZUgnQpdhRqJmTqc4jpvL8LLBYPRta+4oiawujCxGa
         NYZEdwhjyX42EFWTNvxhDlJObRzbMqvy9fFWqVwwDf774b9pDDmabU4QAYIU9f3STl2w
         UPx8bJv6Jt5TGAOYMJki8c45G57ax3Kyzglw3zO10fNrvteobt2djg8AQGX9lAv4jvgO
         tUIfWu2DvfIPlo4lUZlKCQRCVISpcwAA4tvBKLRNAwM2ti76PIrE4PvaF/tPr7/bE5+Y
         /HE3OgVmr+Hd/N+Ekvj6ZNlGVlVe6nTyHXEpUVMZ8SYcLWHKikfw8aGTYH243oZ7Kzvh
         HYvA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of keith.busch@intel.com designates 134.134.136.126 as permitted sender) smtp.mailfrom=keith.busch@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: AHQUAuaqaa3UyWANSWyi53GZdImZdXokuR17ngX4ZXpYMl1iDj8s8GCF
	BYXdP02RlzvITft4AcrrOfRo7PgUdILRfNoY9Hq9gjawSg/0PHF182c9z2N8hZSHldnmY+kO0ub
	g0PLNc2x4JaJ3m0vAYPtpi9HI3WP0XwgpXUcEzAC6/i/YGNDgPNS/ioiKvmAd+45XRg==
X-Received: by 2002:a17:902:4d46:: with SMTP id o6mr5079854plh.302.1550164240347;
        Thu, 14 Feb 2019 09:10:40 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYsjYXbzyw8XuDJR5HbiPv2UEzK/6wu+09fW0XEUsdBV+SvlwYG8fg6p9i/BPaJRDDZgDBN
X-Received: by 2002:a17:902:4d46:: with SMTP id o6mr5079793plh.302.1550164239406;
        Thu, 14 Feb 2019 09:10:39 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550164239; cv=none;
        d=google.com; s=arc-20160816;
        b=xUYAdFjimfvg8Jg1dGFJp4RMiVnr+E6SpX0Je5c5gJKICDsvyHWgK6gT0nPyviTm7N
         tcrm+7D6a14Vs5jIsqwiIg1nWLcmd9rsplNlZlVOwAE1tfhev14HCmHoO9AAYEE/Eot4
         JTU4MhLX6pDgzzxgZVtIBwU4AhTqD56xkJVX3lEN8VqNSGmPK6W3o6kKfe8Vu5MeZO6T
         JL4RomT7GUpxX5jOStiOTJWS8B0aAOBO3jyRTf7+RjZXcvhRw1hAmKdHT3PxX+eyHOAi
         sllP6cV4geEtlcL58gFUe4VrWfF9LG0E8f8cR2dk4aSvYCTI7TKw/8T/BWG2Iv9HGsVT
         rWvA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from;
        bh=aAfl4dS5AoUlguQ06daS7InlD2mgNefIJaWvl5vgoko=;
        b=hOCCzC1QxJXMnzZU4lKgPfDLW3hfB9MqgXIDh0565ahm7wk48cEZIYTGqXM16xxCyi
         Cid9rdE2UCEnmXko7h0kzCDt+eodOX178taxArsCPmwtOJYAG91V1Jnv/Le2dvG5Y4pR
         fM2h6vxYQcFRoJd4lxrupgvwJxBiej4mvoBNZmCHNoP4UGNQnu632Gr3dNnzSDbgpnDM
         ZL0YpwOu5PgVhhjRp7AxMSkOygRx6sTynTb6DmV3HRwYTRS/c071P7FrM5nC0Pz2uBl5
         ThKXrKbfCuDfKMngL9/TNpZxphwj8bRWO1QR8bmPCBdB6m1+7RW74D6jHSLyYPZd7meW
         53rw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of keith.busch@intel.com designates 134.134.136.126 as permitted sender) smtp.mailfrom=keith.busch@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga18.intel.com (mga18.intel.com. [134.134.136.126])
        by mx.google.com with ESMTPS id j17si2724426pfn.271.2019.02.14.09.10.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Feb 2019 09:10:39 -0800 (PST)
Received-SPF: pass (google.com: domain of keith.busch@intel.com designates 134.134.136.126 as permitted sender) client-ip=134.134.136.126;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of keith.busch@intel.com designates 134.134.136.126 as permitted sender) smtp.mailfrom=keith.busch@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga003.fm.intel.com ([10.253.24.29])
  by orsmga106.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 14 Feb 2019 09:10:38 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.58,369,1544515200"; 
   d="scan'208";a="133613093"
Received: from unknown (HELO localhost.lm.intel.com) ([10.232.112.69])
  by FMSMGA003.fm.intel.com with ESMTP; 14 Feb 2019 09:10:37 -0800
From: Keith Busch <keith.busch@intel.com>
To: linux-kernel@vger.kernel.org,
	linux-acpi@vger.kernel.org,
	linux-mm@kvack.org,
	linux-api@vger.kernel.org
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Rafael Wysocki <rafael@kernel.org>,
	Dave Hansen <dave.hansen@intel.com>,
	Dan Williams <dan.j.williams@intel.com>,
	Keith Busch <keith.busch@intel.com>
Subject: [PATCHv6 00/10] Heterogenous memory node attributes
Date: Thu, 14 Feb 2019 10:10:07 -0700
Message-Id: <20190214171017.9362-1-keith.busch@intel.com>
X-Mailer: git-send-email 2.13.6
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

== Changes since v5 ==

  Updated HMAT parsing to account for the recently released ACPI 6.3
  changes.

  HMAT attribute calculation overflow checks.

  Fixed memory leak if HMAT parse fails.

  Minor change to the patch order. All the base node attributes occur
  before HMAT usage for these new node attributes to resolve a
  dependency on a new struct.

  Reporting failures to parse HMAT or allocate structures are elevated
  to a NOTICE level from DEBUG. Any failure will result in just one
  print so that it is obvious something may need to be investigated
  rather than silently fail, but also not to be too alarming either.

  Determining the cpu and memory node local relationships is quite
  different this time (PATCH 7/10). The local relationship to a memory
  target will be either *only* the node from the Initiator Proximity
  Domain if provided, or if it is not provided, all the nodes that have
  the same highest performance. Latency was chosen to take prioirty over
  bandwidth when ranking performance.

  Renamed "side_cache" to "memory_side_cache". The previous name was
  ambiguous.

  Removed "level" as an exported cache attribute. It was redundant with
  the directory name anyway.

  Minor changelog updates, added received reviews, and documentation
  fixes.

Just want to point out that I am sticking with struct device
instead of using struct kobject embedded in the attribute tracking
structures. Previous feedback was leaning either way on this point.

== Background ==

Platforms may provide multiple types of cpu attached system memory. The
memory ranges for each type may have different characteristics that
applications may wish to know about when considering what node they want
their memory allocated from. 

It had previously been difficult to describe these setups as memory
rangers were generally lumped into the NUMA node of the CPUs. New
platform attributes have been created and in use today that describe
the more complex memory hierarchies that can be created.

This series' objective is to provide the attributes from such systems
that are useful for applications to know about, and readily usable with
existing tools and libraries. Those applications may query performance
attributes relative to a particular CPU they're running on in order to
make more informed choices for where they want to allocate hot and cold
data. This works with mbind() or the numactl library.

Keith Busch (10):
  acpi: Create subtable parsing infrastructure
  acpi: Add HMAT to generic parsing tables
  acpi/hmat: Parse and report heterogeneous memory
  node: Link memory nodes to their compute nodes
  node: Add heterogenous memory access attributes
  node: Add memory-side caching attributes
  acpi/hmat: Register processor domain to its memory
  acpi/hmat: Register performance attributes
  acpi/hmat: Register memory side cache attributes
  doc/mm: New documentation for memory performance

 Documentation/ABI/stable/sysfs-devices-node   |  89 +++-
 Documentation/admin-guide/mm/numaperf.rst     | 164 +++++++
 arch/arm64/kernel/acpi_numa.c                 |   2 +-
 arch/arm64/kernel/smp.c                       |   4 +-
 arch/ia64/kernel/acpi.c                       |  12 +-
 arch/x86/kernel/acpi/boot.c                   |  36 +-
 drivers/acpi/Kconfig                          |   1 +
 drivers/acpi/Makefile                         |   1 +
 drivers/acpi/hmat/Kconfig                     |   9 +
 drivers/acpi/hmat/Makefile                    |   1 +
 drivers/acpi/hmat/hmat.c                      | 677 ++++++++++++++++++++++++++
 drivers/acpi/numa.c                           |  16 +-
 drivers/acpi/scan.c                           |   4 +-
 drivers/acpi/tables.c                         |  76 ++-
 drivers/base/Kconfig                          |   8 +
 drivers/base/node.c                           | 351 ++++++++++++-
 drivers/irqchip/irq-gic-v2m.c                 |   2 +-
 drivers/irqchip/irq-gic-v3-its-pci-msi.c      |   2 +-
 drivers/irqchip/irq-gic-v3-its-platform-msi.c |   2 +-
 drivers/irqchip/irq-gic-v3-its.c              |   6 +-
 drivers/irqchip/irq-gic-v3.c                  |  10 +-
 drivers/irqchip/irq-gic.c                     |   4 +-
 drivers/mailbox/pcc.c                         |   2 +-
 include/linux/acpi.h                          |   6 +-
 include/linux/node.h                          |  60 ++-
 25 files changed, 1480 insertions(+), 65 deletions(-)
 create mode 100644 Documentation/admin-guide/mm/numaperf.rst
 create mode 100644 drivers/acpi/hmat/Kconfig
 create mode 100644 drivers/acpi/hmat/Makefile
 create mode 100644 drivers/acpi/hmat/hmat.c

-- 
2.14.4

