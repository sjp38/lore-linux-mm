Return-Path: <SRS0=NGLy=QU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4EBDEC43381
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 23:05:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 04CD1222A1
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 23:05:23 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 04CD1222A1
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A22A48E0010; Wed, 13 Feb 2019 18:05:22 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9AD288E0001; Wed, 13 Feb 2019 18:05:22 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8294C8E0010; Wed, 13 Feb 2019 18:05:22 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 370AF8E0001
	for <linux-mm@kvack.org>; Wed, 13 Feb 2019 18:05:22 -0500 (EST)
Received: by mail-pl1-f199.google.com with SMTP id b4so2807442plb.9
        for <linux-mm@kvack.org>; Wed, 13 Feb 2019 15:05:22 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=RzbtnJhqY18zIuZY4t315OOLtNGQZKeZZoAOjTb5+XQ=;
        b=YZRIZXIqRpo/KQuAssW/jbaQOlSF8jUdluRYreC97G58GTxhECKN/kp6cJsZxV2AXU
         RQekEh3yOYYLtOXRQJ3F60KGow/UshZeMGXOmeIE3tf9PUy7OkMRq0Q/PgKJ7NY6HGXM
         svhqYgneczdsrMePCydQZy/RD/z1KlaKVS9ntavMXHMt0knwxU+QdO4PN2tfH98whVrH
         0ZQRFtEz9GYq0csRZY5n7ZOKPNlDIuktoqq+5VphL8ujFC/95u+PKeaTJ5Tb8LkoS9UC
         zwzyX7PBOj8an1IEUex3fol9Vk7iFXNi/6L6gnu8FwUL15wppxK6XDcIYdyyG9NKDaTE
         GNOw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.65 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: AHQUAubyAGg46QukN2WxiSa/52meYFY+k4qGlbcNx9TowHtXhX+othAI
	SfKBbKXSCZtF1n6Z4MTcxmXi8J1TecYNAlVjpH7JNwTWoFKfyQnzPB9XPqwj/7IE/n23sH0oyvj
	xqvecSR4BcOOe7qn+b1Z3Pr0zpMjBljiUoGSVP7sdFQHYQVML3+dZ+109Cab9XwOpmA==
X-Received: by 2002:a63:235c:: with SMTP id u28mr616422pgm.400.1550099121896;
        Wed, 13 Feb 2019 15:05:21 -0800 (PST)
X-Google-Smtp-Source: AHgI3IbZgaZ1Vn1shW7GRAm+jZH//DOrXM0zT6vY1rzRokulNnLTSEnBtNKJGOXXSDTf1p5CEsMV
X-Received: by 2002:a63:235c:: with SMTP id u28mr616341pgm.400.1550099120953;
        Wed, 13 Feb 2019 15:05:20 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550099120; cv=none;
        d=google.com; s=arc-20160816;
        b=xgL8MGiDwG0YsFC9Uq4VUp+i6uAK4+WtDx9bk5pFmsC5E304GW1lUmFUgRhnZHQ9DP
         GeP3JDD0KlE44Q6IeIP0Wq3SF8OubFvMk6Z5uj2HRgb26b6jvZNQQZtj0HF9swG7EF0r
         6pG438b/Mtsdk+n6QhQ/xe0bj2/v0w3ISZaydaF141BmJkRN+xs0S7JzLNDjMp5M3kwZ
         9D5e9i/A0IMhmYoUK9AibhL9+GNyVyWrC8MEU/BpTls3wQMoy6tpWTbzWMFIFJ7eyQRJ
         KNOYr3DnVa4ijFZa7M/HQXfPcBq4AF8V+QVjLiIumq8k3zU/7td5iRm76RqFY1l12G4r
         5JxA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=RzbtnJhqY18zIuZY4t315OOLtNGQZKeZZoAOjTb5+XQ=;
        b=a01BeGuKqwaparAorqJRHId3iOky8lwpodYvtCdyVVg2toSNsnSRFaI0WKkedlXBwj
         T5hCBFiNZotb/HSkKjkIHSg0SulSo1B4fBKxZwemFM/SgZosdx6wNWVxfXkNDcmFK06D
         bDW7Nb4pRF8gJeSRGHNikr86GqWYusDZquCBBrNQAz8iTUb7xyIzKYttUqGmzCCuXeU3
         rMLzUf0aNnPeii0A8BrXjV/g4/B9hoCfFYDGiEYXjvS//RxvycnI2SXn3b8FIrNHGR6M
         LynXN5OZCi0K40AlcQAfXoeGy8V0fxsVA/NGF/2ghYSd4OJO9riOkykY7L1uw6WH/pQd
         av/g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.65 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id 3si599378pli.417.2019.02.13.15.05.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Feb 2019 15:05:20 -0800 (PST)
Received-SPF: pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.65 as permitted sender) client-ip=134.134.136.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.65 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga001.jf.intel.com ([10.7.209.18])
  by orsmga103.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 13 Feb 2019 15:05:20 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.58,366,1544515200"; 
   d="scan'208";a="138415588"
Received: from iweiny-desk2.sc.intel.com ([10.3.52.157])
  by orsmga001.jf.intel.com with ESMTP; 13 Feb 2019 15:05:18 -0800
From: ira.weiny@intel.com
To: linux-mips@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	kvm-ppc@vger.kernel.org,
	linuxppc-dev@lists.ozlabs.org,
	linux-s390@vger.kernel.org,
	linux-sh@vger.kernel.org,
	sparclinux@vger.kernel.org,
	kvm@vger.kernel.org,
	linux-fpga@vger.kernel.org,
	dri-devel@lists.freedesktop.org,
	linux-rdma@vger.kernel.org,
	linux-media@vger.kernel.org,
	linux-scsi@vger.kernel.org,
	devel@driverdev.osuosl.org,
	virtualization@lists.linux-foundation.org,
	netdev@vger.kernel.org,
	linux-fbdev@vger.kernel.org,
	xen-devel@lists.xenproject.org,
	devel@lists.orangefs.org,
	linux-mm@kvack.org,
	ceph-devel@vger.kernel.org,
	rds-devel@oss.oracle.com
Cc: Ira Weiny <ira.weiny@intel.com>,
	John Hubbard <jhubbard@nvidia.com>,
	David Hildenbrand <david@redhat.com>,
	Cornelia Huck <cohuck@redhat.com>,
	Yoshinori Sato <ysato@users.sourceforge.jp>,
	Rich Felker <dalias@libc.org>,
	"David S. Miller" <davem@davemloft.net>,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>,
	Borislav Petkov <bp@alien8.de>,
	Joerg Roedel <joro@8bytes.org>,
	Wu Hao <hao.wu@intel.com>,
	Alan Tull <atull@kernel.org>,
	Moritz Fischer <mdf@kernel.org>,
	David Airlie <airlied@linux.ie>,
	Daniel Vetter <daniel@ffwll.ch>,
	Jason Gunthorpe <jgg@ziepe.ca>,
	Dennis Dalessandro <dennis.dalessandro@intel.com>,
	Christian Benvenuti <benve@cisco.com>,
	Mauro Carvalho Chehab <mchehab@kernel.org>,
	Matt Porter <mporter@kernel.crashing.org>,
	Alexandre Bounine <alex.bou9@gmail.com>,
	=?UTF-8?q?Kai=20M=C3=A4kisara?= <Kai.Makisara@kolumbus.fi>,
	"James E.J. Bottomley" <jejb@linux.ibm.com>,
	"Martin K. Petersen" <martin.petersen@oracle.com>,
	Rob Springer <rspringer@google.com>,
	Todd Poynor <toddpoynor@google.com>,
	Ben Chan <benchan@chromium.org>,
	Jens Wiklander <jens.wiklander@linaro.org>,
	Alex Williamson <alex.williamson@redhat.com>,
	"Michael S. Tsirkin" <mst@redhat.com>,
	Jason Wang <jasowang@redhat.com>,
	Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>,
	Stefano Stabellini <sstabellini@kernel.org>,
	Martin Brandenburg <martin@omnibond.com>,
	Peter Zijlstra <peterz@infradead.org>,
	Alexander Viro <viro@zeniv.linux.org.uk>,
	Andrew Morton <akpm@linux-foundation.org>,
	Michal Hocko <mhocko@suse.com>,
	"Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH V2 2/7] mm/gup: Change write parameter to flags in fast walk
Date: Wed, 13 Feb 2019 15:04:50 -0800
Message-Id: <20190213230455.5605-3-ira.weiny@intel.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190213230455.5605-1-ira.weiny@intel.com>
References: <20190211201643.7599-1-ira.weiny@intel.com>
 <20190213230455.5605-1-ira.weiny@intel.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Ira Weiny <ira.weiny@intel.com>

In order to support more options in the GUP fast walk, change
the write parameter to flags throughout the call stack.

This patch does not change functionality and passes FOLL_WRITE
where write was previously used.

Signed-off-by: Ira Weiny <ira.weiny@intel.com>
---
 mm/gup.c | 52 ++++++++++++++++++++++++++--------------------------
 1 file changed, 26 insertions(+), 26 deletions(-)

diff --git a/mm/gup.c b/mm/gup.c
index ee96eaff118c..681388236106 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -1417,7 +1417,7 @@ static void undo_dev_pagemap(int *nr, int nr_start, struct page **pages)
 
 #ifdef CONFIG_ARCH_HAS_PTE_SPECIAL
 static int gup_pte_range(pmd_t pmd, unsigned long addr, unsigned long end,
-			 int write, struct page **pages, int *nr)
+			 unsigned int flags, struct page **pages, int *nr)
 {
 	struct dev_pagemap *pgmap = NULL;
 	int nr_start = *nr, ret = 0;
@@ -1435,7 +1435,7 @@ static int gup_pte_range(pmd_t pmd, unsigned long addr, unsigned long end,
 		if (pte_protnone(pte))
 			goto pte_unmap;
 
-		if (!pte_access_permitted(pte, write))
+		if (!pte_access_permitted(pte, flags & FOLL_WRITE))
 			goto pte_unmap;
 
 		if (pte_devmap(pte)) {
@@ -1487,7 +1487,7 @@ static int gup_pte_range(pmd_t pmd, unsigned long addr, unsigned long end,
  * useful to have gup_huge_pmd even if we can't operate on ptes.
  */
 static int gup_pte_range(pmd_t pmd, unsigned long addr, unsigned long end,
-			 int write, struct page **pages, int *nr)
+			 unsigned int flags, struct page **pages, int *nr)
 {
 	return 0;
 }
@@ -1570,12 +1570,12 @@ static int __gup_device_huge_pud(pud_t pud, pud_t *pudp, unsigned long addr,
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
@@ -1608,12 +1608,12 @@ static int gup_huge_pmd(pmd_t orig, pmd_t *pmdp, unsigned long addr,
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
@@ -1646,13 +1646,13 @@ static int gup_huge_pud(pud_t orig, pud_t *pudp, unsigned long addr,
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
@@ -1683,7 +1683,7 @@ static int gup_huge_pgd(pgd_t orig, pgd_t *pgdp, unsigned long addr,
 }
 
 static int gup_pmd_range(pud_t pud, unsigned long addr, unsigned long end,
-		int write, struct page **pages, int *nr)
+		unsigned int flags, struct page **pages, int *nr)
 {
 	unsigned long next;
 	pmd_t *pmdp;
@@ -1705,7 +1705,7 @@ static int gup_pmd_range(pud_t pud, unsigned long addr, unsigned long end,
 			if (pmd_protnone(pmd))
 				return 0;
 
-			if (!gup_huge_pmd(pmd, pmdp, addr, next, write,
+			if (!gup_huge_pmd(pmd, pmdp, addr, next, flags,
 				pages, nr))
 				return 0;
 
@@ -1715,9 +1715,9 @@ static int gup_pmd_range(pud_t pud, unsigned long addr, unsigned long end,
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
 
@@ -1725,7 +1725,7 @@ static int gup_pmd_range(pud_t pud, unsigned long addr, unsigned long end,
 }
 
 static int gup_pud_range(p4d_t p4d, unsigned long addr, unsigned long end,
-			 int write, struct page **pages, int *nr)
+			 unsigned int flags, struct page **pages, int *nr)
 {
 	unsigned long next;
 	pud_t *pudp;
@@ -1738,14 +1738,14 @@ static int gup_pud_range(p4d_t p4d, unsigned long addr, unsigned long end,
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
 
@@ -1753,7 +1753,7 @@ static int gup_pud_range(p4d_t p4d, unsigned long addr, unsigned long end,
 }
 
 static int gup_p4d_range(pgd_t pgd, unsigned long addr, unsigned long end,
-			 int write, struct page **pages, int *nr)
+			 unsigned int flags, struct page **pages, int *nr)
 {
 	unsigned long next;
 	p4d_t *p4dp;
@@ -1768,9 +1768,9 @@ static int gup_p4d_range(pgd_t pgd, unsigned long addr, unsigned long end,
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
 
@@ -1778,7 +1778,7 @@ static int gup_p4d_range(pgd_t pgd, unsigned long addr, unsigned long end,
 }
 
 static void gup_pgd_range(unsigned long addr, unsigned long end,
-		int write, struct page **pages, int *nr)
+		unsigned int flags, struct page **pages, int *nr)
 {
 	unsigned long next;
 	pgd_t *pgdp;
@@ -1791,14 +1791,14 @@ static void gup_pgd_range(unsigned long addr, unsigned long end,
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
@@ -1852,7 +1852,7 @@ int __get_user_pages_fast(unsigned long start, int nr_pages, int write,
 
 	if (gup_fast_permitted(start, nr_pages)) {
 		local_irq_save(flags);
-		gup_pgd_range(start, end, write, pages, &nr);
+		gup_pgd_range(start, end, write ? FOLL_WRITE : 0, pages, &nr);
 		local_irq_restore(flags);
 	}
 
@@ -1894,7 +1894,7 @@ int get_user_pages_fast(unsigned long start, int nr_pages, int write,
 
 	if (gup_fast_permitted(start, nr_pages)) {
 		local_irq_disable();
-		gup_pgd_range(addr, end, write, pages, &nr);
+		gup_pgd_range(addr, end, write ? FOLL_WRITE : 0, pages, &nr);
 		local_irq_enable();
 		ret = nr;
 	}
-- 
2.20.1

