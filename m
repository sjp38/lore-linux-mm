Return-Path: <SRS0=cFM0=SE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 91EBEC43381
	for <linux-mm@archiver.kernel.org>; Tue,  2 Apr 2019 06:16:02 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 415A320840
	for <linux-mm@archiver.kernel.org>; Tue,  2 Apr 2019 06:16:02 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="rv67fSE1"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 415A320840
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BFBA16B000A; Tue,  2 Apr 2019 02:16:01 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BAD326B000C; Tue,  2 Apr 2019 02:16:01 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A9B2B6B000D; Tue,  2 Apr 2019 02:16:01 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 6D4716B000A
	for <linux-mm@kvack.org>; Tue,  2 Apr 2019 02:16:01 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id q18so9203313pll.16
        for <linux-mm@kvack.org>; Mon, 01 Apr 2019 23:16:01 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id;
        bh=HNLOXKMkXS3VFA0QLpE3irTtPfGsxTQAztgaYb0moyE=;
        b=bZA6QW8zSFGhSMMQF2TwXpaOR8Hqp5YBP5LEJdetSlV1lMaBMArHhTMlOKhNfJgYab
         dexjdm2p9zLKdxF7ShuCoTTQtlB+4otk4dEupAUaKxXLSeSECcQm+qYVXN4gDwSURa28
         3+/7q3Y2/nA7R1zPCyYDPRrPrzeNyRSvky5gLnfixTJNWu33/Wwi+K2YAy89LoSyIk6Z
         1vZ623V0EJc7WGm0jft59dtXOUYKlOWOjH2nuceckk1Dfq8opxpMTHwcMSO74Uq/woo4
         1+U++x9RPmb6iGICXBzipL9yQca68ZMEcU/ivvB9npEzhDmL+WP3QBawOlDm91e6kz2z
         sc6Q==
X-Gm-Message-State: APjAAAVT1SNuQdek/cbh799xmTJ4Y9Yd808x8XFyOd0lI5Jqg+Y/Jge2
	PmhAeV64Snr43r1EJ9s8kUrXps3lGugQosLAsr7BDjT6+qy2T0tNiWYLAu+VJVbC7slPDWNld65
	0GX4bqemuAgiMCq1lvqN04R7myDStBYjZUiubaFGNn08xqJdZyJImFTUDjzWJjr7rAg==
X-Received: by 2002:a63:7154:: with SMTP id b20mr57651873pgn.359.1554185760370;
        Mon, 01 Apr 2019 23:16:00 -0700 (PDT)
X-Received: by 2002:a63:7154:: with SMTP id b20mr57651807pgn.359.1554185759364;
        Mon, 01 Apr 2019 23:15:59 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554185759; cv=none;
        d=google.com; s=arc-20160816;
        b=xgAs6grj9Mz4L0ihI7Tbx+KFFg6I8LNSYJbP6Q7wBtIGfGBj6K7uJbbI0rjwLirxxJ
         +OmQEOOnZa/yQRmwKaiD/cYdcicXjih7lUDEP+Y8kpCiddILVo0c9aOTOScabQ+76rHi
         A8Js9AHe/bEjwiTjmPaioI8Q0ZsUr1CY5ZBUSMPTSCVQlKju+JBIr64/NzOI6neuTQxK
         TYY3fp5DsgGTgwksdLrZjuviXMI3oCysFkhaPhjdQnCVqK5GyFchfKQg5wFgVZna4676
         6N69RKL+iO7r4xsOjJsagknoSntOj+qXvyh+sMHHQaL2yvQqb7bQ5CnMUs+qTbg9Pwh5
         TqTA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from:dkim-signature;
        bh=HNLOXKMkXS3VFA0QLpE3irTtPfGsxTQAztgaYb0moyE=;
        b=qt6hA+pMx8G7+IK944oQ+hG/O6ievNIejppOSCAeYdiVS97W8KGVtieY6uKaHekcnx
         dp3fcmCjrubap9A2aoNViH/J6Ew/BTFq0/i0VJe5Opaem8CC2JO8+wPNCggyDR6ertKp
         fZhbrrqMYvx6iXTu9EyvOnGWJrcxtzMlkgfoMiEIWqbxX4gLjK79SLIxU3lM4mHXNhDO
         s29ePX2wpoEPPwuNO0pWqPBfjrB9HuCH/tIlx8xt4AKL0EL3Dvb0BZlOmbggU8AyN5Ae
         kK16mNJ9HbgZ5cbUF7rTdmxhJoaq2MHfo+eS2OKBJexsVa6QEF5zJ9XkwS9S87C0d+BQ
         HX0g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=rv67fSE1;
       spf=pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=laoar.shao@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 91sor15713180ply.0.2019.04.01.23.15.59
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 01 Apr 2019 23:15:59 -0700 (PDT)
Received-SPF: pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=rv67fSE1;
       spf=pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=laoar.shao@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id;
        bh=HNLOXKMkXS3VFA0QLpE3irTtPfGsxTQAztgaYb0moyE=;
        b=rv67fSE1zYWK1oMVHX7gjzVy/QgtD08f8JxcvftIrG649QzK7VvQRqzDoOiKmNPIPH
         R/+zr6YCDmmvHCx/p1nxSPDeIs2YfB050PT2NimGIPQ+vve/dglrcT2qCEwWzf7AeCwL
         nNAQnFtMp61W07A9zcwgeaSNMgFRPZ/1XT5Lxl+cI3/w83YUoRbh4BKQ8XWVW7s3bb+7
         X0IczXfjk86hFW7WztbjFhzOj5daEJPquxCZ8tvDEqj5uUlURCMAs0wSAy+otrTK8nbL
         f1dJBrnK7y5E9fw9Ua9DZYWLv4+srilKt9KpEGxvof0B/J3fdNbnsLapzXYFBVnXFkYm
         M4cA==
X-Google-Smtp-Source: APXvYqz4D9HiXIP+szJbeCcicHuGf94mfm0FK+7UrYfQu42+0h4oyH/s1M3cy99EhrlMh0ayMdSEBg==
X-Received: by 2002:a17:902:8c8b:: with SMTP id t11mr11105941plo.15.1554185759044;
        Mon, 01 Apr 2019 23:15:59 -0700 (PDT)
Received: from localhost.localdomain ([203.100.54.194])
        by smtp.gmail.com with ESMTPSA id u26sm17151470pfn.5.2019.04.01.23.15.52
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 01 Apr 2019 23:15:55 -0700 (PDT)
From: Yafang Shao <laoar.shao@gmail.com>
To: mhocko@suse.com,
	willy@infradead.org,
	jack@suse.cz,
	hughd@google.com,
	vbabka@suse.cz,
	akpm@linux-foundation.org
Cc: linux-mm@kvack.org,
	Yafang Shao <laoar.shao@gmail.com>
Subject: [PATCH] mm: add vm event for page cache miss
Date: Tue,  2 Apr 2019 14:15:20 +0800
Message-Id: <1554185720-26404-1-git-send-email-laoar.shao@gmail.com>
X-Mailer: git-send-email 1.8.3.1
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

We found that some latency spike was caused by page cache miss on our
database server.
So we decide to measure the page cache miss.
Currently the kernel is lack of this facility for measuring it.

This patch introduces a new vm counter PGCACHEMISS for this purpose.
This counter will be incremented in bellow scenario,
- page cache miss in generic file read routine
- read access page cache miss in mmap
- read access page cache miss in swapin

NB, readahead routine is not counted because it won't stall the
application directly.

Signed-off-by: Yafang Shao <laoar.shao@gmail.com>
---
 include/linux/pagemap.h       | 7 +++++++
 include/linux/vm_event_item.h | 1 +
 mm/filemap.c                  | 2 ++
 mm/memory.c                   | 1 +
 mm/shmem.c                    | 9 +++++----
 mm/vmstat.c                   | 1 +
 6 files changed, 17 insertions(+), 4 deletions(-)

diff --git a/include/linux/pagemap.h b/include/linux/pagemap.h
index f939e00..8355b51 100644
--- a/include/linux/pagemap.h
+++ b/include/linux/pagemap.h
@@ -233,6 +233,13 @@ pgoff_t page_cache_next_miss(struct address_space *mapping,
 pgoff_t page_cache_prev_miss(struct address_space *mapping,
 			     pgoff_t index, unsigned long max_scan);
 
+static inline void page_cache_read_miss(struct vm_fault *vmf)
+{
+	if (!vmf || (vmf->flags & (FAULT_FLAG_USER | FAULT_FLAG_WRITE)) ==
+	    FAULT_FLAG_USER)
+		count_vm_event(PGCACHEMISS);
+}
+
 #define FGP_ACCESSED		0x00000001
 #define FGP_LOCK		0x00000002
 #define FGP_CREAT		0x00000004
diff --git a/include/linux/vm_event_item.h b/include/linux/vm_event_item.h
index 47a3441..d589f05 100644
--- a/include/linux/vm_event_item.h
+++ b/include/linux/vm_event_item.h
@@ -29,6 +29,7 @@ enum vm_event_item { PGPGIN, PGPGOUT, PSWPIN, PSWPOUT,
 		PGFREE, PGACTIVATE, PGDEACTIVATE, PGLAZYFREE,
 		PGFAULT, PGMAJFAULT,
 		PGLAZYFREED,
+		PGCACHEMISS,
 		PGREFILL,
 		PGSTEAL_KSWAPD,
 		PGSTEAL_DIRECT,
diff --git a/mm/filemap.c b/mm/filemap.c
index 4157f85..fc12c2d 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -2256,6 +2256,7 @@ static ssize_t generic_file_buffered_read(struct kiocb *iocb,
 		goto out;
 
 no_cached_page:
+		page_cache_read_miss(NULL);
 		/*
 		 * Ok, it wasn't cached, so we need to create a new
 		 * page..
@@ -2556,6 +2557,7 @@ vm_fault_t filemap_fault(struct vm_fault *vmf)
 		fpin = do_async_mmap_readahead(vmf, page);
 	} else if (!page) {
 		/* No page in the page cache at all */
+		page_cache_read_miss(vmf);
 		count_vm_event(PGMAJFAULT);
 		count_memcg_event_mm(vmf->vma->vm_mm, PGMAJFAULT);
 		ret = VM_FAULT_MAJOR;
diff --git a/mm/memory.c b/mm/memory.c
index bd157f2..63bcd41 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2754,6 +2754,7 @@ vm_fault_t do_swap_page(struct vm_fault *vmf)
 		ret = VM_FAULT_MAJOR;
 		count_vm_event(PGMAJFAULT);
 		count_memcg_event_mm(vma->vm_mm, PGMAJFAULT);
+		page_cache_read_miss(vmf);
 	} else if (PageHWPoison(page)) {
 		/*
 		 * hwpoisoned dirty swapcache pages are kept for killing
diff --git a/mm/shmem.c b/mm/shmem.c
index 3a4b74c..47e33a4 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -127,7 +127,7 @@ static int shmem_replace_page(struct page **pagep, gfp_t gfp,
 static int shmem_swapin_page(struct inode *inode, pgoff_t index,
 			     struct page **pagep, enum sgp_type sgp,
 			     gfp_t gfp, struct vm_area_struct *vma,
-			     vm_fault_t *fault_type);
+			     struct vm_fault *vmf, vm_fault_t *fault_type);
 static int shmem_getpage_gfp(struct inode *inode, pgoff_t index,
 		struct page **pagep, enum sgp_type sgp,
 		gfp_t gfp, struct vm_area_struct *vma,
@@ -1159,7 +1159,7 @@ static int shmem_unuse_swap_entries(struct inode *inode, struct pagevec pvec,
 		error = shmem_swapin_page(inode, indices[i],
 					  &page, SGP_CACHE,
 					  mapping_gfp_mask(mapping),
-					  NULL, NULL);
+					  NULL, NULL, NULL);
 		if (error == 0) {
 			unlock_page(page);
 			put_page(page);
@@ -1614,7 +1614,7 @@ static int shmem_replace_page(struct page **pagep, gfp_t gfp,
 static int shmem_swapin_page(struct inode *inode, pgoff_t index,
 			     struct page **pagep, enum sgp_type sgp,
 			     gfp_t gfp, struct vm_area_struct *vma,
-			     vm_fault_t *fault_type)
+			     struct vm_fault *vmf, vm_fault_t *fault_type)
 {
 	struct address_space *mapping = inode->i_mapping;
 	struct shmem_inode_info *info = SHMEM_I(inode);
@@ -1636,6 +1636,7 @@ static int shmem_swapin_page(struct inode *inode, pgoff_t index,
 			*fault_type |= VM_FAULT_MAJOR;
 			count_vm_event(PGMAJFAULT);
 			count_memcg_event_mm(charge_mm, PGMAJFAULT);
+			page_cache_read_miss(vmf);
 		}
 		/* Here we actually start the io */
 		page = shmem_swapin(swap, gfp, info, index);
@@ -1758,7 +1759,7 @@ static int shmem_getpage_gfp(struct inode *inode, pgoff_t index,
 	page = find_lock_entry(mapping, index);
 	if (xa_is_value(page)) {
 		error = shmem_swapin_page(inode, index, &page,
-					  sgp, gfp, vma, fault_type);
+					  sgp, gfp, vma, vmf, fault_type);
 		if (error == -EEXIST)
 			goto repeat;
 
diff --git a/mm/vmstat.c b/mm/vmstat.c
index 36b56f8..c49ecba 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -1188,6 +1188,7 @@ int fragmentation_index(struct zone *zone, unsigned int order)
 	"pgfault",
 	"pgmajfault",
 	"pglazyfreed",
+	"pgcachemiss",
 
 	"pgrefill",
 	"pgsteal_kswapd",
-- 
1.8.3.1

