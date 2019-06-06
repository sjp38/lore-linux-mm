Return-Path: <SRS0=utKX=UF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1CC7AC04AB5
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 18:45:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CA9AD20868
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 18:44:59 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="lSL5uWTC"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CA9AD20868
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CFB776B027D; Thu,  6 Jun 2019 14:44:49 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CD7B06B0280; Thu,  6 Jun 2019 14:44:49 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 903076B0281; Thu,  6 Jun 2019 14:44:49 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 6E34F6B0280
	for <linux-mm@kvack.org>; Thu,  6 Jun 2019 14:44:49 -0400 (EDT)
Received: by mail-qk1-f197.google.com with SMTP id i196so2754754qke.20
        for <linux-mm@kvack.org>; Thu, 06 Jun 2019 11:44:49 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=cde22D2D/SQ7DjRMRDYakpeqSceiEmLYAy9R4sDRFZ4=;
        b=aNq3y32ocGy7+kOvmds1SNkj5iVCSMhoV2bbIbpSHKZPKtiIO6voTfI+hzB/UfweEa
         4gkHmABbDioVbYnnjlmI8nm+eNjLTBuowjYESQrcWgZTGVItG6dHl3bDi8WQLGW8RbMW
         EFfHsaxXIJfOHSjFiDPfdU71BhNVdFPzYQB/uymweA2hXegIlF4vxblD2Pm/0Tcw5eDq
         H/qPZCZjr0fNZ1iHP8fd3idLPeBHliqMdNZv0TiNeGXGpPO8l4hL3jqIJbCymu/nnObW
         6dGT5bjpTtdv/wzejm6hF8bH95gJgvYQQKrXKM2aWNL/lkw8nYP9mdygWh9/AF2bKFWc
         +Ciw==
X-Gm-Message-State: APjAAAWND16cmlxwn8LIrju/XpwXrPs3OVHU9a8N7TZJjFt+XSeKHPzJ
	FqORTLEXdNSqcKUS9dS+EyQ/7kkKOIdnyoBpnanpCCHYMbF0z/SRPjmMyq4Ee0RyLCVmYYhIICS
	6LXklcOCv+ihHjfYBJPZdndxldOgVwqXd/u7nCCKjbI5klRBPGeGBfS6RIohIDjlj/g==
X-Received: by 2002:ae9:c21a:: with SMTP id j26mr20775598qkg.310.1559846689197;
        Thu, 06 Jun 2019 11:44:49 -0700 (PDT)
X-Received: by 2002:ae9:c21a:: with SMTP id j26mr20775557qkg.310.1559846688458;
        Thu, 06 Jun 2019 11:44:48 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559846688; cv=none;
        d=google.com; s=arc-20160816;
        b=u9aWdgIHZoDqL5T9OgGMqobef88P7aqEpbIPI1co03wzmiNruW0Wa6nJU4gau7rtsL
         Dg26n2+RNNz/b7t1zw8PMBpieLJ35swnt798j0CE7UKH+oDPTlEBeVrC14gATgFqeESt
         dCassprbhcdtvcyCPNZ3k6PW8D7tUuFxwpB/yswezg9mXYd+fDJgADd3XmPeC5npL7rw
         OjV70G0l7eZYqefWXadFYPH4i0KYUez432YiftX+BTtojNH9aeNVaOuMB1tQhTWlbOF2
         pqq2rLASowtkgHpIDf77ElbHV8VoHCU4FXfsSCoIUWLxxV8z/I93rk7wxJnZsaBlTgZB
         mz+w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=cde22D2D/SQ7DjRMRDYakpeqSceiEmLYAy9R4sDRFZ4=;
        b=hV+Ug9nhQFQKcrHIL5kHYEgMA1FC64z6LCzJFv+DT9xRDBcd5Yf41AcNhzrS6opHEE
         8eHoXdpUVf6rlqz7Mn45gAHn17hYo0+XN8sV9y5C/baghPzt9w6/Fyu3bRElIG84hofa
         Qac3wHkSyXpPwwsOsDB3MITXFeHg6Nv/hvy6nqlbg9lSNjo3Ll5a9Kdc63pw+PYjph8k
         iHZysYoMSPme60G3/0MQD6jJqmGvxvZrd/HnEnGrXJZ/io5whG6/NRw+qR12j9TwIhlI
         gDzzEth3x5Dd0Dp1/oxdf7ccbQrWtOF4EP1nBBR60tF4XOkCSe8xJCJFyX6Nqn6NhkGF
         CroQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=lSL5uWTC;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y2sor907928qkl.107.2019.06.06.11.44.48
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 06 Jun 2019 11:44:48 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=lSL5uWTC;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=cde22D2D/SQ7DjRMRDYakpeqSceiEmLYAy9R4sDRFZ4=;
        b=lSL5uWTCwCDgnbM/9/jrfQbxzPhWl8p/lDEgf4FT0uXH6Y+QewAJIhobM0Y5pnTV9Q
         mHJJmWUwI+A1PUB/WHWHue/Bz0y86gLvYZNesbGU1EQLEO4zSV4kHiD4h1a3k/MFDCdt
         WER1Mq2EaZX18rAxQeUToKW/nL69Y1jxs8Z6SnX3i9uxlnWxabF1Y6RuKi6OeGO9ieDQ
         MKnU5o9rvxa7nvv/y/bNKbuZLHNH9r7rBleushaJ37/rgvNJIPoVwIFEEjE9KU47+m6B
         Zk1tFH65d0SU9drWp7Mv6gBGKQ18TW6fwuehe84ewVEWflPwK/zZvOf9mFM3yphUj1/7
         R/wA==
X-Google-Smtp-Source: APXvYqxTSq7xbg9zxLiy0kEDCOrZTnZLTLbqUahJa+pbRkNf/2oRcK31kQh3sfGGk+OlBqVQE/baDQ==
X-Received: by 2002:a37:4fca:: with SMTP id d193mr40455150qkb.298.1559846688185;
        Thu, 06 Jun 2019 11:44:48 -0700 (PDT)
Received: from ziepe.ca (hlfxns017vw-156-34-55-100.dhcp-dynamic.fibreop.ns.bellaliant.net. [156.34.55.100])
        by smtp.gmail.com with ESMTPSA id o38sm1731656qto.96.2019.06.06.11.44.45
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 06 Jun 2019 11:44:46 -0700 (PDT)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1hYxNV-0008IN-IO; Thu, 06 Jun 2019 15:44:45 -0300
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
	Jason Gunthorpe <jgg@mellanox.com>
Subject: [PATCH v2 hmm 04/11] mm/hmm: Simplify hmm_get_or_create and make it reliable
Date: Thu,  6 Jun 2019 15:44:31 -0300
Message-Id: <20190606184438.31646-5-jgg@ziepe.ca>
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190606184438.31646-1-jgg@ziepe.ca>
References: <20190606184438.31646-1-jgg@ziepe.ca>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Jason Gunthorpe <jgg@mellanox.com>

As coded this function can false-fail in various racy situations. Make it
reliable by running only under the write side of the mmap_sem and avoiding
the false-failing compare/exchange pattern.

Also make the locking very easy to understand by only ever reading or
writing mm->hmm while holding the write side of the mmap_sem.

Signed-off-by: Jason Gunthorpe <jgg@mellanox.com>
---
v2:
- Fix error unwind of mmgrab (Jerome)
- Use hmm local instead of 2nd container_of (Jerome)
---
 mm/hmm.c | 80 ++++++++++++++++++++------------------------------------
 1 file changed, 29 insertions(+), 51 deletions(-)

diff --git a/mm/hmm.c b/mm/hmm.c
index cc7c26fda3300e..dc30edad9a8a02 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -40,16 +40,6 @@
 #if IS_ENABLED(CONFIG_HMM_MIRROR)
 static const struct mmu_notifier_ops hmm_mmu_notifier_ops;
 
-static inline struct hmm *mm_get_hmm(struct mm_struct *mm)
-{
-	struct hmm *hmm = READ_ONCE(mm->hmm);
-
-	if (hmm && kref_get_unless_zero(&hmm->kref))
-		return hmm;
-
-	return NULL;
-}
-
 /**
  * hmm_get_or_create - register HMM against an mm (HMM internal)
  *
@@ -64,11 +54,20 @@ static inline struct hmm *mm_get_hmm(struct mm_struct *mm)
  */
 static struct hmm *hmm_get_or_create(struct mm_struct *mm)
 {
-	struct hmm *hmm = mm_get_hmm(mm);
-	bool cleanup = false;
+	struct hmm *hmm;
 
-	if (hmm)
-		return hmm;
+	lockdep_assert_held_exclusive(&mm->mmap_sem);
+
+	if (mm->hmm) {
+		if (kref_get_unless_zero(&mm->hmm->kref))
+			return mm->hmm;
+		/*
+		 * The hmm is being freed by some other CPU and is pending a
+		 * RCU grace period, but this CPU can NULL now it since we
+		 * have the mmap_sem.
+		 */
+		mm->hmm = NULL;
+	}
 
 	hmm = kmalloc(sizeof(*hmm), GFP_KERNEL);
 	if (!hmm)
@@ -83,57 +82,36 @@ static struct hmm *hmm_get_or_create(struct mm_struct *mm)
 	hmm->notifiers = 0;
 	hmm->dead = false;
 	hmm->mm = mm;
-	mmgrab(hmm->mm);
-
-	spin_lock(&mm->page_table_lock);
-	if (!mm->hmm)
-		mm->hmm = hmm;
-	else
-		cleanup = true;
-	spin_unlock(&mm->page_table_lock);
 
-	if (cleanup)
-		goto error;
-
-	/*
-	 * We should only get here if hold the mmap_sem in write mode ie on
-	 * registration of first mirror through hmm_mirror_register()
-	 */
 	hmm->mmu_notifier.ops = &hmm_mmu_notifier_ops;
-	if (__mmu_notifier_register(&hmm->mmu_notifier, mm))
-		goto error_mm;
+	if (__mmu_notifier_register(&hmm->mmu_notifier, mm)) {
+		kfree(hmm);
+		return NULL;
+	}
 
+	mmgrab(hmm->mm);
+	mm->hmm = hmm;
 	return hmm;
-
-error_mm:
-	spin_lock(&mm->page_table_lock);
-	if (mm->hmm == hmm)
-		mm->hmm = NULL;
-	spin_unlock(&mm->page_table_lock);
-error:
-	mmdrop(hmm->mm);
-	kfree(hmm);
-	return NULL;
 }
 
 static void hmm_free_rcu(struct rcu_head *rcu)
 {
-	kfree(container_of(rcu, struct hmm, rcu));
+	struct hmm *hmm = container_of(rcu, struct hmm, rcu);
+
+	down_write(&hmm->mm->mmap_sem);
+	if (hmm->mm->hmm == hmm)
+		hmm->mm->hmm = NULL;
+	up_write(&hmm->mm->mmap_sem);
+	mmdrop(hmm->mm);
+
+	kfree(hmm);
 }
 
 static void hmm_free(struct kref *kref)
 {
 	struct hmm *hmm = container_of(kref, struct hmm, kref);
-	struct mm_struct *mm = hmm->mm;
-
-	mmu_notifier_unregister_no_release(&hmm->mmu_notifier, mm);
 
-	spin_lock(&mm->page_table_lock);
-	if (mm->hmm == hmm)
-		mm->hmm = NULL;
-	spin_unlock(&mm->page_table_lock);
-
-	mmdrop(hmm->mm);
+	mmu_notifier_unregister_no_release(&hmm->mmu_notifier, hmm->mm);
 	mmu_notifier_call_srcu(&hmm->rcu, hmm_free_rcu);
 }
 
-- 
2.21.0

