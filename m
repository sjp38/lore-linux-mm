Return-Path: <SRS0=ywda=QG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9AFB4C282D7
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 12:45:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5814420882
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 12:45:24 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5814420882
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 116898E0003; Wed, 30 Jan 2019 07:45:17 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DCADF8E0005; Wed, 30 Jan 2019 07:45:16 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BCC478E0003; Wed, 30 Jan 2019 07:45:16 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 352788E0004
	for <linux-mm@kvack.org>; Wed, 30 Jan 2019 07:45:16 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id e12so9347605edd.16
        for <linux-mm@kvack.org>; Wed, 30 Jan 2019 04:45:16 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=ulYz79XtO1G0723Gc8tScT/ZS89wck5bZo+KvUiTKmc=;
        b=PrnddM8s35zCPw+PFZq6Vfr7jhlyS2nzwhSARTyVRXMQhH4nsUNgc6Sgx8GsEVc0Yo
         Nfq7XPIcZLP2iSGS48boKAPsY2AxP9a+Zx1rq2H4Flwb0Djm1irwbiO5L4/Z+GT9h5Ae
         hKISiVRSzVC7aGBiseBZ4WHPylWUHdwJgX1x1ktFaAFiqgx1by1/86xhj8+pCqafLRBF
         BIW/J0266BEH1QAFdDltgTnARQM0GjM2Q8tO9SSqH8RII+9ia16mysey/RP8IdpRyOct
         s3EU3hq2R5VdOMaAa6cH9AWuwJbiQncUh9mZhQtT2JsNYV5Ma9Dk/IVPd+CxD/laIvUz
         Q9vg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Gm-Message-State: AJcUukeBLt44VHY3LzSsWm/Z/qMWoh0c+tiIRUAHp+ezJvEtBDvjhl9T
	pV/U0onoSIrJiLTej2MQ/qJdgr93fJmIZv7CPLgM6gMoBqwgfezwnx9rJS/cdbWsDyGZtHEdVf2
	3yXucC9UwIrmmitz+kx9r29ic+JQ/6/1cnNELGM1L4zW9kKYAcPWeBwd1KPvHR5Q9WQ==
X-Received: by 2002:a50:8fe4:: with SMTP id y91mr29446089edy.231.1548852315663;
        Wed, 30 Jan 2019 04:45:15 -0800 (PST)
X-Google-Smtp-Source: ALg8bN4KTmChHCtugxnfjeHunYMIKA/lDkEQB8n9CzJLKE8f2Shl76mTeRpwaE9HWWUuT628tPb5
X-Received: by 2002:a50:8fe4:: with SMTP id y91mr29445995edy.231.1548852314136;
        Wed, 30 Jan 2019 04:45:14 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548852314; cv=none;
        d=google.com; s=arc-20160816;
        b=kuGkaAgJ19g/gHHtknwYnFZYYai5DPx4DGjlHV495vrL6joSsRZGV6NavL+HsCx4sW
         tKNjF9GTBsFN+MbQvc1LKsNyrk4jRJtksP/KElYaOA9YsSqU9XUTLVMdH4pvy6cQ85c9
         bSXT92oOBvo5j3+hsUh4oGP/ff/jPW7x3+7J+mc+330hk4pW0y/Q1TKww0XzCkVjO4S+
         pcDv0FZbBgAta6khG634Gw72/0BU/k7qbd3svoj/lF9AU1hYwd4C4XbwpxF66j0RYrPv
         Pco6Tks/kJcmYvXYtb+B80KYIR++qJ0cVAXYM4VqdFCdWTw8wOv0yKUC0sk7c3mgEVxr
         UmLw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=ulYz79XtO1G0723Gc8tScT/ZS89wck5bZo+KvUiTKmc=;
        b=FZyLbzXDg2kTPxBij7tLjj8ItW6FIUknwlEJ4aFtm3rlSREj2OUrKQjxCenZvDYD3C
         7wNMnnblQbVs1Ha1vf1UIy/l5WKP0wmIjq1FjTCmJcu2te3+f8PmBrryUZJ8w32XYy82
         5rReqUC5jrFlHAzTFSvmZYhbPjdKr9BJpGevX5jiz1+3laEOV/pivpJC1aT4+UEp6qS6
         MqEzenpirByrWYwKjuJpqKh7y7ttz5nIXmcAyQgqMqWAVTDoXsee9OmkNCaUOX7Jc4/g
         YNPV5WyCA6kNRqC49091LhO7b+0gMLQdI/yyIm3QbvQudbHUKx0BYrRh9SbduhpYnrk6
         L4JA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id n2si786123ejr.241.2019.01.30.04.45.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 30 Jan 2019 04:45:14 -0800 (PST)
Received-SPF: pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 44459AFC5;
	Wed, 30 Jan 2019 12:45:13 +0000 (UTC)
From: Vlastimil Babka <vbabka@suse.cz>
To: Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org,
	linux-mm@kvack.org,
	linux-api@vger.kernel.org,
	Peter Zijlstra <peterz@infradead.org>,
	Greg KH <gregkh@linuxfoundation.org>,
	Jann Horn <jannh@google.com>,
	Vlastimil Babka <vbabka@suse.cz>,
	Jiri Kosina <jikos@kernel.org>,
	Dominique Martinet <asmadeus@codewreck.org>,
	Andy Lutomirski <luto@amacapital.net>,
	Dave Chinner <david@fromorbit.com>,
	Kevin Easton <kevin@guarana.org>,
	Matthew Wilcox <willy@infradead.org>,
	Cyril Hrubis <chrubis@suse.cz>,
	Tejun Heo <tj@kernel.org>,
	"Kirill A . Shutemov" <kirill@shutemov.name>,
	Daniel Gruss <daniel@gruss.cc>,
	Jiri Kosina <jkosina@suse.cz>
Subject: [PATCH 3/3] mm/mincore: provide mapped status when cached status is not allowed
Date: Wed, 30 Jan 2019 13:44:20 +0100
Message-Id: <20190130124420.1834-4-vbabka@suse.cz>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190130124420.1834-1-vbabka@suse.cz>
References: <nycvar.YFH.7.76.1901051817390.16954@cbobk.fhfr.pm>
 <20190130124420.1834-1-vbabka@suse.cz>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

After "mm/mincore: make mincore() more conservative" we sometimes restrict the
information about page cache residency, which we have to do without breaking
existing userspace, if possible. We thus fake the resulting values as 1, which
should be safer than faking them as 0, as there might theoretically exist code
that would try to fault in the page(s) until mincore() returns 1.

Faking 1 however means that such code would not fault in a page even if it was
not in page cache, with unwanted performance implications. We can improve the
situation by revisting the approach of 574823bfab82 ("Change mincore() to count
"mapped" pages rather than "cached" pages") but only applying it to cases where
page cache residency check is restricted. Thus mincore() will return 0 for an
unmapped page (which may or may not be resident in a pagecache), and 1 after
the process faults it in.

One potential downside is that mincore() will be again able to recognize when a
previously mapped page was reclaimed. While that might be useful for some
attack scenarios, it's not as crucial as recognizing that somebody else faulted
the page in, and there are also other ways to recognize reclaimed pages anyway.

Cc: Jiri Kosina <jikos@kernel.org>
Cc: Dominique Martinet <asmadeus@codewreck.org>
Cc: Andy Lutomirski <luto@amacapital.net>
Cc: Dave Chinner <david@fromorbit.com>
Cc: Kevin Easton <kevin@guarana.org>
Cc: Matthew Wilcox <willy@infradead.org>
Cc: Cyril Hrubis <chrubis@suse.cz>
Cc: Tejun Heo <tj@kernel.org>
Cc: Kirill A. Shutemov <kirill@shutemov.name>
Cc: Daniel Gruss <daniel@gruss.cc>
Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
---
 mm/mincore.c | 49 +++++++++++++++++++++++++++++++++----------------
 1 file changed, 33 insertions(+), 16 deletions(-)

diff --git a/mm/mincore.c b/mm/mincore.c
index 747a4907a3ac..d6784a803ae7 100644
--- a/mm/mincore.c
+++ b/mm/mincore.c
@@ -21,12 +21,18 @@
 #include <linux/uaccess.h>
 #include <asm/pgtable.h>
 
+struct mincore_walk_private {
+	unsigned char *vec;
+	bool can_check_pagecache;
+};
+
 static int mincore_hugetlb(pte_t *pte, unsigned long hmask, unsigned long addr,
 			unsigned long end, struct mm_walk *walk)
 {
 #ifdef CONFIG_HUGETLB_PAGE
 	unsigned char present;
-	unsigned char *vec = walk->private;
+	struct mincore_walk_private *walk_private = walk->private;
+	unsigned char *vec = walk_private->vec;
 
 	/*
 	 * Hugepages under user process are always in RAM and never
@@ -35,7 +41,7 @@ static int mincore_hugetlb(pte_t *pte, unsigned long hmask, unsigned long addr,
 	present = pte && !huge_pte_none(huge_ptep_get(pte));
 	for (; addr != end; vec++, addr += PAGE_SIZE)
 		*vec = present;
-	walk->private = vec;
+	walk_private->vec = vec;
 #else
 	BUG();
 #endif
@@ -85,7 +91,8 @@ static unsigned char mincore_page(struct address_space *mapping, pgoff_t pgoff)
 }
 
 static int __mincore_unmapped_range(unsigned long addr, unsigned long end,
-				struct vm_area_struct *vma, unsigned char *vec)
+				struct vm_area_struct *vma, unsigned char *vec,
+				bool can_check_pagecache)
 {
 	unsigned long nr = (end - addr) >> PAGE_SHIFT;
 	int i;
@@ -95,7 +102,9 @@ static int __mincore_unmapped_range(unsigned long addr, unsigned long end,
 
 		pgoff = linear_page_index(vma, addr);
 		for (i = 0; i < nr; i++, pgoff++)
-			vec[i] = mincore_page(vma->vm_file->f_mapping, pgoff);
+			vec[i] = can_check_pagecache ?
+				 mincore_page(vma->vm_file->f_mapping, pgoff)
+				 : 0;
 	} else {
 		for (i = 0; i < nr; i++)
 			vec[i] = 0;
@@ -106,8 +115,11 @@ static int __mincore_unmapped_range(unsigned long addr, unsigned long end,
 static int mincore_unmapped_range(unsigned long addr, unsigned long end,
 				   struct mm_walk *walk)
 {
-	walk->private += __mincore_unmapped_range(addr, end,
-						  walk->vma, walk->private);
+	struct mincore_walk_private *walk_private = walk->private;
+	unsigned char *vec = walk_private->vec;
+
+	walk_private->vec += __mincore_unmapped_range(addr, end, walk->vma,
+				vec, walk_private->can_check_pagecache);
 	return 0;
 }
 
@@ -117,7 +129,8 @@ static int mincore_pte_range(pmd_t *pmd, unsigned long addr, unsigned long end,
 	spinlock_t *ptl;
 	struct vm_area_struct *vma = walk->vma;
 	pte_t *ptep;
-	unsigned char *vec = walk->private;
+	struct mincore_walk_private *walk_private = walk->private;
+	unsigned char *vec = walk_private->vec;
 	int nr = (end - addr) >> PAGE_SHIFT;
 
 	ptl = pmd_trans_huge_lock(pmd, vma);
@@ -128,7 +141,8 @@ static int mincore_pte_range(pmd_t *pmd, unsigned long addr, unsigned long end,
 	}
 
 	if (pmd_trans_unstable(pmd)) {
-		__mincore_unmapped_range(addr, end, vma, vec);
+		__mincore_unmapped_range(addr, end, vma, vec,
+					walk_private->can_check_pagecache);
 		goto out;
 	}
 
@@ -138,7 +152,7 @@ static int mincore_pte_range(pmd_t *pmd, unsigned long addr, unsigned long end,
 
 		if (pte_none(pte))
 			__mincore_unmapped_range(addr, addr + PAGE_SIZE,
-						 vma, vec);
+				 vma, vec, walk_private->can_check_pagecache);
 		else if (pte_present(pte))
 			*vec = 1;
 		else { /* pte is a swap entry */
@@ -152,8 +166,12 @@ static int mincore_pte_range(pmd_t *pmd, unsigned long addr, unsigned long end,
 				*vec = 1;
 			} else {
 #ifdef CONFIG_SWAP
-				*vec = mincore_page(swap_address_space(entry),
+				if (walk_private->can_check_pagecache)
+					*vec = mincore_page(
+						    swap_address_space(entry),
 						    swp_offset(entry));
+				else
+					*vec = 0;
 #else
 				WARN_ON(1);
 				*vec = 1;
@@ -187,22 +205,21 @@ static long do_mincore(unsigned long addr, unsigned long pages, unsigned char *v
 	struct vm_area_struct *vma;
 	unsigned long end;
 	int err;
+	struct mincore_walk_private walk_private = {
+		.vec = vec
+	};
 	struct mm_walk mincore_walk = {
 		.pmd_entry = mincore_pte_range,
 		.pte_hole = mincore_unmapped_range,
 		.hugetlb_entry = mincore_hugetlb,
-		.private = vec,
+		.private = &walk_private
 	};
 
 	vma = find_vma(current->mm, addr);
 	if (!vma || addr < vma->vm_start)
 		return -ENOMEM;
 	end = min(vma->vm_end, addr + (pages << PAGE_SHIFT));
-	if (!can_do_mincore(vma)) {
-		unsigned long pages = (end - addr) >> PAGE_SHIFT;
-		memset(vec, 1, pages);
-		return pages;
-	}
+	walk_private.can_check_pagecache = can_do_mincore(vma);
 	mincore_walk.mm = vma->vm_mm;
 	err = walk_page_range(addr, end, &mincore_walk);
 	if (err < 0)
-- 
2.20.1

