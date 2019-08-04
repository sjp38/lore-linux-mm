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
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1A72BC41531
	for <linux-mm@archiver.kernel.org>; Sun,  4 Aug 2019 22:50:10 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C4D9D217D9
	for <linux-mm@archiver.kernel.org>; Sun,  4 Aug 2019 22:50:09 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="DGwCGc6X"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C4D9D217D9
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B7A726B0274; Sun,  4 Aug 2019 18:49:52 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A8CAA6B0275; Sun,  4 Aug 2019 18:49:52 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 892786B0276; Sun,  4 Aug 2019 18:49:52 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 50EF26B0274
	for <linux-mm@kvack.org>; Sun,  4 Aug 2019 18:49:52 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id k20so51397808pgg.15
        for <linux-mm@kvack.org>; Sun, 04 Aug 2019 15:49:52 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=AuJQGBUMCI3UccHUazXwp/b3Q3tZUYyhW4Da3QIy1yc=;
        b=HRvpvTnkQGmuLyw8aAGQdOIBjB9pevMZQhDu57q+SrTcAmUkSNyQD3IOiMf3Y+K06n
         C8c+jth6pr4J9LElHdJmla3qDZLtVWFAiAEjty2nMFNMyVaQABePTHdkEFDYq5OyC8nP
         YFMeZ/1A9QNeqK1JyiYMDho32e9gWsD50BL+NnNDTkHWQpJ5+GwHUGu+FYQ5j/ob8TR0
         8kXXlSdY/zDt7OqsqCqpE6VI/fRHyjEeRqRnd8Tx21wskBqDYgGOtQMstop64SvpDB0W
         1XafqHMLpuiNkjXUsVEnyDnSj7sJfeIIpa6JBbG4y/hQZgdEBaOXhVLzTcG6O3maGf2/
         xqhQ==
X-Gm-Message-State: APjAAAXCc0fuJSobR1NPVP96tGCtYbURDkNK05U3cff22AEFpq06TF4Q
	oEfZ4BBropvIYyV8g/0Cp1xckE1qGyoivSIU+kO+7ZCi30UjfhxOxC0Cjaq6VUgGe0gxPQI2p8M
	bPtiDx5cfQycIDBZsTGRZh3wrRbVjN6APCxnjR/RgQksgO9yMsXYJeNyXnswAev0t3A==
X-Received: by 2002:a17:902:7b98:: with SMTP id w24mr7861973pll.163.1564958991962;
        Sun, 04 Aug 2019 15:49:51 -0700 (PDT)
X-Received: by 2002:a17:902:7b98:: with SMTP id w24mr7861952pll.163.1564958991336;
        Sun, 04 Aug 2019 15:49:51 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564958991; cv=none;
        d=google.com; s=arc-20160816;
        b=k+KhoKEw3ZGW8NRmW7EJ/UR4GQ+emW1jhcqwlDuQ1BzmwK5fHk4/lcoyWjUfogtxk5
         37GUJrwWsn1ffn+xrfRv3clfzOIoxlmAjKZi/N56PaCHfiIuO2Rk7VS85aZL08Hw6zG7
         nCXsBfBiH+7DwzJegF3pomaeKXoG7Ca8IXM5Wwm5Wt2Ee+Y/lW3ze5Se1C+DvJVSdfG5
         IDsvV/aV1cVxXPW2lsvrE6nQmW7HiBhzYJKKLwLJ4aACdDIevGcmw/ez/dq5kpJqyAzj
         0002zUwi9jV2DWV7gjCRO4P0WdN6VEY6YPo8JhVlJbnV9Ohu+E3nmYR2ruwcNNeZuWhC
         cvsg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=AuJQGBUMCI3UccHUazXwp/b3Q3tZUYyhW4Da3QIy1yc=;
        b=YEmCQNKU57R6R3/Hnjy/3QavkPjZiGYHaID43f89Rkx2O4l/BX3PKIX7DAIJA8imfX
         Lz9KG3xnQnORs789wfQ8Eceyk5tkA+3L3IVrltjqYqq0cBwAWKGRQ5barqo16Ad85fNz
         +bz7bX53AmrUkCMc1EwuxdTiocUHtSc0IwOLzHPq8pug9Lg/gj3PI6DUBsV3dzIVUFaF
         xgFFdp3SpWI2gspnkFIU6BySdbinlzQgcoP5trQD2PsBSB8S6WdoI0eRBxbxovVg3r09
         KDQtinxLqz7BSLB+e/VH9loI7cK6AOyuN1LP4K0qPg6vO91Wb2yB/mhBhb4ATmykYRYi
         y9nA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=DGwCGc6X;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id w22sor56464333pgc.73.2019.08.04.15.49.51
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 04 Aug 2019 15:49:51 -0700 (PDT)
Received-SPF: pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=DGwCGc6X;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=AuJQGBUMCI3UccHUazXwp/b3Q3tZUYyhW4Da3QIy1yc=;
        b=DGwCGc6XDVUwXaE45gbbQy6fhhO+2zHlJorg8NcW6argb8euBbhs0pQfwz4p3wmYGr
         nE4Tqc1S5TSCGn3z79bluHB8kOP9URQ6GDk8Ag8nOY+Zwx7t9ZzdbkCdvZMxHFv73WPf
         yFrTejZLylWrlE9UzmSxnSGub+p3uIuGa+QwFG1rIqaL2jFj/TWeF75UBCckNw/JWLPd
         Hk2vfaOt8Y8GmAEec78Ag4Fdx8td9DJVeEYJYZvv4nQW4t60cvCAgLcPPzOrCX7IP55D
         7nJuSqZwA2LhbQQi1IP2+3jA4kCrhPeh22tmmVy2bqH2f2tTU9mzsW8VQ8AU7oTjorNW
         HTKQ==
X-Google-Smtp-Source: APXvYqzeg0CaPIMsZN4B1HhyHGpth3yiq29pMJbbq07Rs0YdWkJ20xSQ2I1Fc/jcHmyqwiJczRrqSg==
X-Received: by 2002:a63:c006:: with SMTP id h6mr3370638pgg.290.1564958991047;
        Sun, 04 Aug 2019 15:49:51 -0700 (PDT)
Received: from blueforge.nvidia.com (searspoint.nvidia.com. [216.228.112.21])
        by smtp.gmail.com with ESMTPSA id r6sm35946836pjb.22.2019.08.04.15.49.49
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Sun, 04 Aug 2019 15:49:50 -0700 (PDT)
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
	Juergen Gross <jgross@suse.com>,
	Boris Ostrovsky <boris.ostrovsky@oracle.com>
Subject: [PATCH v2 20/34] xen: convert put_page() to put_user_page*()
Date: Sun,  4 Aug 2019 15:49:01 -0700
Message-Id: <20190804224915.28669-21-jhubbard@nvidia.com>
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

This also handles pages[i] == NULL cases, thanks to an approach
that is actually written by Juergen Gross.

Signed-off-by: Juergen Gross <jgross@suse.com>
Signed-off-by: John Hubbard <jhubbard@nvidia.com>

Cc: Boris Ostrovsky <boris.ostrovsky@oracle.com>
Cc: xen-devel@lists.xenproject.org
---

Hi Juergen,

Say, this is *exactly* what you proposed in your gup.patch, so
I've speculatively added your Signed-off-by above, but need your
approval before that's final. Let me know please...

thanks,
John Hubbard


 drivers/xen/privcmd.c | 32 +++++++++++---------------------
 1 file changed, 11 insertions(+), 21 deletions(-)

diff --git a/drivers/xen/privcmd.c b/drivers/xen/privcmd.c
index c6070e70dd73..c7d0763ca8c2 100644
--- a/drivers/xen/privcmd.c
+++ b/drivers/xen/privcmd.c
@@ -582,10 +582,11 @@ static long privcmd_ioctl_mmap_batch(
 
 static int lock_pages(
 	struct privcmd_dm_op_buf kbufs[], unsigned int num,
-	struct page *pages[], unsigned int nr_pages)
+	struct page *pages[], unsigned int *nr_pages)
 {
-	unsigned int i;
+	unsigned int i, free = *nr_pages;
 
+	*nr_pages = 0;
 	for (i = 0; i < num; i++) {
 		unsigned int requested;
 		int pinned;
@@ -593,35 +594,22 @@ static int lock_pages(
 		requested = DIV_ROUND_UP(
 			offset_in_page(kbufs[i].uptr) + kbufs[i].size,
 			PAGE_SIZE);
-		if (requested > nr_pages)
+		if (requested > free)
 			return -ENOSPC;
 
 		pinned = get_user_pages_fast(
 			(unsigned long) kbufs[i].uptr,
-			requested, FOLL_WRITE, pages);
+			requested, FOLL_WRITE, pages + *nr_pages);
 		if (pinned < 0)
 			return pinned;
 
-		nr_pages -= pinned;
-		pages += pinned;
+		free -= pinned;
+		*nr_pages += pinned;
 	}
 
 	return 0;
 }
 
-static void unlock_pages(struct page *pages[], unsigned int nr_pages)
-{
-	unsigned int i;
-
-	if (!pages)
-		return;
-
-	for (i = 0; i < nr_pages; i++) {
-		if (pages[i])
-			put_page(pages[i]);
-	}
-}
-
 static long privcmd_ioctl_dm_op(struct file *file, void __user *udata)
 {
 	struct privcmd_data *data = file->private_data;
@@ -681,11 +669,12 @@ static long privcmd_ioctl_dm_op(struct file *file, void __user *udata)
 
 	xbufs = kcalloc(kdata.num, sizeof(*xbufs), GFP_KERNEL);
 	if (!xbufs) {
+		nr_pages = 0;
 		rc = -ENOMEM;
 		goto out;
 	}
 
-	rc = lock_pages(kbufs, kdata.num, pages, nr_pages);
+	rc = lock_pages(kbufs, kdata.num, pages, &nr_pages);
 	if (rc)
 		goto out;
 
@@ -699,7 +688,8 @@ static long privcmd_ioctl_dm_op(struct file *file, void __user *udata)
 	xen_preemptible_hcall_end();
 
 out:
-	unlock_pages(pages, nr_pages);
+	if (pages)
+		put_user_pages(pages, nr_pages);
 	kfree(xbufs);
 	kfree(pages);
 	kfree(kbufs);
-- 
2.22.0

