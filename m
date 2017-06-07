Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id 778256B0350
	for <linux-mm@kvack.org>; Wed,  7 Jun 2017 17:17:52 -0400 (EDT)
Received: by mail-io0-f197.google.com with SMTP id t87so6829772ioe.7
        for <linux-mm@kvack.org>; Wed, 07 Jun 2017 14:17:52 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id v3sor1341440iof.100.2017.06.07.14.17.51
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 07 Jun 2017 14:17:51 -0700 (PDT)
From: Tycho Andersen <tycho@docker.com>
Subject: [RFC v4 0/3] Add support for eXclusive Page Frame Ownership
Date: Wed,  7 Jun 2017 15:16:50 -0600
Message-Id: <20170607211653.14536-1-tycho@docker.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Juerg Haefliger <juergh@gmail.com>, kernel-hardening@lists.openwall.com, Tycho Andersen <tycho@docker.com>

Hi all,

I have talked with Juerg about picking up the torch for XPFO [1], and have been
playing around with the set for a bit. I've fixed one memory corruption issue
since v3, and also tried and failed at integrating hugepages support. The code
in patch 3 seems to split up the page and apply the right protections, but
somehow the lkdtm test read succeeds and no fault is generated, and I don't
understand why.

[1]: https://lkml.org/lkml/2016/11/4/245

Thoughts welcome,

Tycho

Juerg Haefliger (2):
  mm, x86: Add support for eXclusive Page Frame Ownership (XPFO)
  lkdtm: Add tests for XPFO

Tycho Andersen (1):
  xpfo: add support for hugepages

 Documentation/admin-guide/kernel-parameters.txt |   2 +
 arch/x86/Kconfig                                |   1 +
 arch/x86/include/asm/pgtable.h                  |  22 +++
 arch/x86/mm/Makefile                            |   1 +
 arch/x86/mm/pageattr.c                          |  21 +--
 arch/x86/mm/xpfo.c                              |  82 +++++++++
 drivers/misc/Makefile                           |   1 +
 drivers/misc/lkdtm.h                            |   3 +
 drivers/misc/lkdtm_core.c                       |   1 +
 drivers/misc/lkdtm_xpfo.c                       | 105 ++++++++++++
 include/linux/highmem.h                         |  15 +-
 include/linux/xpfo.h                            |  38 +++++
 mm/Makefile                                     |   1 +
 mm/page_alloc.c                                 |   2 +
 mm/page_ext.c                                   |   4 +
 mm/xpfo.c                                       | 210 ++++++++++++++++++++++++
 security/Kconfig                                |  19 +++
 17 files changed, 508 insertions(+), 20 deletions(-)
 create mode 100644 arch/x86/mm/xpfo.c
 create mode 100644 drivers/misc/lkdtm_xpfo.c
 create mode 100644 include/linux/xpfo.h
 create mode 100644 mm/xpfo.c

-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
