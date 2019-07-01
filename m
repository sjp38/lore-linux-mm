Return-Path: <SRS0=jfnU=U6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F029FC5B578
	for <linux-mm@archiver.kernel.org>; Mon,  1 Jul 2019 06:21:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A9930212F5
	for <linux-mm@archiver.kernel.org>; Mon,  1 Jul 2019 06:21:27 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="o95YPE7E"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A9930212F5
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3B33D6B0266; Mon,  1 Jul 2019 02:21:13 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 315948E000E; Mon,  1 Jul 2019 02:21:13 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 13DED8E000D; Mon,  1 Jul 2019 02:21:13 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f206.google.com (mail-pg1-f206.google.com [209.85.215.206])
	by kanga.kvack.org (Postfix) with ESMTP id C5D046B0266
	for <linux-mm@kvack.org>; Mon,  1 Jul 2019 02:21:12 -0400 (EDT)
Received: by mail-pg1-f206.google.com with SMTP id w5so2765407pgs.5
        for <linux-mm@kvack.org>; Sun, 30 Jun 2019 23:21:12 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=tWgCV0T5gyBBloZRaADn3Gi+6+ID0uvOOaOC/BREjAY=;
        b=PbXp8azU6UMtRuXFLSXEhg0/X/bPDQKhwptUCGPuE1AmfFEhIo7e8rtPboBfNC0gQZ
         v8dOKbkEtTUYKpI2j6QB5lclHnM/fI3v30MDk/wAfl0UVCNqJ0uPh76qvZA9jkQhxTIT
         B8G3tA8czeoiQiyNxdVu63DaVCA8AA7qQGgT7UovwuhHWTP57/9XcpgTKbM+TCM3NE89
         FnPL0NNDF7YANJsF2bwxznPDnedW9y6tIGbfhDLaZQTxMXfb9BE3mqpOKUxm02zirSCY
         ne5ti1nql7rvDplf/KT3l716zn3fC5UVT0aJ8owovRHWzXTXvvTLoloM+ToJ+SCD3Fxb
         58Ag==
X-Gm-Message-State: APjAAAUMtgcPhrt92B+FVEin8cYfhy6c4uGSSco8+JnV5QniIUl/HW6x
	8jG/SBrHHqyE8/39X4PMQo9LXzq96K4Egru8qsOggfsPWmEHOHvKZR6agOXJ4aVlCByyVo8VGYB
	MWI4ffGCHUTC09+Q6DX6fzU1bVR6u1MtuNPCcHJkMxxy8v/2arYYdHNcRLgWevTI=
X-Received: by 2002:a65:5c88:: with SMTP id a8mr22562716pgt.388.1561962072253;
        Sun, 30 Jun 2019 23:21:12 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxO+ETh6nyTjwkz7AbgnCaJUYSnXRbM/dGspDahbks44PRpC8StKZa82bQfDEwRDBPt1kJh
X-Received: by 2002:a65:5c88:: with SMTP id a8mr22562629pgt.388.1561962070881;
        Sun, 30 Jun 2019 23:21:10 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561962070; cv=none;
        d=google.com; s=arc-20160816;
        b=nb86xEbQxWhLdB0dOb4ONSIO+Fsd3Y/U3FERAk85npa9Zm+TP5bluJN58skrgXjL/E
         9+N2vDQQ/6uIZg0SpeH3hj/Og4nR9NmaGo6aJsBKRqzJ6lxbRy1gL+b4SxTe+8enHld0
         GEcRBKSAmzTtfkyVrGM9GLtgGmKMdiMzUrDgBqAwrezurGmHbc1Wn+qkw0upe1lbIPm9
         k4mFkuDnCTrfRehFv5Xx8zWGClRtOHv766dAAype1R/1lyom8v9Ul5TaW4oBJrZvKXbz
         BHluv72dSvO5zP8geF6F2cvPAiQcD1SII/115du0CytZ5tTMGDZ4qCdvJQAf1eqnApgv
         KXcw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=tWgCV0T5gyBBloZRaADn3Gi+6+ID0uvOOaOC/BREjAY=;
        b=scOp9+QJ8xIzScRWAq68aVuCj5tmiDYKtJ7tbQdlsl9PYfRg2kUyCvX9ttDKNVy8wD
         UfGT/+kOXtU565CpC7AcYJIMY4BcfskW7lsh6TOwJn26mJ8+Z7NNIauEerTSe1c+OJs2
         isi01ELa58n4yUBownWNkd0+CWVYFN1FVLYXEIXsEDSp5kb9pXmWY+FCIX2UZZJ8wDRY
         ptab2aSfG3sQj3Cefcmv+wQRUCE0/eb8PofPmRrCjuAayxV08tmFXkGbiD/Xrkd4asao
         6XrO/RNRyPK5TztVpNz2G9cX0/NZJNHlclKNQSED03PRIUgGmKxUAZuxSn8O21EiO8nM
         Zzig==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=o95YPE7E;
       spf=pass (google.com: best guess record for domain of batv+bb02ddf78a79a38d855c+5790+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+bb02ddf78a79a38d855c+5790+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id j124si10763234pfb.151.2019.06.30.23.21.10
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Sun, 30 Jun 2019 23:21:10 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+bb02ddf78a79a38d855c+5790+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=o95YPE7E;
       spf=pass (google.com: best guess record for domain of batv+bb02ddf78a79a38d855c+5790+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+bb02ddf78a79a38d855c+5790+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=tWgCV0T5gyBBloZRaADn3Gi+6+ID0uvOOaOC/BREjAY=; b=o95YPE7Ed8kykY6bfvr4aZ6u4a
	iqVj/FoZrabOP8GDjgVj/9kqBGTTn4CmRLeIxb1rNW3VxoSW4AVNy/eAyP4qrIvkxkbxj+rI/Pvok
	RmFYJ5q7h6/x66KlLFTEjo/16kYV8FBai9C7tW5NgGcfwfE+rgvK/NKditEuH0Fv6LFdrnBsnb9Cz
	3jCoRpM3l4EDwQLfGOFXE5x/awO4QWFV3Iwjwsar5N34jJAtY9I4Ge806rGwjeZ32tkVsqr4SKF5i
	+B8R6m57E3Hu5awfYglSUsyp/80U+lJGXdAGb9+ckm2WeqWt4HoRPT4Z475oxzhHiwLHg1y7KmucZ
	WnLoHtpA==;
Received: from [46.140.178.35] (helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hhpgZ-0003OJ-Fg; Mon, 01 Jul 2019 06:21:07 +0000
From: Christoph Hellwig <hch@lst.de>
To: Dan Williams <dan.j.williams@intel.com>,
	=?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>,
	Jason Gunthorpe <jgg@mellanox.com>,
	Ben Skeggs <bskeggs@redhat.com>
Cc: Ira Weiny <ira.weiny@intel.com>,
	linux-mm@kvack.org,
	nouveau@lists.freedesktop.org,
	dri-devel@lists.freedesktop.org,
	linux-nvdimm@lists.01.org,
	linux-pci@vger.kernel.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH 20/22] mm: move hmm_vma_fault to nouveau
Date: Mon,  1 Jul 2019 08:20:18 +0200
Message-Id: <20190701062020.19239-21-hch@lst.de>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190701062020.19239-1-hch@lst.de>
References: <20190701062020.19239-1-hch@lst.de>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

hmm_vma_fault is marked as a legacy API to get rid of, but quite suites
the current nouvea flow.  Move it to the only user in preparation for
fixing a locking bug involving caller and callee.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 drivers/gpu/drm/nouveau/nouveau_svm.c | 54 ++++++++++++++++++++++++++-
 include/linux/hmm.h                   | 54 ---------------------------
 2 files changed, 53 insertions(+), 55 deletions(-)

diff --git a/drivers/gpu/drm/nouveau/nouveau_svm.c b/drivers/gpu/drm/nouveau/nouveau_svm.c
index 9d40114d7949..e831f4184a17 100644
--- a/drivers/gpu/drm/nouveau/nouveau_svm.c
+++ b/drivers/gpu/drm/nouveau/nouveau_svm.c
@@ -36,6 +36,13 @@
 #include <linux/sort.h>
 #include <linux/hmm.h>
 
+/*
+ * When waiting for mmu notifiers we need some kind of time out otherwise we
+ * could potentialy wait for ever, 1000ms ie 1s sounds like a long time to
+ * wait already.
+ */
+#define NOUVEAU_RANGE_FAULT_TIMEOUT 1000
+
 struct nouveau_svm {
 	struct nouveau_drm *drm;
 	struct mutex mutex;
@@ -475,6 +482,51 @@ nouveau_svm_fault_cache(struct nouveau_svm *svm,
 		fault->inst, fault->addr, fault->access);
 }
 
+static int
+nouveau_range_fault(struct hmm_mirror *mirror, struct hmm_range *range,
+		    bool block)
+{
+	long ret;
+
+	/*
+	 * With the old API the driver must set each individual entries with
+	 * the requested flags (valid, write, ...). So here we set the mask to
+	 * keep intact the entries provided by the driver and zero out the
+	 * default_flags.
+	 */
+	range->default_flags = 0;
+	range->pfn_flags_mask = -1UL;
+
+	ret = hmm_range_register(range, mirror,
+				 range->start, range->end,
+				 PAGE_SHIFT);
+	if (ret)
+		return (int)ret;
+
+	if (!hmm_range_wait_until_valid(range, NOUVEAU_RANGE_FAULT_TIMEOUT)) {
+		/*
+		 * The mmap_sem was taken by driver we release it here and
+		 * returns -EAGAIN which correspond to mmap_sem have been
+		 * drop in the old API.
+		 */
+		up_read(&range->vma->vm_mm->mmap_sem);
+		return -EAGAIN;
+	}
+
+	ret = hmm_range_fault(range, block);
+	if (ret <= 0) {
+		if (ret == -EBUSY || !ret) {
+			/* Same as above, drop mmap_sem to match old API. */
+			up_read(&range->vma->vm_mm->mmap_sem);
+			ret = -EBUSY;
+		} else if (ret == -EAGAIN)
+			ret = -EBUSY;
+		hmm_range_unregister(range);
+		return ret;
+	}
+	return 0;
+}
+
 static int
 nouveau_svm_fault(struct nvif_notify *notify)
 {
@@ -649,7 +701,7 @@ nouveau_svm_fault(struct nvif_notify *notify)
 		range.values = nouveau_svm_pfn_values;
 		range.pfn_shift = NVIF_VMM_PFNMAP_V0_ADDR_SHIFT;
 again:
-		ret = hmm_vma_fault(&svmm->mirror, &range, true);
+		ret = nouveau_range_fault(&svmm->mirror, &range, true);
 		if (ret == 0) {
 			mutex_lock(&svmm->mutex);
 			if (!hmm_range_unregister(&range)) {
diff --git a/include/linux/hmm.h b/include/linux/hmm.h
index 4b185d286c3b..3457cf9182e5 100644
--- a/include/linux/hmm.h
+++ b/include/linux/hmm.h
@@ -478,60 +478,6 @@ long hmm_range_dma_unmap(struct hmm_range *range,
 			 dma_addr_t *daddrs,
 			 bool dirty);
 
-/*
- * HMM_RANGE_DEFAULT_TIMEOUT - default timeout (ms) when waiting for a range
- *
- * When waiting for mmu notifiers we need some kind of time out otherwise we
- * could potentialy wait for ever, 1000ms ie 1s sounds like a long time to
- * wait already.
- */
-#define HMM_RANGE_DEFAULT_TIMEOUT 1000
-
-/* This is a temporary helper to avoid merge conflict between trees. */
-static inline int hmm_vma_fault(struct hmm_mirror *mirror,
-				struct hmm_range *range, bool block)
-{
-	long ret;
-
-	/*
-	 * With the old API the driver must set each individual entries with
-	 * the requested flags (valid, write, ...). So here we set the mask to
-	 * keep intact the entries provided by the driver and zero out the
-	 * default_flags.
-	 */
-	range->default_flags = 0;
-	range->pfn_flags_mask = -1UL;
-
-	ret = hmm_range_register(range, mirror,
-				 range->start, range->end,
-				 PAGE_SHIFT);
-	if (ret)
-		return (int)ret;
-
-	if (!hmm_range_wait_until_valid(range, HMM_RANGE_DEFAULT_TIMEOUT)) {
-		/*
-		 * The mmap_sem was taken by driver we release it here and
-		 * returns -EAGAIN which correspond to mmap_sem have been
-		 * drop in the old API.
-		 */
-		up_read(&range->vma->vm_mm->mmap_sem);
-		return -EAGAIN;
-	}
-
-	ret = hmm_range_fault(range, block);
-	if (ret <= 0) {
-		if (ret == -EBUSY || !ret) {
-			/* Same as above, drop mmap_sem to match old API. */
-			up_read(&range->vma->vm_mm->mmap_sem);
-			ret = -EBUSY;
-		} else if (ret == -EAGAIN)
-			ret = -EBUSY;
-		hmm_range_unregister(range);
-		return ret;
-	}
-	return 0;
-}
-
 /* Below are for HMM internal use only! Not to be used by device driver! */
 static inline void hmm_mm_init(struct mm_struct *mm)
 {
-- 
2.20.1

