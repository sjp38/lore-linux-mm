Return-Path: <SRS0=9FL3=UX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AE0EBC4646B
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 21:02:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 641A820656
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 21:02:13 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="eVFuqGal"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 641A820656
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 47CFD8E0003; Mon, 24 Jun 2019 17:02:07 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 329548E0008; Mon, 24 Jun 2019 17:02:07 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 06AEB8E0003; Mon, 24 Jun 2019 17:02:07 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id 9BE908E0002
	for <linux-mm@kvack.org>; Mon, 24 Jun 2019 17:02:06 -0400 (EDT)
Received: by mail-wr1-f69.google.com with SMTP id t4so6896938wrs.10
        for <linux-mm@kvack.org>; Mon, 24 Jun 2019 14:02:06 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=bvrLwS8goK61NFHHKG+L59ElQQ6a+tjA3TuLNO1hols=;
        b=Eb6g2yx5+S9E7n/HWlhwAmBpgiG/YdXjyTK0DT8ki8ciFk4bv/6cp06bUktf3Kk49r
         PMSaAVj8P+ZDN/BBijr1fuUIa/JZUFLLvK4gQ/YVzoNr77ZLHr9kN0C3cQlafl5f6Ppa
         afnyO161BsOG0iDTwHrkSO3blNGET9j8NZpZSqDf1TBwNF+DkBe+dr7Fr4EjDrJuwTzi
         h7nV3eqTBnP874ELXcAmY9nX8lkYHoZatoL7dsXZplwMVWpUc/W7r8Zvv74A4FjqgyaH
         FT1u3Ea15Sn7aGWMjelIWq0Ovvv8II2kWly4xK54bzRJo6jtZ2zHtk5P9wicECFg65+R
         ekvg==
X-Gm-Message-State: APjAAAXUxxPdTZBOql9eBtloP6UX8Duk5/4z8tuolQtKOzaJf7QKMnme
	BK1QeH2CSkYZOHvsJ0s/hnmaTxlZIxtVonjQiINTNWNLUyTbQwFtVPF6RoovLnDr/42s1+Gg8i8
	R+h0WyaHUFmfCFOzkyNofJEyNt5CMA3aQ3GTsBd2RsEYnLasoJBi1YTYH9/0LOWWqeQ==
X-Received: by 2002:a1c:305:: with SMTP id 5mr17857927wmd.101.1561410126186;
        Mon, 24 Jun 2019 14:02:06 -0700 (PDT)
X-Received: by 2002:a1c:305:: with SMTP id 5mr17857891wmd.101.1561410125233;
        Mon, 24 Jun 2019 14:02:05 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561410125; cv=none;
        d=google.com; s=arc-20160816;
        b=kUEr9PZ8hHH4KHm1DU1zMxZfykdYaAzB0+gozmjZ3hOEOq3t6MBOC9oSSuoQLXz1iz
         LA46Kz5NJcgfHHPKiaWj3gmIClWDQf4C5dlx4sJUvrgHhthaBaaVETxH5rrgWtLh3Zi2
         s3q8ncleAcu7AzgEUp0sPSD4259Koi3keQCN9HqWv0iWbdJY7gV042vlUx9Y+x9fyF9A
         FHryaCrJhFMLi7D09sQr4t+/mRNfRMyJBrW5UaenIzV76aWno1+xfe1Ft9DZZF2ffz8z
         fT4rcU1qb/Gy99xWjgAIqHrj6g60PB6M7WT5MGaWFnUvUJwb9FDuP38rlfu+swKNWwlO
         0lSQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=bvrLwS8goK61NFHHKG+L59ElQQ6a+tjA3TuLNO1hols=;
        b=QUEB+T5V/7/sZwu6/v+yDTHRCjlBvqKK9LWS/+kdNmWL4MI61nLLViFV/7xHBc/0Fi
         bwAZTv29GnIZBJqGujZc5PLRAVH7i8TlnUoNRzS9dcszJSm2PMCqHeyolMRvf5/gqHh7
         mDlxXdHfTeRv9sC2ruWLtplf444CPHpRdMyQTdrI+pC7jLywV34LsHF/U7V518l4cTUl
         4P7ijFi+03rtoY7aXORrqgh5dq97rgDu0+SxXXpmqNd54OC/2K11n7KHgsYwwlOHN1VQ
         ODIw/SRnjKp5hd+iShUh9+JLAfTiGdiyM2IwJWpnP5dVvF5PksBYGNk3dB8pL+0CwlIS
         fBJQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=eVFuqGal;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g8sor7213085wrp.5.2019.06.24.14.02.05
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 24 Jun 2019 14:02:05 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=eVFuqGal;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=bvrLwS8goK61NFHHKG+L59ElQQ6a+tjA3TuLNO1hols=;
        b=eVFuqGal7MmrKBtKN1rp7PO9U9nA5Z3G5ySp7ACdyjU8KPVJwiMhZOX3ijBDCcRL1S
         GTWW6OsNpDRwAQ99IpOKbjE4ke8ZJxp+O8FP/MG8xEtB6bNNyhoddDXqx09MksC3ucTO
         oJ93yVe3SvCZh0B9cLyVmwFyg4NWK+yvtmHIR5Ht19fKXdc1deBlAadM2MfQOo7DpfxL
         u45+uLrEWPgz5VW+SYVHONBoIIEBy3hHaaX9UXvxqchVA5MxvXU51AT2KJdXKstwNhpK
         HS8SeD4+RAjEkcCeH/9NHi+z2QOq0pKZI8APHroOaypyHDbREEEL9MVSPuU3viLHbv3C
         +MFg==
X-Google-Smtp-Source: APXvYqzXxflttImXsUfCwAd7r65RK1DVJZBGVN7mipcY4Irf1EG1vjNhQIrTK0Km8IeO1SnCpwVb8g==
X-Received: by 2002:adf:b1ca:: with SMTP id r10mr34168985wra.156.1561410124460;
        Mon, 24 Jun 2019 14:02:04 -0700 (PDT)
Received: from ziepe.ca ([66.187.232.66])
        by smtp.gmail.com with ESMTPSA id n14sm26883973wra.75.2019.06.24.14.02.02
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 24 Jun 2019 14:02:02 -0700 (PDT)
Received: from jgg by jggl.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1hfW6C-0001M7-PX; Mon, 24 Jun 2019 18:02:00 -0300
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
Subject: [PATCH v4 hmm 02/12] mm/hmm: Use hmm_mirror not mm as an argument for hmm_range_register
Date: Mon, 24 Jun 2019 18:01:00 -0300
Message-Id: <20190624210110.5098-3-jgg@ziepe.ca>
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

Ralph observes that hmm_range_register() can only be called by a driver
while a mirror is registered. Make this clear in the API by passing in the
mirror structure as a parameter.

This also simplifies understanding the lifetime model for struct hmm, as
the hmm pointer must be valid as part of a registered mirror so all we
need in hmm_register_range() is a simple kref_get.

Suggested-by: Ralph Campbell <rcampbell@nvidia.com>
Signed-off-by: Jason Gunthorpe <jgg@mellanox.com>
Reviewed-by: John Hubbard <jhubbard@nvidia.com>
Reviewed-by: Ralph Campbell <rcampbell@nvidia.com>
Reviewed-by: Ira Weiny <ira.weiny@intel.com>
Reviewed-by: Christoph Hellwig <hch@lst.de>
Tested-by: Philip Yang <Philip.Yang@amd.com>
---
v2
- Include the oneline patch to nouveau_svm.c
---
 drivers/gpu/drm/nouveau/nouveau_svm.c |  2 +-
 include/linux/hmm.h                   |  7 ++++---
 mm/hmm.c                              | 13 ++++---------
 3 files changed, 9 insertions(+), 13 deletions(-)

diff --git a/drivers/gpu/drm/nouveau/nouveau_svm.c b/drivers/gpu/drm/nouveau/nouveau_svm.c
index 93ed43c413f0bb..8c92374afcf227 100644
--- a/drivers/gpu/drm/nouveau/nouveau_svm.c
+++ b/drivers/gpu/drm/nouveau/nouveau_svm.c
@@ -649,7 +649,7 @@ nouveau_svm_fault(struct nvif_notify *notify)
 		range.values = nouveau_svm_pfn_values;
 		range.pfn_shift = NVIF_VMM_PFNMAP_V0_ADDR_SHIFT;
 again:
-		ret = hmm_vma_fault(&range, true);
+		ret = hmm_vma_fault(&svmm->mirror, &range, true);
 		if (ret == 0) {
 			mutex_lock(&svmm->mutex);
 			if (!hmm_vma_range_done(&range)) {
diff --git a/include/linux/hmm.h b/include/linux/hmm.h
index cb01cf1fa3c08b..1fba6979adf460 100644
--- a/include/linux/hmm.h
+++ b/include/linux/hmm.h
@@ -496,7 +496,7 @@ static inline bool hmm_mirror_mm_is_alive(struct hmm_mirror *mirror)
  * Please see Documentation/vm/hmm.rst for how to use the range API.
  */
 int hmm_range_register(struct hmm_range *range,
-		       struct mm_struct *mm,
+		       struct hmm_mirror *mirror,
 		       unsigned long start,
 		       unsigned long end,
 		       unsigned page_shift);
@@ -532,7 +532,8 @@ static inline bool hmm_vma_range_done(struct hmm_range *range)
 }
 
 /* This is a temporary helper to avoid merge conflict between trees. */
-static inline int hmm_vma_fault(struct hmm_range *range, bool block)
+static inline int hmm_vma_fault(struct hmm_mirror *mirror,
+				struct hmm_range *range, bool block)
 {
 	long ret;
 
@@ -545,7 +546,7 @@ static inline int hmm_vma_fault(struct hmm_range *range, bool block)
 	range->default_flags = 0;
 	range->pfn_flags_mask = -1UL;
 
-	ret = hmm_range_register(range, range->vma->vm_mm,
+	ret = hmm_range_register(range, mirror,
 				 range->start, range->end,
 				 PAGE_SHIFT);
 	if (ret)
diff --git a/mm/hmm.c b/mm/hmm.c
index f6956d78e3cb25..22a97ada108b4e 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -914,13 +914,13 @@ static void hmm_pfns_clear(struct hmm_range *range,
  * Track updates to the CPU page table see include/linux/hmm.h
  */
 int hmm_range_register(struct hmm_range *range,
-		       struct mm_struct *mm,
+		       struct hmm_mirror *mirror,
 		       unsigned long start,
 		       unsigned long end,
 		       unsigned page_shift)
 {
 	unsigned long mask = ((1UL << page_shift) - 1UL);
-	struct hmm *hmm;
+	struct hmm *hmm = mirror->hmm;
 
 	range->valid = false;
 	range->hmm = NULL;
@@ -934,20 +934,15 @@ int hmm_range_register(struct hmm_range *range,
 	range->start = start;
 	range->end = end;
 
-	hmm = hmm_get_or_create(mm);
-	if (!hmm)
-		return -EFAULT;
-
 	/* Check if hmm_mm_destroy() was call. */
-	if (hmm->mm == NULL || hmm->dead) {
-		hmm_put(hmm);
+	if (hmm->mm == NULL || hmm->dead)
 		return -EFAULT;
-	}
 
 	/* Initialize range to track CPU page table updates. */
 	mutex_lock(&hmm->lock);
 
 	range->hmm = hmm;
+	kref_get(&hmm->kref);
 	list_add_rcu(&range->list, &hmm->ranges);
 
 	/*
-- 
2.22.0

