Return-Path: <SRS0=cVar=VV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9BC09C7618F
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 04:25:43 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 469EF22387
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 04:25:43 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="vK9pooKo"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 469EF22387
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1EADD6B0266; Wed, 24 Jul 2019 00:25:35 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 19A068E0003; Wed, 24 Jul 2019 00:25:35 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 088A58E0002; Wed, 24 Jul 2019 00:25:35 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id C4B886B0266
	for <linux-mm@kvack.org>; Wed, 24 Jul 2019 00:25:34 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id t18so17468311pgu.20
        for <linux-mm@kvack.org>; Tue, 23 Jul 2019 21:25:34 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=KSu4c8K87otioLO5Qi7krPYXd9lfPqD3DBn+R95C1d0=;
        b=TfY1Z8H3cVbtlKI1aVxGIQpqpJxpQxjRH4sC9aVSfJuuBX3rvGoboFUOJ+AKGG0Wdd
         aYMRgUu0sCq9V272IoEN/lRZJ3PdFSZUPV1nr3akq7AcWw7yE6D5ct55/HTvbCEQy7Wp
         jHdjK7QXgpPpkoPP2g3xQu+BOSu0D+MkvWtQ/stxgnYwNFPpU76HhDUWlG1WV8OxngOX
         pi5kgpEWkx2cr7Ivdm6ElYjshA2eN9uWK8dsl+PXeEUq+dPE2PzBo0ewNiwabCSxUPag
         3IysQ17DgjAo7zRhBGfxf2LfKcCThkH24v3qh7YmKemR6e3HYi4i2FinEhVl1yVdFibX
         WtbQ==
X-Gm-Message-State: APjAAAUSUKy2Z8a2UgmkkZAGdFDCoiMm6EN7KQ5C8uFNWEEyXD4sIkoa
	hL2wiGGeyWRksfaya9Ov9yNzwvmC9POwqIXHA9nHG5jxYp6xUP6xXp6mn7AgFLVkaetTc0XpKIs
	B+R08jvf7UUYrEGdwtgJE+d0/9itZ1fKk6twRLlLAL9qBKIKRi1m8gyQPt+ro3g7JFQ==
X-Received: by 2002:aa7:8189:: with SMTP id g9mr9412215pfi.143.1563942334429;
        Tue, 23 Jul 2019 21:25:34 -0700 (PDT)
X-Received: by 2002:aa7:8189:: with SMTP id g9mr9412154pfi.143.1563942333226;
        Tue, 23 Jul 2019 21:25:33 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563942333; cv=none;
        d=google.com; s=arc-20160816;
        b=JsofmDMWs3PNNK3W13YCxh3TSh3TDGEDRc87aUfHyLLMqDYMvkAiHaL60hYXJUh/OD
         HDaHtUq7TTKGvTS54+6Llg5l8107MXjmOvRVbW2ylLY3EGN6c6yG4hK87QGArsp4dlMa
         xIPc0/oC8nzTSVxB3Mrmwk1nyggepD2M8raUUeeHKwrg71t/P1N3g0QALJyy+CkjyRID
         bbnw5LVKMiR+HNIj6C2hlsaXYZcmofYhkcigP/eA+yJM6IHQsRjHJbSXWcI/Wnet5Y5V
         M3q/4YkJBE7KnDs/ANHS2/qFjMxZxbuvoq5dYsJOQa9d4m88yAb57z/PhxPwMweWPbzJ
         5lPA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=KSu4c8K87otioLO5Qi7krPYXd9lfPqD3DBn+R95C1d0=;
        b=ATWjfdJ2FIwCplIqMVRuQCkJnPhJxXAZ2hE+qMSRcg03U+sdryXVtWSV3rFQZ56xl3
         CBy4s3bq/WsPQWKsBa4IBL3+zUtP4qtXWOPr/LUmSpJPbzCG83zj4LJuFH/Q6MgIU4+J
         Zc0fUjdk+x5ablCrkCwHYcdL6dcbxAgsp4jjgMyhtAyaSsU5qkZToFoXyiej49fgHqOM
         F+AiNyLkX7jY3p/1IbA7BKT/VP7G+dGHpxQ7RbvbRh33QV+ax25LEoB6iIUlywz4K+dx
         bB6ddi8rB1WREVHhImllMOD5t8BugYae556a6yeSVtb+c4fym0sgwIPL8h9bMn6030I0
         U7oA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=vK9pooKo;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q39sor54660127pjb.7.2019.07.23.21.25.33
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 23 Jul 2019 21:25:33 -0700 (PDT)
Received-SPF: pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=vK9pooKo;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=KSu4c8K87otioLO5Qi7krPYXd9lfPqD3DBn+R95C1d0=;
        b=vK9pooKon6/mOtb3SY3teg2KToasteUZ4QJ6ySDYhY+bolLRcoJ0V7EApmOF6ww8+5
         uA5XzDj5MgYzDTTUihWBvQPudQbRA6pP0Np2RjOxAW+25aABpMhwK96bgYN77XodLsbz
         TjJmoxROhxmbYmas70jZF8oQ9Vvbm2huGu9ybaSW1Ge8TFjgZCxQqbtBWvoBjF//tpwO
         vlXCDNjVvcKyqLnAYMUPy1UP+NivsNAfedccjedMaIPaHnlBhFEHQeh7YTlVhbGBE4Ft
         9r/ZEWoW7VQgYw3mrzI+TQqbyaEji4PuYSqkM7tx8/3qaXyX/w+rFyy3S1NH5tXtFcGX
         418w==
X-Google-Smtp-Source: APXvYqxBFutwlAV+HAhH1stPSp3r5XPR8jEYK6DoryZdcZaAiPzxQPw8sNObOsdod3FjgjrDKk14TQ==
X-Received: by 2002:a17:90a:1b48:: with SMTP id q66mr82032950pjq.83.1563942332936;
        Tue, 23 Jul 2019 21:25:32 -0700 (PDT)
Received: from blueforge.nvidia.com (searspoint.nvidia.com. [216.228.112.21])
        by smtp.gmail.com with ESMTPSA id a15sm34153364pgw.3.2019.07.23.21.25.31
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Tue, 23 Jul 2019 21:25:32 -0700 (PDT)
From: john.hubbard@gmail.com
X-Google-Original-From: jhubbard@nvidia.com
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>,
	Anna Schumaker <anna.schumaker@netapp.com>,
	"David S . Miller" <davem@davemloft.net>,
	Dominique Martinet <asmadeus@codewreck.org>,
	Eric Van Hensbergen <ericvh@gmail.com>,
	Jason Gunthorpe <jgg@ziepe.ca>,
	Jason Wang <jasowang@redhat.com>,
	Jens Axboe <axboe@kernel.dk>,
	Latchesar Ionkov <lucho@ionkov.net>,
	"Michael S . Tsirkin" <mst@redhat.com>,
	Miklos Szeredi <miklos@szeredi.hu>,
	Trond Myklebust <trond.myklebust@hammerspace.com>,
	Christoph Hellwig <hch@lst.de>,
	Matthew Wilcox <willy@infradead.org>,
	linux-mm@kvack.org,
	LKML <linux-kernel@vger.kernel.org>,
	ceph-devel@vger.kernel.org,
	kvm@vger.kernel.org,
	linux-block@vger.kernel.org,
	linux-cifs@vger.kernel.org,
	linux-fsdevel@vger.kernel.org,
	linux-nfs@vger.kernel.org,
	linux-rdma@vger.kernel.org,
	netdev@vger.kernel.org,
	samba-technical@lists.samba.org,
	v9fs-developer@lists.sourceforge.net,
	virtualization@lists.linux-foundation.org,
	=?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>,
	John Hubbard <jhubbard@nvidia.com>,
	Jan Kara <jack@suse.cz>,
	Dan Williams <dan.j.williams@intel.com>,
	Johannes Thumshirn <jthumshirn@suse.de>,
	Ming Lei <ming.lei@redhat.com>,
	Dave Chinner <david@fromorbit.com>,
	Boaz Harrosh <boaz@plexistor.com>,
	Steve French <sfrench@samba.org>
Subject: [PATCH 08/12] fs/cifs: convert put_page() to put_user_page*()
Date: Tue, 23 Jul 2019 21:25:14 -0700
Message-Id: <20190724042518.14363-9-jhubbard@nvidia.com>
X-Mailer: git-send-email 2.22.0
In-Reply-To: <20190724042518.14363-1-jhubbard@nvidia.com>
References: <20190724042518.14363-1-jhubbard@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
X-NVConfidentiality: public
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Jérôme Glisse <jglisse@redhat.com>

For pages that were retained via get_user_pages*(), release those pages
via the new put_user_page*() routines, instead of via put_page().

This is part a tree-wide conversion, as described in commit fc1d8e7cca2d
("mm: introduce put_user_page*(), placeholder versions").

Signed-off-by: Jérôme Glisse <jglisse@redhat.com>
Signed-off-by: John Hubbard <jhubbard@nvidia.com>
Cc: linux-fsdevel@vger.kernel.org
Cc: linux-block@vger.kernel.org
Cc: linux-mm@kvack.org
Cc: linux-cifs@vger.kernel.org
Cc: Jan Kara <jack@suse.cz>
Cc: Dan Williams <dan.j.williams@intel.com>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>
Cc: Johannes Thumshirn <jthumshirn@suse.de>
Cc: Christoph Hellwig <hch@lst.de>
Cc: Jens Axboe <axboe@kernel.dk>
Cc: Ming Lei <ming.lei@redhat.com>
Cc: Dave Chinner <david@fromorbit.com>
Cc: Jason Gunthorpe <jgg@ziepe.ca>
Cc: Matthew Wilcox <willy@infradead.org>
Cc: Boaz Harrosh <boaz@plexistor.com>
Cc: Steve French <sfrench@samba.org>
---
 fs/cifs/cifsglob.h |  3 +++
 fs/cifs/file.c     | 22 +++++++++++++++++-----
 fs/cifs/misc.c     | 19 +++++++++++++++----
 3 files changed, 35 insertions(+), 9 deletions(-)

diff --git a/fs/cifs/cifsglob.h b/fs/cifs/cifsglob.h
index fe610e7e3670..e95cb82bfa50 100644
--- a/fs/cifs/cifsglob.h
+++ b/fs/cifs/cifsglob.h
@@ -1283,6 +1283,7 @@ struct cifs_aio_ctx {
 	 * If yes, iter is a copy of the user passed iov_iter
 	 */
 	bool			direct_io;
+	bool			from_gup;
 };
 
 struct cifs_readdata;
@@ -1317,6 +1318,7 @@ struct cifs_readdata {
 	struct cifs_credits		credits;
 	unsigned int			nr_pages;
 	struct page			**pages;
+	bool				from_gup;
 };
 
 struct cifs_writedata;
@@ -1343,6 +1345,7 @@ struct cifs_writedata {
 	struct cifs_credits		credits;
 	unsigned int			nr_pages;
 	struct page			**pages;
+	bool				from_gup;
 };
 
 /*
diff --git a/fs/cifs/file.c b/fs/cifs/file.c
index 97090693d182..84fa7e0a578f 100644
--- a/fs/cifs/file.c
+++ b/fs/cifs/file.c
@@ -2571,8 +2571,13 @@ cifs_uncached_writedata_release(struct kref *refcount)
 					struct cifs_writedata, refcount);
 
 	kref_put(&wdata->ctx->refcount, cifs_aio_ctx_release);
-	for (i = 0; i < wdata->nr_pages; i++)
-		put_page(wdata->pages[i]);
+	if (wdata->from_gup) {
+		for (i = 0; i < wdata->nr_pages; i++)
+			put_user_page(wdata->pages[i]);
+	} else {
+		for (i = 0; i < wdata->nr_pages; i++)
+			put_page(wdata->pages[i]);
+	}
 	cifs_writedata_release(refcount);
 }
 
@@ -2781,7 +2786,7 @@ cifs_write_from_iter(loff_t offset, size_t len, struct iov_iter *from,
 				break;
 			}
 
-
+			wdata->from_gup = iov_iter_get_pages_use_gup(from);
 			wdata->page_offset = start;
 			wdata->tailsz =
 				nr_pages > 1 ?
@@ -2797,6 +2802,7 @@ cifs_write_from_iter(loff_t offset, size_t len, struct iov_iter *from,
 				add_credits_and_wake_if(server, credits, 0);
 				break;
 			}
+			wdata->from_gup = false;
 
 			rc = cifs_write_allocate_pages(wdata->pages, nr_pages);
 			if (rc) {
@@ -3238,8 +3244,12 @@ cifs_uncached_readdata_release(struct kref *refcount)
 	unsigned int i;
 
 	kref_put(&rdata->ctx->refcount, cifs_aio_ctx_release);
-	for (i = 0; i < rdata->nr_pages; i++) {
-		put_page(rdata->pages[i]);
+	if (rdata->from_gup) {
+		for (i = 0; i < rdata->nr_pages; i++)
+			put_user_page(rdata->pages[i]);
+	} else {
+		for (i = 0; i < rdata->nr_pages; i++)
+			put_page(rdata->pages[i]);
 	}
 	cifs_readdata_release(refcount);
 }
@@ -3502,6 +3512,7 @@ cifs_send_async_read(loff_t offset, size_t len, struct cifsFileInfo *open_file,
 				break;
 			}
 
+			rdata->from_gup = iov_iter_get_pages_use_gup(&direct_iov);
 			npages = (cur_len + start + PAGE_SIZE-1) / PAGE_SIZE;
 			rdata->page_offset = start;
 			rdata->tailsz = npages > 1 ?
@@ -3519,6 +3530,7 @@ cifs_send_async_read(loff_t offset, size_t len, struct cifsFileInfo *open_file,
 				rc = -ENOMEM;
 				break;
 			}
+			rdata->from_gup = false;
 
 			rc = cifs_read_allocate_pages(rdata, npages);
 			if (rc) {
diff --git a/fs/cifs/misc.c b/fs/cifs/misc.c
index f383877a6511..5a04c34fea05 100644
--- a/fs/cifs/misc.c
+++ b/fs/cifs/misc.c
@@ -822,10 +822,18 @@ cifs_aio_ctx_release(struct kref *refcount)
 	if (ctx->bv) {
 		unsigned i;
 
-		for (i = 0; i < ctx->npages; i++) {
-			if (ctx->should_dirty)
-				set_page_dirty(ctx->bv[i].bv_page);
-			put_page(ctx->bv[i].bv_page);
+		if (ctx->from_gup) {
+			for (i = 0; i < ctx->npages; i++) {
+				if (ctx->should_dirty)
+					set_page_dirty(ctx->bv[i].bv_page);
+				put_user_page(ctx->bv[i].bv_page);
+			}
+		} else {
+			for (i = 0; i < ctx->npages; i++) {
+				if (ctx->should_dirty)
+					set_page_dirty(ctx->bv[i].bv_page);
+				put_page(ctx->bv[i].bv_page);
+			}
 		}
 		kvfree(ctx->bv);
 	}
@@ -881,6 +889,9 @@ setup_aio_ctx_iter(struct cifs_aio_ctx *ctx, struct iov_iter *iter, int rw)
 
 	saved_len = count;
 
+	/* This is only use by cifs_aio_ctx_release() */
+	ctx->from_gup = iov_iter_get_pages_use_gup(iter);
+
 	while (count && npages < max_pages) {
 		rc = iov_iter_get_pages(iter, pages, count, max_pages, &start);
 		if (rc < 0) {
-- 
2.22.0

