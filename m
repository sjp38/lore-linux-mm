Return-Path: <SRS0=Ydgi=QF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BDD19C282D0
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 13:27:10 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6C2AB21473
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 13:27:10 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6C2AB21473
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=il.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D09B28E0003; Tue, 29 Jan 2019 08:27:08 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C90848E0001; Tue, 29 Jan 2019 08:27:08 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AB5D98E0003; Tue, 29 Jan 2019 08:27:08 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 693F78E0001
	for <linux-mm@kvack.org>; Tue, 29 Jan 2019 08:27:08 -0500 (EST)
Received: by mail-pl1-f200.google.com with SMTP id m13so14259389pls.15
        for <linux-mm@kvack.org>; Tue, 29 Jan 2019 05:27:08 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:in-reply-to:references:message-id
         :content-transfer-encoding:mime-version;
        bh=Fhn6AAKqP7x/M5y05t6fcfWePsF0vMP0ZzYGpTJLS7c=;
        b=QPAW+v+Xs3bb4q1L32uqCov9ErFdUhhZneRmpj8zb2D7FN+/v82+6qyYROlnfi5OQF
         0ecxTuTNZrmFbbL6T5PNuuHiEnj2rEcSwv8K0zhQGc+Le2A5/c1fwzWmOIRU0K0roKBj
         ZLs2kRohY94Q9kcpeccH90LfyxS6xhRHmfSTuSgY/SccmjZQugIFfmBkSYqx4OQjYRdP
         s7hpXeKigk1gO2n8qKkIeg4BqMk8DKRkJGcfQj7ygkSOo4vvNAGNdLZMr74MZauOxUyu
         kG+mBVc87Hvkh6GjNOAbfO6KiZwGnyD/777CcLSaYHKJLDJrfnDoC0SNGpipoX6YJR24
         HiTQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of joeln@il.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=joeln@il.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: AJcUuke9OCibX4KKdLULuXYfI6lDH5N35t3/RlBc2EhoCBhbT81OG+S+
	0GWr7OT6EJTQkXbKTVqVgjylUroECn0VUwZRUmRIY/RTMu+NtBUlsNFK4AM+3pnn1kTeIzc707e
	DWbe1uKUmKKb6iMPQ+FLW4yr2y0OMW0ATCEtpm/0zMEv6iCYYithDTdQPuGYsBwCf9A==
X-Received: by 2002:a17:902:a40f:: with SMTP id p15mr26628648plq.286.1548768428051;
        Tue, 29 Jan 2019 05:27:08 -0800 (PST)
X-Google-Smtp-Source: ALg8bN7Oiink09SgKiTHgE3RV0qGn3Hchi4X4iSmLANeCL+6uHDwG629vutx4RGjR+R/gnf5Eqo7
X-Received: by 2002:a17:902:a40f:: with SMTP id p15mr26628597plq.286.1548768427057;
        Tue, 29 Jan 2019 05:27:07 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548768427; cv=none;
        d=google.com; s=arc-20160816;
        b=RidAnyvfYbDct1ExQu3CXS4hSyy3BtV2wlFKDVdqPRX9EgPjiVKNsxZj2XaTXv5NH/
         JdoYso2mgVeAcwHMbfQUYoVXOfkSrkQcD9QrQcN+GdObxaK1NOkqXFPKjvA5rvBaBugu
         ttKJO/P0u1RPIRQJGOIBHN3UDR7duRFQhwW+/9ZEeNfsFI6HayUKlYIZnKIZw0WoHmEO
         Mdhz3MO44IGAxYDtkK6fNF84S8NuE2lee5od6BArNK9mxZss2N0aRRAbEpRQ3moPVL7b
         KJ7pF2VcBgmz1UMSiWZLA5lG2RnKZgECnSBsQPb8BM7M0HGYB6Kwpj87hm+/Ed9x8/l7
         pzGw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:message-id:references
         :in-reply-to:date:subject:cc:to:from;
        bh=Fhn6AAKqP7x/M5y05t6fcfWePsF0vMP0ZzYGpTJLS7c=;
        b=KzcGZcyvwUGFX86QhK6TWvB/itzgh7RFv041iO7lsb+8Osp/lhDzOkNr1hAwYKheGE
         JkLIaT7y0ok1vTOSCw9j2dLk1mo+OTj+236VCu0zX/RPA3fAtVyYJ0Z/UrN4hDvWhaoe
         Jr4cMLTLiyhY00XYPOPlM7+TZnRtlgEsBds2x6yFvHlnenHTf5+Whdjeas0LXsSrK+/d
         PDaWU2OYtEtMtDbnfwZia8ttAcfBaUizHzor6mkYJZ3NYoD1UQi7oORnW2U4sGkKHZyd
         NXUSRSaLowimcDpTSKkCRfwwv9l5ANoQsD/CHUu8Q7w8dhZE7ooqoTJFd5kBQTRYymSR
         CQ1g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of joeln@il.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=joeln@il.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id x23si36394059pln.100.2019.01.29.05.27.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Jan 2019 05:27:07 -0800 (PST)
Received-SPF: pass (google.com: domain of joeln@il.ibm.com designates 148.163.156.1 as permitted sender) client-ip=148.163.156.1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of joeln@il.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=joeln@il.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098394.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x0TDJlU9036087
	for <linux-mm@kvack.org>; Tue, 29 Jan 2019 08:27:06 -0500
Received: from e06smtp02.uk.ibm.com (e06smtp02.uk.ibm.com [195.75.94.98])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2qap89neen-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 29 Jan 2019 08:27:06 -0500
Received: from localhost
	by e06smtp02.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <joeln@il.ibm.com>;
	Tue, 29 Jan 2019 13:27:02 -0000
Received: from b06cxnps4076.portsmouth.uk.ibm.com (9.149.109.198)
	by e06smtp02.uk.ibm.com (192.168.101.132) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Tue, 29 Jan 2019 13:26:59 -0000
Received: from d06av22.portsmouth.uk.ibm.com (d06av22.portsmouth.uk.ibm.com [9.149.105.58])
	by b06cxnps4076.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x0TDQwDx63373492
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL);
	Tue, 29 Jan 2019 13:26:58 GMT
Received: from d06av22.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 0104E4C046;
	Tue, 29 Jan 2019 13:26:58 +0000 (GMT)
Received: from d06av22.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 5B94D4C044;
	Tue, 29 Jan 2019 13:26:56 +0000 (GMT)
Received: from tal (unknown [9.148.32.96])
	by d06av22.portsmouth.uk.ibm.com (Postfix) with ESMTPS;
	Tue, 29 Jan 2019 13:26:56 +0000 (GMT)
Received: by tal (sSMTP sendmail emulation); Tue, 29 Jan 2019 15:26:55 +0200
From: Joel Nider <joeln@il.ibm.com>
To: Jason Gunthorpe <jgg@ziepe.ca>
Cc: Leon Romanovsky <leon@kernel.org>, Doug Ledford <dledford@redhat.com>,
        Mike Rapoport <rppt@linux.ibm.com>, Joel Nider <joeln@il.ibm.com>,
        linux-mm@kvack.org, linux-rdma@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: [PATCH 4/5] RDMA/uverbs: add owner parameter to ib_umem_odp_get
Date: Tue, 29 Jan 2019 15:26:25 +0200
X-Mailer: git-send-email 2.7.4
In-Reply-To: <1548768386-28289-1-git-send-email-joeln@il.ibm.com>
References: <1548768386-28289-1-git-send-email-joeln@il.ibm.com>
X-TM-AS-GCONF: 00
x-cbid: 19012913-0008-0000-0000-000002B7768D
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19012913-0009-0000-0000-00002223B94B
Message-Id: <1548768386-28289-5-git-send-email-joeln@il.ibm.com>
Content-Type: text/plain
Content-Transfer-Encoding: 8bit
MIME-Version: 1.0
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-01-29_10:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=738 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1901290101
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Propagate the change of adding the owner parameter to several internal
core functions, as well as the ib_umem_odp_get() kernel interface
function. The mm of the address space that owns the memory region is
saved in the per_mm struct, which is then used by
ib_umem_odp_map_dma_pages() when resolving a page fault from ODP.

Signed-off-by: Joel Nider <joeln@il.ibm.com>
---
 drivers/infiniband/core/umem.c     |  4 +--
 drivers/infiniband/core/umem_odp.c | 50 ++++++++++++++++++--------------------
 drivers/infiniband/hw/mlx5/odp.c   |  6 ++++-
 include/rdma/ib_umem_odp.h         |  6 +++--
 4 files changed, 35 insertions(+), 31 deletions(-)

diff --git a/drivers/infiniband/core/umem.c b/drivers/infiniband/core/umem.c
index 9646cee..77874e5 100644
--- a/drivers/infiniband/core/umem.c
+++ b/drivers/infiniband/core/umem.c
@@ -142,7 +142,7 @@ struct ib_umem *ib_umem_get(struct ib_ucontext *context, unsigned long addr,
 	mmgrab(mm);
 
 	if (access & IB_ACCESS_ON_DEMAND) {
-		ret = ib_umem_odp_get(to_ib_umem_odp(umem), access);
+		ret = ib_umem_odp_get(to_ib_umem_odp(umem), access, owner);
 		if (ret)
 			goto umem_kfree;
 		return umem;
@@ -200,7 +200,7 @@ struct ib_umem *ib_umem_get(struct ib_ucontext *context, unsigned long addr,
 				     mm, cur_base,
 				     min_t(unsigned long, npages,
 				     PAGE_SIZE / sizeof(struct page *)),
-				     gup_flags, page_list, vma_list, NULL);
+				     gup_flags, page_list, vma_list);
 		if (ret < 0) {
 			up_read(&mm->mmap_sem);
 			goto umem_release;
diff --git a/drivers/infiniband/core/umem_odp.c b/drivers/infiniband/core/umem_odp.c
index a4ec430..49826070 100644
--- a/drivers/infiniband/core/umem_odp.c
+++ b/drivers/infiniband/core/umem_odp.c
@@ -227,7 +227,8 @@ static void remove_umem_from_per_mm(struct ib_umem_odp *umem_odp)
 }
 
 static struct ib_ucontext_per_mm *alloc_per_mm(struct ib_ucontext *ctx,
-					       struct mm_struct *mm)
+					       struct mm_struct *mm,
+					       struct pid *owner)
 {
 	struct ib_ucontext_per_mm *per_mm;
 	int ret;
@@ -241,12 +242,8 @@ static struct ib_ucontext_per_mm *alloc_per_mm(struct ib_ucontext *ctx,
 	per_mm->umem_tree = RB_ROOT_CACHED;
 	init_rwsem(&per_mm->umem_rwsem);
 	per_mm->active = ctx->invalidate_range;
-
-	rcu_read_lock();
-	per_mm->tgid = get_task_pid(current->group_leader, PIDTYPE_PID);
-	rcu_read_unlock();
-
-	WARN_ON(mm != current->mm);
+	per_mm->tgid = owner;
+	mmgrab(per_mm->mm);
 
 	per_mm->mn.ops = &ib_umem_notifiers;
 	ret = mmu_notifier_register(&per_mm->mn, per_mm->mm);
@@ -265,7 +262,7 @@ static struct ib_ucontext_per_mm *alloc_per_mm(struct ib_ucontext *ctx,
 	return ERR_PTR(ret);
 }
 
-static int get_per_mm(struct ib_umem_odp *umem_odp)
+static int get_per_mm(struct ib_umem_odp *umem_odp, struct pid *owner)
 {
 	struct ib_ucontext *ctx = umem_odp->umem.context;
 	struct ib_ucontext_per_mm *per_mm;
@@ -280,7 +277,7 @@ static int get_per_mm(struct ib_umem_odp *umem_odp)
 			goto found;
 	}
 
-	per_mm = alloc_per_mm(ctx, umem_odp->umem.owning_mm);
+	per_mm = alloc_per_mm(ctx, umem_odp->umem.owning_mm, owner);
 	if (IS_ERR(per_mm)) {
 		mutex_unlock(&ctx->per_mm_list_lock);
 		return PTR_ERR(per_mm);
@@ -333,7 +330,8 @@ void put_per_mm(struct ib_umem_odp *umem_odp)
 }
 
 struct ib_umem_odp *ib_alloc_odp_umem(struct ib_ucontext_per_mm *per_mm,
-				      unsigned long addr, size_t size)
+				      unsigned long addr, size_t size,
+				      struct mm_struct *owner_mm)
 {
 	struct ib_ucontext *ctx = per_mm->context;
 	struct ib_umem_odp *odp_data;
@@ -345,12 +343,14 @@ struct ib_umem_odp *ib_alloc_odp_umem(struct ib_ucontext_per_mm *per_mm,
 	if (!odp_data)
 		return ERR_PTR(-ENOMEM);
 	umem = &odp_data->umem;
+
 	umem->context    = ctx;
 	umem->length     = size;
 	umem->address    = addr;
 	umem->page_shift = PAGE_SHIFT;
 	umem->writable   = 1;
 	umem->is_odp = 1;
+	umem->owning_mm = owner_mm;
 	odp_data->per_mm = per_mm;
 
 	mutex_init(&odp_data->umem_mutex);
@@ -389,13 +389,9 @@ struct ib_umem_odp *ib_alloc_odp_umem(struct ib_ucontext_per_mm *per_mm,
 }
 EXPORT_SYMBOL(ib_alloc_odp_umem);
 
-int ib_umem_odp_get(struct ib_umem_odp *umem_odp, int access)
+int ib_umem_odp_get(struct ib_umem_odp *umem_odp, int access, struct pid *owner)
 {
 	struct ib_umem *umem = &umem_odp->umem;
-	/*
-	 * NOTE: This must called in a process context where umem->owning_mm
-	 * == current->mm
-	 */
 	struct mm_struct *mm = umem->owning_mm;
 	int ret_val;
 
@@ -437,7 +433,7 @@ int ib_umem_odp_get(struct ib_umem_odp *umem_odp, int access)
 		}
 	}
 
-	ret_val = get_per_mm(umem_odp);
+	ret_val = get_per_mm(umem_odp, owner);
 	if (ret_val)
 		goto out_dma_list;
 	add_umem_to_per_mm(umem_odp);
@@ -574,8 +570,8 @@ static int ib_umem_odp_map_dma_single_page(
  *        the return value.
  * @access_mask: bit mask of the requested access permissions for the given
  *               range.
- * @current_seq: the MMU notifiers sequance value for synchronization with
- *               invalidations. the sequance number is read from
+ * @current_seq: the MMU notifiers sequence value for synchronization with
+ *               invalidations. the sequence number is read from
  *               umem_odp->notifiers_seq before calling this function
  */
 int ib_umem_odp_map_dma_pages(struct ib_umem_odp *umem_odp, u64 user_virt,
@@ -584,7 +580,7 @@ int ib_umem_odp_map_dma_pages(struct ib_umem_odp *umem_odp, u64 user_virt,
 {
 	struct ib_umem *umem = &umem_odp->umem;
 	struct task_struct *owning_process  = NULL;
-	struct mm_struct *owning_mm = umem_odp->umem.owning_mm;
+	struct mm_struct *owning_mm;
 	struct page       **local_page_list = NULL;
 	u64 page_mask, off;
 	int j, k, ret = 0, start_idx, npages = 0, page_shift;
@@ -609,12 +605,13 @@ int ib_umem_odp_map_dma_pages(struct ib_umem_odp *umem_odp, u64 user_virt,
 	bcnt += off; /* Charge for the first page offset as well. */
 
 	/*
-	 * owning_process is allowed to be NULL, this means somehow the mm is
-	 * existing beyond the lifetime of the originating process.. Presumably
+	 * owning_process may be NULL, because the mm can
+	 * exist independently of the originating process.
 	 * mmget_not_zero will fail in this case.
 	 */
 	owning_process = get_pid_task(umem_odp->per_mm->tgid, PIDTYPE_PID);
-	if (WARN_ON(!mmget_not_zero(umem_odp->umem.owning_mm))) {
+	owning_mm = umem_odp->per_mm->mm;
+	if (WARN_ON(!mmget_not_zero(owning_mm))) {
 		ret = -EINVAL;
 		goto out_put_task;
 	}
@@ -632,15 +629,16 @@ int ib_umem_odp_map_dma_pages(struct ib_umem_odp *umem_odp, u64 user_virt,
 
 		down_read(&owning_mm->mmap_sem);
 		/*
-		 * Note: this might result in redundent page getting. We can
+		 * Note: this might result in redundant page getting. We can
 		 * avoid this by checking dma_list to be 0 before calling
-		 * get_user_pages. However, this make the code much more
+		 * get_user_pages. However, this makes the code much more
 		 * complex (and doesn't gain us much performance in most use
 		 * cases).
 		 */
-		npages = get_user_pages_remote(owning_process, owning_mm,
+		npages = get_user_pages_remote_longterm(owning_process,
+				owning_mm,
 				user_virt, gup_num_pages,
-				flags, local_page_list, NULL, NULL);
+				flags, local_page_list, NULL);
 		up_read(&owning_mm->mmap_sem);
 
 		if (npages < 0) {
diff --git a/drivers/infiniband/hw/mlx5/odp.c b/drivers/infiniband/hw/mlx5/odp.c
index c317e18..1abc917 100644
--- a/drivers/infiniband/hw/mlx5/odp.c
+++ b/drivers/infiniband/hw/mlx5/odp.c
@@ -439,8 +439,12 @@ static struct ib_umem_odp *implicit_mr_get_data(struct mlx5_ib_mr *mr,
 		if (nentries)
 			nentries++;
 	} else {
+		struct mm_struct *owner_mm = current->mm;
+
+		if (mr->umem->owning_mm)
+			owner_mm = mr->umem->owning_mm;
 		odp = ib_alloc_odp_umem(odp_mr->per_mm, addr,
-					MLX5_IMR_MTT_SIZE);
+					MLX5_IMR_MTT_SIZE, owner_mm);
 		if (IS_ERR(odp)) {
 			mutex_unlock(&odp_mr->umem_mutex);
 			return ERR_CAST(odp);
diff --git a/include/rdma/ib_umem_odp.h b/include/rdma/ib_umem_odp.h
index 0b1446f..28099e6 100644
--- a/include/rdma/ib_umem_odp.h
+++ b/include/rdma/ib_umem_odp.h
@@ -102,9 +102,11 @@ struct ib_ucontext_per_mm {
 	struct rcu_head rcu;
 };
 
-int ib_umem_odp_get(struct ib_umem_odp *umem_odp, int access);
+int ib_umem_odp_get(struct ib_umem_odp *umem_odp, int access,
+		     struct pid *owner);
 struct ib_umem_odp *ib_alloc_odp_umem(struct ib_ucontext_per_mm *per_mm,
-				      unsigned long addr, size_t size);
+				      unsigned long addr, size_t size,
+				      struct mm_struct *owner_mm);
 void ib_umem_odp_release(struct ib_umem_odp *umem_odp);
 
 /*
-- 
2.7.4

