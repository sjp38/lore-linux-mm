Return-Path: <SRS0=eSYi=V6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A0778C19759
	for <linux-mm@archiver.kernel.org>; Fri,  2 Aug 2019 02:20:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5AF8A2083B
	for <linux-mm@archiver.kernel.org>; Fri,  2 Aug 2019 02:20:58 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="XcvG9Oty"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5AF8A2083B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C10216B0272; Thu,  1 Aug 2019 22:20:40 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B9A396B0273; Thu,  1 Aug 2019 22:20:40 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9A0AC6B0274; Thu,  1 Aug 2019 22:20:40 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 61E536B0272
	for <linux-mm@kvack.org>; Thu,  1 Aug 2019 22:20:40 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id a21so39529646pgv.0
        for <linux-mm@kvack.org>; Thu, 01 Aug 2019 19:20:40 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=0y5rJgolnpdx1vwnOpLTxW7O4fuw+3wJL+gU2Q7/qgc=;
        b=hQ1g0aymoOajOz/jU/Gh8ilxwoGec6FEJzBaQvsQN0V/u8WPYYNUzpxQyY69xjykZX
         cgFy54AhFPUA3TOzLPKRXlYkhugVdcDUIzFVv2SLHy4HANUD0erT6s6LHjlsECg7JF2b
         NgCCZX7n9HrqPzyyrrI+t+WkvmioRO16GukB3uHmrPukW5EpS20BaEQ9rn6YXQn4RB6Y
         krSC7wYOP5VnVkMy5joLi1Tqr+K1CpzpwWkNOM3nyVOqK4x1n5571KOpen+xgfoXt/JK
         lq0AtGtaX6laO5YaS3J8JbIN8fZ26pEilHJJAvbDT/ZNwkO6H5dcP4wR/sRIwHBRA1WI
         7SpA==
X-Gm-Message-State: APjAAAX1u3x58aeOEsa6OOTsKglypVPPGDy2JG5R7ysc+2B6r/PGSjMk
	hZpU08tDGcJ2g5Ib2CI3hLW6eNRK7EvFiy7iKlzPll1J9FnXCD0lDzae0eumgVhobJhM7g/qNni
	oKKb6O1SWFfdJbzYd7XrGPMt03r4u15cCRMfZcheOLQUUSQj86fPCwa+5Yeyli4Cv2g==
X-Received: by 2002:a17:90a:d817:: with SMTP id a23mr1858814pjv.54.1564712440051;
        Thu, 01 Aug 2019 19:20:40 -0700 (PDT)
X-Received: by 2002:a17:90a:d817:: with SMTP id a23mr1858749pjv.54.1564712439252;
        Thu, 01 Aug 2019 19:20:39 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564712439; cv=none;
        d=google.com; s=arc-20160816;
        b=eg2k1Jien1Vucd4O0Mr74JJTKdiih38gqVt8W9JmYPpoPrwgH2cS8bFWLFE8lo2TLq
         2qWouiWYBGZgoFgIKzdfwvc28Z0yTzkLrns8teAk4uxvJMirOx/9bLbk1Zw8lF75+Xfe
         qQJr0aNViuRbwSlpPigQPA2mpp8Zorjh2xUXAraECQfgxbh6/QYxChY/mBDnGOMwOM1D
         Q/NVJoM7f+P1zeOGltnYsGi993CKsz6yry+hjIrAViepKAL7cHvCHjjeKJC43LX5PtWI
         iqnS3wMGJHatZv/4f5FeMv1xvFH9TDcglT2Uw5kCPCHMACcdGVEOv3JkrfAvudJgbND+
         UAcQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=0y5rJgolnpdx1vwnOpLTxW7O4fuw+3wJL+gU2Q7/qgc=;
        b=0BqlQqOxhgrnD/ytGzAL6U+vBW/wFxBN5b9SiRw2vpToRl0jI6GmP50Ds6l+O0Szw3
         u+DLh97Ln7RS0efZg1yxSVIGxr0NGF9EHG/FQQXh2x1q98gq2YYPPnaTzdZdzUd2EnDK
         L/JEPHKRYQvokmVG6Tao9tFG85zM4UnvJiY+r+Zk0+enUvNfSgqvY+FooC/PTmDTgTHO
         ZfVNig/H5g+W1djsjpIupjC/2dHgevvhIsA9oo2a0cZSuerdQW3ykDMSP2yPZuHy5JtX
         BaOIH28VlN4XDF9v42/PtWvL8xb2UoxjjF2e2TBusgIPwWE+s1bLZhjlcvFpoj4D7M1+
         0OBQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=XcvG9Oty;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id o2sor8318925pjp.26.2019.08.01.19.20.39
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 01 Aug 2019 19:20:39 -0700 (PDT)
Received-SPF: pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=XcvG9Oty;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=0y5rJgolnpdx1vwnOpLTxW7O4fuw+3wJL+gU2Q7/qgc=;
        b=XcvG9OtyU86jk5JnQKO48GBJW89xfPHHxg+Ne0d0GJwSK2IuihtMCJFR8pabDqBzEF
         DuPSfNePU528rZ6hBUi+QFYoZILMY8tdggEmTr3mN7PzDRJ7a6OmrfV2tsrS8kf2+6HI
         Zo6kU0MY4gjn6C4vTTeXk9IHVKARwawE7INoHfJ5sfq56uo1gVj3e8g1oiz6b7OI/wgS
         KnIyWK9Z49VV7ULXr41yNDN0bWyja3EYTBz6mLtPsaZCe7aB+yHXvCTEBAOwbU3wp1bf
         uiomAHYjSX4K0Tach88phQCyk3zfRucll/enDp2U+3MmHAZ/atNajIitsMHfeEHfycq9
         ft2g==
X-Google-Smtp-Source: APXvYqwl6c8l8akPJ/a0xk+3KepmeSM3zSOQCzHQzAg87pSWv9yrqkhky05R7WwjG4AiAw2gALdPbw==
X-Received: by 2002:a17:90a:b908:: with SMTP id p8mr1903028pjr.94.1564712438974;
        Thu, 01 Aug 2019 19:20:38 -0700 (PDT)
Received: from blueforge.nvidia.com (searspoint.nvidia.com. [216.228.112.21])
        by smtp.gmail.com with ESMTPSA id u9sm38179744pgc.5.2019.08.01.19.20.37
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Thu, 01 Aug 2019 19:20:38 -0700 (PDT)
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
Subject: [PATCH 17/34] vfio: convert put_page() to put_user_page*()
Date: Thu,  1 Aug 2019 19:19:48 -0700
Message-Id: <20190802022005.5117-18-jhubbard@nvidia.com>
X-Mailer: git-send-email 2.22.0
In-Reply-To: <20190802022005.5117-1-jhubbard@nvidia.com>
References: <20190802022005.5117-1-jhubbard@nvidia.com>
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

As Christophe Hellwig put it, "set_page_dirty() is only safe if we are
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

