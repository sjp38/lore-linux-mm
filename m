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
	by smtp.lore.kernel.org (Postfix) with ESMTP id BAFB2C32756
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 01:33:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6E1BB21743
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 01:33:57 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="o6mo9l1j"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6E1BB21743
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 39C746B000A; Tue,  6 Aug 2019 21:33:53 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2DB536B000C; Tue,  6 Aug 2019 21:33:53 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0BEFD6B000D; Tue,  6 Aug 2019 21:33:52 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id BD91F6B000A
	for <linux-mm@kvack.org>; Tue,  6 Aug 2019 21:33:52 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id a20so57185871pfn.19
        for <linux-mm@kvack.org>; Tue, 06 Aug 2019 18:33:52 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=qSYlns3rxzw4u/DyjG2ivKH4pSlvpz3tTvNpv+Vzl0A=;
        b=iLTqxs+7ohmuqJonhCIx+ULIOel5BLeWwBfIJVTws/vZSXsHaMMANfPA8GKUNmNudY
         P/H2yvbVFgQmDe2p62If0IIStweuejsqTh5oEwepo4JACGOwM+hiBA4zMImPvnaFbUt5
         pTn23So5GtXmcQSFssYdMHERSXRoakY+w4lLhTpnUQzRyATogSH5+6oqrTcVGoLYcP/P
         qtUmEKsUkHghX62pkNMNYOtx7gDqaPDwNf0eGd0yKqrSNZ5ZpxA0FQ/gemZYnyZdzs35
         QT6iBr979WMX++TuyKcxZ/dX1aUOb5CUZ1Y/arw+DEzhVIahPQTdExZHXE0atxn9RrXz
         KSFA==
X-Gm-Message-State: APjAAAVmRi64hFVnCIEMN4HTa6nzQM/1A5Q6mqBk9bEfo+shAX55shVX
	aa7oDCv5yozUWFn1PlKHRAoqanl3EQV5CyKfB6M3xG2ZfCON0e8fU9wqdDpx8kOElT0D4uh4C7t
	oTe1Coi1bnW+Omf4GiIfL0T2NxqWaubkahJMfyLegCwgpzUj8QJ1IY44J0qPoEprCmg==
X-Received: by 2002:a17:90a:9386:: with SMTP id q6mr5910093pjo.81.1565141632447;
        Tue, 06 Aug 2019 18:33:52 -0700 (PDT)
X-Received: by 2002:a17:90a:9386:: with SMTP id q6mr5910041pjo.81.1565141631237;
        Tue, 06 Aug 2019 18:33:51 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565141631; cv=none;
        d=google.com; s=arc-20160816;
        b=Z3rgSG9K37FTUhYV2JSHTWgc25eoy5UUVlhslAO/E2k8D7RAjJ5xfKIzgK0TBbBE6e
         p1YnngWs1UqbCRf/NxjUo6Ek4kHr5DEJR9P4OSsibgex6s5MGf0rBlDTNElYuCycfQdG
         2tcrgfdIpj7otr7zTyPkeOchyq5jKn1ZtYonXZSyquCgz/aFahIfodJLVrja9AcjtKva
         7hcXXHbP6LdP6IWLU24Xhkd+iws41S+m5IswJQdcUiX+6Ip4emCvUlWwS2wecZ5gPtdt
         xZ2YODAHHi3xxfWk6sQj2FRE+38L8AGOlcnmg77b6m/LqJ3coeC60cduYPUmDrJWZ+MK
         OAPw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=qSYlns3rxzw4u/DyjG2ivKH4pSlvpz3tTvNpv+Vzl0A=;
        b=hoZuzum1sgsoTdGRbcuXwLpel4sIh/SgVMpndhTajAYxSSBqypD+o7DHPwwr7exEGX
         x95LTauHttGBQHD3FvceNHGimpuUs/30t2ospoXHZp4D03bDUMozxhhWoHRMLSsEBerT
         JdWmZW9Hswm2C78Ji2jFgWR8W2lQ7HeGSf0wqIpXn55MZAJ1a2nJMjQGmnfWJda8MpeQ
         uUofhSgl4H+sIsFKR5LFNdrIzkGxQymZQf2Bs1NEFTvaW3ps6T2zo+yg6wrwYE58/XSR
         UjzDSJGP3l2rGu2yvYzfs7bMIIaiVMvb+zr6vnPcfRJGrKbuwnjTuMM6pGbFlYQRWZ0b
         ca5Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=o6mo9l1j;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f2sor105960326plj.43.2019.08.06.18.33.51
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 06 Aug 2019 18:33:51 -0700 (PDT)
Received-SPF: pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=o6mo9l1j;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=qSYlns3rxzw4u/DyjG2ivKH4pSlvpz3tTvNpv+Vzl0A=;
        b=o6mo9l1jaXg+eMDFKaNMa2tg/rxLBBKYWlvcPGnYqTLJ6EWvSYsiRghX6j47/q9rMr
         84j8e3Yul6LQ7lHeoCZqaOtV1Y4Gv5o9K0/EGcQDxw/gR6R/7t0gQcvoTpKrmjd3fG8g
         hiqPFCS5vJa1Qj7lCZhoWWL6yOXq4is+EBT1hKsXYnV7zaRUazBHi3BtdYNpYAe5CRju
         z7Dmd9KsYgKv//T3YZfMHcVWWju6h+mXkz/E9tEKZv46K/hHidNAqz7F/GmH0YADDlhE
         liPbKMnwOVxubOeskSFOatlavAAiM6+YdZhWA6YXMMK8L2WunUwM4F+csPpaCLsukLQY
         QFvw==
X-Google-Smtp-Source: APXvYqxrQ92FJ5fnVrv9nCzHJjd2+LbhtkGZjTJsccqKC5giOi/hDrrdS9iR/bRMrAzgu/a8QFmu2Q==
X-Received: by 2002:a17:902:bc83:: with SMTP id bb3mr6081534plb.56.1565141630984;
        Tue, 06 Aug 2019 18:33:50 -0700 (PDT)
Received: from blueforge.nvidia.com (searspoint.nvidia.com. [216.228.112.21])
        by smtp.gmail.com with ESMTPSA id u69sm111740800pgu.77.2019.08.06.18.33.49
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Tue, 06 Aug 2019 18:33:50 -0700 (PDT)
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
Subject: [PATCH v3 04/41] net/rds: convert put_page() to put_user_page*()
Date: Tue,  6 Aug 2019 18:33:03 -0700
Message-Id: <20190807013340.9706-5-jhubbard@nvidia.com>
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

