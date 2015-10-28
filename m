Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f173.google.com (mail-ig0-f173.google.com [209.85.213.173])
	by kanga.kvack.org (Postfix) with ESMTP id CC64682F64
	for <linux-mm@kvack.org>; Wed, 28 Oct 2015 07:23:41 -0400 (EDT)
Received: by igbhv6 with SMTP id hv6so4513179igb.0
        for <linux-mm@kvack.org>; Wed, 28 Oct 2015 04:23:41 -0700 (PDT)
Received: from smtprelay.synopsys.com (smtprelay4.synopsys.com. [198.182.47.9])
        by mx.google.com with ESMTPS id j8si20756827ige.88.2015.10.28.04.23.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 28 Oct 2015 04:23:41 -0700 (PDT)
From: Vineet Gupta <Vineet.Gupta1@synopsys.com>
Subject: [PATCH 0/3] HIGHMEM support for ARC
Date: Wed, 28 Oct 2015 16:53:10 +0530
Message-ID: <1446031393-2312-1-git-send-email-vgupta@synopsys.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Max Filippov <jcmvbkbc@gmail.com>, Joonsoo Kim <js1304@gmail.com>, Mel
 Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-snps-arc@lists.infraded.org, Alexey Brodkin <Alexey.Brodkin@synopsys.com>, Vineet Gupta <Vineet.Gupta1@synopsys.com>

Hi,

This series adds highmem suppport for ARC. It adds the kmap atomic API and some
leg work for future patch for PAE40.

Please Review.

Thx,
-Vineet

Vineet Gupta (3):
  ARC: mm: preps ahead of HIGHMEM support
  ARC: mm: HIGHMEM: kmap API implementation
  ARC: mm: HIGHMEM: switch to using phys_addr_t for physical addresses

 arch/arc/Kconfig                  |   7 ++
 arch/arc/include/asm/cacheflush.h |   8 +--
 arch/arc/include/asm/highmem.h    |  61 +++++++++++++++++
 arch/arc/include/asm/kmap_types.h |  18 +++++
 arch/arc/include/asm/pgtable.h    |   9 +--
 arch/arc/include/asm/processor.h  |   7 +-
 arch/arc/mm/Makefile              |   1 +
 arch/arc/mm/cache.c               |  42 +++++++-----
 arch/arc/mm/fault.c               |  13 +++-
 arch/arc/mm/highmem.c             | 138 ++++++++++++++++++++++++++++++++++++++
 arch/arc/mm/init.c                |  20 +++++-
 arch/arc/mm/tlb.c                 |  10 +--
 12 files changed, 293 insertions(+), 41 deletions(-)
 create mode 100644 arch/arc/include/asm/highmem.h
 create mode 100644 arch/arc/include/asm/kmap_types.h
 create mode 100644 arch/arc/mm/highmem.c

-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
