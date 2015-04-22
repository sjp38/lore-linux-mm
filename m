Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id 262656B0032
	for <linux-mm@kvack.org>; Wed, 22 Apr 2015 04:52:56 -0400 (EDT)
Received: by pabtp1 with SMTP id tp1so267109449pab.2
        for <linux-mm@kvack.org>; Wed, 22 Apr 2015 01:52:55 -0700 (PDT)
Received: from mailout3.w1.samsung.com (mailout3.w1.samsung.com. [210.118.77.13])
        by mx.google.com with ESMTPS id hu6si6741291pac.153.2015.04.22.01.52.54
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 22 Apr 2015 01:52:55 -0700 (PDT)
Received: from eucpsbgm2.samsung.com (unknown [203.254.199.245])
 by mailout3.w1.samsung.com
 (Oracle Communications Messaging Server 7.0.5.31.0 64bit (built May  5 2014))
 with ESMTP id <0NN700M2RA5EV140@mailout3.w1.samsung.com> for
 linux-mm@kvack.org; Wed, 22 Apr 2015 09:56:02 +0100 (BST)
From: Marcin Jabrzyk <m.jabrzyk@samsung.com>
Subject: [PATCH v2 0/2] zram, zsmalloc: remove obsolete DEBUGs
Date: Wed, 22 Apr 2015 10:52:34 +0200
Message-id: <1429692756-15197-1-git-send-email-m.jabrzyk@samsung.com>
In-reply-to: <1429615220-20676-1-git-send-email-m.jabrzyk@samsung.com>
References: <1429615220-20676-1-git-send-email-m.jabrzyk@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: minchan@kernel.org, ngupta@vflare.org, sergey.senozhatsky.work@gmail.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: akpm@linux-foundation.org, kyungmin.park@samsung.com, Marcin Jabrzyk <m.jabrzyk@samsung.com>

This patchset removes unused DEBUG defines in zram and zsmalloc,
that remained in sources and config without actual usage.

Changes from v1:
- Apply the removal also to zsmalloc

Marcin Jabrzyk (2):
  zram: remove obsolete ZRAM_DEBUG option
  zsmalloc: remove obsolete ZSMALLOC_DEBUG

 drivers/block/zram/Kconfig    | 10 +---------
 drivers/block/zram/zram_drv.c |  4 ----
 mm/zsmalloc.c                 |  4 ----
 3 files changed, 1 insertion(+), 17 deletions(-)

-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
