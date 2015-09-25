Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f177.google.com (mail-wi0-f177.google.com [209.85.212.177])
	by kanga.kvack.org (Postfix) with ESMTP id 8E51E6B0253
	for <linux-mm@kvack.org>; Fri, 25 Sep 2015 08:15:56 -0400 (EDT)
Received: by wiclk2 with SMTP id lk2so16993703wic.1
        for <linux-mm@kvack.org>; Fri, 25 Sep 2015 05:15:56 -0700 (PDT)
Received: from eu-smtp-delivery-143.mimecast.com (eu-smtp-delivery-143.mimecast.com. [146.101.78.143])
        by mx.google.com with ESMTPS id si6si4320547wic.33.2015.09.25.05.15.55
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 25 Sep 2015 05:15:55 -0700 (PDT)
From: Robin Murphy <robin.murphy@arm.com>
Subject: [PATCH 0/4] Assorted DMA mapping tweaks
Date: Fri, 25 Sep 2015 13:15:42 +0100
Message-Id: <cover.1443178314.git.robin.murphy@arm.com>
Content-Type: text/plain; charset=WINDOWS-1252
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, linux-kernel@vger.kernel.org
Cc: arnd@arndb.de, m.szyprowski@samsung.com, sumit.semwal@linaro.org, sakari.ailus@iki.fi, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-arm-kernel@lists.infradead.org

Hi Andrew,

This is a miscellany of fixes and tweaks to the common DMA mapping code
which I've been collecting. They don't strictly depend on each other,
but I figure I may as well send them all together for the sake of
explaining them in one place:

#1 is a straightforward and hopefully obvious bugfix.
#2 has been posted before but I subsequently forgot to follow up on it.
   It's still possible to hit this at least on arm64 systems, with the
   SWIOTLB/pl330 combination blowing up just running dmatest.
#3 follows on from a recent discussion about dma_sync_sg[0]; there's
   already a related patch in -next from Sakari clarifying the docs.
#4 seemed worth posting now that the recent rework means it no longer
   has to be a sprawling touch-all-the-architectures patch for something
   so small.

Thanks,
Robin.

[0]:http://thread.gmane.org/gmane.linux.kernel/2043117

Robin Murphy (4):
  dmapool: Fix overflow condition in pool_find_page
  dma-mapping: Tidy up dma_parms default handling
  dma-debug: Check nents in dma_sync_sg*
  dma-debug: Allow poisoning nonzero allocations

 include/asm-generic/dma-mapping-common.h |  2 +-
 include/linux/dma-debug.h                |  6 ++++--
 include/linux/dma-mapping.h              | 17 ++++++++++-------
 include/linux/poison.h                   |  3 +++
 lib/Kconfig.debug                        | 10 ++++++++++
 lib/dma-debug.c                          | 14 +++++++++++++-
 mm/dmapool.c                             |  2 +-
 7 files changed, 42 insertions(+), 12 deletions(-)

--=20
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
