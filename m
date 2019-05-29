Return-Path: <SRS0=FSMz=T5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,T_DKIMWL_WL_HIGH,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E25FDC28CC1
	for <linux-mm@archiver.kernel.org>; Wed, 29 May 2019 21:36:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8ED7024223
	for <linux-mm@archiver.kernel.org>; Wed, 29 May 2019 21:36:56 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="h0HkURYE"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8ED7024223
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CCE1F6B026A; Wed, 29 May 2019 17:36:54 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CA8436B026D; Wed, 29 May 2019 17:36:54 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AD12F6B0274; Wed, 29 May 2019 17:36:54 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 5432F6B026D
	for <linux-mm@kvack.org>; Wed, 29 May 2019 17:36:54 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id r191so786966pgr.23
        for <linux-mm@kvack.org>; Wed, 29 May 2019 14:36:54 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:smtp-origin-hostprefix:from
         :smtp-origin-hostname:to:cc:smtp-origin-cluster:subject:date
         :message-id:in-reply-to:references:mime-version;
        bh=e4fE3iJAPMCO/Qbuvxgy9RjCcmbzJ+JxIMLpqr9tekI=;
        b=B8eLg95d1zofvcCONdptKO0klnQMhVFY2WSsBZRxI9pLvpvGQkc8X4fWO5mYJofVBY
         vF9K1NTaCr49D4TBW76iIfDka25UyQgohk86DqMsw5Ro6RN0DHZIt1K5FAqwH0s5Fe8e
         3lMfm1ZnAmbeuWqnxsVzwjy0aygkWpDiC4nIo3FO7UQFI8l+s+X1/Uc5nJfJgA+vIM1z
         FChovOGiXor3N9OzGEKiAfjtIAvH20fk7zXnvK5uxFT2EvaHj4rEkKOmBlGvOxZWsYI9
         zFD0qYfEnyZ4+fIeU48R1LUQjpSjTxzEj/mFSdrPF8cmExCUS+z0+I3fCkH/R2Qh9Mr7
         GP2w==
X-Gm-Message-State: APjAAAU4+Z302ivVZ522qmM4V7nkNyCl0BS0bvHsbq5Tj/H8HQH0pBwO
	uvhr52emkn2Wyn9iJ/gIeV4uIh6lo3HA7h7+YBBgPBtyPRwxEC5Qx4/lyJRYUbpCwUGkqCBDqXu
	VUm0p4ciudjieWpMRnh8xpk5PLgVcVMN2B1umEi5SCnzg0SjrWMERMgL+wfYrNVF79Q==
X-Received: by 2002:a63:ee0b:: with SMTP id e11mr93726pgi.453.1559165813900;
        Wed, 29 May 2019 14:36:53 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy5HJq6HynN9xSxkO/u3kYbTd8P0d0bAp4h8+ONUM/HPit4Y+QJNo/3khDmKQg+pqKnanDc
X-Received: by 2002:a63:ee0b:: with SMTP id e11mr93675pgi.453.1559165812699;
        Wed, 29 May 2019 14:36:52 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559165812; cv=none;
        d=google.com; s=arc-20160816;
        b=pZe++amySsExI5Ik3E95J+EHvEdaN9krgMBMMYe+/vD/gxu286AP1ILjCRAbatPoj2
         9NnxLejQMmgXpfRyn+09zRnW9jN4xqMeW23NzBu+PSJzQyxbLRB4Mvr4HUr15oQ9JELj
         1vJKnh2NXC+P5v0n7QPA3nUxb87FHCFGJrDoMpFihRdeeAKgupAkoFQPWQzCHvEbDpfd
         mlS0dXghW0XqIGf1h2k2Z6a9XL/gNDobI1QfBdx1ntnAsuAo4gC4BE6zk0PTROKcc1uX
         Mgyup7g6lyjvH61j2918DdPPnS4SSzovv8hrwsfZzItOVT2/Ah8o2g3jFYo9COaET/3r
         DUBQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:in-reply-to:message-id:date:subject
         :smtp-origin-cluster:cc:to:smtp-origin-hostname:from
         :smtp-origin-hostprefix:dkim-signature;
        bh=e4fE3iJAPMCO/Qbuvxgy9RjCcmbzJ+JxIMLpqr9tekI=;
        b=bt9eVLEPwJW9QnL8C5Tww3MT3VRpVRdTcYrEYZqdvpb/remCqdd3y7vV5wLohLuGoC
         2ew2KDwvgbCkqkp2ii+h4XrxscuHFyYjG273QY1t+bXQsNhGedD1ItEPeJK6TpYAoglk
         LAg05BnqvYg8yutOy1PF28CyLvwsSyHRAzemnoceewHhjiXuCSsGyOpZL86XVbdySTfS
         kpojUQ/Br6a+Fx2CRomLYh1gWdxaQaAZaDFBc0H8Zd3Rin58xPbwZFQItXJNqXVwSzNo
         PSS6jUrXFLgHCkxFsq7JLfCN28XybfrPPK6NNWJlO2Wd0VDxn7fL2Z+6dw6cnkoImf67
         01Ew==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=h0HkURYE;
       spf=pass (google.com: domain of prvs=105246f206=songliubraving@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=105246f206=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id q17si981771pgl.27.2019.05.29.14.36.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 29 May 2019 14:36:52 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=105246f206=songliubraving@fb.com designates 67.231.145.42 as permitted sender) client-ip=67.231.145.42;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=h0HkURYE;
       spf=pass (google.com: domain of prvs=105246f206=songliubraving@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=105246f206=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0044008.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x4TLTHvl011980
	for <linux-mm@kvack.org>; Wed, 29 May 2019 14:36:50 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : in-reply-to : references : mime-version :
 content-type; s=facebook; bh=e4fE3iJAPMCO/Qbuvxgy9RjCcmbzJ+JxIMLpqr9tekI=;
 b=h0HkURYEjg9fLq+Wub9w8QuMyIbE+9Tj+Oqdm/UqK7ZWyiyevkDoiDhjnAiyxq3fmWjb
 CmnSzy8S7tTvI9S7+mGGz+SQD1UwS4UVUYfXqpEZo/bWpJfacN1KdQUipB0xsjLGZR8z
 4BaEmDl5lLMvC7QiE8fzH4U6+/q3lzwXcAY= 
Received: from mail.thefacebook.com (mailout.thefacebook.com [199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 2ssv0esfw1-6
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 29 May 2019 14:36:50 -0700
Received: from mx-out.facebook.com (2620:10d:c081:10::13) by
 mail.thefacebook.com (2620:10d:c081:35::125) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA) id 15.1.1713.5;
 Wed, 29 May 2019 14:36:49 -0700
Received: by devbig006.ftw2.facebook.com (Postfix, from userid 4523)
	id C392762E1F88; Wed, 29 May 2019 14:21:11 -0700 (PDT)
Smtp-Origin-Hostprefix: devbig
From: Song Liu <songliubraving@fb.com>
Smtp-Origin-Hostname: devbig006.ftw2.facebook.com
To: <linux-kernel@vger.kernel.org>, <linux-mm@kvack.org>
CC: <namit@vmware.com>, <peterz@infradead.org>, <oleg@redhat.com>,
        <rostedt@goodmis.org>, <mhiramat@kernel.org>,
        <matthew.wilcox@oracle.com>, <kirill.shutemov@linux.intel.com>,
        <kernel-team@fb.com>, <william.kucharski@oracle.com>,
        <chad.mynhier@oracle.com>, <mike.kravetz@oracle.com>,
        Song Liu <songliubraving@fb.com>
Smtp-Origin-Cluster: ftw2c04
Subject: [PATCH uprobe, thp 1/4] mm, thp: allow preallocate pgtable for split_huge_pmd_address()
Date: Wed, 29 May 2019 14:20:46 -0700
Message-ID: <20190529212049.2413886-2-songliubraving@fb.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190529212049.2413886-1-songliubraving@fb.com>
References: <20190529212049.2413886-1-songliubraving@fb.com>
X-FB-Internal: Safe
MIME-Version: 1.0
Content-Type: text/plain
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-05-29_11:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=fb_default_notspam policy=fb_default score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=971 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1905290134
X-FB-Internal: deliver
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Currently, __split_huge_pmd_locked() uses page fault to handle file backed
THP. This is required because splitting pmd requires allocating a new
pgtable.

This patch allows the caller of __split_huge_pmd_locked() and
split_huge_pmd_address() to preallocate the pgtable, so that refault is
not required.

This is useful when the caller of split_huge_pmd_address() would like to
use small pages before refault.

Signed-off-by: Song Liu <songliubraving@fb.com>
---
 include/linux/huge_mm.h |  5 +++--
 mm/huge_memory.c        | 33 +++++++++++++++++++++++----------
 mm/rmap.c               |  2 +-
 3 files changed, 27 insertions(+), 13 deletions(-)

diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
index 7cd5c150c21d..2d8a40fd06e4 100644
--- a/include/linux/huge_mm.h
+++ b/include/linux/huge_mm.h
@@ -161,7 +161,7 @@ void __split_huge_pmd(struct vm_area_struct *vma, pmd_t *pmd,
 
 
 void split_huge_pmd_address(struct vm_area_struct *vma, unsigned long address,
-		bool freeze, struct page *page);
+		bool freeze, struct page *page, pgtable_t prealloc_pgtable);
 
 void __split_huge_pud(struct vm_area_struct *vma, pud_t *pud,
 		unsigned long address);
@@ -299,7 +299,8 @@ static inline void deferred_split_huge_page(struct page *page) {}
 static inline void __split_huge_pmd(struct vm_area_struct *vma, pmd_t *pmd,
 		unsigned long address, bool freeze, struct page *page) {}
 static inline void split_huge_pmd_address(struct vm_area_struct *vma,
-		unsigned long address, bool freeze, struct page *page) {}
+		unsigned long address, bool freeze, struct page *page,
+		pgtable_t prealloc_pgtable) {}
 
 #define split_huge_pud(__vma, __pmd, __address)	\
 	do { } while (0)
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 9f8bce9a6b32..dcb0e30213af 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -2118,7 +2118,7 @@ static void __split_huge_zero_page_pmd(struct vm_area_struct *vma,
 }
 
 static void __split_huge_pmd_locked(struct vm_area_struct *vma, pmd_t *pmd,
-		unsigned long haddr, bool freeze)
+		unsigned long haddr, bool freeze, pgtable_t prealloc_pgtable)
 {
 	struct mm_struct *mm = vma->vm_mm;
 	struct page *page;
@@ -2133,10 +2133,15 @@ static void __split_huge_pmd_locked(struct vm_area_struct *vma, pmd_t *pmd,
 	VM_BUG_ON_VMA(vma->vm_end < haddr + HPAGE_PMD_SIZE, vma);
 	VM_BUG_ON(!is_pmd_migration_entry(*pmd) && !pmd_trans_huge(*pmd)
 				&& !pmd_devmap(*pmd));
+	/* only file backed vma need preallocate pgtable*/
+	VM_BUG_ON(vma_is_anonymous(vma) && prealloc_pgtable);
 
 	count_vm_event(THP_SPLIT_PMD);
 
-	if (!vma_is_anonymous(vma)) {
+	if (prealloc_pgtable) {
+		pgtable_trans_huge_deposit(mm, pmd, prealloc_pgtable);
+		mm_inc_nr_pmds(mm);
+	} else if (!vma_is_anonymous(vma)) {
 		_pmd = pmdp_huge_clear_flush_notify(vma, haddr, pmd);
 		/*
 		 * We are going to unmap this huge page. So
@@ -2277,8 +2282,9 @@ static void __split_huge_pmd_locked(struct vm_area_struct *vma, pmd_t *pmd,
 	}
 }
 
-void __split_huge_pmd(struct vm_area_struct *vma, pmd_t *pmd,
-		unsigned long address, bool freeze, struct page *page)
+static void ____split_huge_pmd(struct vm_area_struct *vma, pmd_t *pmd,
+		unsigned long address, bool freeze, struct page *page,
+		pgtable_t prealloc_pgtable)
 {
 	spinlock_t *ptl;
 	struct mmu_notifier_range range;
@@ -2303,7 +2309,8 @@ void __split_huge_pmd(struct vm_area_struct *vma, pmd_t *pmd,
 			clear_page_mlock(page);
 	} else if (!(pmd_devmap(*pmd) || is_pmd_migration_entry(*pmd)))
 		goto out;
-	__split_huge_pmd_locked(vma, pmd, range.start, freeze);
+	__split_huge_pmd_locked(vma, pmd, range.start, freeze,
+				prealloc_pgtable);
 out:
 	spin_unlock(ptl);
 	/*
@@ -2322,8 +2329,14 @@ void __split_huge_pmd(struct vm_area_struct *vma, pmd_t *pmd,
 	mmu_notifier_invalidate_range_only_end(&range);
 }
 
+void __split_huge_pmd(struct vm_area_struct *vma, pmd_t *pmd,
+		unsigned long address, bool freeze, struct page *page)
+{
+	____split_huge_pmd(vma, pmd, address, freeze, page, NULL);
+}
+
 void split_huge_pmd_address(struct vm_area_struct *vma, unsigned long address,
-		bool freeze, struct page *page)
+		bool freeze, struct page *page, pgtable_t prealloc_pgtable)
 {
 	pgd_t *pgd;
 	p4d_t *p4d;
@@ -2344,7 +2357,7 @@ void split_huge_pmd_address(struct vm_area_struct *vma, unsigned long address,
 
 	pmd = pmd_offset(pud, address);
 
-	__split_huge_pmd(vma, pmd, address, freeze, page);
+	____split_huge_pmd(vma, pmd, address, freeze, page, prealloc_pgtable);
 }
 
 void vma_adjust_trans_huge(struct vm_area_struct *vma,
@@ -2360,7 +2373,7 @@ void vma_adjust_trans_huge(struct vm_area_struct *vma,
 	if (start & ~HPAGE_PMD_MASK &&
 	    (start & HPAGE_PMD_MASK) >= vma->vm_start &&
 	    (start & HPAGE_PMD_MASK) + HPAGE_PMD_SIZE <= vma->vm_end)
-		split_huge_pmd_address(vma, start, false, NULL);
+		split_huge_pmd_address(vma, start, false, NULL, NULL);
 
 	/*
 	 * If the new end address isn't hpage aligned and it could
@@ -2370,7 +2383,7 @@ void vma_adjust_trans_huge(struct vm_area_struct *vma,
 	if (end & ~HPAGE_PMD_MASK &&
 	    (end & HPAGE_PMD_MASK) >= vma->vm_start &&
 	    (end & HPAGE_PMD_MASK) + HPAGE_PMD_SIZE <= vma->vm_end)
-		split_huge_pmd_address(vma, end, false, NULL);
+		split_huge_pmd_address(vma, end, false, NULL, NULL);
 
 	/*
 	 * If we're also updating the vma->vm_next->vm_start, if the new
@@ -2384,7 +2397,7 @@ void vma_adjust_trans_huge(struct vm_area_struct *vma,
 		if (nstart & ~HPAGE_PMD_MASK &&
 		    (nstart & HPAGE_PMD_MASK) >= next->vm_start &&
 		    (nstart & HPAGE_PMD_MASK) + HPAGE_PMD_SIZE <= next->vm_end)
-			split_huge_pmd_address(next, nstart, false, NULL);
+			split_huge_pmd_address(next, nstart, false, NULL, NULL);
 	}
 }
 
diff --git a/mm/rmap.c b/mm/rmap.c
index e5dfe2ae6b0d..6970d732507c 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -1361,7 +1361,7 @@ static bool try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
 
 	if (flags & TTU_SPLIT_HUGE_PMD) {
 		split_huge_pmd_address(vma, address,
-				flags & TTU_SPLIT_FREEZE, page);
+				flags & TTU_SPLIT_FREEZE, page, NULL);
 	}
 
 	/*
-- 
2.17.1

