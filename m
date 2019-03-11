Return-Path: <SRS0=4gxf=RO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_PASS,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CB5D9C43381
	for <linux-mm@archiver.kernel.org>; Mon, 11 Mar 2019 20:55:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 863DB2147C
	for <linux-mm@archiver.kernel.org>; Mon, 11 Mar 2019 20:55:42 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 863DB2147C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1FF1C8E0003; Mon, 11 Mar 2019 16:55:42 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1ADDE8E0002; Mon, 11 Mar 2019 16:55:42 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0C4DB8E0003; Mon, 11 Mar 2019 16:55:42 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id C0F9B8E0002
	for <linux-mm@kvack.org>; Mon, 11 Mar 2019 16:55:41 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id z5so157160pgv.11
        for <linux-mm@kvack.org>; Mon, 11 Mar 2019 13:55:41 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id;
        bh=CZ5LpoQlDUJ2t6PN49q7I9YAJQjIEhTDk43oykgNnb8=;
        b=sxgyfDpYvx3rUs+2Oli/NLObg1ixWTOQ9+yrtj9GUvsGvVB5gcQ+zJ8AGzxNSbfX+/
         EMVYA1kkF1bvH6lX33SZnLzfLbG/hZ3523yp5ADNePcSeqcv+/gOLnSnmvMHEDCkOcdK
         lPC1Oe3sv3UtCy0pgIqv9bHuMZSKtwVMnU1b0RgvGr0UPtvi5uOp1IvEFmumxTChn2xe
         QeFh6uk69hOkiJElAoxoPGOtI4To0TkGLIaRAliZqnmSX/02xmVAyW38RX5bcPryXDZN
         YnQc7H0Kj6DVKTrHb2S6g1PfgVYtDusB0PmEParMmODZMr5ORCWd3SnL8HzUQngBAIu5
         wmrg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of keith.busch@intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=keith.busch@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAVRHItdNQDst7sRv3ktsNtwi45Ruoz1cWg3oGASPmh681IFDn9g
	Symh25m/FLqTIQRYnpAiq789vJWch8jBMCcKjr7rq/OXu/0lRfB779z6/KtMqi5Xcsotw2iRRM9
	oDv6NVTvTHMsVkhxrSn+IPRV8XNJtQXIZYBKWnWTLzgflVFhv/mOp/mbIqi64Zd8ZYA==
X-Received: by 2002:a17:902:9893:: with SMTP id s19mr36215621plp.165.1552337741295;
        Mon, 11 Mar 2019 13:55:41 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwKpSJfGeO6nj48TMCFIWwMidbrRNT9hDgHKnwlE5zAvYMUSgx8LAUmXj8AvIhXnrbKXsjd
X-Received: by 2002:a17:902:9893:: with SMTP id s19mr36215562plp.165.1552337740130;
        Mon, 11 Mar 2019 13:55:40 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552337740; cv=none;
        d=google.com; s=arc-20160816;
        b=QJJOhxN/S3Jhi2YcwoIGpyVxMHpSReIsW3oQV02ZyFFesxqzpB2gDxatchln5ouEjB
         Bp/dySqaAn0M0oPAY0vLWCxo8CI7z2G9VVUxW8kTnkoqVI5XP5tlkTOTWJ5Fpy+XuaYZ
         GVi91H5prg+XNVUzoWzXn92Z4WgmyLl36Zvz6ZKDMsFdqpwrwGKIXJnP9557QG5PiNi/
         f9PglSzLKRUA3Jbweo2JgbtT6QQVhNuHPVlmjDXN/nnyYFSi9wrjGkTkOVkS7wGkBrrM
         CKs6LAnU/wAh2vpDE5KNGFCm0J8oINGqN02sbhvXRw5WFMzIJMmwCq2JYyg5uMqdBWg2
         YMJg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from;
        bh=CZ5LpoQlDUJ2t6PN49q7I9YAJQjIEhTDk43oykgNnb8=;
        b=xyZ/zzzX12RWqZc1mj3+oqLEHEOEqrFJ6P16ln2a5p68IO6Y7AZ1rHw1BVfUCA6yDM
         A8xKauFZurA2jDNU/HlJkzcxV/7NsQt9HdqDX+zN39PG9j0QkfQPxhDMtltskeezhj5C
         MXcxWWy9kwh09LGkt+NPxScMlcb3W/FDfWTW/PzyDwOlivb5sYaFyQAbZlxwfM/ovTeg
         y/AVvyQrx/zdhn7uvAsqomb5qvY3wAInq0goX800iB8nueWmHyaGtQubY7uzh0cYVn2C
         8vGe+SnWbU3ezIMSFEaCuxz6GzDnw3nGdlG5kaT2uYmSSg6kA1e+eKO7IRGVjJUNYMCK
         Yipw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of keith.busch@intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=keith.busch@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id n189si5626588pga.46.2019.03.11.13.55.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Mar 2019 13:55:40 -0700 (PDT)
Received-SPF: pass (google.com: domain of keith.busch@intel.com designates 134.134.136.20 as permitted sender) client-ip=134.134.136.20;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of keith.busch@intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=keith.busch@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga003.fm.intel.com ([10.253.24.29])
  by orsmga101.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 11 Mar 2019 13:55:39 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.58,468,1544515200"; 
   d="scan'208";a="139910152"
Received: from unknown (HELO localhost.lm.intel.com) ([10.232.112.69])
  by FMSMGA003.fm.intel.com with ESMTP; 11 Mar 2019 13:55:39 -0700
From: Keith Busch <keith.busch@intel.com>
To: linux-kernel@vger.kernel.org,
	linux-acpi@vger.kernel.org,
	linux-mm@kvack.org,
	linux-api@vger.kernel.org
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Rafael Wysocki <rafael@kernel.org>,
	Dave Hansen <dave.hansen@intel.com>,
	Dan Williams <dan.j.williams@intel.com>,
	Jonathan Cameron <jonathan.cameron@huawei.com>,
	Brice Goglin <Brice.Goglin@inria.fr>,
	Keith Busch <keith.busch@intel.com>
Subject: [PATCHv8 00/10] Heterogenous memory node attributes
Date: Mon, 11 Mar 2019 14:55:56 -0600
Message-Id: <20190311205606.11228-1-keith.busch@intel.com>
X-Mailer: git-send-email 2.13.6
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

== Changes since v7 ==

  Fixed an early return that prevented reporting HMAT when there are no
  direct attached initiators.

  Fixed introducing a variable that was unused until several patches
  later.

  Miscellaneous typos, editorial clarifications, and whitespace fixups.

  Merged to most current linux-next.

  Added received review, test, and ack by's.

I've published a git tree available on this branch:

  https://git.kernel.org/pub/scm/linux/kernel/git/kbusch/linux.git/log/?h=hmat-v8

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

 Documentation/ABI/stable/sysfs-devices-node   |  87 +++-
 Documentation/admin-guide/mm/numaperf.rst     | 169 +++++++
 arch/arm64/kernel/acpi_numa.c                 |   2 +-
 arch/arm64/kernel/smp.c                       |   4 +-
 arch/ia64/kernel/acpi.c                       |  16 +-
 arch/x86/kernel/acpi/boot.c                   |  36 +-
 drivers/acpi/Kconfig                          |   1 +
 drivers/acpi/Makefile                         |   1 +
 drivers/acpi/hmat/Kconfig                     |  11 +
 drivers/acpi/hmat/Makefile                    |   1 +
 drivers/acpi/hmat/hmat.c                      | 666 ++++++++++++++++++++++++++
 drivers/acpi/numa.c                           |  16 +-
 drivers/acpi/scan.c                           |   4 +-
 drivers/acpi/tables.c                         |  76 ++-
 drivers/base/Kconfig                          |   8 +
 drivers/base/node.c                           | 352 +++++++++++++-
 drivers/irqchip/irq-gic-v2m.c                 |   2 +-
 drivers/irqchip/irq-gic-v3-its-pci-msi.c      |   2 +-
 drivers/irqchip/irq-gic-v3-its-platform-msi.c |   2 +-
 drivers/irqchip/irq-gic-v3-its.c              |   6 +-
 drivers/irqchip/irq-gic-v3.c                  |  10 +-
 drivers/irqchip/irq-gic.c                     |   4 +-
 drivers/mailbox/pcc.c                         |   2 +-
 include/linux/acpi.h                          |   6 +-
 include/linux/node.h                          |  71 +++
 25 files changed, 1489 insertions(+), 66 deletions(-)
 create mode 100644 Documentation/admin-guide/mm/numaperf.rst
 create mode 100644 drivers/acpi/hmat/Kconfig
 create mode 100644 drivers/acpi/hmat/Makefile
 create mode 100644 drivers/acpi/hmat/hmat.c

-- 
2.14.4

