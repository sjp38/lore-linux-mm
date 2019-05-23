Return-Path: <SRS0=On+J=TX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C6147C282DD
	for <linux-mm@archiver.kernel.org>; Thu, 23 May 2019 15:03:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 87A0B20881
	for <linux-mm@archiver.kernel.org>; Thu, 23 May 2019 15:03:29 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 87A0B20881
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 20B186B000C; Thu, 23 May 2019 11:03:29 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 194616B000D; Thu, 23 May 2019 11:03:29 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F02B06B000E; Thu, 23 May 2019 11:03:28 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id A22B66B000C
	for <linux-mm@kvack.org>; Thu, 23 May 2019 11:03:28 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id f41so9481605ede.1
        for <linux-mm@kvack.org>; Thu, 23 May 2019 08:03:28 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=zg85nJ35pKxFSS0/87yLMaYaC6bRh9JcCczKm9Nv3WA=;
        b=HdI9t8gg5uqKgx4GhNX7ZTw+IdCN2UhfbyPYlePy4dm9Tk9+mCzIOXvZvKPzsDIQWK
         cKtL3ZBYLI6CnYekxjP/nv5QsMQpSoqVvokw9IFNMPC3f4wHjBLCoEuTGm7KHRkLtnaa
         5Bxj377hzXHQaRNHdFN51QTIOTh50DZempUE7Ty2CB+afCGlLeTj1w2U7Vg52Eo9xH8g
         NDoAf3TJapEADyRdLm2Ov1Nx837tm8XX3FMATB8p1HeD0UGXw0J6P1wlmCij/kRgD4DT
         zycY51Re3prpX2IJOQiqBc53PVK5kdsTMKX0FRgk+2zyrOL4djY6ACXKYPN/mlhTiN1Q
         YbqA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of robin.murphy@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=robin.murphy@arm.com
X-Gm-Message-State: APjAAAUiiM+37YmQ69HdsAazeC3dovFT/qbBrq7RzuP+XbVEqYun1/Cy
	QyHJdvEFclS26VYNDFRey4CGv0ilKWGx/X28iF5RXSCCr26H5oAZ5bcNXiCbo6KiJc+9q40rdAn
	knlUXdjtoKRyzL9cEaBpwyRD4ESs+StcUg0Ap1wXgl2shMMm6hkt5Xb9SREwkO2oUUg==
X-Received: by 2002:a50:f5d9:: with SMTP id x25mr95689358edm.128.1558623808099;
        Thu, 23 May 2019 08:03:28 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzu2e5eLO2rGWMZ7XtltV3TLvKsQCTHKIIrzkMu/RSggogrT1ZucqWzJYnKeNbz1UHPMMEF
X-Received: by 2002:a50:f5d9:: with SMTP id x25mr95689242edm.128.1558623807115;
        Thu, 23 May 2019 08:03:27 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558623807; cv=none;
        d=google.com; s=arc-20160816;
        b=bNa4YoC9F2M1A/Cw47Q7LZDGoe6wzEM6J+WHdd9/Qlo+B/+oYxfXN7xUo/r2SVIh+n
         zh1+o9XxHsKxLqgemPE2LfuOQ3xsaodiiUXCWZ69K5QgYZJWGASoWY1jCb7+Z6dj3F1B
         Ham70WcDH17ndVPDG+YyteXPfPTushkk1fmRsndUh+5ct6N87vQymohFliyfwYNxqFgH
         dfa/BXloP3MSJXEkW1tH83xocOSsfTNix8WXeNr7tkHhS5NQ96Lm0pEoFBDrYO166E6V
         gD5Lh3z1c3sUSVqadt0VBZl5dISO1YadLEafa9QlE0VbFw0PX0HjOfcNiw7yXdnw32Y5
         Cn9g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=zg85nJ35pKxFSS0/87yLMaYaC6bRh9JcCczKm9Nv3WA=;
        b=VO/SNho8G48J2up29mjvjPM5EBLj5tmEHWRR5Ncqc4/oPkygsPdpaIUrzXX6EAPLzT
         xYSfHf1+KvBX4bjP1PmfGmp2T5LvvtXu5YpK+XtKjmtxNnOf4HgZgVOpsUVVFYLSEmtj
         Y5xtYeuUcfbRJgmjotg8TV/VRjxsuMB2pvW/XMs780oSJ4BtOl4ukCbeEOPN/lyddtZy
         5MFn6La7LiePgXBw/mZYKbckL9sJk0NSmlL6e7OvxnfwLCRm/nHN7H3WISHRzYBUxXg+
         otgTz8aGPECAdv9GusE/CffqSzvecCyQkCTzceepifEtbrhZfP2Ps/RwsquoLPQ+lCJb
         LYfg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of robin.murphy@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=robin.murphy@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id w19si4622189eju.0.2019.05.23.08.03.26
        for <linux-mm@kvack.org>;
        Thu, 23 May 2019 08:03:27 -0700 (PDT)
Received-SPF: pass (google.com: domain of robin.murphy@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of robin.murphy@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=robin.murphy@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id EE37780D;
	Thu, 23 May 2019 08:03:25 -0700 (PDT)
Received: from e110467-lin.cambridge.arm.com (e110467-lin.cambridge.arm.com [10.1.196.75])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPA id 2055C3F690;
	Thu, 23 May 2019 08:03:23 -0700 (PDT)
From: Robin Murphy <robin.murphy@arm.com>
To: linux-mm@kvack.org
Cc: akpm@linux-foundation.org,
	will.deacon@arm.com,
	catalin.marinas@arm.com,
	anshuman.khandual@arm.com,
	linux-arm-kernel@lists.infradead.org,
	linux-kernel@vger.kernel.org,
	Michal Hocko <mhocko@suse.com>,
	David Hildenbrand <david@redhat.com>,
	Dan Williams <dan.j.williams@intel.com>
Subject: [PATCH v3 1/4] mm/memremap: Rename and consolidate SECTION_SIZE
Date: Thu, 23 May 2019 16:03:13 +0100
Message-Id: <d291c21d1b401e324f0e0bf23e1b3fdb4159d425.1558547956.git.robin.murphy@arm.com>
X-Mailer: git-send-email 2.21.0.dirty
In-Reply-To: <cover.1558547956.git.robin.murphy@arm.com>
References: <cover.1558547956.git.robin.murphy@arm.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Trying to activate ZONE_DEVICE for arm64 reveals that memremap's
internal helpers for sparsemem sections conflict with and arm64's
definitions for hugepages, which inherit the name of "sections" from
earlier versions of the ARM architecture.

Disambiguate memremap (and now HMM too) by propagating sparsemem's PA_
prefix, to clarify that these values are in terms of addresses rather
than PFNs (and because it's a heck of a lot easier than changing all the
arch code). SECTION_MASK is unused, so it can just go.

[anshuman: Consolidated mm/hmm.c instance and updated the commit message]

Acked-by: Michal Hocko <mhocko@suse.com>
Reviewed-by: David Hildenbrand <david@redhat.com>
Acked-by: Dan Williams <dan.j.williams@intel.com>
Signed-off-by: Robin Murphy <robin.murphy@arm.com>
Signed-off-by: Anshuman Khandual <anshuman.khandual@arm.com>
---
 include/linux/mmzone.h |  1 +
 kernel/memremap.c      | 10 ++++------
 mm/hmm.c               |  2 --
 3 files changed, 5 insertions(+), 8 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 70394cabaf4e..427b79c39b3c 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -1134,6 +1134,7 @@ static inline unsigned long early_pfn_to_nid(unsigned long pfn)
  * PFN_SECTION_SHIFT		pfn to/from section number
  */
 #define PA_SECTION_SHIFT	(SECTION_SIZE_BITS)
+#define PA_SECTION_SIZE		(1UL << PA_SECTION_SHIFT)
 #define PFN_SECTION_SHIFT	(SECTION_SIZE_BITS - PAGE_SHIFT)
 
 #define NR_MEM_SECTIONS		(1UL << SECTIONS_SHIFT)
diff --git a/kernel/memremap.c b/kernel/memremap.c
index 1490e63f69a9..b8c8010e87e0 100644
--- a/kernel/memremap.c
+++ b/kernel/memremap.c
@@ -14,8 +14,6 @@
 #include <linux/hmm.h>
 
 static DEFINE_XARRAY(pgmap_array);
-#define SECTION_MASK ~((1UL << PA_SECTION_SHIFT) - 1)
-#define SECTION_SIZE (1UL << PA_SECTION_SHIFT)
 
 #if IS_ENABLED(CONFIG_DEVICE_PRIVATE)
 vm_fault_t device_private_entry_fault(struct vm_area_struct *vma,
@@ -97,8 +95,8 @@ static void devm_memremap_pages_release(void *data)
 		put_page(pfn_to_page(pfn));
 
 	/* pages are dead and unused, undo the arch mapping */
-	align_start = res->start & ~(SECTION_SIZE - 1);
-	align_size = ALIGN(res->start + resource_size(res), SECTION_SIZE)
+	align_start = res->start & ~(PA_SECTION_SIZE - 1);
+	align_size = ALIGN(res->start + resource_size(res), PA_SECTION_SIZE)
 		- align_start;
 
 	nid = page_to_nid(pfn_to_page(align_start >> PAGE_SHIFT));
@@ -159,8 +157,8 @@ void *devm_memremap_pages(struct device *dev, struct dev_pagemap *pgmap)
 	if (!pgmap->ref || !pgmap->kill)
 		return ERR_PTR(-EINVAL);
 
-	align_start = res->start & ~(SECTION_SIZE - 1);
-	align_size = ALIGN(res->start + resource_size(res), SECTION_SIZE)
+	align_start = res->start & ~(PA_SECTION_SIZE - 1);
+	align_size = ALIGN(res->start + resource_size(res), PA_SECTION_SIZE)
 		- align_start;
 	align_end = align_start + align_size - 1;
 
diff --git a/mm/hmm.c b/mm/hmm.c
index 0db8491090b8..a7e7f8e33c5f 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -34,8 +34,6 @@
 #include <linux/mmu_notifier.h>
 #include <linux/memory_hotplug.h>
 
-#define PA_SECTION_SIZE (1UL << PA_SECTION_SHIFT)
-
 #if IS_ENABLED(CONFIG_HMM_MIRROR)
 static const struct mmu_notifier_ops hmm_mmu_notifier_ops;
 
-- 
2.21.0.dirty

