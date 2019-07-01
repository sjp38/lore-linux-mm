Return-Path: <SRS0=jfnU=U6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3DEDBC5B578
	for <linux-mm@archiver.kernel.org>; Mon,  1 Jul 2019 06:21:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DC4452146E
	for <linux-mm@archiver.kernel.org>; Mon,  1 Jul 2019 06:21:04 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="fAnfAaMz"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DC4452146E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B2AD58E000A; Mon,  1 Jul 2019 02:20:54 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AD2B16B000C; Mon,  1 Jul 2019 02:20:54 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8DF628E000A; Mon,  1 Jul 2019 02:20:54 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f207.google.com (mail-pf1-f207.google.com [209.85.210.207])
	by kanga.kvack.org (Postfix) with ESMTP id 4C8B86B0008
	for <linux-mm@kvack.org>; Mon,  1 Jul 2019 02:20:54 -0400 (EDT)
Received: by mail-pf1-f207.google.com with SMTP id a20so8207324pfn.19
        for <linux-mm@kvack.org>; Sun, 30 Jun 2019 23:20:54 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=kPt7QqoQAeZJ9C9mepK91f+1X9hMOg2RzNm4lgmOCmg=;
        b=WqiTbUz5GOHB7F6RAp/D5VBBt5D1+JqXV+P5Pz9Tt/Tgqxpjy74XJwZBahP2ZLEoCp
         el5hZm7hUGeVyFfFxvX/xtFBfmCj3HtBEDCSxQkiGg8UWmt2x4S0F0Wgp1LD8vXwT+y7
         n4cxBI0wHvUd9HZuzWZEvRDMO/g5yMX6jj1JgJWeo6DSs7XFHVp4XLrZJwN38ai40fhG
         KoqnYU1Wn5fRzksxhH04tifDOmMXw3RyvwGyBUgJuXNUHruFHWl7VOTbWnzHmMZkWlG+
         0QXpqh4xCbZXZG5qhhPYeL0NgkHVJhSxwd3k8KJp+Dw1CvXa6wfVPMVJuQafs9UFTCY4
         W8NQ==
X-Gm-Message-State: APjAAAVL4dGMd26MIWroOgdf7GACi5L4SAA058uVaqsxdzQGLj1Hg0F+
	z1yB4k1Bw5ys/knsAgFGqAiI46cO2EJS3XGLmvZ3emGSeJ5albra9GjUUjUHuGmDL2/uKx9i3bG
	a9Yqzv3M7iCtAibIwR4r9XNVo+7cA5WayOS5KturqL+XGCun9MUSlrmsqHNNXGm4=
X-Received: by 2002:a17:90a:8c0c:: with SMTP id a12mr29163689pjo.67.1561962053980;
        Sun, 30 Jun 2019 23:20:53 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwM3qLFqeRNI3ikSatOWw48SonGI9fIjRAjQkoYwtxERa70rp07agOdkdDLri6ky2w2she/
X-Received: by 2002:a17:90a:8c0c:: with SMTP id a12mr29163630pjo.67.1561962053039;
        Sun, 30 Jun 2019 23:20:53 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561962053; cv=none;
        d=google.com; s=arc-20160816;
        b=DadpXkFfpR+Uke7wgtQ+h0o9cXc4eP2UFvoFlRzQCQ+H/D7rD08tRpxJCN/SjpKOMW
         c1y3hGOrZ4XPtwU3ldPshxq9qhsCx9UwukfqOTIl8c5QzdhwnjfI76t/kTTnnbAS0o29
         6ihvpP6GBTMhuL2SeA0uaT+ik3oPOZ+pGUz7ZxMUWLgeWAftF10jqF5XVklJZ0lLm9My
         zfb+QzcYbzRn0b1PIYZq743m9fr9c8iRZmktswbiykSmz3GLWpV+4vGH6eyaiXhud2aB
         lKwAwd1qVDtQyItojp/xvqVnUdDnJEvbjHGdFD+umAhOtC+T3OQnRC1LHVM6REa39hkO
         fjXQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=kPt7QqoQAeZJ9C9mepK91f+1X9hMOg2RzNm4lgmOCmg=;
        b=G1qnU1O1wv/vgdPNkHqK5q+41uwjatTtrCTR7lQLiYceYdxVBz0tCI3LiQ+zMOVFcV
         CjvsNYl+0l0YqxJamaKMc0m1WXTLNizGrvzZ48c4eZl72PVbRulvOOijCatTEZbxuo+v
         C+fvfLLfExAxpt3FxVh09GFMbCyRFLLt4UE4jQGJuq5QfFCI9/A9/QHPREJ9866SHK1i
         zqHhNvgq6hWuY1MaAkzlUEtAAmNZrQs0SswDMqCCS0pmyh6hLsSd/jST/oVNdF32tYGI
         gRUvWzmeivXOroRtVemkVA25kRhtWWqi86qDbfVKcf4uk9577AZTG7X6GkK2BZ89bLWi
         dang==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=fAnfAaMz;
       spf=pass (google.com: best guess record for domain of batv+bb02ddf78a79a38d855c+5790+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+bb02ddf78a79a38d855c+5790+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id l67si9974819plb.370.2019.06.30.23.20.52
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Sun, 30 Jun 2019 23:20:53 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+bb02ddf78a79a38d855c+5790+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=fAnfAaMz;
       spf=pass (google.com: best guess record for domain of batv+bb02ddf78a79a38d855c+5790+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+bb02ddf78a79a38d855c+5790+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=kPt7QqoQAeZJ9C9mepK91f+1X9hMOg2RzNm4lgmOCmg=; b=fAnfAaMz3Bi39bBAZqCZSGeuQM
	Xsba2waTpHlBW5IwPPLVvjXXLeCwtvh5KfJzq7GeBah6VXSNUvFwesh2TsCGgr9GJ++YhdjQyDGYn
	qR+hlXN/DEa6X4qKaWvnCUCWIdC8L5OLPLmZJvX0+tVWLdwKnUVCUHVXAnv2/hxfZj8mqEskLXeAY
	LRYWG+DnZJIKCqdLfbjS6vrZRwUwsFBEwYabVFw8EzHSik9cafdWu9IuVzT7o2kHPFn+aI4zJwnb+
	B0oPDvbD5Fj2Rg+GDLbMFwXG7/EkSLMjm/VCaQt5ozhMjljL8ESsrrq/wDdpcShqnf5EfoKN5TqJB
	uem06+qw==;
Received: from [46.140.178.35] (helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hhpgH-00031D-N6; Mon, 01 Jul 2019 06:20:50 +0000
From: Christoph Hellwig <hch@lst.de>
To: Dan Williams <dan.j.williams@intel.com>,
	=?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>,
	Jason Gunthorpe <jgg@mellanox.com>,
	Ben Skeggs <bskeggs@redhat.com>
Cc: Ira Weiny <ira.weiny@intel.com>,
	linux-mm@kvack.org,
	nouveau@lists.freedesktop.org,
	dri-devel@lists.freedesktop.org,
	linux-nvdimm@lists.01.org,
	linux-pci@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	John Hubbard <jhubbard@nvidia.com>,
	Ralph Campbell <rcampbell@nvidia.com>,
	Philip Yang <Philip.Yang@amd.com>
Subject: [PATCH 12/22] mm/hmm: Hold on to the mmget for the lifetime of the range
Date: Mon,  1 Jul 2019 08:20:10 +0200
Message-Id: <20190701062020.19239-13-hch@lst.de>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190701062020.19239-1-hch@lst.de>
References: <20190701062020.19239-1-hch@lst.de>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Jason Gunthorpe <jgg@mellanox.com>

Range functions like hmm_range_snapshot() and hmm_range_fault() call
find_vma, which requires hodling the mmget() and the mmap_sem for the mm.

Make this simpler for the callers by holding the mmget() inside the range
for the lifetime of the range. Other functions that accept a range should
only be called if the range is registered.

This has the side effect of directly preventing hmm_release() from
happening while a range is registered. That means range->dead cannot be
false during the lifetime of the range, so remove dead and
hmm_mirror_mm_is_alive() entirely.

Signed-off-by: Jason Gunthorpe <jgg@mellanox.com>
Reviewed-by: John Hubbard <jhubbard@nvidia.com>
Reviewed-by: Ralph Campbell <rcampbell@nvidia.com>
Reviewed-by: Christoph Hellwig <hch@lst.de>
Tested-by: Philip Yang <Philip.Yang@amd.com>
---
 include/linux/hmm.h | 26 --------------------------
 mm/hmm.c            | 32 +++++++++++---------------------
 2 files changed, 11 insertions(+), 47 deletions(-)

diff --git a/include/linux/hmm.h b/include/linux/hmm.h
index 26e7c477490c..bf013e965257 100644
--- a/include/linux/hmm.h
+++ b/include/linux/hmm.h
@@ -82,7 +82,6 @@
  * @mirrors_sem: read/write semaphore protecting the mirrors list
  * @wq: wait queue for user waiting on a range invalidation
  * @notifiers: count of active mmu notifiers
- * @dead: is the mm dead ?
  */
 struct hmm {
 	struct mm_struct	*mm;
@@ -95,7 +94,6 @@ struct hmm {
 	wait_queue_head_t	wq;
 	struct rcu_head		rcu;
 	long			notifiers;
-	bool			dead;
 };
 
 /*
@@ -459,30 +457,6 @@ struct hmm_mirror {
 int hmm_mirror_register(struct hmm_mirror *mirror, struct mm_struct *mm);
 void hmm_mirror_unregister(struct hmm_mirror *mirror);
 
-/*
- * hmm_mirror_mm_is_alive() - test if mm is still alive
- * @mirror: the HMM mm mirror for which we want to lock the mmap_sem
- * Return: false if the mm is dead, true otherwise
- *
- * This is an optimization, it will not always accurately return false if the
- * mm is dead; i.e., there can be false negatives (process is being killed but
- * HMM is not yet informed of that). It is only intended to be used to optimize
- * out cases where the driver is about to do something time consuming and it
- * would be better to skip it if the mm is dead.
- */
-static inline bool hmm_mirror_mm_is_alive(struct hmm_mirror *mirror)
-{
-	struct mm_struct *mm;
-
-	if (!mirror || !mirror->hmm)
-		return false;
-	mm = READ_ONCE(mirror->hmm->mm);
-	if (mirror->hmm->dead || !mm)
-		return false;
-
-	return true;
-}
-
 /*
  * Please see Documentation/vm/hmm.rst for how to use the range API.
  */
diff --git a/mm/hmm.c b/mm/hmm.c
index 73c8af4827fe..1eddda45cefa 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -67,7 +67,6 @@ static struct hmm *hmm_get_or_create(struct mm_struct *mm)
 	mutex_init(&hmm->lock);
 	kref_init(&hmm->kref);
 	hmm->notifiers = 0;
-	hmm->dead = false;
 	hmm->mm = mm;
 
 	hmm->mmu_notifier.ops = &hmm_mmu_notifier_ops;
@@ -120,21 +119,16 @@ static void hmm_release(struct mmu_notifier *mn, struct mm_struct *mm)
 {
 	struct hmm *hmm = container_of(mn, struct hmm, mmu_notifier);
 	struct hmm_mirror *mirror;
-	struct hmm_range *range;
 
 	/* Bail out if hmm is in the process of being freed */
 	if (!kref_get_unless_zero(&hmm->kref))
 		return;
 
-	/* Report this HMM as dying. */
-	hmm->dead = true;
-
-	/* Wake-up everyone waiting on any range. */
-	mutex_lock(&hmm->lock);
-	list_for_each_entry(range, &hmm->ranges, list)
-		range->valid = false;
-	wake_up_all(&hmm->wq);
-	mutex_unlock(&hmm->lock);
+	/*
+	 * Since hmm_range_register() holds the mmget() lock hmm_release() is
+	 * prevented as long as a range exists.
+	 */
+	WARN_ON(!list_empty_careful(&hmm->ranges));
 
 	down_write(&hmm->mirrors_sem);
 	mirror = list_first_entry_or_null(&hmm->mirrors, struct hmm_mirror,
@@ -903,8 +897,8 @@ int hmm_range_register(struct hmm_range *range,
 	range->start = start;
 	range->end = end;
 
-	/* Check if hmm_mm_destroy() was call. */
-	if (hmm->mm == NULL || hmm->dead)
+	/* Prevent hmm_release() from running while the range is valid */
+	if (!mmget_not_zero(hmm->mm))
 		return -EFAULT;
 
 	/* Initialize range to track CPU page table updates. */
@@ -942,11 +936,12 @@ void hmm_range_unregister(struct hmm_range *range)
 		return;
 
 	mutex_lock(&hmm->lock);
-	list_del(&range->list);
+	list_del_init(&range->list);
 	mutex_unlock(&hmm->lock);
 
 	/* Drop reference taken by hmm_range_register() */
 	range->valid = false;
+	mmput(hmm->mm);
 	hmm_put(hmm);
 	range->hmm = NULL;
 }
@@ -974,10 +969,7 @@ long hmm_range_snapshot(struct hmm_range *range)
 	struct vm_area_struct *vma;
 	struct mm_walk mm_walk;
 
-	/* Check if hmm_mm_destroy() was call. */
-	if (hmm->mm == NULL || hmm->dead)
-		return -EFAULT;
-
+	lockdep_assert_held(&hmm->mm->mmap_sem);
 	do {
 		/* If range is no longer valid force retry. */
 		if (!range->valid)
@@ -1072,9 +1064,7 @@ long hmm_range_fault(struct hmm_range *range, bool block)
 	struct mm_walk mm_walk;
 	int ret;
 
-	/* Check if hmm_mm_destroy() was call. */
-	if (hmm->mm == NULL || hmm->dead)
-		return -EFAULT;
+	lockdep_assert_held(&hmm->mm->mmap_sem);
 
 	do {
 		/* If range is no longer valid force retry. */
-- 
2.20.1

