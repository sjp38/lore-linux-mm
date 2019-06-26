Return-Path: <SRS0=C/CR=UZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 68182C48BD3
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 12:28:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2804D2063F
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 12:28:24 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="d5qB8osf"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2804D2063F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5B3298E0016; Wed, 26 Jun 2019 08:28:07 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 514C98E000E; Wed, 26 Jun 2019 08:28:07 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 319238E0016; Wed, 26 Jun 2019 08:28:07 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id ED1AE8E000E
	for <linux-mm@kvack.org>; Wed, 26 Jun 2019 08:28:06 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id bb9so1371837plb.2
        for <linux-mm@kvack.org>; Wed, 26 Jun 2019 05:28:06 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=u3zsuvlhpuVlW2irmLMymipD93NE9PuZGgr9ihGk+cw=;
        b=dyTT4tqihhNKYUC7FDsWtDD/afbL9ukgDruM5f9lJoUba5qV5nYlNIn87/E/ofyvBK
         +v4WZ3fItVYcrOWpmDJ8ZsI3K4Spcyq8pgccWqwJaryETfPxayP1nGzyZcH72PZeTJmI
         E2Eiey3vY/p+3I7B0Z0naoavdAd1x6gUgQs/IPinACtpFDrDqyHGNF/4bTbH2Ji7ptow
         xjJTnNTWIjwkO8TLWhIQWOwpB/j28ofm1Wat18QGjxMAauSJVATB51i3vD3+8hE1LBvw
         jHOi7Buko7sfnwszNqKWIF/ageNb0ufKsnn+J1D9lUZ2TL49kl02bLc9cy51u4cZqGl3
         BAzQ==
X-Gm-Message-State: APjAAAXFbEdXCx5p64sfOHCodV9YlktWstszmnNBwjCRgKDsn0swwHuR
	xdSzctpHKafTVXkWr1inFJxlE9zMAjUKw8CaGQ5sHUJ444zDUaI7lv3SkiRZWZRVTrKsIXH71Th
	2oWafNQUV38IyJ05AKSRea34g7eUPgXnW1lTo4+VLVT6WRe1pILMvymWpVZ7H07o=
X-Received: by 2002:a17:902:9a04:: with SMTP id v4mr5041612plp.95.1561552086609;
        Wed, 26 Jun 2019 05:28:06 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz63bUGoy3VyxxsOWhRQLdCSyFm4GjsQ8votbk23RxkH5pVEAD+ay/aaFPD+7RO6bkhd0mk
X-Received: by 2002:a17:902:9a04:: with SMTP id v4mr5041557plp.95.1561552085804;
        Wed, 26 Jun 2019 05:28:05 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561552085; cv=none;
        d=google.com; s=arc-20160816;
        b=xCV+0yfcbZHZUFOxAbQ2/tKSjrrrLkCFm9m/izF3debmMg3VJqu8wzkjhoX0Ipr1dj
         ZoCYT0AaUiclYVH+xiHkvwjKaOJqcsZESUOEBCGZTDt/6v78ddhdJp1diao9jzAPm2iW
         my54l9jIcdFFoC0LI2RUjsMrXX9YlDen8QOYBILBsySm+XrbQbZ0md97CmqBIoNCLL9D
         ocTpciG2+B12gkEPTiX62fff8xjsAPvvOgjW29HSI1ja+lBB1clWqkCS25KoToBByJHN
         HQSGIeB/tLW7io3mGjHWN8QsXqTVo28DpXz7rZX8vuTumxuai17CpYEWRFD57LbkYkwa
         UkvA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=u3zsuvlhpuVlW2irmLMymipD93NE9PuZGgr9ihGk+cw=;
        b=PMIS1CxxTlKOtg7NtMcZfTax1Zq4wm5Slw2/61NpZJEXkIAW3/q9WFTqqnN8R8uisl
         +W2N1WP/8Mwz8teMkiEcGHxJqTh1qo9z9zmHT8RkBq1H6PETvfkPulyKNLoJzk2P4GA9
         gG7caUmwWnJys0M7My6Y9mM6u9O51gL9s9tOu7q3/Qhh8Xa4CCAxJoM4dsc2NeuO5zLp
         srV59mCF7KINWF6JD260FC4w63d0hi4Z+VclRraB+CcKjf95ApJ6hKL/XvhiLl50rhPp
         Sie+Du407XEgj4FwQgN+kdq7DPwMQKERaX5MMha0b45nJM1oxVRuFZPYDxBWZhOnz9xy
         zw7w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=d5qB8osf;
       spf=pass (google.com: best guess record for domain of batv+ab1f803c58217d155be4+5785+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+ab1f803c58217d155be4+5785+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id j31si4659152pgi.151.2019.06.26.05.28.05
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Wed, 26 Jun 2019 05:28:05 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+ab1f803c58217d155be4+5785+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=d5qB8osf;
       spf=pass (google.com: best guess record for domain of batv+ab1f803c58217d155be4+5785+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+ab1f803c58217d155be4+5785+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=u3zsuvlhpuVlW2irmLMymipD93NE9PuZGgr9ihGk+cw=; b=d5qB8osfJqMohKxbGTFQMSvZ2L
	1KQRqOrBzZgw95hqR7pC5Tucj3aBgj0VNA4cifFq8mAtLKD0y1772q8m2Z/ML4g9MnP7VyGZXROYQ
	CGsjiwCerbX6BpeiN/MViA/hM/oV9hr2xUNh/hyDYSytiOYO4VuD3HQ99ONPGzpXSDohyUZvaf5+5
	tEP6Go2MhIcoBaHR6YQM6iXPbXRjeKNPZuAc5iukG7vmbCG+osMb+7klCclgJbFAUga+T2bDeuUhW
	MOLIB+v5w+TI2bA58t30lzk9E06TgqWSiqBPClXaFtnn8gsbsrA6lO0aCw7Xfkzg6beeIa6ehrRFz
	vyIO8/mQ==;
Received: from clnet-p19-102.ikbnet.co.at ([83.175.77.102] helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hg71t-0001U5-Fd; Wed, 26 Jun 2019 12:28:01 +0000
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
Subject: [PATCH 13/25] memremap: remove the data field in struct dev_pagemap
Date: Wed, 26 Jun 2019 14:27:12 +0200
Message-Id: <20190626122724.13313-14-hch@lst.de>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190626122724.13313-1-hch@lst.de>
References: <20190626122724.13313-1-hch@lst.de>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

struct dev_pagemap is always embedded into a containing structure, so
there is no need to an additional private data field.

Signed-off-by: Christoph Hellwig <hch@lst.de>
Reviewed-by: Jason Gunthorpe <jgg@mellanox.com>
---
 drivers/nvdimm/pmem.c    | 2 +-
 include/linux/memremap.h | 3 +--
 kernel/memremap.c        | 2 +-
 mm/hmm.c                 | 9 +++++----
 4 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/drivers/nvdimm/pmem.c b/drivers/nvdimm/pmem.c
index 48767171a4df..093408ce40ad 100644
--- a/drivers/nvdimm/pmem.c
+++ b/drivers/nvdimm/pmem.c
@@ -334,7 +334,7 @@ static void pmem_release_disk(void *__pmem)
 	put_disk(pmem->disk);
 }
 
-static void pmem_pagemap_page_free(struct page *page, void *data)
+static void pmem_pagemap_page_free(struct page *page)
 {
 	wake_up_var(&page->_refcount);
 }
diff --git a/include/linux/memremap.h b/include/linux/memremap.h
index ac985bd03a7f..336eca601dad 100644
--- a/include/linux/memremap.h
+++ b/include/linux/memremap.h
@@ -69,7 +69,7 @@ struct dev_pagemap_ops {
 	 * reach 0 refcount unless there is a refcount bug. This allows the
 	 * device driver to implement its own memory management.)
 	 */
-	void (*page_free)(struct page *page, void *data);
+	void (*page_free)(struct page *page);
 
 	/*
 	 * Transition the refcount in struct dev_pagemap to the dead state.
@@ -104,7 +104,6 @@ struct dev_pagemap {
 	struct resource res;
 	struct percpu_ref *ref;
 	struct device *dev;
-	void *data;
 	enum memory_type type;
 	u64 pci_p2pdma_bus_offset;
 	const struct dev_pagemap_ops *ops;
diff --git a/kernel/memremap.c b/kernel/memremap.c
index c06a5487dda7..6c3dbb692037 100644
--- a/kernel/memremap.c
+++ b/kernel/memremap.c
@@ -376,7 +376,7 @@ void __put_devmap_managed_page(struct page *page)
 
 		mem_cgroup_uncharge(page);
 
-		page->pgmap->ops->page_free(page, page->pgmap->data);
+		page->pgmap->ops->page_free(page);
 	} else if (!count)
 		__put_page(page);
 }
diff --git a/mm/hmm.c b/mm/hmm.c
index 96633ee066d8..36e25cdbdac1 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -1368,15 +1368,17 @@ static void hmm_devmem_ref_kill(struct dev_pagemap *pgmap)
 
 static vm_fault_t hmm_devmem_migrate_to_ram(struct vm_fault *vmf)
 {
-	struct hmm_devmem *devmem = vmf->page->pgmap->data;
+	struct hmm_devmem *devmem =
+		container_of(vmf->page->pgmap, struct hmm_devmem, pagemap);
 
 	return devmem->ops->fault(devmem, vmf->vma, vmf->address, vmf->page,
 			vmf->flags, vmf->pmd);
 }
 
-static void hmm_devmem_free(struct page *page, void *data)
+static void hmm_devmem_free(struct page *page)
 {
-	struct hmm_devmem *devmem = data;
+	struct hmm_devmem *devmem =
+		container_of(page->pgmap, struct hmm_devmem, pagemap);
 
 	devmem->ops->free(devmem, page);
 }
@@ -1442,7 +1444,6 @@ struct hmm_devmem *hmm_devmem_add(const struct hmm_devmem_ops *ops,
 	devmem->pagemap.ops = &hmm_pagemap_ops;
 	devmem->pagemap.altmap_valid = false;
 	devmem->pagemap.ref = &devmem->ref;
-	devmem->pagemap.data = devmem;
 
 	result = devm_memremap_pages(devmem->device, &devmem->pagemap);
 	if (IS_ERR(result))
-- 
2.20.1

