Return-Path: <SRS0=7jwN=UM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A556BC31E45
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 09:43:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5DE0B21473
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 09:43:58 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="Jh8lILEB"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5DE0B21473
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 09D806B0266; Thu, 13 Jun 2019 05:43:58 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 023A26B0269; Thu, 13 Jun 2019 05:43:57 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E07556B026A; Thu, 13 Jun 2019 05:43:57 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id A8D426B0266
	for <linux-mm@kvack.org>; Thu, 13 Jun 2019 05:43:57 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id a21so13450640pgh.11
        for <linux-mm@kvack.org>; Thu, 13 Jun 2019 02:43:57 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=J6KgL/HbS2N6LTNHClyEsjbtYbBDeWvEUc8ywUokDbM=;
        b=f5LkD+wm7cyDB8KPN8FEfBAGblEDAChi+rl94hfUAbCOo6VY5/OFHd+DT2SY5B7HgO
         qHeBdjCafanVQEeksOjGsCIPujwClulnADifG6zsMMsDZGhQwuiMhitAQnsKiuGuHmBk
         oW+SQ/R7mOKN/lZKKwVMh5qHnQGr5/n9Gi9z2iduT7NPvF7sHD56Rifo7ITS2UNST7Aq
         mhwSO9L0FpVv+P/d0IaJG8oNaT8NhuU7IFFRPlRqYxtBTSHQ5hIdSSSMXFQDS61/FFFF
         7XNC4gXR5OZ7TgrqPBmQk6ZWNL+teLCw+zYmfNP/8AVxQuC1lYa8BUeFbB9931KjCt2c
         QscA==
X-Gm-Message-State: APjAAAV1iHU0Am9WCEpONXRioskCHehNNXBpkDnHdb4mGRIKWOegmwhY
	7OhRgAIOL/pRx9tYFiybjgkZ05prIUoWi2UHj8dzpNG7LvomRtE8QhKA/V0RBl6cOzOyFFxan2q
	N26+vP9K39IEECJFBeBoe89AB+NahGZ09f9/BnTN7G17gXN2btOByDXYevZPZGYo=
X-Received: by 2002:a65:4cce:: with SMTP id n14mr10261232pgt.251.1560419037184;
        Thu, 13 Jun 2019 02:43:57 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzypqL/LxUrxAEzdoT9bbNBxM5B+a9bAtcbuCEk3j+p6SZFgn18o33kU1RNDe2rZhHM4FAs
X-Received: by 2002:a65:4cce:: with SMTP id n14mr10261102pgt.251.1560419035940;
        Thu, 13 Jun 2019 02:43:55 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560419035; cv=none;
        d=google.com; s=arc-20160816;
        b=alHGemeCGWgfCLUfBA0N0EiyLcnOv+/JTFUuiU8bhjX/ms1airPCRnuTK6Y+sLlJfD
         aJtQOM7JXf4k/PmizS+HwPas+9WOV2BnDgcocbSijFYueTDLqtdVZEKelEt0F9yci6Vy
         1IO6V4D1bLc4U/JO1XZUSZu0rCCFKIPYxwUKpxNJBxKpbQCEuCY9FFsDd3ljC3zTCDx6
         gblAaAte6bhRvO/uPdOm5uxPdCuoRW+uvOM4Ibyy1nFe1iYowIlrjwe4UFSvh0iz2Lt0
         3df4wIo3h5TXDmCkyPu880zGDkcXT3359Y99gkANhNYuSL1ZqNVMzSltfkW0LGI4k4n3
         XS/g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=J6KgL/HbS2N6LTNHClyEsjbtYbBDeWvEUc8ywUokDbM=;
        b=dAmi8rRayKDvYwPWM/pX4uQzNNX6FiLNJQ8Q9Is5hmrqGcsNraOCzczew8zKshxCLc
         y3HcaqjqTO42qt0ySOj1nff7jpNKU78DN207wRj+S9/YtD2ngrkQC+hB/NAWsj6/JoWy
         KkH44t/ceeY4MBrDQI+K/iVhUL8cKlHW06R5VcqXBw8c9hW1TaahDWa7D0hjBAxgEP9P
         NJrlTetvYEnm4eUwEHtmesoAhM27urd6wvnvPD8ErR7yW+5pgQnAbV4p2IdIvIlnO3Dl
         tOPPE2qFfqnB/A6wiLN8K0LL17NPZBFtPRAApZWlnPzY9/r/XvxHxFANdgNF0aCv8jod
         P6fw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=Jh8lILEB;
       spf=pass (google.com: best guess record for domain of batv+aff2f865c54b6c032bcd+5772+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+aff2f865c54b6c032bcd+5772+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id j100si2585885pje.52.2019.06.13.02.43.55
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Thu, 13 Jun 2019 02:43:55 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+aff2f865c54b6c032bcd+5772+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=Jh8lILEB;
       spf=pass (google.com: best guess record for domain of batv+aff2f865c54b6c032bcd+5772+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+aff2f865c54b6c032bcd+5772+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=J6KgL/HbS2N6LTNHClyEsjbtYbBDeWvEUc8ywUokDbM=; b=Jh8lILEBlkoz7BxZUpZfrk+rPo
	5Vv8zvkEs/Fw9OO79N5N/Y0XT5tjZHyEHTWn8eyvOgqXtUXVd1z/SRTfQtsDOkc03rcc8Oqr+0gGj
	XtkmK2r6kYcloDj/rKBacpiDOED1N5eXx2e3cRHkATAi8m82hHeWGVKkUJ/Fey7N4V9iRL/1FecYK
	PCRNRhSXbu3d/ofC8c+2tCSbKz0UToD06c23kveqrK8w7bUNKe5YMyLwjfgvyitQrNsCgWTU3bjfC
	+/5c3xHAUo+nzc8XFEIMoLhoIwvUGPRqZ8AKtA0fnh3a7Vt8YVEbCbjiXL7LVQ5gOLdxh0voFqRRa
	p1FErRFg==;
Received: from mpp-cp1-natpool-1-198.ethz.ch ([82.130.71.198] helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hbMGu-0001ni-6t; Thu, 13 Jun 2019 09:43:52 +0000
From: Christoph Hellwig <hch@lst.de>
To: Dan Williams <dan.j.williams@intel.com>,
	=?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>,
	Jason Gunthorpe <jgg@mellanox.com>,
	Ben Skeggs <bskeggs@redhat.com>
Cc: linux-mm@kvack.org,
	nouveau@lists.freedesktop.org,
	dri-devel@lists.freedesktop.org,
	linux-nvdimm@lists.01.org,
	linux-pci@vger.kernel.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH 08/22] memremap: pass a struct dev_pagemap to ->kill
Date: Thu, 13 Jun 2019 11:43:11 +0200
Message-Id: <20190613094326.24093-9-hch@lst.de>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190613094326.24093-1-hch@lst.de>
References: <20190613094326.24093-1-hch@lst.de>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Passing the actual typed structure leads to more understandable code
vs the actual references.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 drivers/dax/device.c              | 7 +++----
 drivers/nvdimm/pmem.c             | 6 +++---
 drivers/pci/p2pdma.c              | 6 +++---
 include/linux/memremap.h          | 2 +-
 kernel/memremap.c                 | 4 ++--
 mm/hmm.c                          | 4 ++--
 tools/testing/nvdimm/test/iomap.c | 6 ++----
 7 files changed, 16 insertions(+), 19 deletions(-)

diff --git a/drivers/dax/device.c b/drivers/dax/device.c
index 4adab774dade..e23fa1bd8c97 100644
--- a/drivers/dax/device.c
+++ b/drivers/dax/device.c
@@ -37,13 +37,12 @@ static void dev_dax_percpu_exit(void *data)
 	percpu_ref_exit(ref);
 }
 
-static void dev_dax_percpu_kill(struct percpu_ref *data)
+static void dev_dax_percpu_kill(struct dev_pagemap *pgmap)
 {
-	struct percpu_ref *ref = data;
-	struct dev_dax *dev_dax = ref_to_dev_dax(ref);
+	struct dev_dax *dev_dax = container_of(pgmap, struct dev_dax, pgmap);
 
 	dev_dbg(&dev_dax->dev, "%s\n", __func__);
-	percpu_ref_kill(ref);
+	percpu_ref_kill(pgmap->ref);
 }
 
 static int check_vma(struct dev_dax *dev_dax, struct vm_area_struct *vma,
diff --git a/drivers/nvdimm/pmem.c b/drivers/nvdimm/pmem.c
index 4efbf184ea68..b9638c6553a1 100644
--- a/drivers/nvdimm/pmem.c
+++ b/drivers/nvdimm/pmem.c
@@ -316,11 +316,11 @@ static void pmem_release_queue(void *q)
 	blk_cleanup_queue(q);
 }
 
-static void pmem_kill(struct percpu_ref *ref)
+static void pmem_kill(struct dev_pagemap *pgmap)
 {
-	struct request_queue *q;
+	struct request_queue *q =
+		container_of(pgmap->ref, struct request_queue, q_usage_counter);
 
-	q = container_of(ref, typeof(*q), q_usage_counter);
 	blk_freeze_queue_start(q);
 }
 
diff --git a/drivers/pci/p2pdma.c b/drivers/pci/p2pdma.c
index 6e76380f5b97..3bcacc9222c6 100644
--- a/drivers/pci/p2pdma.c
+++ b/drivers/pci/p2pdma.c
@@ -82,7 +82,7 @@ static void pci_p2pdma_percpu_release(struct percpu_ref *ref)
 	complete_all(&p2p->devmap_ref_done);
 }
 
-static void pci_p2pdma_percpu_kill(struct percpu_ref *ref)
+static void pci_p2pdma_percpu_kill(struct dev_pagemap *pgmap)
 {
 	/*
 	 * pci_p2pdma_add_resource() may be called multiple times
@@ -90,10 +90,10 @@ static void pci_p2pdma_percpu_kill(struct percpu_ref *ref)
 	 * times. We only want the first action to actually kill the
 	 * percpu_ref.
 	 */
-	if (percpu_ref_is_dying(ref))
+	if (percpu_ref_is_dying(pgmap->ref))
 		return;
 
-	percpu_ref_kill(ref);
+	percpu_ref_kill(pgmap->ref);
 }
 
 static void pci_p2pdma_release(void *data)
diff --git a/include/linux/memremap.h b/include/linux/memremap.h
index 5f7f40875b35..96a3a6d564ad 100644
--- a/include/linux/memremap.h
+++ b/include/linux/memremap.h
@@ -74,7 +74,7 @@ struct dev_pagemap_ops {
 	/*
 	 * Transition the percpu_ref in struct dev_pagemap to the dead state.
 	 */
-	void (*kill)(struct percpu_ref *ref);
+	void (*kill)(struct dev_pagemap *pgmap);
 };
 
 /**
diff --git a/kernel/memremap.c b/kernel/memremap.c
index e23286ce0ec4..94b830b6eca5 100644
--- a/kernel/memremap.c
+++ b/kernel/memremap.c
@@ -92,7 +92,7 @@ static void devm_memremap_pages_release(void *data)
 	unsigned long pfn;
 	int nid;
 
-	pgmap->ops->kill(pgmap->ref);
+	pgmap->ops->kill(pgmap);
 	for_each_device_pfn(pfn, pgmap)
 		put_page(pfn_to_page(pfn));
 
@@ -266,7 +266,7 @@ void *devm_memremap_pages(struct device *dev, struct dev_pagemap *pgmap)
  err_pfn_remap:
 	pgmap_array_delete(res);
  err_array:
-	pgmap->ops->kill(pgmap->ref);
+	pgmap->ops->kill(pgmap);
 	return ERR_PTR(error);
 }
 EXPORT_SYMBOL_GPL(devm_memremap_pages);
diff --git a/mm/hmm.c b/mm/hmm.c
index 2501ac6045d0..c76a1b5defda 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -1325,9 +1325,9 @@ static void hmm_devmem_ref_exit(void *data)
 	percpu_ref_exit(ref);
 }
 
-static void hmm_devmem_ref_kill(struct percpu_ref *ref)
+static void hmm_devmem_ref_kill(struct dev_pagemap *pgmap)
 {
-	percpu_ref_kill(ref);
+	percpu_ref_kill(pgmap->ref);
 }
 
 static vm_fault_t hmm_devmem_fault(struct vm_area_struct *vma,
diff --git a/tools/testing/nvdimm/test/iomap.c b/tools/testing/nvdimm/test/iomap.c
index 7f5ece9b5011..ee07c4de2b35 100644
--- a/tools/testing/nvdimm/test/iomap.c
+++ b/tools/testing/nvdimm/test/iomap.c
@@ -104,11 +104,9 @@ void *__wrap_devm_memremap(struct device *dev, resource_size_t offset,
 }
 EXPORT_SYMBOL(__wrap_devm_memremap);
 
-static void nfit_test_kill(void *_pgmap)
+static void nfit_test_kill(void *pgmap)
 {
-	struct dev_pagemap *pgmap = _pgmap;
-
-	pgmap->ops->kill(pgmap->ref);
+	pgmap->ops->kill(pgmap);
 }
 
 void *__wrap_devm_memremap_pages(struct device *dev, struct dev_pagemap *pgmap)
-- 
2.20.1

