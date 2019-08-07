Return-Path: <SRS0=t1E5=WD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E5D7DC433FF
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 01:34:32 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9F0CA217D9
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 01:34:32 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="eL3MErGF"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9F0CA217D9
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id ACF986B0272; Tue,  6 Aug 2019 21:34:17 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9E1616B0273; Tue,  6 Aug 2019 21:34:17 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7E2D96B0274; Tue,  6 Aug 2019 21:34:17 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 40D826B0272
	for <linux-mm@kvack.org>; Tue,  6 Aug 2019 21:34:17 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id j12so49347565pll.14
        for <linux-mm@kvack.org>; Tue, 06 Aug 2019 18:34:17 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=1X33MY8P1PVcaLkCZcp6PkXiHV9wvPThIXgNE9TFbj4=;
        b=Fq7f8F/QtFJhd774K+CBwrIJvprkdPnnd1TaIvK6tK5zgYSLJEDshSGF2VR9PYXTqh
         TxGtxSu/Kh7OrV6CvvP4+LaKGWEZG5q1zuYq9P7ShB4/dcEt9N5Sq5zPOtDF+ZIEJRLo
         87Rt5onh7qUQY5dHN1A4+cOYXkTWafqd2oeDOPcxaxxs/shVjgmXAEK4TvPqNQXbWaXc
         s7AA+nb1qTXqT2/NwXEcw2UrGb8i/vZLSsNKONGUNnP9Ky2N+O0s8k8UiyYl/gwS2G2T
         T8TB4815+ItRXH59w5XXKnXB3jMuMYMUR7fZ/ooaL4hmFI7iGHoOMSSab7C0vklZzKQU
         ChOw==
X-Gm-Message-State: APjAAAVsI528Fp2u+4RUcBlS7ssWhcF9rTcsRCtW4IzR5RjtrXMAX2aw
	+AH+Z2W4j7vUFrbkSYDCPXEiQw7HOwqgtayLDeyfzHYgGvcbp8aYTCy5FJgTkVAOITfCrlShO3G
	FaarHoFdO7ehvYt9jTB0jXPl8el202id94MhKOadG+Hkbf7SHGTHFJ2BwJiVuQLlyUA==
X-Received: by 2002:a63:de4f:: with SMTP id y15mr5721359pgi.239.1565141656785;
        Tue, 06 Aug 2019 18:34:16 -0700 (PDT)
X-Received: by 2002:a63:de4f:: with SMTP id y15mr5721297pgi.239.1565141655525;
        Tue, 06 Aug 2019 18:34:15 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565141655; cv=none;
        d=google.com; s=arc-20160816;
        b=Mz+xR2USfc6O0RzPpRMjm+s3n4dfKcSrWvD+02A3TEd0T94g/ZyWzLhJnobVLuVndF
         MRXromk6+XMUbu02Yc/Wq0fV9ZVvsBXlZ8Rtcyqn9J2SBSB9YgeXycB+DMrypRw3ECL5
         yffGlXV0hVqgw6D4Zud7/w/ICPRV33OJ3s8+z6qg9SEw2M7Op4Btv4gyS7c5zImQ3yPP
         3+Vzb3oCAejIl9s9zCwl1ddhrZUyRvUQ7q6euyM+MqylHNPFF45kTfDs/Nn2b2L2QoOM
         pCSuYrZJCp/UfeVwgljXURmDRqPXjXF0rJz1e+7arX41eFUmd6njxhqTtpPfmyY1FpVJ
         RpOw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=1X33MY8P1PVcaLkCZcp6PkXiHV9wvPThIXgNE9TFbj4=;
        b=qm9j5PaLpEumlAToii/jfOsnT2GJ9N5bRjOAOFwR7EN9vNMdhEcMLp6GaMHw65lSF6
         Y9M89gcJQO12RBitpt2Bdt2RNvvB7aUr1VLZZYNcfS+5c/SVIF4UI51rt4TObAd1n8A0
         9Y3TrTlR5y2rV57M/m+1YR89wb6dlYrbwuOYEKv92TbWK82oLMs4vmWYz8pc0RNnYDxj
         uSGCv5xePYxnZ6CB7Vj6Aelfj+Nt55n+ieo4Xvz+JAT6pHQvy4GZRhurheWkRR8oF3ZK
         OKhEsf1Zuwn1iLm/qtU0tPZ8AZ02ThPagTWX7IScq9f3g2NUGtxv9zTELRozrKUZPRZ7
         CnXg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=eL3MErGF;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p187sor54848616pga.43.2019.08.06.18.34.15
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 06 Aug 2019 18:34:15 -0700 (PDT)
Received-SPF: pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=eL3MErGF;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=1X33MY8P1PVcaLkCZcp6PkXiHV9wvPThIXgNE9TFbj4=;
        b=eL3MErGFo1XqhdMwEg2Kjw8ppwk7Vahm6mgoNNA3cii/CVgkEKjt7vsL/U/CmyPRH+
         vBu50G7ybGgkp7Hokph0DkgDWhI/CbhoDAa+AbddMqWT6ISLL60rYA89HWspc4xyz4Vp
         5XWKqpmskK/zJd8DBYamJF8+Y0ROhmLz8Fdh4cz2AghIDfFUZCj9rMXq3aFWqKMWQAG2
         HgrGAFAgdTFgMvzU7LHu/FiPYMdm8mLe8AL0h5BcC9G6165T14l59ud/pmRsQYRQ9HTJ
         QDGVt3CGvwstyiOJQq9AlYZoAOTVBthJyf2RDDu2y6x+HTZ/VWBzsErS5Ba5fNi4EntP
         9Gew==
X-Google-Smtp-Source: APXvYqzI59Ma7HfX7JZrmVs+MBRFW3wzbxtnFzHUxVGy1m1ZSRzZ7m9Bk2Hb9Owa8Q1RMoC2THAX6w==
X-Received: by 2002:a63:c008:: with SMTP id h8mr5698079pgg.427.1565141655205;
        Tue, 06 Aug 2019 18:34:15 -0700 (PDT)
Received: from blueforge.nvidia.com (searspoint.nvidia.com. [216.228.112.21])
        by smtp.gmail.com with ESMTPSA id u69sm111740800pgu.77.2019.08.06.18.34.13
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Tue, 06 Aug 2019 18:34:14 -0700 (PDT)
From: john.hubbard@gmail.com
X-Google-Original-From: jhubbard@nvidia.com
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Hellwig <hch@infradead.org>,
	Dan Williams <dan.j.williams@intel.com>,
	Dave Chinner <david@fromorbit.com>,
	Dave Hansen <dave.hansen@linux.intel.com>,
	Ira Weiny <ira.weiny@intel.com>,
	Jan Kara <jack@suse.cz>,
	Jason Gunthorpe <jgg@ziepe.ca>,
	=?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>,
	LKML <linux-kernel@vger.kernel.org>,
	amd-gfx@lists.freedesktop.org,
	ceph-devel@vger.kernel.org,
	devel@driverdev.osuosl.org,
	devel@lists.orangefs.org,
	dri-devel@lists.freedesktop.org,
	intel-gfx@lists.freedesktop.org,
	kvm@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org,
	linux-block@vger.kernel.org,
	linux-crypto@vger.kernel.org,
	linux-fbdev@vger.kernel.org,
	linux-fsdevel@vger.kernel.org,
	linux-media@vger.kernel.org,
	linux-mm@kvack.org,
	linux-nfs@vger.kernel.org,
	linux-rdma@vger.kernel.org,
	linux-rpi-kernel@lists.infradead.org,
	linux-xfs@vger.kernel.org,
	netdev@vger.kernel.org,
	rds-devel@oss.oracle.com,
	sparclinux@vger.kernel.org,
	x86@kernel.org,
	xen-devel@lists.xenproject.org,
	John Hubbard <jhubbard@nvidia.com>,
	Alex Williamson <alex.williamson@redhat.com>
Subject: [PATCH v3 19/41] vfio: convert put_page() to put_user_page*()
Date: Tue,  6 Aug 2019 18:33:18 -0700
Message-Id: <20190807013340.9706-20-jhubbard@nvidia.com>
X-Mailer: git-send-email 2.22.0
In-Reply-To: <20190807013340.9706-1-jhubbard@nvidia.com>
References: <20190807013340.9706-1-jhubbard@nvidia.com>
MIME-Version: 1.0
X-NVConfidentiality: public
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: John Hubbard <jhubbard@nvidia.com>

For pages that were retained via get_user_pages*(), release those pages
via the new put_user_page*() routines, instead of via put_page() or
release_pages().

This is part a tree-wide conversion, as described in commit fc1d8e7cca2d
("mm: introduce put_user_page*(), placeholder versions").

Note that this effectively changes the code's behavior in
qp_release_pages(): it now ultimately calls set_page_dirty_lock(),
instead of set_page_dirty(). This is probably more accurate.

As Christoph Hellwig put it, "set_page_dirty() is only safe if we are
dealing with a file backed page where we have reference on the inode it
hangs off." [1]

[1] https://lore.kernel.org/r/20190723153640.GB720@lst.de

Cc: Alex Williamson <alex.williamson@redhat.com>
Cc: kvm@vger.kernel.org
Signed-off-by: John Hubbard <jhubbard@nvidia.com>
---
 drivers/vfio/vfio_iommu_type1.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/vfio/vfio_iommu_type1.c b/drivers/vfio/vfio_iommu_type1.c
index 054391f30fa8..5a5461a14299 100644
--- a/drivers/vfio/vfio_iommu_type1.c
+++ b/drivers/vfio/vfio_iommu_type1.c
@@ -320,9 +320,9 @@ static int put_pfn(unsigned long pfn, int prot)
 {
 	if (!is_invalid_reserved_pfn(pfn)) {
 		struct page *page = pfn_to_page(pfn);
-		if (prot & IOMMU_WRITE)
-			SetPageDirty(page);
-		put_page(page);
+		bool dirty = prot & IOMMU_WRITE;
+
+		put_user_pages_dirty_lock(&page, 1, dirty);
 		return 1;
 	}
 	return 0;
@@ -356,7 +356,7 @@ static int vaddr_get_pfn(struct mm_struct *mm, unsigned long vaddr,
 		 */
 		if (ret > 0 && vma_is_fsdax(vmas[0])) {
 			ret = -EOPNOTSUPP;
-			put_page(page[0]);
+			put_user_page(page[0]);
 		}
 	}
 	up_read(&mm->mmap_sem);
-- 
2.22.0

