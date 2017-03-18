Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id AAB8E6B038D
	for <linux-mm@kvack.org>; Fri, 17 Mar 2017 20:55:10 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id j127so86673306qke.2
        for <linux-mm@kvack.org>; Fri, 17 Mar 2017 17:55:10 -0700 (PDT)
Received: from mail-qt0-f176.google.com (mail-qt0-f176.google.com. [209.85.216.176])
        by mx.google.com with ESMTPS id d79si7661178qkb.326.2017.03.17.17.55.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 17 Mar 2017 17:55:10 -0700 (PDT)
Received: by mail-qt0-f176.google.com with SMTP id n21so75238839qta.1
        for <linux-mm@kvack.org>; Fri, 17 Mar 2017 17:55:09 -0700 (PDT)
From: Laura Abbott <labbott@redhat.com>
Subject: [RFC PATCHv2 03/21] staging: android: ion: Remove dmap_cnt
Date: Fri, 17 Mar 2017 17:54:35 -0700
Message-Id: <1489798493-16600-4-git-send-email-labbott@redhat.com>
In-Reply-To: <1489798493-16600-1-git-send-email-labbott@redhat.com>
References: <1489798493-16600-1-git-send-email-labbott@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sumit Semwal <sumit.semwal@linaro.org>, Riley Andrews <riandrews@android.com>, arve@android.com
Cc: Laura Abbott <labbott@redhat.com>, romlem@google.com, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org, linaro-mm-sig@lists.linaro.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org, dri-devel@lists.freedesktop.org, Brian Starkey <brian.starkey@arm.com>, Daniel Vetter <daniel.vetter@intel.com>, Mark Brown <broonie@kernel.org>, Benjamin Gaignard <benjamin.gaignard@linaro.org>, linux-mm@kvack.org, Laurent Pinchart <laurent.pinchart@ideasonboard.com>


The reference counting of dma_map calls was removed. Remove the
associated counter field as well.

Signed-off-by: Laura Abbott <labbott@redhat.com>
---
 drivers/staging/android/ion/ion_priv.h | 2 --
 1 file changed, 2 deletions(-)

diff --git a/drivers/staging/android/ion/ion_priv.h b/drivers/staging/android/ion/ion_priv.h
index 5b3059c..46d3ff5 100644
--- a/drivers/staging/android/ion/ion_priv.h
+++ b/drivers/staging/android/ion/ion_priv.h
@@ -44,7 +44,6 @@
  * @lock:		protects the buffers cnt fields
  * @kmap_cnt:		number of times the buffer is mapped to the kernel
  * @vaddr:		the kernel mapping if kmap_cnt is not zero
- * @dmap_cnt:		number of times the buffer is mapped for dma
  * @sg_table:		the sg table for the buffer if dmap_cnt is not zero
  * @pages:		flat array of pages in the buffer -- used by fault
  *			handler and only valid for buffers that are faulted in
@@ -70,7 +69,6 @@ struct ion_buffer {
 	struct mutex lock;
 	int kmap_cnt;
 	void *vaddr;
-	int dmap_cnt;
 	struct sg_table *sg_table;
 	struct page **pages;
 	struct list_head vmas;
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
