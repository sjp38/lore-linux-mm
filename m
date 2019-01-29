Return-Path: <SRS0=Ydgi=QF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 758EBC169C4
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 16:54:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2D7A620989
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 16:54:58 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2D7A620989
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3B41C8E0009; Tue, 29 Jan 2019 11:54:50 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 315B68E0008; Tue, 29 Jan 2019 11:54:50 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1BFE28E0009; Tue, 29 Jan 2019 11:54:50 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id D83158E0008
	for <linux-mm@kvack.org>; Tue, 29 Jan 2019 11:54:49 -0500 (EST)
Received: by mail-qt1-f198.google.com with SMTP id n39so25006460qtn.18
        for <linux-mm@kvack.org>; Tue, 29 Jan 2019 08:54:49 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=5VHDy0ljnDYb93eYIPu560MNKs/uH4VBN2aPll6gvwM=;
        b=bkONQpIBQ7PeZZ2xYysaU+AyC5xHHHRFtjDvw6HXpPZexkubPjwBjihYzbfj8I2bPt
         /cf6cyWYoga2pIJ1mjWdNdB+Oqv/6wTakQqmi8NmxDZV1jaSI/2WzFgoNP5ZY7jFpYfQ
         F5vYJVrGZyXbk7bprJGHyevu3ScPEvbKwSxQ19BP3HaKNLsqsP7c4UKP1W/QYPZD+A3o
         gpAHm3Eg20ktK6xdlmRKN9pMOMSXArqMxCjtrEaFnEKQyXdHTjk8INhDoQTsSRdyrAhE
         VgJgHOcCXu07QxxJcDiZzw+YCq+gPiiZNd5MzsXs5WpLnxApzCrdQzGvtJGnu4PPwh9r
         7cqw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AJcUukcVLvLc7OPCKgjx3pYp8n27C4MJM0jtEXcDgpLleQ7R4ZAU64cR
	VAU0n/xn/XaNY4Zb1Vi0nrBBaGSu5gt3fIjR6dvuoOnJprF1mH+vZdb0QvMQGooFQbC+UY/0kSw
	S8qwrVgyH6DoXOv8gKuqp+gcj1qafPa5BvuSyoNe0hPW4d/2JMaGUgbmolrMXc0fOlg==
X-Received: by 2002:a37:9c57:: with SMTP id f84mr24020613qke.176.1548780889652;
        Tue, 29 Jan 2019 08:54:49 -0800 (PST)
X-Google-Smtp-Source: ALg8bN4Jlk1c8feMOlSqrMRTk7C5WtERn8xC1Gbt3ZcKdvnaG7Af+WwIHNuzs4qn6cc7z4nJpLcP
X-Received: by 2002:a37:9c57:: with SMTP id f84mr24020575qke.176.1548780889045;
        Tue, 29 Jan 2019 08:54:49 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548780889; cv=none;
        d=google.com; s=arc-20160816;
        b=sznxDE9xi8IibE/+Ic/4SwONWPFH4Kbm0tYac8v+qdN7GqbwOSx12/35wUZf7Uezwf
         zwePs/ez32TmJx0yNYhSS3Xw0jsUWl1zjW3l649VYcrF79rcNkMgevE1b27qxU/u2AZD
         oYHUsGzyLBIGOidDmwCXCdq2FKpNAXZgpnQiD7qJG4qf/RUUihA9J5wlnClYyAnrKa3c
         A1JBSavtDdhPtjDWbal7/EaLUuaqduv9IiE+/q2mz7JhfBRmVqYLJL05YMfNjvNLGALI
         aKLvxy+6vK0euzXi2nY99kC4V4AzDiG8v3V1XkLzEQRBfashsfrmf9eJGxTpczSKTaZX
         Hvtg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=5VHDy0ljnDYb93eYIPu560MNKs/uH4VBN2aPll6gvwM=;
        b=Y2rPu1W0QgyPE75J6VtjuCBqBEeWnJhjC861Ki/LzOmV1JQH6Kb/S99lfbx1V/9K0O
         WoTLLv2bjUDcAF1+dpoZYxfUeZJyQ6a2wSascB8LRrXe1Ly5m0mBNs7K61yRvbtFt2AQ
         1T7ks9gRZCFdI1Dn1stnzl2FiDMPBNpltHk9Af66pzgP79dU24lDWzzZcIhmaQrHadBF
         NRlEQ1BrNG9zlpfVGRJwaGK2D8xEYeJwN81x0+xbdqC4N5sEVPzL046a8+MYYvetVCU2
         IyZ6K4wJdRs3SMz5brZBvIos8THCwnn2Ww+DjsgvDGxh5uhIC7Co8z6+XAE8ase1ztVD
         zLMA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id m36si2136142qvc.170.2019.01.29.08.54.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Jan 2019 08:54:49 -0800 (PST)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx07.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 207177E9D3;
	Tue, 29 Jan 2019 16:54:48 +0000 (UTC)
Received: from localhost.localdomain.com (ovpn-122-2.rdu2.redhat.com [10.10.122.2])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 035EF103BAAD;
	Tue, 29 Jan 2019 16:54:46 +0000 (UTC)
From: jglisse@redhat.com
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org,
	=?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Ralph Campbell <rcampbell@nvidia.com>,
	John Hubbard <jhubbard@nvidia.com>
Subject: [PATCH 07/10] mm/hmm: add an helper function that fault pages and map them to a device
Date: Tue, 29 Jan 2019 11:54:25 -0500
Message-Id: <20190129165428.3931-8-jglisse@redhat.com>
In-Reply-To: <20190129165428.3931-1-jglisse@redhat.com>
References: <20190129165428.3931-1-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.22
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.26]); Tue, 29 Jan 2019 16:54:48 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Jérôme Glisse <jglisse@redhat.com>

This is a all in one helper that fault pages in a range and map them to
a device so that every single device driver do not have to re-implement
this common pattern.

Signed-off-by: Jérôme Glisse <jglisse@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Ralph Campbell <rcampbell@nvidia.com>
Cc: John Hubbard <jhubbard@nvidia.com>
---
 include/linux/hmm.h |   9 +++
 mm/hmm.c            | 152 ++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 161 insertions(+)

diff --git a/include/linux/hmm.h b/include/linux/hmm.h
index 4263f8fb32e5..fc3630d0bbfd 100644
--- a/include/linux/hmm.h
+++ b/include/linux/hmm.h
@@ -502,6 +502,15 @@ int hmm_range_register(struct hmm_range *range,
 void hmm_range_unregister(struct hmm_range *range);
 long hmm_range_snapshot(struct hmm_range *range);
 long hmm_range_fault(struct hmm_range *range, bool block);
+long hmm_range_dma_map(struct hmm_range *range,
+		       struct device *device,
+		       dma_addr_t *daddrs,
+		       bool block);
+long hmm_range_dma_unmap(struct hmm_range *range,
+			 struct vm_area_struct *vma,
+			 struct device *device,
+			 dma_addr_t *daddrs,
+			 bool dirty);
 
 /*
  * HMM_RANGE_DEFAULT_TIMEOUT - default timeout (ms) when waiting for a range
diff --git a/mm/hmm.c b/mm/hmm.c
index 0a4ff31e9d7a..9cd68334a759 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -30,6 +30,7 @@
 #include <linux/hugetlb.h>
 #include <linux/memremap.h>
 #include <linux/jump_label.h>
+#include <linux/dma-mapping.h>
 #include <linux/mmu_notifier.h>
 #include <linux/memory_hotplug.h>
 
@@ -985,6 +986,157 @@ long hmm_range_fault(struct hmm_range *range, bool block)
 	return (hmm_vma_walk.last - range->start) >> PAGE_SHIFT;
 }
 EXPORT_SYMBOL(hmm_range_fault);
+
+/*
+ * hmm_range_dma_map() - hmm_range_fault() and dma map page all in one.
+ * @range: range being faulted
+ * @device: device against to dma map page to
+ * @daddrs: dma address of mapped pages
+ * @block: allow blocking on fault (if true it sleeps and do not drop mmap_sem)
+ * Returns: number of pages mapped on success, -EAGAIN if mmap_sem have been
+ *          drop and you need to try again, some other error value otherwise
+ *
+ * Note same usage pattern as hmm_range_fault().
+ */
+long hmm_range_dma_map(struct hmm_range *range,
+		       struct device *device,
+		       dma_addr_t *daddrs,
+		       bool block)
+{
+	unsigned long i, npages, mapped;
+	long ret;
+
+	ret = hmm_range_fault(range, block);
+	if (ret <= 0)
+		return ret ? ret : -EBUSY;
+
+	npages = (range->end - range->start) >> PAGE_SHIFT;
+	for (i = 0, mapped = 0; i < npages; ++i) {
+		enum dma_data_direction dir = DMA_FROM_DEVICE;
+		struct page *page;
+
+		/*
+		 * FIXME need to update DMA API to provide invalid DMA address
+		 * value instead of a function to test dma address value. This
+		 * would remove lot of dumb code duplicated accross many arch.
+		 *
+		 * For now setting it to 0 here is good enough as the pfns[]
+		 * value is what is use to check what is valid and what isn't.
+		 */
+		daddrs[i] = 0;
+
+		page = hmm_pfn_to_page(range, range->pfns[i]);
+		if (page == NULL)
+			continue;
+
+		/* Check if range is being invalidated */
+		if (!range->valid) {
+			ret = -EBUSY;
+			goto unmap;
+		}
+
+		/* If it is read and write than map bi-directional. */
+		if (range->pfns[i] & range->values[HMM_PFN_WRITE])
+			dir = DMA_BIDIRECTIONAL;
+
+		daddrs[i] = dma_map_page(device, page, 0, PAGE_SIZE, dir);
+		if (dma_mapping_error(device, daddrs[i])) {
+			ret = -EFAULT;
+			goto unmap;
+		}
+
+		mapped++;
+	}
+
+	return mapped;
+
+unmap:
+	for (npages = i, i = 0; (i < npages) && mapped; ++i) {
+		enum dma_data_direction dir = DMA_FROM_DEVICE;
+		struct page *page;
+
+		page = hmm_pfn_to_page(range, range->pfns[i]);
+		if (page == NULL)
+			continue;
+
+		if (dma_mapping_error(device, daddrs[i]))
+			continue;
+
+		/* If it is read and write than map bi-directional. */
+		if (range->pfns[i] & range->values[HMM_PFN_WRITE])
+			dir = DMA_BIDIRECTIONAL;
+
+		dma_unmap_page(device, daddrs[i], PAGE_SIZE, dir);
+		mapped--;
+	}
+
+	return ret;
+}
+EXPORT_SYMBOL(hmm_range_dma_map);
+
+/*
+ * hmm_range_dma_unmap() - unmap range of that was map with hmm_range_dma_map()
+ * @range: range being unmapped
+ * @vma: the vma against which the range (optional)
+ * @device: device against which dma map was done
+ * @daddrs: dma address of mapped pages
+ * @dirty: dirty page if it had the write flag set
+ * Returns: number of page unmapped on success, -EINVAL otherwise
+ *
+ * Note that caller MUST abide by mmu notifier or use HMM mirror and abide
+ * to the sync_cpu_device_pagetables() callback so that it is safe here to
+ * call set_page_dirty(). Caller must also take appropriate locks to avoid
+ * concurrent mmu notifier or sync_cpu_device_pagetables() to make progress.
+ */
+long hmm_range_dma_unmap(struct hmm_range *range,
+			 struct vm_area_struct *vma,
+			 struct device *device,
+			 dma_addr_t *daddrs,
+			 bool dirty)
+{
+	unsigned long i, npages;
+	long cpages = 0;
+
+	/* Sanity check. */
+	if (range->end <= range->start)
+		return -EINVAL;
+	if (!daddrs)
+		return -EINVAL;
+	if (!range->pfns)
+		return -EINVAL;
+
+	npages = (range->end - range->start) >> PAGE_SHIFT;
+	for (i = 0; i < npages; ++i) {
+		enum dma_data_direction dir = DMA_FROM_DEVICE;
+		struct page *page;
+
+		page = hmm_pfn_to_page(range, range->pfns[i]);
+		if (page == NULL)
+			continue;
+
+		/* If it is read and write than map bi-directional. */
+		if (range->pfns[i] & range->values[HMM_PFN_WRITE]) {
+			dir = DMA_BIDIRECTIONAL;
+
+			/*
+			 * See comments in function description on why it is
+			 * safe here to call set_page_dirty()
+			 */
+			if (dirty)
+				set_page_dirty(page);
+		}
+
+		/* Unmap and clear pfns/dma address */
+		dma_unmap_page(device, daddrs[i], PAGE_SIZE, dir);
+		range->pfns[i] = range->values[HMM_PFN_NONE];
+		/* FIXME see comments in hmm_vma_dma_map() */
+		daddrs[i] = 0;
+		cpages++;
+	}
+
+	return cpages;
+}
+EXPORT_SYMBOL(hmm_range_dma_unmap);
 #endif /* IS_ENABLED(CONFIG_HMM_MIRROR) */
 
 
-- 
2.17.2

