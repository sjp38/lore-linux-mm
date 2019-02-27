Return-Path: <SRS0=x8zE=RC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id ED993C43381
	for <linux-mm@archiver.kernel.org>; Wed, 27 Feb 2019 14:48:38 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A8D10217F5
	for <linux-mm@archiver.kernel.org>; Wed, 27 Feb 2019 14:48:38 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A8D10217F5
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4926A8E0007; Wed, 27 Feb 2019 09:48:38 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 43F458E0001; Wed, 27 Feb 2019 09:48:38 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 30A4F8E0007; Wed, 27 Feb 2019 09:48:38 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id E58808E0001
	for <linux-mm@kvack.org>; Wed, 27 Feb 2019 09:48:37 -0500 (EST)
Received: by mail-pg1-f199.google.com with SMTP id y8so12373457pgk.2
        for <linux-mm@kvack.org>; Wed, 27 Feb 2019 06:48:37 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:in-reply-to:references:mime-version
         :content-transfer-encoding:message-id;
        bh=JZXyc97R6jfZRCUk/DAQoor4v0aeWsIvPq8LWKeauDk=;
        b=Xpy+gbyFhILPX1/8CUSZmvdA1vJ2R8MRidvV+RNAjVhXgPrG14jp0H9tVV3uTyiMXO
         1nPG3KTM5CZgcLVdDH58xNXIS0wsc4v6biwM3ie0drgCBstKBVsZ5XqpZIQXJ10C5aF0
         3noXK4rIoDsNZfNprJt4j6ImWjaiiPboY9YGiOBSM7hN3CeTmrcRqnFaGJGy6r37gImz
         dQwJokNopvxUJjEV/oA57mhmohEd7kutiUwFqcwz2gqWMrJl+O5igzgdqQLBGCBc7gDi
         8BzZhulzkmxAWZn90sTuSfcWZ0zqdbIsnVargUuWEkozajTmEsnXiyeOHtbDuUHSOZa1
         QNGg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: AHQUAubDmdsJktUrnowWxTglcRXBJaI4+q9UfH2EBj58EnmRrMNOjDuo
	bEnFIa1Seefst8lUthTHMi7yANfmBLGFE8lJWyMv9iF48z9G4Yv49/oZbb2fa8P8CdkWLP0T4Xg
	Ei1QhIHmWaVbwn06edeI2x0A3mvbpYJIGUaP+arMCtQATbigMc56Lf0rbkJP/z7h9bw==
X-Received: by 2002:a63:8b43:: with SMTP id j64mr3290370pge.332.1551278917520;
        Wed, 27 Feb 2019 06:48:37 -0800 (PST)
X-Google-Smtp-Source: AHgI3Ib5Ovl8lC3bqLxFmEhS3y5QZqx9ac7fh4Qqtb5QgtxzvwGs9PLaf+Q8vvXVH+Cpxesr4FYr
X-Received: by 2002:a63:8b43:: with SMTP id j64mr3290303pge.332.1551278916390;
        Wed, 27 Feb 2019 06:48:36 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551278916; cv=none;
        d=google.com; s=arc-20160816;
        b=tQdVBnWqiHz0zCoSSKoiqysJXVxtSRw0IcyA63VQODk8cY3LUSzLGLYyMFqngcv/bX
         +9NgU7nrnp0Ut4N5hRbsRg5MpZm8SuNqicW+aijpK93r0n5bWDb0tf2gusIYTtSAx+9h
         CxV2Al4tFU6XuOvjP6jkWx/Kv9yICmct3/9czaVsIsSDDMw7nnd0oMnoxGg0roOhPgMr
         hP+KOP0xfWScXVJlt6WSlNmnajPnRkAKkM0VoR6wdafXU1Xk5e4MfBhLSy1Figt9N6lY
         gFWQ+xQhfNa/sjNhiC1HKrJzC3IvG2/8EvvFz9S6PjRcno6hJ+dVB9CsQdIXrg98YeHH
         VuDw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:content-transfer-encoding:mime-version:references
         :in-reply-to:date:subject:cc:to:from;
        bh=JZXyc97R6jfZRCUk/DAQoor4v0aeWsIvPq8LWKeauDk=;
        b=mjTsbwebA40SumHnWM/Mdtskxnrpbm57vZn0m7Cu1x0pBiZYsfr36Cf1Y86ZUvGbb+
         VDpJ4Ajnnl1/cfdauTxhvTn4vVWOe0aYq9jByhoZXB0akOnzqpaAflFZgyBKvTeSJszA
         ZHAFXAksTbedPE4iXTrwSFEk2S2ghgzW6V0Xix3hm6olIHQouWDSre/n9gxmfV5BSt9u
         XWcoCdjsjG8bXpLZG0x+uXOHH3TIEL8dBZJEcR8L/OKrcs+ZLsPsHAtPhNlsXDNVEzdH
         ttwUkExsK2COUNDGVMV7k5LfcJbpeKxk40kUMxAKMt8bF7M3Y6HMqBW1nptYC/7Ezuhh
         aSVg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id z11si15088072pgj.140.2019.02.27.06.48.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Feb 2019 06:48:36 -0800 (PST)
Received-SPF: pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.156.1 as permitted sender) client-ip=148.163.156.1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098394.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x1REYXXo115760
	for <linux-mm@kvack.org>; Wed, 27 Feb 2019 09:48:35 -0500
Received: from e33.co.us.ibm.com (e33.co.us.ibm.com [32.97.110.151])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2qwtujwwdu-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 27 Feb 2019 09:48:33 -0500
Received: from localhost
	by e33.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.ibm.com>;
	Wed, 27 Feb 2019 14:48:13 -0000
Received: from b03cxnp07028.gho.boulder.ibm.com (9.17.130.15)
	by e33.co.us.ibm.com (192.168.1.133) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Wed, 27 Feb 2019 14:48:09 -0000
Received: from b03ledav006.gho.boulder.ibm.com (b03ledav006.gho.boulder.ibm.com [9.17.130.237])
	by b03cxnp07028.gho.boulder.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x1REm8ET24641712
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 27 Feb 2019 14:48:08 GMT
Received: from b03ledav006.gho.boulder.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id B462BC605A;
	Wed, 27 Feb 2019 14:48:08 +0000 (GMT)
Received: from b03ledav006.gho.boulder.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 67DA7C6055;
	Wed, 27 Feb 2019 14:48:05 +0000 (GMT)
Received: from skywalker.ibmuc.com (unknown [9.199.49.135])
	by b03ledav006.gho.boulder.ibm.com (Postfix) with ESMTP;
	Wed, 27 Feb 2019 14:48:05 +0000 (GMT)
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
To: akpm@linux-foundation.org, Michal Hocko <mhocko@kernel.org>,
        Alexey Kardashevskiy <aik@ozlabs.ru>,
        David Gibson <david@gibson.dropbear.id.au>,
        Andrea Arcangeli <aarcange@redhat.com>, mpe@ellerman.id.au
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
        linuxppc-dev@lists.ozlabs.org,
        "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
Subject: [PATCH v8 3/4] powerpc/mm/iommu: Allow migration of cma allocated pages during mm_iommu_do_alloc
Date: Wed, 27 Feb 2019 20:17:35 +0530
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190227144736.5872-1-aneesh.kumar@linux.ibm.com>
References: <20190227144736.5872-1-aneesh.kumar@linux.ibm.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-TM-AS-GCONF: 00
x-cbid: 19022714-0036-0000-0000-00000A920161
X-IBM-SpamModules-Scores: 
X-IBM-SpamModules-Versions: BY=3.00010674; HX=3.00000242; KW=3.00000007;
 PH=3.00000004; SC=3.00000281; SDB=6.01167143; UDB=6.00609716; IPR=6.00947753;
 MB=3.00025765; MTD=3.00000008; XFM=3.00000015; UTC=2019-02-27 14:48:12
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19022714-0037-0000-0000-00004ADE4104
Message-Id: <20190227144736.5872-4-aneesh.kumar@linux.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-02-27_09:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=2 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1902270099
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The current code doesn't do page migration if the page allocated is a compound page.
With HugeTLB migration support, we can end up allocating hugetlb pages from
CMA region. Also, THP pages can be allocated from CMA region. This patch updates
the code to handle compound pages correctly. The patch also switches to a single
get_user_pages with the right count, instead of doing one get_user_pages per page.
That avoids reading page table multiple times. This is done by using
get_user_pages_longterm, because that also takes care of DAX backed pages.

DAX pages lifetime is dictated by file system rules and as such, we need
to make sure that we free these pages on operations like truncate and
punch hole. If we have long term pin on these pages, which are mostly
return to userspace with elevated page count, the entity holding the
long term pin may not be aware of the fact that file got truncated and
the file system blocks possibly got reused. That can result in corruption.

The patch also converts the hpas member of mm_iommu_table_group_mem_t to a union.
We use the same storage location to store pointers to struct page. We cannot
update all the code path use struct page *, because we access hpas in real mode
and we can't do that struct page * to pfn conversion in real mode.

Reviewed-by: Michael Ellerman <mpe@ellerman.id.au>
Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.ibm.com>
---
 arch/powerpc/mm/mmu_context_iommu.c | 125 +++++++++-------------------
 1 file changed, 38 insertions(+), 87 deletions(-)

diff --git a/arch/powerpc/mm/mmu_context_iommu.c b/arch/powerpc/mm/mmu_context_iommu.c
index a712a650a8b6..85b4e9f5c615 100644
--- a/arch/powerpc/mm/mmu_context_iommu.c
+++ b/arch/powerpc/mm/mmu_context_iommu.c
@@ -21,6 +21,7 @@
 #include <linux/sizes.h>
 #include <asm/mmu_context.h>
 #include <asm/pte-walk.h>
+#include <linux/mm_inline.h>
 
 static DEFINE_MUTEX(mem_list_mutex);
 
@@ -34,8 +35,18 @@ struct mm_iommu_table_group_mem_t {
 	atomic64_t mapped;
 	unsigned int pageshift;
 	u64 ua;			/* userspace address */
-	u64 entries;		/* number of entries in hpas[] */
-	u64 *hpas;		/* vmalloc'ed */
+	u64 entries;		/* number of entries in hpas/hpages[] */
+	/*
+	 * in mm_iommu_get we temporarily use this to store
+	 * struct page address.
+	 *
+	 * We need to convert ua to hpa in real mode. Make it
+	 * simpler by storing physical address.
+	 */
+	union {
+		struct page **hpages;	/* vmalloc'ed */
+		phys_addr_t *hpas;
+	};
 #define MM_IOMMU_TABLE_INVALID_HPA	((uint64_t)-1)
 	u64 dev_hpa;		/* Device memory base address */
 };
@@ -80,64 +91,15 @@ bool mm_iommu_preregistered(struct mm_struct *mm)
 }
 EXPORT_SYMBOL_GPL(mm_iommu_preregistered);
 
-/*
- * Taken from alloc_migrate_target with changes to remove CMA allocations
- */
-struct page *new_iommu_non_cma_page(struct page *page, unsigned long private)
-{
-	gfp_t gfp_mask = GFP_USER;
-	struct page *new_page;
-
-	if (PageCompound(page))
-		return NULL;
-
-	if (PageHighMem(page))
-		gfp_mask |= __GFP_HIGHMEM;
-
-	/*
-	 * We don't want the allocation to force an OOM if possibe
-	 */
-	new_page = alloc_page(gfp_mask | __GFP_NORETRY | __GFP_NOWARN);
-	return new_page;
-}
-
-static int mm_iommu_move_page_from_cma(struct page *page)
-{
-	int ret = 0;
-	LIST_HEAD(cma_migrate_pages);
-
-	/* Ignore huge pages for now */
-	if (PageCompound(page))
-		return -EBUSY;
-
-	lru_add_drain();
-	ret = isolate_lru_page(page);
-	if (ret)
-		return ret;
-
-	list_add(&page->lru, &cma_migrate_pages);
-	put_page(page); /* Drop the gup reference */
-
-	ret = migrate_pages(&cma_migrate_pages, new_iommu_non_cma_page,
-				NULL, 0, MIGRATE_SYNC, MR_CONTIG_RANGE);
-	if (ret) {
-		if (!list_empty(&cma_migrate_pages))
-			putback_movable_pages(&cma_migrate_pages);
-	}
-
-	return 0;
-}
-
 static long mm_iommu_do_alloc(struct mm_struct *mm, unsigned long ua,
-		unsigned long entries, unsigned long dev_hpa,
-		struct mm_iommu_table_group_mem_t **pmem)
+			      unsigned long entries, unsigned long dev_hpa,
+			      struct mm_iommu_table_group_mem_t **pmem)
 {
 	struct mm_iommu_table_group_mem_t *mem;
-	long i, j, ret = 0, locked_entries = 0;
+	long i, ret, locked_entries = 0;
 	unsigned int pageshift;
 	unsigned long flags;
 	unsigned long cur_ua;
-	struct page *page = NULL;
 
 	mutex_lock(&mem_list_mutex);
 
@@ -187,41 +149,25 @@ static long mm_iommu_do_alloc(struct mm_struct *mm, unsigned long ua,
 		goto unlock_exit;
 	}
 
+	down_read(&mm->mmap_sem);
+	ret = get_user_pages_longterm(ua, entries, FOLL_WRITE, mem->hpages, NULL);
+	up_read(&mm->mmap_sem);
+	if (ret != entries) {
+		/* free the reference taken */
+		for (i = 0; i < ret; i++)
+			put_page(mem->hpages[i]);
+
+		vfree(mem->hpas);
+		kfree(mem);
+		ret = -EFAULT;
+		goto unlock_exit;
+	}
+
+	pageshift = PAGE_SHIFT;
 	for (i = 0; i < entries; ++i) {
+		struct page *page = mem->hpages[i];
+
 		cur_ua = ua + (i << PAGE_SHIFT);
-		if (1 != get_user_pages_fast(cur_ua,
-					1/* pages */, 1/* iswrite */, &page)) {
-			ret = -EFAULT;
-			for (j = 0; j < i; ++j)
-				put_page(pfn_to_page(mem->hpas[j] >>
-						PAGE_SHIFT));
-			vfree(mem->hpas);
-			kfree(mem);
-			goto unlock_exit;
-		}
-		/*
-		 * If we get a page from the CMA zone, since we are going to
-		 * be pinning these entries, we might as well move them out
-		 * of the CMA zone if possible. NOTE: faulting in + migration
-		 * can be expensive. Batching can be considered later
-		 */
-		if (is_migrate_cma_page(page)) {
-			if (mm_iommu_move_page_from_cma(page))
-				goto populate;
-			if (1 != get_user_pages_fast(cur_ua,
-						1/* pages */, 1/* iswrite */,
-						&page)) {
-				ret = -EFAULT;
-				for (j = 0; j < i; ++j)
-					put_page(pfn_to_page(mem->hpas[j] >>
-								PAGE_SHIFT));
-				vfree(mem->hpas);
-				kfree(mem);
-				goto unlock_exit;
-			}
-		}
-populate:
-		pageshift = PAGE_SHIFT;
 		if (mem->pageshift > PAGE_SHIFT && PageCompound(page)) {
 			pte_t *pte;
 			struct page *head = compound_head(page);
@@ -239,10 +185,15 @@ static long mm_iommu_do_alloc(struct mm_struct *mm, unsigned long ua,
 			local_irq_restore(flags);
 		}
 		mem->pageshift = min(mem->pageshift, pageshift);
+		/*
+		 * We don't need struct page reference any more, switch
+		 * to physical address.
+		 */
 		mem->hpas[i] = page_to_pfn(page) << PAGE_SHIFT;
 	}
 
 good_exit:
+	ret = 0;
 	atomic64_set(&mem->mapped, 1);
 	mem->used = 1;
 	mem->ua = ua;
-- 
2.20.1

