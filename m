Return-Path: <SRS0=DZuJ=WA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A52F3C19759
	for <linux-mm@archiver.kernel.org>; Sun,  4 Aug 2019 22:49:44 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5C16B2089F
	for <linux-mm@archiver.kernel.org>; Sun,  4 Aug 2019 22:49:44 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="UAVd4mr7"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5C16B2089F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 009F86B0266; Sun,  4 Aug 2019 18:49:37 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E395F6B0269; Sun,  4 Aug 2019 18:49:36 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C3CE56B026A; Sun,  4 Aug 2019 18:49:36 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 8CFD16B0266
	for <linux-mm@kvack.org>; Sun,  4 Aug 2019 18:49:36 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id 21so52194652pfu.9
        for <linux-mm@kvack.org>; Sun, 04 Aug 2019 15:49:36 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=wKnEf1dGeTf0vHOLp5WCTJvqak8NT8hcLNnzrVdQpMI=;
        b=jvEugZc15EVL/fL07XEUNllmnvmsve7hEkwsFTJaQ5Sk/LE77C3Rj3iTAacH6BS5dZ
         Kl6k3nGb3AqaL5w2GSoa8xsASlSAqVsTyjkuEZ1LsuwF+7v22MjHYezzDJm9rMm7ZzJ8
         lhIWtv4MnbXSeWA7pE6Fe+7rAGmUCTBz2dClIEMRGRYcZJ71Ec4UqJvHpZ3eNUpR7tkV
         W2J8tlP6yLGEKs7f6lGAbjO6z3PK1G68mkYjIdW7OcbCBugKkk9+LwNd5P4j9UIDu6Vl
         n93gEwc7nkSJUp0kYG2DZLWe/gJb50BUZz8gQR5YwABvnMhUgNnosOIZrw1WLtSzEvbx
         OpYg==
X-Gm-Message-State: APjAAAU+KtPRdy5BxdfdflgqrQv2EVNIXW+dPPCSehj9pLQsE0hCleOr
	loYe+KAi4zaq+vQ8F7943LK0y7Hof1QTk7DkZeFoILftpze3H5OoYBmzNdLzC6b2TdFsqSFbSj1
	ZZqIvdnzGJ6uRWLDzbET9o3hWPFIhShZem5kykyIMep6P5G4BHpiPvlgR3i5Dv865jw==
X-Received: by 2002:a17:902:7407:: with SMTP id g7mr143190095pll.214.1564958976241;
        Sun, 04 Aug 2019 15:49:36 -0700 (PDT)
X-Received: by 2002:a17:902:7407:: with SMTP id g7mr143190061pll.214.1564958975288;
        Sun, 04 Aug 2019 15:49:35 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564958975; cv=none;
        d=google.com; s=arc-20160816;
        b=kyKHpq2Dh2xtl/EDuK3kNkv++J1H3VoLE1niZRLPZQ1086YNh+ubH72gAEBScvVHJ3
         MvcSlNo82V7aKL7EYLo262Ore4jrf2Nxi5EXnTAytbsr/NGGjKHTkPCcYvSN+Scqw0C4
         zH/53t5Co3O9C1KcpDwWKqD7D+056q4rbjm8HMDfWFIQVTeGp6yguG2Up9xwXvwFrESN
         dROa5CdJNbW+5CqU1n2g1DEKgj3ZHuWGnpnEjW6Nii0CMb6gkf/aRH3uwt6iLJ221d5U
         SIOkz2boRVORVhzhA7ni6/qGh3zD6QavEgKpA/qWJ+ZQ0tB63zIHJl2T7KuXI8kMxrcJ
         VhXQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=wKnEf1dGeTf0vHOLp5WCTJvqak8NT8hcLNnzrVdQpMI=;
        b=EdjQ8Sq7vJ+e3VePnyOGAwjgFCO7a61WTMCv9D+AdGjKO+MWDSfstdCyBzHe7QALZg
         we+WgD8tOgY6QnieakA1qUVMIU2YajgXD175MoHXNj/yyn54yE34l92C1r53+ZOW+DEu
         jnzqAK9wHffS2fBbe6kbjV9XqwHRkx2mxRW29a4J3ErvKytX/e6zL1MVSle7dFitFxWx
         z5DH4BdJH4IyvTY3fN3C9cGC1QJLlQAyYcKqfvkHHW8AJsGyYYM3Ab0nsFHnOWIB0+NU
         QufyjL99E7/9PGy6P1PuC3pCPCRve15gIPXbXPtlstnQ6A8ItgAM3XL3AMjY+4ihDMDk
         EZ8A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=UAVd4mr7;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f32sor18574632pje.11.2019.08.04.15.49.35
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 04 Aug 2019 15:49:35 -0700 (PDT)
Received-SPF: pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=UAVd4mr7;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=wKnEf1dGeTf0vHOLp5WCTJvqak8NT8hcLNnzrVdQpMI=;
        b=UAVd4mr7vGvTBL1keSKDuwOUviwbBqcp6QKy80u93848ZN8eU6de8F8i32424yePdd
         zhJ1O4RduGczBUBLeccU6nytEoiOUUwRkUsjuEyue319dSQS2bud/HybqSeEP9UaizKY
         00ht31Ehoc2cMo40WzQ9rGK2yX18fybqCo7t+dG1vWpDgDbdQz/Q1YLF3bcEr/VsNC/+
         VEsECPXiobaIgfjOirKP1fhQQn2wJJKwgSQoEP5vN1KZqZSBZAcxorwveJr5kCfvgpyC
         h19lHwiz4dU7jiPcnb0kWz/BIQhyT1yRrfBg3wROHEiu6fO26e4X5u3gRUvcijrb3cqf
         EWfg==
X-Google-Smtp-Source: APXvYqzq3Lz+VjHUVJbOvV+K9KYqaCKO4VLPyE3SqnlHZP1nl3CDkSu6mPMA16qqbAvOmUhc3KYfTA==
X-Received: by 2002:a17:90a:1c1:: with SMTP id 1mr15255619pjd.72.1564958975035;
        Sun, 04 Aug 2019 15:49:35 -0700 (PDT)
Received: from blueforge.nvidia.com (searspoint.nvidia.com. [216.228.112.21])
        by smtp.gmail.com with ESMTPSA id r6sm35946836pjb.22.2019.08.04.15.49.33
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Sun, 04 Aug 2019 15:49:34 -0700 (PDT)
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
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Frank Haverkamp <haver@linux.vnet.ibm.com>,
	"Guilherme G . Piccoli" <gpiccoli@linux.vnet.ibm.com>,
	Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH v2 10/34] genwqe: convert put_page() to put_user_page*()
Date: Sun,  4 Aug 2019 15:48:51 -0700
Message-Id: <20190804224915.28669-11-jhubbard@nvidia.com>
X-Mailer: git-send-email 2.22.0
In-Reply-To: <20190804224915.28669-1-jhubbard@nvidia.com>
References: <20190804224915.28669-1-jhubbard@nvidia.com>
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

This changes the release code slightly, because each page slot in the
page_list[] array is no longer checked for NULL. However, that check
was wrong anyway, because the get_user_pages() pattern of usage here
never allowed for NULL entries within a range of pinned pages.

Acked-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org>

Cc: Frank Haverkamp <haver@linux.vnet.ibm.com>
Cc: Guilherme G. Piccoli <gpiccoli@linux.vnet.ibm.com>
Cc: Arnd Bergmann <arnd@arndb.de>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Signed-off-by: John Hubbard <jhubbard@nvidia.com>
---
 drivers/misc/genwqe/card_utils.c | 17 +++--------------
 1 file changed, 3 insertions(+), 14 deletions(-)

diff --git a/drivers/misc/genwqe/card_utils.c b/drivers/misc/genwqe/card_utils.c
index 2e1c4d2905e8..2a888f31d2c5 100644
--- a/drivers/misc/genwqe/card_utils.c
+++ b/drivers/misc/genwqe/card_utils.c
@@ -517,24 +517,13 @@ int genwqe_free_sync_sgl(struct genwqe_dev *cd, struct genwqe_sgl *sgl)
 /**
  * genwqe_free_user_pages() - Give pinned pages back
  *
- * Documentation of get_user_pages is in mm/gup.c:
- *
- * If the page is written to, set_page_dirty (or set_page_dirty_lock,
- * as appropriate) must be called after the page is finished with, and
- * before put_page is called.
+ * The pages may have been written to, so we call put_user_pages_dirty_lock(),
+ * rather than put_user_pages().
  */
 static int genwqe_free_user_pages(struct page **page_list,
 			unsigned int nr_pages, int dirty)
 {
-	unsigned int i;
-
-	for (i = 0; i < nr_pages; i++) {
-		if (page_list[i] != NULL) {
-			if (dirty)
-				set_page_dirty_lock(page_list[i]);
-			put_page(page_list[i]);
-		}
-	}
+	put_user_pages_dirty_lock(page_list, nr_pages, dirty);
 	return 0;
 }
 
-- 
2.22.0

