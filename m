Return-Path: <SRS0=4tVm=QS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D8F3DC282D7
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 20:17:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 937BF2184A
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 20:17:07 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 937BF2184A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AFBFD8E0153; Mon, 11 Feb 2019 15:17:06 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9E4B38E0134; Mon, 11 Feb 2019 15:17:06 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8FB418E0153; Mon, 11 Feb 2019 15:17:06 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 4FADD8E0134
	for <linux-mm@kvack.org>; Mon, 11 Feb 2019 15:17:06 -0500 (EST)
Received: by mail-pg1-f199.google.com with SMTP id o9so106994pgv.19
        for <linux-mm@kvack.org>; Mon, 11 Feb 2019 12:17:06 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=DDRtxOsb0F4pxAfQnTfzLJBeZtJFhbG0fIzEq0OuYlc=;
        b=Yf1+EzsE4c/j8vTbn/NITRvlzyvyrMv1zciush88fAKZtdpeMkFMpYNqk8B0cc0pcN
         TiWpFYHATAXxUnLBo5ZSpzhawUTE5HV8v1TgxRqwz0lB3UkKd7I5em/NJkqyEVGPMNK4
         ibimKVQh9qPyXcBhDsXujBDCpAb6X2IdqgQGjCJTCMLAa1/6KyNvZHoM3Y61e2bMDdLX
         ABGVflqRZ+uYjfT8yJ/X0yDyGtqAirkTAOlbwGKS+N5U4YGzig9Z/xBHDVpC1hI4SjdU
         9fVfVejCzXImojnTt8jZ4OBRrZc2NnfPN9Zcmg1Y1QUlM9HG0PBMynm7JM1vqiOkXZHY
         zRyA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.24 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: AHQUAuYcj3apMugnUUf1MPzBD2yaxSmUMBtho63odx7Ku0Apu7sqotRE
	iknEyh3Q1U5QExNFVlBzUSSSeT0kB3f/KXsWIsm+rsJyFNs09Fsh2oD+lFgfcBRAQjhAglv8ptY
	0bCYcbR/8Rq5gsqW5+4YCM8N3Pz1EoeG4cKhTOUIHKIpWMx3nrDEzZnXtNHBfxdqQZA==
X-Received: by 2002:a63:9f19:: with SMTP id g25mr30415486pge.327.1549916225992;
        Mon, 11 Feb 2019 12:17:05 -0800 (PST)
X-Google-Smtp-Source: AHgI3Ibng5UsVRdOivwFDb73QQIPWZo5c93swgvASXwvg1WfCHSkbEoaBpxRNUThjEcgcN+ZWaxS
X-Received: by 2002:a63:9f19:: with SMTP id g25mr30415426pge.327.1549916225064;
        Mon, 11 Feb 2019 12:17:05 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549916225; cv=none;
        d=google.com; s=arc-20160816;
        b=fb6ob47EAzVDM4MV5FYCJShMB81MfKTvjf0vc5SzdugDK6k9aRQiNYEq9/mmiHMccP
         FcQ/iicT6+syVjq8QiDJp1aIHHZHNJ7MK/d4ueYGNiKzzyj78wMwvoRwMe/gUkjmDZzf
         FL99unFvfBNWg/NK7YgleKCap5flt0pNoE8gfFcc7mmX+X53qjSimZfyd6MpHgYICqwD
         iXyv9Dl8E+7x1i4KcStUpT2Dg0Kzm4Hxbpi8Vf56CX5tlsLBARwtwIBEWm1C+Z4huxyj
         N4cnQBu7kEGsMU8JYXPIq9Y/JySc0cvHqxKd3rYOCFp9Yz6GCYsjvTfvmBsynLEAEFdh
         sU9Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=DDRtxOsb0F4pxAfQnTfzLJBeZtJFhbG0fIzEq0OuYlc=;
        b=KBF47DUMr11lyWl+5hJrXbWJfXRUx24xh48n8IIL+cj9nE/2RljAclQr4NhbKyme42
         S8TvJK7idkTHegYjgO206gar58OD+CsCt4Ov2viU9gl+JIzTHiOF8gHjYV6B17hnF5we
         FKkTUkXGUEyaW0JaOapC8Ho1ReJ4fP3hnkcD7nzG09N/C79sqy6pvD4JdwASH/2qTfbV
         IFMUyoncvcrpw+Do76oZFtqXVZz8GbnwXouMeKmwb95C2S3gYvF+vLk3z7k5AyLRESi4
         BpKGUG4KhCF1+aTIPrlKAAlK/uO7HfQe0iaqJmA3u55jK/O9uctHtooMs6ITwDcN5ZxA
         lI4A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.24 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id v1si10376043plp.12.2019.02.11.12.17.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Feb 2019 12:17:05 -0800 (PST)
Received-SPF: pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.24 as permitted sender) client-ip=134.134.136.24;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.24 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga005.fm.intel.com ([10.253.24.32])
  by orsmga102.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 11 Feb 2019 12:17:04 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.58,360,1544515200"; 
   d="scan'208";a="319498283"
Received: from iweiny-desk2.sc.intel.com ([10.3.52.157])
  by fmsmga005.fm.intel.com with ESMTP; 11 Feb 2019 12:17:04 -0800
From: ira.weiny@intel.com
To: linux-rdma@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	linux-mm@kvack.org,
	Daniel Borkmann <daniel@iogearbox.net>,
	Davidlohr Bueso <dave@stgolabs.net>,
	netdev@vger.kernel.org
Cc: Mike Marciniszyn <mike.marciniszyn@intel.com>,
	Dennis Dalessandro <dennis.dalessandro@intel.com>,
	Doug Ledford <dledford@redhat.com>,
	Jason Gunthorpe <jgg@ziepe.ca>,
	Andrew Morton <akpm@linux-foundation.org>,
	"Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>,
	Dan Williams <dan.j.williams@intel.com>,
	Ira Weiny <ira.weiny@intel.com>
Subject: [PATCH 1/3] mm/gup: Change "write" parameter to flags
Date: Mon, 11 Feb 2019 12:16:41 -0800
Message-Id: <20190211201643.7599-2-ira.weiny@intel.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190211201643.7599-1-ira.weiny@intel.com>
References: <20190211201643.7599-1-ira.weiny@intel.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Ira Weiny <ira.weiny@intel.com>

In order to support more options in the GUP fast walk, change the
write parameter to flags throughout the call stack.

This patch does not change functionality and passes FOLL_WRITE
where write was previously used.

Signed-off-by: Ira Weiny <ira.weiny@intel.com>
---
 mm/gup.c | 52 ++++++++++++++++++++++++++--------------------------
 1 file changed, 26 insertions(+), 26 deletions(-)

diff --git a/mm/gup.c b/mm/gup.c
index b63e88eca31b..894ab014bd1e 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -1395,7 +1395,7 @@ static void undo_dev_pagemap(int *nr, int nr_start, struct page **pages)
 
 #ifdef CONFIG_ARCH_HAS_PTE_SPECIAL
 static int gup_pte_range(pmd_t pmd, unsigned long addr, unsigned long end,
-			 int write, struct page **pages, int *nr)
+			 unsigned int flags, struct page **pages, int *nr)
 {
 	struct dev_pagemap *pgmap = NULL;
 	int nr_start = *nr, ret = 0;
@@ -1413,7 +1413,7 @@ static int gup_pte_range(pmd_t pmd, unsigned long addr, unsigned long end,
 		if (pte_protnone(pte))
 			goto pte_unmap;
 
-		if (!pte_access_permitted(pte, write))
+		if (!pte_access_permitted(pte, flags & FOLL_WRITE))
 			goto pte_unmap;
 
 		if (pte_devmap(pte)) {
@@ -1465,7 +1465,7 @@ static int gup_pte_range(pmd_t pmd, unsigned long addr, unsigned long end,
  * useful to have gup_huge_pmd even if we can't operate on ptes.
  */
 static int gup_pte_range(pmd_t pmd, unsigned long addr, unsigned long end,
-			 int write, struct page **pages, int *nr)
+			 unsigned int flags, struct page **pages, int *nr)
 {
 	return 0;
 }
@@ -1548,12 +1548,12 @@ static int __gup_device_huge_pud(pud_t pud, pud_t *pudp, unsigned long addr,
 #endif
 
 static int gup_huge_pmd(pmd_t orig, pmd_t *pmdp, unsigned long addr,
-		unsigned long end, int write, struct page **pages, int *nr)
+		unsigned long end, unsigned int flags, struct page **pages, int *nr)
 {
 	struct page *head, *page;
 	int refs;
 
-	if (!pmd_access_permitted(orig, write))
+	if (!pmd_access_permitted(orig, flags & FOLL_WRITE))
 		return 0;
 
 	if (pmd_devmap(orig))
@@ -1586,12 +1586,12 @@ static int gup_huge_pmd(pmd_t orig, pmd_t *pmdp, unsigned long addr,
 }
 
 static int gup_huge_pud(pud_t orig, pud_t *pudp, unsigned long addr,
-		unsigned long end, int write, struct page **pages, int *nr)
+		unsigned long end, unsigned int flags, struct page **pages, int *nr)
 {
 	struct page *head, *page;
 	int refs;
 
-	if (!pud_access_permitted(orig, write))
+	if (!pud_access_permitted(orig, flags & FOLL_WRITE))
 		return 0;
 
 	if (pud_devmap(orig))
@@ -1624,13 +1624,13 @@ static int gup_huge_pud(pud_t orig, pud_t *pudp, unsigned long addr,
 }
 
 static int gup_huge_pgd(pgd_t orig, pgd_t *pgdp, unsigned long addr,
-			unsigned long end, int write,
+			unsigned long end, unsigned int flags,
 			struct page **pages, int *nr)
 {
 	int refs;
 	struct page *head, *page;
 
-	if (!pgd_access_permitted(orig, write))
+	if (!pgd_access_permitted(orig, flags & FOLL_WRITE))
 		return 0;
 
 	BUILD_BUG_ON(pgd_devmap(orig));
@@ -1661,7 +1661,7 @@ static int gup_huge_pgd(pgd_t orig, pgd_t *pgdp, unsigned long addr,
 }
 
 static int gup_pmd_range(pud_t pud, unsigned long addr, unsigned long end,
-		int write, struct page **pages, int *nr)
+		unsigned int flags, struct page **pages, int *nr)
 {
 	unsigned long next;
 	pmd_t *pmdp;
@@ -1683,7 +1683,7 @@ static int gup_pmd_range(pud_t pud, unsigned long addr, unsigned long end,
 			if (pmd_protnone(pmd))
 				return 0;
 
-			if (!gup_huge_pmd(pmd, pmdp, addr, next, write,
+			if (!gup_huge_pmd(pmd, pmdp, addr, next, flags,
 				pages, nr))
 				return 0;
 
@@ -1693,9 +1693,9 @@ static int gup_pmd_range(pud_t pud, unsigned long addr, unsigned long end,
 			 * pmd format and THP pmd format
 			 */
 			if (!gup_huge_pd(__hugepd(pmd_val(pmd)), addr,
-					 PMD_SHIFT, next, write, pages, nr))
+					 PMD_SHIFT, next, flags, pages, nr))
 				return 0;
-		} else if (!gup_pte_range(pmd, addr, next, write, pages, nr))
+		} else if (!gup_pte_range(pmd, addr, next, flags, pages, nr))
 			return 0;
 	} while (pmdp++, addr = next, addr != end);
 
@@ -1703,7 +1703,7 @@ static int gup_pmd_range(pud_t pud, unsigned long addr, unsigned long end,
 }
 
 static int gup_pud_range(p4d_t p4d, unsigned long addr, unsigned long end,
-			 int write, struct page **pages, int *nr)
+			 unsigned int flags, struct page **pages, int *nr)
 {
 	unsigned long next;
 	pud_t *pudp;
@@ -1716,14 +1716,14 @@ static int gup_pud_range(p4d_t p4d, unsigned long addr, unsigned long end,
 		if (pud_none(pud))
 			return 0;
 		if (unlikely(pud_huge(pud))) {
-			if (!gup_huge_pud(pud, pudp, addr, next, write,
+			if (!gup_huge_pud(pud, pudp, addr, next, flags,
 					  pages, nr))
 				return 0;
 		} else if (unlikely(is_hugepd(__hugepd(pud_val(pud))))) {
 			if (!gup_huge_pd(__hugepd(pud_val(pud)), addr,
-					 PUD_SHIFT, next, write, pages, nr))
+					 PUD_SHIFT, next, flags, pages, nr))
 				return 0;
-		} else if (!gup_pmd_range(pud, addr, next, write, pages, nr))
+		} else if (!gup_pmd_range(pud, addr, next, flags, pages, nr))
 			return 0;
 	} while (pudp++, addr = next, addr != end);
 
@@ -1731,7 +1731,7 @@ static int gup_pud_range(p4d_t p4d, unsigned long addr, unsigned long end,
 }
 
 static int gup_p4d_range(pgd_t pgd, unsigned long addr, unsigned long end,
-			 int write, struct page **pages, int *nr)
+			 unsigned int flags, struct page **pages, int *nr)
 {
 	unsigned long next;
 	p4d_t *p4dp;
@@ -1746,9 +1746,9 @@ static int gup_p4d_range(pgd_t pgd, unsigned long addr, unsigned long end,
 		BUILD_BUG_ON(p4d_huge(p4d));
 		if (unlikely(is_hugepd(__hugepd(p4d_val(p4d))))) {
 			if (!gup_huge_pd(__hugepd(p4d_val(p4d)), addr,
-					 P4D_SHIFT, next, write, pages, nr))
+					 P4D_SHIFT, next, flags, pages, nr))
 				return 0;
-		} else if (!gup_pud_range(p4d, addr, next, write, pages, nr))
+		} else if (!gup_pud_range(p4d, addr, next, flags, pages, nr))
 			return 0;
 	} while (p4dp++, addr = next, addr != end);
 
@@ -1756,7 +1756,7 @@ static int gup_p4d_range(pgd_t pgd, unsigned long addr, unsigned long end,
 }
 
 static void gup_pgd_range(unsigned long addr, unsigned long end,
-		int write, struct page **pages, int *nr)
+		unsigned int flags, struct page **pages, int *nr)
 {
 	unsigned long next;
 	pgd_t *pgdp;
@@ -1769,14 +1769,14 @@ static void gup_pgd_range(unsigned long addr, unsigned long end,
 		if (pgd_none(pgd))
 			return;
 		if (unlikely(pgd_huge(pgd))) {
-			if (!gup_huge_pgd(pgd, pgdp, addr, next, write,
+			if (!gup_huge_pgd(pgd, pgdp, addr, next, flags,
 					  pages, nr))
 				return;
 		} else if (unlikely(is_hugepd(__hugepd(pgd_val(pgd))))) {
 			if (!gup_huge_pd(__hugepd(pgd_val(pgd)), addr,
-					 PGDIR_SHIFT, next, write, pages, nr))
+					 PGDIR_SHIFT, next, flags, pages, nr))
 				return;
-		} else if (!gup_p4d_range(pgd, addr, next, write, pages, nr))
+		} else if (!gup_p4d_range(pgd, addr, next, flags, pages, nr))
 			return;
 	} while (pgdp++, addr = next, addr != end);
 }
@@ -1830,7 +1830,7 @@ int __get_user_pages_fast(unsigned long start, int nr_pages, int write,
 
 	if (gup_fast_permitted(start, nr_pages)) {
 		local_irq_save(flags);
-		gup_pgd_range(start, end, write, pages, &nr);
+		gup_pgd_range(start, end, write ? FOLL_WRITE : 0, pages, &nr);
 		local_irq_restore(flags);
 	}
 
@@ -1872,7 +1872,7 @@ int get_user_pages_fast(unsigned long start, int nr_pages, int write,
 
 	if (gup_fast_permitted(start, nr_pages)) {
 		local_irq_disable();
-		gup_pgd_range(addr, end, write, pages, &nr);
+		gup_pgd_range(addr, end, write ? FOLL_WRITE : 0, pages, &nr);
 		local_irq_enable();
 		ret = nr;
 	}
-- 
2.20.1

