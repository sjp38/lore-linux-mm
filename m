Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f47.google.com (mail-la0-f47.google.com [209.85.215.47])
	by kanga.kvack.org (Postfix) with ESMTP id 6D9C96B0254
	for <linux-mm@kvack.org>; Tue,  1 Sep 2015 10:26:15 -0400 (EDT)
Received: by lanb10 with SMTP id b10so771094lan.3
        for <linux-mm@kvack.org>; Tue, 01 Sep 2015 07:26:14 -0700 (PDT)
Received: from mail-la0-x22f.google.com (mail-la0-x22f.google.com. [2a00:1450:4010:c03::22f])
        by mx.google.com with ESMTPS id 7si7008060lar.137.2015.09.01.07.26.13
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 01 Sep 2015 07:26:14 -0700 (PDT)
Received: by lamp12 with SMTP id p12so886950lam.0
        for <linux-mm@kvack.org>; Tue, 01 Sep 2015 07:26:13 -0700 (PDT)
From: Alexander Kuleshov <kuleshovmail@gmail.com>
Subject: [PATCH 0/5 v2] mm/memblock: Introduce memblock_first_region_size() helper
Date: Tue,  1 Sep 2015 20:25:27 +0600
Message-Id: <1441117527-30466-1-git-send-email-kuleshovmail@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Tony Luck <tony.luck@intel.com>, Pekka Enberg <penberg@kernel.org>, Mel Gorman <mgorman@suse.de>, Xishi Qiu <qiuxishi@huawei.com>, Robin Holt <holt@sgi.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Alexander Kuleshov <kuleshovmail@gmail.com>

Some architectures (like s390, microblaze and etc...) require size
of the first memory region. This patch set provides new memblock_first_region_size()
helper for this case and change usage of memblock.memory.regions[0].size on
memblock_first_region_size() for the following architectures:

* s390
* microblaze
* arm
* unicore32

Changelog:

v2:

Added changes in the architectures to the patchset.

Alexander Kuleshov (5):
  mm/memblock: Introduce memblock_first_region_size() helper
  s390/setup: use memblock_first_region_size helper
  microblaze/mm: Use memblock_first_region_size() helper
  unicore32/mmu: use memblock_first_region_size() helper
  arm/mmu: Use memblock_first_region_size() helper

 arch/arm/mm/mmu.c         | 2 +-
 arch/microblaze/mm/init.c | 6 +++---
 arch/s390/kernel/setup.c  | 2 +-
 arch/unicore32/mm/mmu.c   | 2 +-
 include/linux/memblock.h  | 1 +
 mm/memblock.c             | 5 +++++
 6 files changed, 12 insertions(+), 6 deletions(-)

-- 
2.5.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
