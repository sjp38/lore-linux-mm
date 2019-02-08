Return-Path: <SRS0=ikTF=QP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 085EAC282CB
	for <linux-mm@archiver.kernel.org>; Fri,  8 Feb 2019 07:57:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A79A421917
	for <linux-mm@archiver.kernel.org>; Fri,  8 Feb 2019 07:57:00 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="I4GdsIz4"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A79A421917
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 89CC28E0082; Fri,  8 Feb 2019 02:56:58 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 787098E0002; Fri,  8 Feb 2019 02:56:58 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5AEC78E0082; Fri,  8 Feb 2019 02:56:58 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 130C58E0002
	for <linux-mm@kvack.org>; Fri,  8 Feb 2019 02:56:58 -0500 (EST)
Received: by mail-pl1-f200.google.com with SMTP id a9so1910447pla.2
        for <linux-mm@kvack.org>; Thu, 07 Feb 2019 23:56:58 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=J2d/n7dMaeGjTEKIDIBTiayW7FnCIDacKxsczsn6v/k=;
        b=q9tNhtb7zVYo0lqJg5JphQwuBHmghLINQTBy7GPDeIzwXTNWCwOhJ3moDJ1dPie8e0
         WH/8v3vq3RtzpEC0Y4BSEZ8N9hJODKA5xAj/aNpB/wAnPQFFRLz3AIOdrDXBVXDEXiBB
         6HiUGGx+UxkZC8S+2TPQDHjddDMKVOmiFOIPtg8iW+CsIqVL3A2OqqjfgTebsMDe6+3E
         OE6ugs6qO+gT4KU7NP1wYKvVrp/YD75kc7n4JLd5v6YeIHZUCNMzv1DlPS+cmOeOYPbH
         D9iZ0uqf91UWunwJOyi6S16HNsIz9Vmi5f7pJnvsGrnyOL4mLA0D6+Gg8rwgJvjjQBa7
         rzJQ==
X-Gm-Message-State: AHQUAuaUaR3tcA1/ASGsb2oxJqdww/Ds7ItVMJULkvOm+/ZihVT7JOr4
	tqVTrH6glsu/PlNm2SF9jq+AmJX5CL88TrrNaR1/zlFREH968PcrjIYCggX0GOo4NApBgrI9oxo
	+iuo0nwtVahU2L6RMWFRU3uNQpleRJwI5L8FHT13KJzHmJda6QahqS+ASP0kNhMy7xNEweRaMcV
	6CKNNyVgCY+UIALbopEXQq284lAuhpbXuIxyRlgjkGl7xwIwgL8Ed1XDDgY2DpFd1mx0LHaTpZx
	ANYady48/1YzsTgcsCTnFQVhPJZHV4DIMDH20hc+jGraKs1iMXLLRay1atZ42/Eet7Pj4teT3lq
	NnJ/YVougYxciwcbM8cnS3wyaCUGx15sEu9BmfHkqJSdnQK7GrrdhL/F0w89HiE0yzwuJlwBkcK
	W
X-Received: by 2002:aa7:800c:: with SMTP id j12mr2935431pfi.183.1549612617743;
        Thu, 07 Feb 2019 23:56:57 -0800 (PST)
X-Received: by 2002:aa7:800c:: with SMTP id j12mr2935360pfi.183.1549612616726;
        Thu, 07 Feb 2019 23:56:56 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549612616; cv=none;
        d=google.com; s=arc-20160816;
        b=bNMjrefJQQpjuohlvQRKdj8r3XNmVs4t8kmZllB9bVsrL9GWEn0HIioZUga6VGT1/v
         5xs5WraEaKW/5svPSBR+Uyum695hTHIArgAE2KVd6WfAVwR+/Qt4qPcqt7PzQ5AzEP9d
         /T7Xzn8kcXlWCrDvT4dQym0C0FhdhxrUf7nrqdRXwT0togNCZ+TWrEArSIFzvPkZQGum
         bpOT46LP5RCXYIn2+PN2ZKZV2xW59yMrTTRJgDZOZzTTmIE9j5Xgxouv567oOkzLs/of
         J9m4dNFwE+TyHiSA7pTbZReN5BXJWud1k38UbD1z9d2wdavv7Tt8mmpQrohXK280Igfh
         xAsw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=J2d/n7dMaeGjTEKIDIBTiayW7FnCIDacKxsczsn6v/k=;
        b=pAm7h5eTVkHTzcSWY6i66ba85zGJUmpTpvI16+es67SaQn78kOmLhy5BZJNvK5JEPL
         JR+k7pdc6RZhDTw5CWRq0itXbvEQTFw2oi4om+18QT7SUnKiBuq0XLVGqTwrwFHMK8GH
         18wizLB956nNXzAh2L+1WjuHh975PxJnvea/cPZB7iDXV+baQ86qhztxDLzrgvm1cyZh
         LUhcSSINBnXY1KzBUCt2OSuYKzlbQu57VPK8kEnjpdhItRtR0uWs4tvawGzeVFR80gzm
         I92evVINs6DfsnyHxXAz91ZBiL4EJSxyHvy967noVXxWRnv8PTFx8fTTsI6D/zxm6VcY
         vw2A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=I4GdsIz4;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d71sor1607027pga.73.2019.02.07.23.56.56
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 07 Feb 2019 23:56:56 -0800 (PST)
Received-SPF: pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=I4GdsIz4;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=J2d/n7dMaeGjTEKIDIBTiayW7FnCIDacKxsczsn6v/k=;
        b=I4GdsIz44Gw1ZvdxS8A3KX2aMztLlez48JnFUkyF/acaAc80cF5HhhgrbpoGR2PB+E
         vP8U4msgbCn1JRQtjFisJFWRt+xNAUMU/ob+jHwE+eyLV8RMqHi1bS2fj1pBgNYUiWra
         clSIiacqFsl9crG1jF98vOlxCxG1p6wFAjL7/g1xMk/yIy6s+gR6l5+9vCDOOdx4Xz+I
         AYruW4TVowbQxZCmYY47S19UsD4WvHPvMClC6ZQoh7GC/KFrFfn/1uSc7RX5TAOd5Gg2
         Y3KKyAj5lkTr2tHH/EJJ6Uf280tplM9hzxdBlAg5IgcgttR2fxsX+wVOMcstZ4YtxbXf
         qZ3g==
X-Google-Smtp-Source: AHgI3IYYHIztn9vPyDo0otP9186JN8e6QmitPtzNtoARPeba6iDr110h0m/ZLkxOo1nRMHdRATOVJQ==
X-Received: by 2002:a63:4611:: with SMTP id t17mr9848800pga.119.1549612616425;
        Thu, 07 Feb 2019 23:56:56 -0800 (PST)
Received: from blueforge.nvidia.com (searspoint.nvidia.com. [216.228.112.21])
        by smtp.gmail.com with ESMTPSA id h64sm2642610pfc.142.2019.02.07.23.56.54
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Feb 2019 23:56:55 -0800 (PST)
From: john.hubbard@gmail.com
X-Google-Original-From: jhubbard@nvidia.com
To: Andrew Morton <akpm@linux-foundation.org>,
	linux-mm@kvack.org
Cc: Al Viro <viro@zeniv.linux.org.uk>,
	Christian Benvenuti <benve@cisco.com>,
	Christoph Hellwig <hch@infradead.org>,
	Christopher Lameter <cl@linux.com>,
	Dan Williams <dan.j.williams@intel.com>,
	Dave Chinner <david@fromorbit.com>,
	Dennis Dalessandro <dennis.dalessandro@intel.com>,
	Doug Ledford <dledford@redhat.com>,
	Jan Kara <jack@suse.cz>,
	Jason Gunthorpe <jgg@ziepe.ca>,
	Jerome Glisse <jglisse@redhat.com>,
	Matthew Wilcox <willy@infradead.org>,
	Michal Hocko <mhocko@kernel.org>,
	Mike Rapoport <rppt@linux.ibm.com>,
	Mike Marciniszyn <mike.marciniszyn@intel.com>,
	Ralph Campbell <rcampbell@nvidia.com>,
	Tom Talpey <tom@talpey.com>,
	LKML <linux-kernel@vger.kernel.org>,
	linux-fsdevel@vger.kernel.org,
	John Hubbard <jhubbard@nvidia.com>,
	Jason Gunthorpe <jgg@mellanox.com>
Subject: [PATCH 2/2] infiniband/mm: convert put_page() to put_user_page*()
Date: Thu,  7 Feb 2019 23:56:49 -0800
Message-Id: <20190208075649.3025-3-jhubbard@nvidia.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190208075649.3025-1-jhubbard@nvidia.com>
References: <20190208075649.3025-1-jhubbard@nvidia.com>
MIME-Version: 1.0
X-NVConfidentiality: public
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: John Hubbard <jhubbard@nvidia.com>

For infiniband code that retains pages via get_user_pages*(),
release those pages via the new put_user_page(), or
put_user_pages*(), instead of put_page()

This is a tiny part of the second step of fixing the problem described
in [1]. The steps are:

1) Provide put_user_page*() routines, intended to be used
   for releasing pages that were pinned via get_user_pages*().

2) Convert all of the call sites for get_user_pages*(), to
   invoke put_user_page*(), instead of put_page(). This involves dozens of
   call sites, and will take some time.

3) After (2) is complete, use get_user_pages*() and put_user_page*() to
   implement tracking of these pages. This tracking will be separate from
   the existing struct page refcounting.

4) Use the tracking and identification of these pages, to implement
   special handling (especially in writeback paths) when the pages are
   backed by a filesystem. Again, [1] provides details as to why that is
   desirable.

[1] https://lwn.net/Articles/753027/ : "The Trouble with get_user_pages()"

Cc: Doug Ledford <dledford@redhat.com>
Cc: Jason Gunthorpe <jgg@ziepe.ca>
Cc: Mike Marciniszyn <mike.marciniszyn@intel.com>
Cc: Dennis Dalessandro <dennis.dalessandro@intel.com>
Cc: Christian Benvenuti <benve@cisco.com>

Reviewed-by: Jan Kara <jack@suse.cz>
Reviewed-by: Dennis Dalessandro <dennis.dalessandro@intel.com>
Acked-by: Jason Gunthorpe <jgg@mellanox.com>
Signed-off-by: John Hubbard <jhubbard@nvidia.com>
---
 drivers/infiniband/core/umem.c              |  7 ++++---
 drivers/infiniband/core/umem_odp.c          |  2 +-
 drivers/infiniband/hw/hfi1/user_pages.c     | 11 ++++-------
 drivers/infiniband/hw/mthca/mthca_memfree.c |  6 +++---
 drivers/infiniband/hw/qib/qib_user_pages.c  | 11 ++++-------
 drivers/infiniband/hw/qib/qib_user_sdma.c   |  6 +++---
 drivers/infiniband/hw/usnic/usnic_uiom.c    |  7 ++++---
 7 files changed, 23 insertions(+), 27 deletions(-)

diff --git a/drivers/infiniband/core/umem.c b/drivers/infiniband/core/umem.c
index c6144df47ea4..c2898bc7b3b2 100644
--- a/drivers/infiniband/core/umem.c
+++ b/drivers/infiniband/core/umem.c
@@ -58,9 +58,10 @@ static void __ib_umem_release(struct ib_device *dev, struct ib_umem *umem, int d
 	for_each_sg(umem->sg_head.sgl, sg, umem->npages, i) {
 
 		page = sg_page(sg);
-		if (!PageDirty(page) && umem->writable && dirty)
-			set_page_dirty_lock(page);
-		put_page(page);
+		if (umem->writable && dirty)
+			put_user_pages_dirty_lock(&page, 1);
+		else
+			put_user_page(page);
 	}
 
 	sg_free_table(&umem->sg_head);
diff --git a/drivers/infiniband/core/umem_odp.c b/drivers/infiniband/core/umem_odp.c
index acb882f279cb..d32757c1f77e 100644
--- a/drivers/infiniband/core/umem_odp.c
+++ b/drivers/infiniband/core/umem_odp.c
@@ -663,7 +663,7 @@ int ib_umem_odp_map_dma_pages(struct ib_umem_odp *umem_odp, u64 user_virt,
 					ret = -EFAULT;
 					break;
 				}
-				put_page(local_page_list[j]);
+				put_user_page(local_page_list[j]);
 				continue;
 			}
 
diff --git a/drivers/infiniband/hw/hfi1/user_pages.c b/drivers/infiniband/hw/hfi1/user_pages.c
index e341e6dcc388..99ccc0483711 100644
--- a/drivers/infiniband/hw/hfi1/user_pages.c
+++ b/drivers/infiniband/hw/hfi1/user_pages.c
@@ -121,13 +121,10 @@ int hfi1_acquire_user_pages(struct mm_struct *mm, unsigned long vaddr, size_t np
 void hfi1_release_user_pages(struct mm_struct *mm, struct page **p,
 			     size_t npages, bool dirty)
 {
-	size_t i;
-
-	for (i = 0; i < npages; i++) {
-		if (dirty)
-			set_page_dirty_lock(p[i]);
-		put_page(p[i]);
-	}
+	if (dirty)
+		put_user_pages_dirty_lock(p, npages);
+	else
+		put_user_pages(p, npages);
 
 	if (mm) { /* during close after signal, mm can be NULL */
 		down_write(&mm->mmap_sem);
diff --git a/drivers/infiniband/hw/mthca/mthca_memfree.c b/drivers/infiniband/hw/mthca/mthca_memfree.c
index 112d2f38e0de..99108f3dcf01 100644
--- a/drivers/infiniband/hw/mthca/mthca_memfree.c
+++ b/drivers/infiniband/hw/mthca/mthca_memfree.c
@@ -481,7 +481,7 @@ int mthca_map_user_db(struct mthca_dev *dev, struct mthca_uar *uar,
 
 	ret = pci_map_sg(dev->pdev, &db_tab->page[i].mem, 1, PCI_DMA_TODEVICE);
 	if (ret < 0) {
-		put_page(pages[0]);
+		put_user_page(pages[0]);
 		goto out;
 	}
 
@@ -489,7 +489,7 @@ int mthca_map_user_db(struct mthca_dev *dev, struct mthca_uar *uar,
 				 mthca_uarc_virt(dev, uar, i));
 	if (ret) {
 		pci_unmap_sg(dev->pdev, &db_tab->page[i].mem, 1, PCI_DMA_TODEVICE);
-		put_page(sg_page(&db_tab->page[i].mem));
+		put_user_page(sg_page(&db_tab->page[i].mem));
 		goto out;
 	}
 
@@ -555,7 +555,7 @@ void mthca_cleanup_user_db_tab(struct mthca_dev *dev, struct mthca_uar *uar,
 		if (db_tab->page[i].uvirt) {
 			mthca_UNMAP_ICM(dev, mthca_uarc_virt(dev, uar, i), 1);
 			pci_unmap_sg(dev->pdev, &db_tab->page[i].mem, 1, PCI_DMA_TODEVICE);
-			put_page(sg_page(&db_tab->page[i].mem));
+			put_user_page(sg_page(&db_tab->page[i].mem));
 		}
 	}
 
diff --git a/drivers/infiniband/hw/qib/qib_user_pages.c b/drivers/infiniband/hw/qib/qib_user_pages.c
index 16543d5e80c3..1a5c64c8695f 100644
--- a/drivers/infiniband/hw/qib/qib_user_pages.c
+++ b/drivers/infiniband/hw/qib/qib_user_pages.c
@@ -40,13 +40,10 @@
 static void __qib_release_user_pages(struct page **p, size_t num_pages,
 				     int dirty)
 {
-	size_t i;
-
-	for (i = 0; i < num_pages; i++) {
-		if (dirty)
-			set_page_dirty_lock(p[i]);
-		put_page(p[i]);
-	}
+	if (dirty)
+		put_user_pages_dirty_lock(p, num_pages);
+	else
+		put_user_pages(p, num_pages);
 }
 
 /*
diff --git a/drivers/infiniband/hw/qib/qib_user_sdma.c b/drivers/infiniband/hw/qib/qib_user_sdma.c
index 31c523b2a9f5..a1a1ec4adffc 100644
--- a/drivers/infiniband/hw/qib/qib_user_sdma.c
+++ b/drivers/infiniband/hw/qib/qib_user_sdma.c
@@ -320,7 +320,7 @@ static int qib_user_sdma_page_to_frags(const struct qib_devdata *dd,
 		 * the caller can ignore this page.
 		 */
 		if (put) {
-			put_page(page);
+			put_user_page(page);
 		} else {
 			/* coalesce case */
 			kunmap(page);
@@ -634,7 +634,7 @@ static void qib_user_sdma_free_pkt_frag(struct device *dev,
 			kunmap(pkt->addr[i].page);
 
 		if (pkt->addr[i].put_page)
-			put_page(pkt->addr[i].page);
+			put_user_page(pkt->addr[i].page);
 		else
 			__free_page(pkt->addr[i].page);
 	} else if (pkt->addr[i].kvaddr) {
@@ -709,7 +709,7 @@ static int qib_user_sdma_pin_pages(const struct qib_devdata *dd,
 	/* if error, return all pages not managed by pkt */
 free_pages:
 	while (i < j)
-		put_page(pages[i++]);
+		put_user_page(pages[i++]);
 
 done:
 	return ret;
diff --git a/drivers/infiniband/hw/usnic/usnic_uiom.c b/drivers/infiniband/hw/usnic/usnic_uiom.c
index 49275a548751..2ef8d31dc838 100644
--- a/drivers/infiniband/hw/usnic/usnic_uiom.c
+++ b/drivers/infiniband/hw/usnic/usnic_uiom.c
@@ -77,9 +77,10 @@ static void usnic_uiom_put_pages(struct list_head *chunk_list, int dirty)
 		for_each_sg(chunk->page_list, sg, chunk->nents, i) {
 			page = sg_page(sg);
 			pa = sg_phys(sg);
-			if (!PageDirty(page) && dirty)
-				set_page_dirty_lock(page);
-			put_page(page);
+			if (dirty)
+				put_user_pages_dirty_lock(&page, 1);
+			else
+				put_user_page(page);
 			usnic_dbg("pa: %pa\n", &pa);
 		}
 		kfree(chunk);
-- 
2.20.1

