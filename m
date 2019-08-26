Return-Path: <SRS0=haCV=WW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-14.4 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT,USER_IN_DEF_DKIM_WL
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5E46BC3A59F
	for <linux-mm@archiver.kernel.org>; Mon, 26 Aug 2019 23:33:11 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 10CE4206B7
	for <linux-mm@archiver.kernel.org>; Mon, 26 Aug 2019 23:33:11 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="luYIkwBv"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 10CE4206B7
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B4D736B028E; Mon, 26 Aug 2019 19:33:10 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AD6206B028F; Mon, 26 Aug 2019 19:33:10 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9EE976B0290; Mon, 26 Aug 2019 19:33:10 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0122.hostedemail.com [216.40.44.122])
	by kanga.kvack.org (Postfix) with ESMTP id 7A2516B028E
	for <linux-mm@kvack.org>; Mon, 26 Aug 2019 19:33:10 -0400 (EDT)
Received: from smtpin27.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id 1F8B3180AD7C3
	for <linux-mm@kvack.org>; Mon, 26 Aug 2019 23:33:10 +0000 (UTC)
X-FDA: 75866182140.27.flesh95_38b56b0964e0f
X-HE-Tag: flesh95_38b56b0964e0f
X-Filterd-Recvd-Size: 9147
Received: from mail-yb1-f201.google.com (mail-yb1-f201.google.com [209.85.219.201])
	by imf42.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon, 26 Aug 2019 23:33:09 +0000 (UTC)
Received: by mail-yb1-f201.google.com with SMTP id t1so11687712ybk.23
        for <linux-mm@kvack.org>; Mon, 26 Aug 2019 16:33:09 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:in-reply-to:message-id:mime-version:references:subject:from:to
         :cc;
        bh=Dtawi+SgzwGanwObU635MqvWbAaKXTE4W9/QPb+wB6k=;
        b=luYIkwBv8XOz1G8sCkZp2oCGOt1P9w8BNSktKbn9lsXOJBQIuAa/q4irFZH6ija1vA
         rPRomXoM2TGRep5+amUBhIDga3tWd6tSeGqAy5bdmQqB89f9BSEa6NOgNO8ayE9KCvz5
         U+U+sC+Hd3x9r2qeU8bFt5sCF0u2bU4owlJ4VjWTqlp1jvBhdgWpDNr+8Zs7OxzVjO+q
         +1OTWVwhbWaRqmzfB+5hAlpB3hErlLGN29ED8jKQgohkiBLoKq5ISseEs9TBaNRxZoC1
         RViRu0Ej6Wik50XpmQ1ELTsstdbw5e7TdHXy+ghhaLgLriUK8kCFQn4LB8TrvqpmIv3l
         Qhwg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:date:in-reply-to:message-id:mime-version
         :references:subject:from:to:cc;
        bh=Dtawi+SgzwGanwObU635MqvWbAaKXTE4W9/QPb+wB6k=;
        b=RZjQyuBIV3n8q49c0zhg6sS46Bdy8k1Bw/Mf28CoBbE/8fBFCyhjw39YLnc8SGlPNe
         tDbbHqMFxApj59QKvW0mrZdynhXVXqEgGVb3jS+tbNXHVm0CRKYv68XZOzzCC5dZ2txs
         1Qh7d2Vf9bbl2//5wEfr2VyT0z3OxbFwCpYdQTJ/+tZqDfr5axzon0MoIIaM1Pf3Rd/D
         bEUsWDHfzKEoMFnpaneVMMs1sw1D4JMZ9zCNAwC+F/+7a/8FME4xCQIbOhKhfyq7zAsY
         EYFAYxSKJdakHxARxiHtbX/7HlKuQoD+xE312n/Hvzj8ZJDAC/xnnyjFjsMWmOg/qag/
         sehg==
X-Gm-Message-State: APjAAAUYwYh8rSsQXoV1hR5fnGCDSV2U8p0fquyYZsuvTEpqT9CAf252
	OQDnmfGe9BSn6g847zMIrDmu6NFSPhXSa3/8Rg==
X-Google-Smtp-Source: APXvYqzuNeIn57TpTyP+6aetzuCCRAFyJqF0HLFEL3TIqktlq+fbEzswU6xpHlb9fpNtRYAsJAx7QBEtPIKbSyV54g==
X-Received: by 2002:a81:9945:: with SMTP id q66mr15679128ywg.47.1566862388767;
 Mon, 26 Aug 2019 16:33:08 -0700 (PDT)
Date: Mon, 26 Aug 2019 16:32:37 -0700
In-Reply-To: <20190826233240.11524-1-almasrymina@google.com>
Message-Id: <20190826233240.11524-4-almasrymina@google.com>
Mime-Version: 1.0
References: <20190826233240.11524-1-almasrymina@google.com>
X-Mailer: git-send-email 2.23.0.187.g17f5b7556c-goog
Subject: [PATCH v3 3/6] hugetlb_cgroup: add reservation accounting for private mappings
From: Mina Almasry <almasrymina@google.com>
To: mike.kravetz@oracle.com
Cc: shuah@kernel.org, almasrymina@google.com, rientjes@google.com, 
	shakeelb@google.com, gthelen@google.com, akpm@linux-foundation.org, 
	khalid.aziz@oracle.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, 
	linux-kselftest@vger.kernel.org, cgroups@vger.kernel.org, 
	aneesh.kumar@linux.vnet.ibm.com, mkoutny@suse.com
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Normally the pointer to the cgroup to uncharge hangs off the struct
page, and gets queried when it's time to free the page. With
hugetlb_cgroup reservations, this is not possible. Because it's possible
for a page to be reserved by one task and actually faulted in by another
task.

The best place to put the hugetlb_cgroup pointer to uncharge for
reservations is in the resv_map. But, because the resv_map has different
semantics for private and shared mappings, the code patch to
charge/uncharge shared and private mappings is different. This patch
implements charging and uncharging for private mappings.

For private mappings, the counter to uncharge is in
resv_map->reservation_counter. On initializing the resv_map this is set
to NULL. On reservation of a region in private mapping, the tasks
hugetlb_cgroup is charged and the hugetlb_cgroup is placed is
resv_map->reservation_counter.

On hugetlb_vm_op_close, we uncharge resv_map->reservation_counter.

---
 include/linux/hugetlb.h        |  8 ++++++
 include/linux/hugetlb_cgroup.h | 11 ++++++++
 mm/hugetlb.c                   | 47 ++++++++++++++++++++++++++++++++--
 mm/hugetlb_cgroup.c            | 12 ---------
 4 files changed, 64 insertions(+), 14 deletions(-)

diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
index 128ff1aff1c93..536cb144cf484 100644
--- a/include/linux/hugetlb.h
+++ b/include/linux/hugetlb.h
@@ -46,6 +46,14 @@ struct resv_map {
 	long adds_in_progress;
 	struct list_head region_cache;
 	long region_cache_count;
+ #ifdef CONFIG_CGROUP_HUGETLB
+	/*
+	 * On private mappings, the counter to uncharge reservations is stored
+	 * here. If these fields are 0, then the mapping is shared.
+	 */
+	struct page_counter *reservation_counter;
+	unsigned long pages_per_hpage;
+#endif
 };
 extern struct resv_map *resv_map_alloc(void);
 void resv_map_release(struct kref *ref);
diff --git a/include/linux/hugetlb_cgroup.h b/include/linux/hugetlb_cgroup.h
index 0725f809cd2d9..1fdde63a4e775 100644
--- a/include/linux/hugetlb_cgroup.h
+++ b/include/linux/hugetlb_cgroup.h
@@ -25,6 +25,17 @@ struct hugetlb_cgroup;
 #define HUGETLB_CGROUP_MIN_ORDER	2

 #ifdef CONFIG_CGROUP_HUGETLB
+struct hugetlb_cgroup {
+	struct cgroup_subsys_state css;
+	/*
+	 * the counter to account for hugepages from hugetlb.
+	 */
+	struct page_counter hugepage[HUGE_MAX_HSTATE];
+	/*
+	 * the counter to account for hugepage reservations from hugetlb.
+	 */
+	struct page_counter reserved_hugepage[HUGE_MAX_HSTATE];
+};

 static inline struct hugetlb_cgroup *hugetlb_cgroup_from_page(struct page *page)
 {
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 242cfeb7cc3e1..7c2df7574cf50 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -711,6 +711,16 @@ struct resv_map *resv_map_alloc(void)
 	INIT_LIST_HEAD(&resv_map->regions);

 	resv_map->adds_in_progress = 0;
+#ifdef CONFIG_CGROUP_HUGETLB
+	/*
+	 * Initialize these to 0. On shared mappings, 0's here indicate these
+	 * fields don't do cgroup accounting. On private mappings, these will be
+	 * re-initialized to the proper values, to indicate that hugetlb cgroup
+	 * reservations are to be un-charged from here.
+	 */
+	resv_map->reservation_counter = NULL;
+	resv_map->pages_per_hpage = 0;
+#endif

 	INIT_LIST_HEAD(&resv_map->region_cache);
 	list_add(&rg->link, &resv_map->region_cache);
@@ -3192,7 +3202,19 @@ static void hugetlb_vm_op_close(struct vm_area_struct *vma)

 	reserve = (end - start) - region_count(resv, start, end);

-	kref_put(&resv->refs, resv_map_release);
+#ifdef CONFIG_CGROUP_HUGETLB
+	/*
+	 * Since we check for HPAGE_RESV_OWNER above, this must a private
+	 * mapping, and these values should be none-zero, and should point to
+	 * the hugetlb_cgroup counter to uncharge for this reservation.
+	 */
+	WARN_ON(!resv->reservation_counter);
+	WARN_ON(!resv->pages_per_hpage);
+
+	hugetlb_cgroup_uncharge_counter(
+			resv->reservation_counter,
+			(end - start) * resv->pages_per_hpage);
+#endif

 	if (reserve) {
 		/*
@@ -3202,6 +3224,8 @@ static void hugetlb_vm_op_close(struct vm_area_struct *vma)
 		gbl_reserve = hugepage_subpool_put_pages(spool, reserve);
 		hugetlb_acct_memory(h, -gbl_reserve);
 	}
+
+	kref_put(&resv->refs, resv_map_release);
 }

 static int hugetlb_vm_op_split(struct vm_area_struct *vma, unsigned long addr)
@@ -4535,6 +4559,7 @@ int hugetlb_reserve_pages(struct inode *inode,
 	struct hstate *h = hstate_inode(inode);
 	struct hugepage_subpool *spool = subpool_inode(inode);
 	struct resv_map *resv_map;
+	struct hugetlb_cgroup *h_cg;
 	long gbl_reserve;

 	/* This should never happen */
@@ -4568,11 +4593,29 @@ int hugetlb_reserve_pages(struct inode *inode,
 		chg = region_chg(resv_map, from, to);

 	} else {
+		/* Private mapping. */
+		chg = to - from;
+
+		if (hugetlb_cgroup_charge_cgroup(
+					hstate_index(h),
+					chg * pages_per_huge_page(h),
+					&h_cg, true)) {
+			return -ENOMEM;
+		}
+
 		resv_map = resv_map_alloc();
 		if (!resv_map)
 			return -ENOMEM;

-		chg = to - from;
+#ifdef CONFIG_CGROUP_HUGETLB
+		/*
+		 * Since this branch handles private mappings, we attach the
+		 * counter to uncharge for this reservation off resv_map.
+		 */
+		resv_map->reservation_counter =
+			&h_cg->reserved_hugepage[hstate_index(h)];
+		resv_map->pages_per_hpage = pages_per_huge_page(h);
+#endif

 		set_vma_resv_map(vma, resv_map);
 		set_vma_resv_flags(vma, HPAGE_RESV_OWNER);
diff --git a/mm/hugetlb_cgroup.c b/mm/hugetlb_cgroup.c
index bd9b58474be51..1db97439bdb57 100644
--- a/mm/hugetlb_cgroup.c
+++ b/mm/hugetlb_cgroup.c
@@ -19,18 +19,6 @@
 #include <linux/hugetlb.h>
 #include <linux/hugetlb_cgroup.h>

-struct hugetlb_cgroup {
-	struct cgroup_subsys_state css;
-	/*
-	 * the counter to account for hugepages from hugetlb.
-	 */
-	struct page_counter hugepage[HUGE_MAX_HSTATE];
-	/*
-	 * the counter to account for hugepage reservations from hugetlb.
-	 */
-	struct page_counter reserved_hugepage[HUGE_MAX_HSTATE];
-};
-
 #define MEMFILE_PRIVATE(x, val)	(((x) << 16) | (val))
 #define MEMFILE_IDX(val)	(((val) >> 16) & 0xffff)
 #define MEMFILE_ATTR(val)	((val) & 0xffff)
--
2.23.0.187.g17f5b7556c-goog

