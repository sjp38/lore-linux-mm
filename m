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
	by smtp.lore.kernel.org (Postfix) with ESMTP id B4904C433FF
	for <linux-mm@archiver.kernel.org>; Fri,  2 Aug 2019 02:20:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6D65720840
	for <linux-mm@archiver.kernel.org>; Fri,  2 Aug 2019 02:20:18 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="D/j6QNqz"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6D65720840
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BC5706B0008; Thu,  1 Aug 2019 22:20:16 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id ADA656B000C; Thu,  1 Aug 2019 22:20:16 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7CC4E6B000D; Thu,  1 Aug 2019 22:20:16 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 423726B0008
	for <linux-mm@kvack.org>; Thu,  1 Aug 2019 22:20:16 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id s21so40699981plr.2
        for <linux-mm@kvack.org>; Thu, 01 Aug 2019 19:20:16 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=qSYlns3rxzw4u/DyjG2ivKH4pSlvpz3tTvNpv+Vzl0A=;
        b=B1E+21BZKz+oc+9YS5TXR528NxUQpzEGW6O+9sgV9aQZkbaq6POo+wR9iQ1Gld0eZj
         9CbgNXo5cpJoFuGuXoj+KkLRABG4TDh/pZW2akIebntvU1naSmVA3ZSO9vY4bVJJiidz
         z0KUxiaHFGVg3LaOW7fR4oRfX+MbATfg8K0+ayZBc3Yxj1qto1OFQHRNK64FvIGzDZKA
         u7n1z3YGhcSTSOhvqbSZ2S9f6uTz/I9rnqtOkI4cdqO0GfD6iJZU0J5x5zJR7WEOASJ5
         iDrkYXshHuLyFWHqLlgs+mMDf0EUV75ejRayUOewwlu208upBeIZbElv+n7hNG2sBjiR
         zBcA==
X-Gm-Message-State: APjAAAX2lI9oOlnZeiHNQRUMVCaVVUjOGDgi3QaJKywsOme56lHk+dj2
	VLqrEqZOlf+OPLWdPyDiUgaXI8N+Ym8AP3m2DLT6KSGLr5fsQBNJ2w3LwNkMDBgD0n+QoH80fTB
	SEOVOcE/Fd/ClQZpt0rTwnuRXOzsF+vh5oGtp/t0hkxfAbLGH+x29LQAB/iOxTx5KkA==
X-Received: by 2002:a17:90a:2567:: with SMTP id j94mr1870414pje.121.1564712415953;
        Thu, 01 Aug 2019 19:20:15 -0700 (PDT)
X-Received: by 2002:a17:90a:2567:: with SMTP id j94mr1870371pje.121.1564712415213;
        Thu, 01 Aug 2019 19:20:15 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564712415; cv=none;
        d=google.com; s=arc-20160816;
        b=Nc3hSMyaTZpXeYbwpYqgZdXyjSZYWi6oPftrRJtkGpLHuyCqVrdJ8Cqb8IgU0Wwwvq
         wl+OaXYI/zzf7RQx3zSWOtersi2VZ8dlyDEFvO8w78cIlnJxGLkR5lEAORw84CPkuoKZ
         A2WymA84s4OK0wWRpm8trgwIExqwqVhj8fKzlHT9YkuxSzdUIGZEjOuvv04RKSjt/KH9
         GdmaM4pUj7eQqyabwMEm/x3erB/HaF/iVT31dzG75QrouLjutS5hyYPsE4gAaVJ6/sGz
         4w5n5DXoshP+VygehIwBaDeDCpBgdUn0hG+o+Sn/pTq+0SYQ8NaOFG1WCqN9Aks9N51N
         jsVQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=qSYlns3rxzw4u/DyjG2ivKH4pSlvpz3tTvNpv+Vzl0A=;
        b=DC9yLyGa8Y6eLVvyqzq/u0CZk7HI3Bh3bU1l0cOX+ZDpmw+r/izwXPrPwXSe+LzeBv
         CiJv2Liy417eSi6YLyKnJ7P/KAGrywN5o+SspcOwmQGf64VYfwubjqlh9NabM4SiSS16
         wsgOXk9N74zZpmUPo2sNhmPegZArqAofiqysynGBIRx/ZodQ52VvtmKFqADkNgaRF64S
         TuWvcgtZwGLnhNR7GJ8Qu1PsrM+1ZV9s2Jf9QUmeidTQz5rwaQrg2vSF09/jkUl8oK0I
         Gq4zyVSFa+cshovecTk483PZrQGLBY4zhJqXTPoS+0lD2HawSFBq9rvZhJzqU0qIJV65
         deLQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="D/j6QNqz";
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f9sor87819962plr.31.2019.08.01.19.20.15
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 01 Aug 2019 19:20:15 -0700 (PDT)
Received-SPF: pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="D/j6QNqz";
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=qSYlns3rxzw4u/DyjG2ivKH4pSlvpz3tTvNpv+Vzl0A=;
        b=D/j6QNqz3yFiYsyeUlBoZoB8rZu5aCb/yvzz1zxOgNp3ybEqPbsxe9btxXQCwNnRiL
         1hhEXFWz1aCfU0TnFrQv5Hdu1Y4yj+09YOcLKnBgch2wIeWxdJn+CuF7gDQRR3DG86LM
         Y2SvxC7kLx20v2OT7+JApu4gV5A7mbLpTUBZ6FnTk6beDldtvE5mb/QvfkkyqN0v2VG1
         9ofVdaCVs4q01OeX0AkhxB3Ji5RomrK0H8nso03ee71VFXG/bdlheK3cdFpHFmb/m/jZ
         kT41q1q3qFT4PGqgyOwuRL5tvfmQTGDLJg5egH8fWfpo6yuqqIAezax6SWmNi42S34sa
         BMyg==
X-Google-Smtp-Source: APXvYqwe/PIHkPn7ZzlBTJ10qqxG8IKfziWCo/9dNIX4ajnyTWnRigA/C0Xc1g8+MHenU4v2W+nK1Q==
X-Received: by 2002:a17:902:24b:: with SMTP id 69mr123383293plc.250.1564712414959;
        Thu, 01 Aug 2019 19:20:14 -0700 (PDT)
Received: from blueforge.nvidia.com (searspoint.nvidia.com. [216.228.112.21])
        by smtp.gmail.com with ESMTPSA id u9sm38179744pgc.5.2019.08.01.19.20.13
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Thu, 01 Aug 2019 19:20:14 -0700 (PDT)
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
	Santosh Shilimkar <santosh.shilimkar@oracle.com>,
	"David S . Miller" <davem@davemloft.net>
Subject: [PATCH 02/34] net/rds: convert put_page() to put_user_page*()
Date: Thu,  1 Aug 2019 19:19:33 -0700
Message-Id: <20190802022005.5117-3-jhubbard@nvidia.com>
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

Cc: Santosh Shilimkar <santosh.shilimkar@oracle.com>
Cc: David S. Miller <davem@davemloft.net>
Cc: netdev@vger.kernel.org
Cc: linux-rdma@vger.kernel.org
Cc: rds-devel@oss.oracle.com
Signed-off-by: John Hubbard <jhubbard@nvidia.com>
---
 net/rds/info.c    |  5 ++---
 net/rds/message.c |  2 +-
 net/rds/rdma.c    | 15 +++++++--------
 3 files changed, 10 insertions(+), 12 deletions(-)

diff --git a/net/rds/info.c b/net/rds/info.c
index 03f6fd56d237..ca6af2889adf 100644
--- a/net/rds/info.c
+++ b/net/rds/info.c
@@ -162,7 +162,6 @@ int rds_info_getsockopt(struct socket *sock, int optname, char __user *optval,
 	struct rds_info_lengths lens;
 	unsigned long nr_pages = 0;
 	unsigned long start;
-	unsigned long i;
 	rds_info_func func;
 	struct page **pages = NULL;
 	int ret;
@@ -235,8 +234,8 @@ int rds_info_getsockopt(struct socket *sock, int optname, char __user *optval,
 		ret = -EFAULT;
 
 out:
-	for (i = 0; pages && i < nr_pages; i++)
-		put_page(pages[i]);
+	if (pages)
+		put_user_pages(pages, nr_pages);
 	kfree(pages);
 
 	return ret;
diff --git a/net/rds/message.c b/net/rds/message.c
index 50f13f1d4ae0..d7b0d266c437 100644
--- a/net/rds/message.c
+++ b/net/rds/message.c
@@ -404,7 +404,7 @@ static int rds_message_zcopy_from_user(struct rds_message *rm, struct iov_iter *
 			int i;
 
 			for (i = 0; i < rm->data.op_nents; i++)
-				put_page(sg_page(&rm->data.op_sg[i]));
+				put_user_page(sg_page(&rm->data.op_sg[i]));
 			mmp = &rm->data.op_mmp_znotifier->z_mmp;
 			mm_unaccount_pinned_pages(mmp);
 			ret = -EFAULT;
diff --git a/net/rds/rdma.c b/net/rds/rdma.c
index 916f5ec373d8..6762e8696b99 100644
--- a/net/rds/rdma.c
+++ b/net/rds/rdma.c
@@ -162,8 +162,7 @@ static int rds_pin_pages(unsigned long user_addr, unsigned int nr_pages,
 				  pages);
 
 	if (ret >= 0 && ret < nr_pages) {
-		while (ret--)
-			put_page(pages[ret]);
+		put_user_pages(pages, ret);
 		ret = -EFAULT;
 	}
 
@@ -276,7 +275,7 @@ static int __rds_rdma_map(struct rds_sock *rs, struct rds_get_mr_args *args,
 
 	if (IS_ERR(trans_private)) {
 		for (i = 0 ; i < nents; i++)
-			put_page(sg_page(&sg[i]));
+			put_user_page(sg_page(&sg[i]));
 		kfree(sg);
 		ret = PTR_ERR(trans_private);
 		goto out;
@@ -464,9 +463,10 @@ void rds_rdma_free_op(struct rm_rdma_op *ro)
 		 * to local memory */
 		if (!ro->op_write) {
 			WARN_ON(!page->mapping && irqs_disabled());
-			set_page_dirty(page);
+			put_user_pages_dirty_lock(&page, 1, true);
+		} else {
+			put_user_page(page);
 		}
-		put_page(page);
 	}
 
 	kfree(ro->op_notifier);
@@ -481,8 +481,7 @@ void rds_atomic_free_op(struct rm_atomic_op *ao)
 	/* Mark page dirty if it was possibly modified, which
 	 * is the case for a RDMA_READ which copies from remote
 	 * to local memory */
-	set_page_dirty(page);
-	put_page(page);
+	put_user_pages_dirty_lock(&page, 1, true);
 
 	kfree(ao->op_notifier);
 	ao->op_notifier = NULL;
@@ -867,7 +866,7 @@ int rds_cmsg_atomic(struct rds_sock *rs, struct rds_message *rm,
 	return ret;
 err:
 	if (page)
-		put_page(page);
+		put_user_page(page);
 	rm->atomic.op_active = 0;
 	kfree(rm->atomic.op_notifier);
 
-- 
2.22.0

