Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 2824F6B0003
	for <linux-mm@kvack.org>; Sun, 11 Nov 2018 04:04:05 -0500 (EST)
Received: by mail-pl1-f198.google.com with SMTP id s24-v6so4712772plp.12
        for <linux-mm@kvack.org>; Sun, 11 Nov 2018 01:04:05 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id u10-v6sor15292483plr.61.2018.11.11.01.04.03
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 11 Nov 2018 01:04:03 -0800 (PST)
From: Nicolas Boichat <drinkcat@chromium.org>
Subject: [PATCH v2 0/3] iommu/io-pgtable-arm-v7s: Use DMA32 zone for page tables
Date: Sun, 11 Nov 2018 17:03:38 +0800
Message-Id: <20181111090341.120786-1-drinkcat@chromium.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Robin Murphy <robin.murphy@arm.com>
Cc: Will Deacon <will.deacon@arm.com>, Joerg Roedel <joro@8bytes.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@suse.com>, Mel Gorman <mgorman@techsingularity.net>, Levin Alexander <Alexander.Levin@microsoft.com>, Huaisheng Ye <yehs1@lenovo.com>, Mike Rapoport <rppt@linux.vnet.ibm.com>, linux-arm-kernel@lists.infradead.org, iommu@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Yong Wu <yong.wu@mediatek.com>, Matthias Brugger <matthias.bgg@gmail.com>, Tomasz Figa <tfiga@google.com>, yingjoe.chen@mediatek.com

This is a follow-up to the discussion in [1], to make sure that the page
tables allocated by iommu/io-pgtable-arm-v7s are contained within 32-bit
physical address space.

[1] https://lists.linuxfoundation.org/pipermail/iommu/2018-November/030876.html

Fixes since v1:
 - Add support for SLAB_CACHE_DMA32 in slab and slub (patches 1/2)
 - iommu/io-pgtable-arm-v7s (patch 3):
   - Changed approach to use SLAB_CACHE_DMA32 added by the previous
     commit.
   - Use DMA or DMA32 depending on the architecture (DMA for arm,
     DMA32 for arm64).

Nicolas Boichat (3):
  mm: slab/slub: Add check_slab_flags function to check for valid flags
  mm: Add support for SLAB_CACHE_DMA32
  iommu/io-pgtable-arm-v7s: Request DMA32 memory, and improve debugging

 drivers/iommu/io-pgtable-arm-v7s.c | 20 ++++++++++++++++----
 include/linux/slab.h               |  2 ++
 mm/internal.h                      | 21 +++++++++++++++++++--
 mm/slab.c                          | 10 +++-------
 mm/slab.h                          |  3 ++-
 mm/slab_common.c                   |  2 +-
 mm/slub.c                          | 24 +++++++++++++++++-------
 7 files changed, 60 insertions(+), 22 deletions(-)

-- 
2.19.1.930.g4563a0d9d0-goog
