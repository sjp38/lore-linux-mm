Return-Path: <SRS0=9FL3=UX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1B279C4646B
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 21:02:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B77AD20656
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 21:02:32 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="hxllCZWi"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B77AD20656
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9BE478E000E; Mon, 24 Jun 2019 17:02:09 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8F65C8E000A; Mon, 24 Jun 2019 17:02:09 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7C2308E000D; Mon, 24 Jun 2019 17:02:09 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f70.google.com (mail-wm1-f70.google.com [209.85.128.70])
	by kanga.kvack.org (Postfix) with ESMTP id 213528E000A
	for <linux-mm@kvack.org>; Mon, 24 Jun 2019 17:02:09 -0400 (EDT)
Received: by mail-wm1-f70.google.com with SMTP id t62so289678wmt.1
        for <linux-mm@kvack.org>; Mon, 24 Jun 2019 14:02:09 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=S3r5edHB129w6+WHP2qce1cv++fCEyzuU0DGZG/FVjU=;
        b=Q90qIyYHsVGJ5kHDuvm2ZoNyMFVaOfzZqLQeAlECoL5a5brZaoAbDnAZZwOU0KwXb6
         JPNpPCThvKv/7YHvtdqZ3/4Kg9RwA7oK49NCM1buaRU45whfdLHJRscTD+ytFfUitdia
         0xalviR5VwzlOkrT3gqH2wrzfYJCYQsG99vAkCQAXmg/ucgsRLEC1hG4J3fSSNw2SUZH
         bEZ+ZQv16N9aX3JCGrh7MtnQrvRy7TL5wClecvQ9i7ya/HxVqd9wF9O4ainIj9eZXfxR
         P+yjD+6a7/o93MdKcDmqp3OxdzcHpGkkA7RGppZIkNDMSigTddHve7j1b2JQLJ4A8OfZ
         MYag==
X-Gm-Message-State: APjAAAUSsbWcLmgdvzbsMrY9ZPl2YSe1yvbpZ89OgVqG/v4GP04h7zYi
	i7HPcFrWq8LI9br/X4+UlHv7IqNc91y2EoKkz70GZTQzk25f6l7n/5wHgrYTxwWvWbhXzlUz2TO
	AvMLLI1km46m9Bt6wK7h7Eg4De0e/IiJBSKlevFEMbMm1uhpAZ6n2EwHr0pmiTvoXDw==
X-Received: by 2002:a1c:20cf:: with SMTP id g198mr5317672wmg.88.1561410128700;
        Mon, 24 Jun 2019 14:02:08 -0700 (PDT)
X-Received: by 2002:a1c:20cf:: with SMTP id g198mr5317637wmg.88.1561410127628;
        Mon, 24 Jun 2019 14:02:07 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561410127; cv=none;
        d=google.com; s=arc-20160816;
        b=u4FwKWXssNZvTXJ6K79A1RqCe3/e7nFAQljqZMal7EomvMkXZAeR9mQLBK+L5UdDoV
         i75JNGBNmrQoN/Ea1kXZya3aR9lKZ6kfkjIofSjsEIgBAiMko3ZBmHPiqgwadxZvdPUE
         UJN1Gihj9tjiS6wgOBXoZZgGKJ/Y4aomdgy4u7zP57M/E5pCPuDFW9XeqB8JCpWW968/
         TbtfKWptbf6QTTuKVY0MLdpVxdiWjifL1BfUoVIefARkBzXWZVu4C8UexFlvfX3ky3up
         OevbHTQER+WQghJoZLtZaibaXMvDgB0yi5UsZ5rapw70jTv5WSNEIblL5K+pV/XvlycI
         D9vw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=S3r5edHB129w6+WHP2qce1cv++fCEyzuU0DGZG/FVjU=;
        b=SO8v/hZBxdXn3o1R0S6MUsTKqBb0F1ERiVdc30+mR0n4ZdsZzqmhpObX0Cbf8s1q2y
         pcZPCXiPH6zsXEP5xhNAjpGTPBiB/JLf8wKRRtn2nYp+2vbq2BlnOTxfduBM/RZnQ4Wg
         qUFEJQXUtcPBnk4WyE2cI/fp846NW7J+Dsx3cTQymmzLDPLVvzEejyqINfcvqCYVNW3V
         14JL2162b1hn6KlKYoxLxkeH6UIK0ewpTgo72Bwoh/w+6soDKjHln3sqyc4+jo85zJQg
         2lh2iHDeasbsUO6Vg5xzBTDnFoA6eKfbUMbC4Sn6K0DCdxXMKcyRoREtGszKEysj9hHm
         apDg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=hxllCZWi;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v187sor374981wme.3.2019.06.24.14.02.07
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 24 Jun 2019 14:02:07 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=hxllCZWi;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=S3r5edHB129w6+WHP2qce1cv++fCEyzuU0DGZG/FVjU=;
        b=hxllCZWingbWA/f5vgNASI2pGcmQkq+YMV0+41KqM+6SHez+NGQ1uJO082ws99YMd9
         a02GfWbWiybTgkW5XKpp58ScKdfgpRyQkF+lx8bQgY/E0sad83Uy5xKeM+5fDXk5l+dn
         kREAcw817qhEHGbJzh/JPNg+S+obDw/5JZAk7sJkD1VoJOjy+A9WMNZt4hUg76s0LIwA
         7CnwGTdpr/y52OLSiCtTuB/yhZqVQPS2pkaGeOalh4K4i+1u3/L+S9jsgkydPV6oBOsv
         +C7ZAWxMOYu5gNiQFVoJHSQaBp2JqH18fs4FjehP3vhAnvD2AIJi3c1yJBiWTS4qwHYX
         +fIw==
X-Google-Smtp-Source: APXvYqyInST0pwmwLzJ/uxOPmS6zD6FzKVUhnIxI9FAO5JkPPLVhNSreFOU/LTKh9NST5RUcH7Pi3Q==
X-Received: by 2002:a1c:3:: with SMTP id 3mr16798813wma.6.1561410127205;
        Mon, 24 Jun 2019 14:02:07 -0700 (PDT)
Received: from ziepe.ca ([66.187.232.66])
        by smtp.gmail.com with ESMTPSA id l4sm411869wmh.18.2019.06.24.14.02.02
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 24 Jun 2019 14:02:02 -0700 (PDT)
Received: from jgg by jggl.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1hfW6D-0001N7-5h; Mon, 24 Jun 2019 18:02:01 -0300
From: Jason Gunthorpe <jgg@ziepe.ca>
To: Jerome Glisse <jglisse@redhat.com>,
	Ralph Campbell <rcampbell@nvidia.com>,
	John Hubbard <jhubbard@nvidia.com>,
	Felix.Kuehling@amd.com
Cc: linux-rdma@vger.kernel.org,
	linux-mm@kvack.org,
	Andrea Arcangeli <aarcange@redhat.com>,
	dri-devel@lists.freedesktop.org,
	amd-gfx@lists.freedesktop.org,
	Ben Skeggs <bskeggs@redhat.com>,
	Christoph Hellwig <hch@lst.de>,
	Philip Yang <Philip.Yang@amd.com>,
	Ira Weiny <ira.weiny@intel.com>,
	Jason Gunthorpe <jgg@mellanox.com>
Subject: [PATCH v4 hmm 12/12] mm/hmm: Fix error flows in hmm_invalidate_range_start
Date: Mon, 24 Jun 2019 18:01:10 -0300
Message-Id: <20190624210110.5098-13-jgg@ziepe.ca>
X-Mailer: git-send-email 2.22.0
In-Reply-To: <20190624210110.5098-1-jgg@ziepe.ca>
References: <20190624210110.5098-1-jgg@ziepe.ca>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Jason Gunthorpe <jgg@mellanox.com>

If the trylock on the hmm->mirrors_sem fails the function will return
without decrementing the notifiers that were previously incremented. Since
the caller will not call invalidate_range_end() on EAGAIN this will result
in notifiers becoming permanently incremented and deadlock.

If the sync_cpu_device_pagetables() required blocking the function will
not return EAGAIN even though the device continues to touch the
pages. This is a violation of the mmu notifier contract.

Switch, and rename, the ranges_lock to a spin lock so we can reliably
obtain it without blocking during error unwind.

The error unwind is necessary since the notifiers count must be held
incremented across the call to sync_cpu_device_pagetables() as we cannot
allow the range to become marked valid by a parallel
invalidate_start/end() pair while doing sync_cpu_device_pagetables().

Signed-off-by: Jason Gunthorpe <jgg@mellanox.com>
Reviewed-by: Ralph Campbell <rcampbell@nvidia.com>
Reviewed-by: Christoph Hellwig <hch@lst.de>
Tested-by: Philip Yang <Philip.Yang@amd.com>
---
 include/linux/hmm.h |  2 +-
 mm/hmm.c            | 72 +++++++++++++++++++++++++++------------------
 2 files changed, 45 insertions(+), 29 deletions(-)

diff --git a/include/linux/hmm.h b/include/linux/hmm.h
index bf013e96525771..0fa8ea34ccef6d 100644
--- a/include/linux/hmm.h
+++ b/include/linux/hmm.h
@@ -86,7 +86,7 @@
 struct hmm {
 	struct mm_struct	*mm;
 	struct kref		kref;
-	struct mutex		lock;
+	spinlock_t		ranges_lock;
 	struct list_head	ranges;
 	struct list_head	mirrors;
 	struct mmu_notifier	mmu_notifier;
diff --git a/mm/hmm.c b/mm/hmm.c
index b224ea635a7716..89549eac03d506 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -64,7 +64,7 @@ static struct hmm *hmm_get_or_create(struct mm_struct *mm)
 	init_rwsem(&hmm->mirrors_sem);
 	hmm->mmu_notifier.ops = NULL;
 	INIT_LIST_HEAD(&hmm->ranges);
-	mutex_init(&hmm->lock);
+	spin_lock_init(&hmm->ranges_lock);
 	kref_init(&hmm->kref);
 	hmm->notifiers = 0;
 	hmm->mm = mm;
@@ -144,6 +144,23 @@ static void hmm_release(struct mmu_notifier *mn, struct mm_struct *mm)
 	hmm_put(hmm);
 }
 
+static void notifiers_decrement(struct hmm *hmm)
+{
+	lockdep_assert_held(&hmm->ranges_lock);
+
+	hmm->notifiers--;
+	if (!hmm->notifiers) {
+		struct hmm_range *range;
+
+		list_for_each_entry(range, &hmm->ranges, list) {
+			if (range->valid)
+				continue;
+			range->valid = true;
+		}
+		wake_up_all(&hmm->wq);
+	}
+}
+
 static int hmm_invalidate_range_start(struct mmu_notifier *mn,
 			const struct mmu_notifier_range *nrange)
 {
@@ -151,6 +168,7 @@ static int hmm_invalidate_range_start(struct mmu_notifier *mn,
 	struct hmm_mirror *mirror;
 	struct hmm_update update;
 	struct hmm_range *range;
+	unsigned long flags;
 	int ret = 0;
 
 	if (!kref_get_unless_zero(&hmm->kref))
@@ -161,12 +179,7 @@ static int hmm_invalidate_range_start(struct mmu_notifier *mn,
 	update.event = HMM_UPDATE_INVALIDATE;
 	update.blockable = mmu_notifier_range_blockable(nrange);
 
-	if (mmu_notifier_range_blockable(nrange))
-		mutex_lock(&hmm->lock);
-	else if (!mutex_trylock(&hmm->lock)) {
-		ret = -EAGAIN;
-		goto out;
-	}
+	spin_lock_irqsave(&hmm->ranges_lock, flags);
 	hmm->notifiers++;
 	list_for_each_entry(range, &hmm->ranges, list) {
 		if (update.end < range->start || update.start >= range->end)
@@ -174,7 +187,7 @@ static int hmm_invalidate_range_start(struct mmu_notifier *mn,
 
 		range->valid = false;
 	}
-	mutex_unlock(&hmm->lock);
+	spin_unlock_irqrestore(&hmm->ranges_lock, flags);
 
 	if (mmu_notifier_range_blockable(nrange))
 		down_read(&hmm->mirrors_sem);
@@ -182,16 +195,26 @@ static int hmm_invalidate_range_start(struct mmu_notifier *mn,
 		ret = -EAGAIN;
 		goto out;
 	}
+
 	list_for_each_entry(mirror, &hmm->mirrors, list) {
-		int ret;
+		int rc;
 
-		ret = mirror->ops->sync_cpu_device_pagetables(mirror, &update);
-		if (!update.blockable && ret == -EAGAIN)
+		rc = mirror->ops->sync_cpu_device_pagetables(mirror, &update);
+		if (rc) {
+			if (WARN_ON(update.blockable || rc != -EAGAIN))
+				continue;
+			ret = -EAGAIN;
 			break;
+		}
 	}
 	up_read(&hmm->mirrors_sem);
 
 out:
+	if (ret) {
+		spin_lock_irqsave(&hmm->ranges_lock, flags);
+		notifiers_decrement(hmm);
+		spin_unlock_irqrestore(&hmm->ranges_lock, flags);
+	}
 	hmm_put(hmm);
 	return ret;
 }
@@ -200,23 +223,14 @@ static void hmm_invalidate_range_end(struct mmu_notifier *mn,
 			const struct mmu_notifier_range *nrange)
 {
 	struct hmm *hmm = container_of(mn, struct hmm, mmu_notifier);
+	unsigned long flags;
 
 	if (!kref_get_unless_zero(&hmm->kref))
 		return;
 
-	mutex_lock(&hmm->lock);
-	hmm->notifiers--;
-	if (!hmm->notifiers) {
-		struct hmm_range *range;
-
-		list_for_each_entry(range, &hmm->ranges, list) {
-			if (range->valid)
-				continue;
-			range->valid = true;
-		}
-		wake_up_all(&hmm->wq);
-	}
-	mutex_unlock(&hmm->lock);
+	spin_lock_irqsave(&hmm->ranges_lock, flags);
+	notifiers_decrement(hmm);
+	spin_unlock_irqrestore(&hmm->ranges_lock, flags);
 
 	hmm_put(hmm);
 }
@@ -868,6 +882,7 @@ int hmm_range_register(struct hmm_range *range,
 {
 	unsigned long mask = ((1UL << page_shift) - 1UL);
 	struct hmm *hmm = mirror->hmm;
+	unsigned long flags;
 
 	range->valid = false;
 	range->hmm = NULL;
@@ -886,7 +901,7 @@ int hmm_range_register(struct hmm_range *range,
 		return -EFAULT;
 
 	/* Initialize range to track CPU page table updates. */
-	mutex_lock(&hmm->lock);
+	spin_lock_irqsave(&hmm->ranges_lock, flags);
 
 	range->hmm = hmm;
 	kref_get(&hmm->kref);
@@ -898,7 +913,7 @@ int hmm_range_register(struct hmm_range *range,
 	 */
 	if (!hmm->notifiers)
 		range->valid = true;
-	mutex_unlock(&hmm->lock);
+	spin_unlock_irqrestore(&hmm->ranges_lock, flags);
 
 	return 0;
 }
@@ -914,10 +929,11 @@ EXPORT_SYMBOL(hmm_range_register);
 void hmm_range_unregister(struct hmm_range *range)
 {
 	struct hmm *hmm = range->hmm;
+	unsigned long flags;
 
-	mutex_lock(&hmm->lock);
+	spin_lock_irqsave(&hmm->ranges_lock, flags);
 	list_del_init(&range->list);
-	mutex_unlock(&hmm->lock);
+	spin_unlock_irqrestore(&hmm->ranges_lock, flags);
 
 	/* Drop reference taken by hmm_range_register() */
 	mmput(hmm->mm);
-- 
2.22.0

