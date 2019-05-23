Return-Path: <SRS0=On+J=TX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AB9BBC282DD
	for <linux-mm@archiver.kernel.org>; Thu, 23 May 2019 15:34:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5E2022177E
	for <linux-mm@archiver.kernel.org>; Thu, 23 May 2019 15:34:42 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="K8z8HnLI"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5E2022177E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id ACDE46B0274; Thu, 23 May 2019 11:34:40 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A7EA76B0275; Thu, 23 May 2019 11:34:40 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 944856B0277; Thu, 23 May 2019 11:34:40 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 706136B0275
	for <linux-mm@kvack.org>; Thu, 23 May 2019 11:34:40 -0400 (EDT)
Received: by mail-qk1-f199.google.com with SMTP id v144so5751492qka.13
        for <linux-mm@kvack.org>; Thu, 23 May 2019 08:34:40 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=gR5B+R57dzhfm++AjZVD0k9PFQ5ymVIe8oDIOybm+/Y=;
        b=jpSUczE0XUmUUMzXg6YEtO1YIOOS2zzeKzIPXe3qbSc5Hk+Qhcke+MKddfv4yuJs2l
         sNbKJAAqzKcS4lsEnGzBJt3gOtPUELKSWxRJFyxeV6P60pEjMRIuciwBgduXoulEBzYc
         kg6nV4QnZW0ye/Fs8C+Bp//5CLOgLmNScODQfQyFGjFSsfMjkzwS2sr5cZAtJfzbIVR7
         jOd9uFkEtUnp0E7kRsqqmMb6Een5DshD67yFzdhU8Zmh8Fm9VTOlJe0oH3Z8mHU7JVLv
         gI7oqSZ6+QQ3/u06flFMeSCPUvrDCVUC1mWZ2dkJuv2UwXaDAsGc/muphjO5yLoXeURv
         rBPw==
X-Gm-Message-State: APjAAAV2/0gBuJVw/yLoFB8bHgmj3i12VFHVHHLgv80CKybBX9pix1jo
	ZBTgdvauqdjLsCszMJZBgsSGJ6DPXwrMvtttU8DIcHAGmIi6TN5bJePliWaW0NlT8DtgkjLUvHp
	n2YG/n9MuXV3aZ6l6/KwG/ropPrHDgwknlAuuKTTe8pkPPlL9qyERRObaQRCsYAFTgQ==
X-Received: by 2002:ae9:e806:: with SMTP id a6mr59488974qkg.247.1558625680218;
        Thu, 23 May 2019 08:34:40 -0700 (PDT)
X-Received: by 2002:ae9:e806:: with SMTP id a6mr59488895qkg.247.1558625679454;
        Thu, 23 May 2019 08:34:39 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558625679; cv=none;
        d=google.com; s=arc-20160816;
        b=H0Y1GTzEoxBtsYzRStEqREjx6BVtaylMa+tdlQpdm2I3v+zFUbOkVMw238qLWoo61b
         hrjPTCDW7zha/+gAFXnu6qkGAbPJwfbhMbLG7viRbQeQC5ZnfxL8MGAAeen9M3dxERQ/
         cpH2YoqVYmZnUBLKoxBxdT6oVLbsmcFLaMY82x9dn1Z1qfMwdj3XiTgq32bxzbaUIr9M
         nfMhdq1cnLMpEzRB2t2FUqiljGnWLYN4w/o4oF9YvrS5346/k0XePkrAZOlyWPAyouP1
         wfZpNoQ3KDCmdVtQf9oz/JeZiSrPYiGmUghMjHpFEfky39gOOO5UGSqVgsPy5NZaLBiS
         z0MA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=gR5B+R57dzhfm++AjZVD0k9PFQ5ymVIe8oDIOybm+/Y=;
        b=Tz2xpnHOgNPdoeBsjSl1+3j1lPjpfJOlCoAt68s8bC5t+naw7komvp8YdfXsDto+1V
         HaCwJ5zAxscfM1LLa1bLj3ivghSRb5GGmd/lpbVyJDGFSg2fs0hZ1B+j7aBJH2wGoovt
         1gnVPRWG9eAtojElMlYk7BimzrAGRC+/jO5E/Lie9k5+qIVbkO/Ox/djWPy9ceKq2xgw
         mlrbvv/Pyuhff0bldHJy3IS7kNSW48ZTTJ2WwpMzltO4eMh5zJchQ4Sqj1AO7K39NwzL
         R/3T7a19857rNhDqoN5/++bZCc6sdgmZcY4Q9J6uT5pc9IUtW53djnMShjKjXHT2u6kZ
         qyww==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=K8z8HnLI;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d127sor4371798qkc.16.2019.05.23.08.34.39
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 23 May 2019 08:34:39 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=K8z8HnLI;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=gR5B+R57dzhfm++AjZVD0k9PFQ5ymVIe8oDIOybm+/Y=;
        b=K8z8HnLIYzj0CvIlrQpPXO2d+uOz8Pq+97N2YabABx1Vrr+qMaFLmh2VnVLx7a2oGq
         wOLg9W+DBwbkikfS0ff5K3MxYHAk3TSgoQYOvWZ/gmtirGdLKUC9DG9R8Ipu8mV0wg1O
         AVWPOOkR7fDNM3E0R1Ft5vDpgr37TJcvqhe3MhUEFNRKFUO4zvfCWS/qD4Zi6BZH+zi+
         2nHw0N8KVoBb1X1p7s0lsRt99Yq5hmwdLBLjHEaLE1oOXEBXSTOo4PBEa5CReklY8/7U
         mJVOX/VX4CF+TvyigLMWsvggRdPp9oUrqqQAiJtfOXeUBS65Sy7nS52+0lUgbQD2cN4+
         7aZQ==
X-Google-Smtp-Source: APXvYqx/CGFpFj+ej4XSzm0t6zCGOlTT7rmKjSiwJVztU6ABpwKrdUJowycnkB+WIld4Nb1SIXkSCw==
X-Received: by 2002:a37:c445:: with SMTP id h5mr48174135qkm.105.1558625679185;
        Thu, 23 May 2019 08:34:39 -0700 (PDT)
Received: from ziepe.ca (hlfxns017vw-156-34-49-251.dhcp-dynamic.fibreop.ns.bellaliant.net. [156.34.49.251])
        by smtp.gmail.com with ESMTPSA id v126sm13212129qkh.86.2019.05.23.08.34.38
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 23 May 2019 08:34:38 -0700 (PDT)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1hTpjp-0004zA-Sv; Thu, 23 May 2019 12:34:37 -0300
From: Jason Gunthorpe <jgg@ziepe.ca>
To: linux-rdma@vger.kernel.org,
	linux-mm@kvack.org,
	Jerome Glisse <jglisse@redhat.com>,
	Ralph Campbell <rcampbell@nvidia.com>,
	John Hubbard <jhubbard@nvidia.com>
Cc: Jason Gunthorpe <jgg@mellanox.com>
Subject: [RFC PATCH 01/11] mm/hmm: Fix use after free with struct hmm in the mmu notifiers
Date: Thu, 23 May 2019 12:34:26 -0300
Message-Id: <20190523153436.19102-2-jgg@ziepe.ca>
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190523153436.19102-1-jgg@ziepe.ca>
References: <20190523153436.19102-1-jgg@ziepe.ca>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Jason Gunthorpe <jgg@mellanox.com>

mmu_notifier_unregister_no_release() is not a fence and the mmu_notifier
system will continue to reference hmm->mn until the srcu grace period
expires.

Resulting in use after free races like this:

         CPU0                                     CPU1
                                               __mmu_notifier_invalidate_range_start()
                                                 srcu_read_lock
                                                 hlist_for_each ()
                                                   // mn == hmm->mn
hmm_mirror_unregister()
  hmm_put()
    hmm_free()
      mmu_notifier_unregister_no_release()
         hlist_del_init_rcu(hmm-mn->list)
			                           mn->ops->invalidate_range_start(mn, range);
					             mm_get_hmm()
      mm->hmm = NULL;
      kfree(hmm)
                                                     mutex_lock(&hmm->lock);

Use SRCU to kfree the hmm memory so that the notifiers can rely on hmm
existing. Get the now-safe hmm struct through container_of and directly
check kref_get_unless_zero to lock it against free.

Signed-off-by: Jason Gunthorpe <jgg@mellanox.com>
---
 include/linux/hmm.h |  1 +
 mm/hmm.c            | 25 +++++++++++++++++++------
 2 files changed, 20 insertions(+), 6 deletions(-)

diff --git a/include/linux/hmm.h b/include/linux/hmm.h
index 51ec27a8466816..8b91c90d3b88cb 100644
--- a/include/linux/hmm.h
+++ b/include/linux/hmm.h
@@ -102,6 +102,7 @@ struct hmm {
 	struct mmu_notifier	mmu_notifier;
 	struct rw_semaphore	mirrors_sem;
 	wait_queue_head_t	wq;
+	struct rcu_head		rcu;
 	long			notifiers;
 	bool			dead;
 };
diff --git a/mm/hmm.c b/mm/hmm.c
index 816c2356f2449f..824e7e160d8167 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -113,6 +113,11 @@ static struct hmm *hmm_get_or_create(struct mm_struct *mm)
 	return NULL;
 }
 
+static void hmm_fee_rcu(struct rcu_head *rcu)
+{
+	kfree(container_of(rcu, struct hmm, rcu));
+}
+
 static void hmm_free(struct kref *kref)
 {
 	struct hmm *hmm = container_of(kref, struct hmm, kref);
@@ -125,7 +130,7 @@ static void hmm_free(struct kref *kref)
 		mm->hmm = NULL;
 	spin_unlock(&mm->page_table_lock);
 
-	kfree(hmm);
+	mmu_notifier_call_srcu(&hmm->rcu, hmm_fee_rcu);
 }
 
 static inline void hmm_put(struct hmm *hmm)
@@ -153,10 +158,14 @@ void hmm_mm_destroy(struct mm_struct *mm)
 
 static void hmm_release(struct mmu_notifier *mn, struct mm_struct *mm)
 {
-	struct hmm *hmm = mm_get_hmm(mm);
+	struct hmm *hmm = container_of(mn, struct hmm, mmu_notifier);
 	struct hmm_mirror *mirror;
 	struct hmm_range *range;
 
+	/* hmm is in progress to free */
+	if (!kref_get_unless_zero(&hmm->kref))
+		return;
+
 	/* Report this HMM as dying. */
 	hmm->dead = true;
 
@@ -194,13 +203,15 @@ static void hmm_release(struct mmu_notifier *mn, struct mm_struct *mm)
 static int hmm_invalidate_range_start(struct mmu_notifier *mn,
 			const struct mmu_notifier_range *nrange)
 {
-	struct hmm *hmm = mm_get_hmm(nrange->mm);
+	struct hmm *hmm = container_of(mn, struct hmm, mmu_notifier);
 	struct hmm_mirror *mirror;
 	struct hmm_update update;
 	struct hmm_range *range;
 	int ret = 0;
 
-	VM_BUG_ON(!hmm);
+	/* hmm is in progress to free */
+	if (!kref_get_unless_zero(&hmm->kref))
+		return 0;
 
 	update.start = nrange->start;
 	update.end = nrange->end;
@@ -248,9 +259,11 @@ static int hmm_invalidate_range_start(struct mmu_notifier *mn,
 static void hmm_invalidate_range_end(struct mmu_notifier *mn,
 			const struct mmu_notifier_range *nrange)
 {
-	struct hmm *hmm = mm_get_hmm(nrange->mm);
+	struct hmm *hmm = container_of(mn, struct hmm, mmu_notifier);
 
-	VM_BUG_ON(!hmm);
+	/* hmm is in progress to free */
+	if (!kref_get_unless_zero(&hmm->kref))
+		return;
 
 	mutex_lock(&hmm->lock);
 	hmm->notifiers--;
-- 
2.21.0

