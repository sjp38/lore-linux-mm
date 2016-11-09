Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 5B0756B0038
	for <linux-mm@kvack.org>; Wed,  9 Nov 2016 16:21:02 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id n85so95709311pfi.4
        for <linux-mm@kvack.org>; Wed, 09 Nov 2016 13:21:02 -0800 (PST)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id t8si1091843pay.1.2016.11.09.13.21.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 09 Nov 2016 13:21:01 -0800 (PST)
Subject: [swiotlb PATCH v3 0/3] Add support for DMA writable pages being
 writable by the network stack.
From: Alexander Duyck <alexander.h.duyck@intel.com>
Date: Wed, 09 Nov 2016 10:19:57 -0500
Message-ID: <20161109151639.25151.24290.stgit@ahduyck-blue-test.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, konrad.wilk@oracle.com
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org

This patch series is a subset of the patches originally submitted with the
above patch title.  Specifically all of these patches relate to the
swiotlb.

I wasn't sure if I needed to resubmit this series or not.  I see that v2 is
currently sitting in the for-linus-4.9 branch of the swiotlb git repo.  If
no updates are required for the previous set then this patch set can be
ignored since most of the changes are just cosmetic.

v1: Split out changes DMA_ERROR_CODE fix for swiotlb-xen
    Minor fixes based on issues found by kernel build bot
    Few minor changes for issues found on code review
    Added Acked-by for patches that were acked and not changed

v2: Added a few more Acked-by
    Added swiotlb_unmap_sg to functions dropped in patch 1, dropped Acked-by
    Submitting patches to mm instead of net-next

v3: Split patch set, first 3 to swiotlb, remaining 23 still to mm
    Minor clean-ups for swiotlb code, mostly cosmetic
    Replaced my patch with the one originally submitted by Christoph Hellwig

---

Alexander Duyck (2):
      swiotlb-xen: Enforce return of DMA_ERROR_CODE in mapping function
      swiotlb: Add support for DMA_ATTR_SKIP_CPU_SYNC

Christoph Hellwig (1):
      swiotlb: remove unused swiotlb_map_sg and swiotlb_unmap_sg functions


 arch/arm/xen/mm.c              |    1 -
 arch/x86/xen/pci-swiotlb-xen.c |    1 -
 drivers/xen/swiotlb-xen.c      |   19 +++++---------
 include/linux/swiotlb.h        |   14 +++--------
 include/xen/swiotlb-xen.h      |    3 --
 lib/swiotlb.c                  |   53 +++++++++++++++++-----------------------
 6 files changed, 33 insertions(+), 58 deletions(-)

--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
