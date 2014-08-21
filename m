Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id E596E6B0035
	for <linux-mm@kvack.org>; Thu, 21 Aug 2014 04:45:34 -0400 (EDT)
Received: by mail-pa0-f49.google.com with SMTP id hz1so13814183pad.8
        for <linux-mm@kvack.org>; Thu, 21 Aug 2014 01:45:34 -0700 (PDT)
Received: from mailout1.w1.samsung.com (mailout1.w1.samsung.com. [210.118.77.11])
        by mx.google.com with ESMTPS id fr9si35551399pdb.74.2014.08.21.01.45.33
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Thu, 21 Aug 2014 01:45:34 -0700 (PDT)
Received: from eucpsbgm1.samsung.com (unknown [203.254.199.244])
 by mailout1.w1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0NAN00HAAEZMHF40@mailout1.w1.samsung.com> for
 linux-mm@kvack.org; Thu, 21 Aug 2014 09:45:22 +0100 (BST)
From: Marek Szyprowski <m.szyprowski@samsung.com>
Subject: [PATCH 0/2] ARM: Remove lowmem limit for default CMA region
Date: Thu, 21 Aug 2014 10:45:12 +0200
Message-id: <1408610714-16204-1-git-send-email-m.szyprowski@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org
Cc: Marek Szyprowski <m.szyprowski@samsung.com>, Russell King - ARM Linux <linux@arm.linux.org.uk>, Michal Nazarewicz <mina86@mina86.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>

Hello,

Russell King recently noticed that limiting default CMA region only to
low memory on ARM architecture causes serious memory management issues
with machines having a lot of memory (which is mainly available as high
memory). More information can be found the following thread:
http://thread.gmane.org/gmane.linux.ports.arm.kernel/348441/

Those two patches removes this limit letting kernel to put default CMA
region into high memory when this is possible (there is enough high
memory available and architecture specific DMA limit fits).

This should solve strange OOM issues on systems with lots of RAM
(i.e. >1GiB) and large (>256M) CMA area.

Best regards
Marek Szyprowski
Samsung R&D Institute Poland


Marek Szyprowski (2):
  mm: cma: adjust address limit to avoid hitting low/high memory
    boundary
  ARM: mm: don't limit default CMA region only to low memory

 arch/arm/mm/init.c |  2 +-
 mm/cma.c           | 21 +++++++++++++++++++++
 2 files changed, 22 insertions(+), 1 deletion(-)

-- 
1.9.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
