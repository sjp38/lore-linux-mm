Return-Path: <SRS0=cVar=VV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6065FC761A8
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 04:25:32 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 198CB22387
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 04:25:32 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="srCEjuKd"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 198CB22387
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B61A86B000C; Wed, 24 Jul 2019 00:25:28 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AEA7B8E0003; Wed, 24 Jul 2019 00:25:28 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8A2488E0002; Wed, 24 Jul 2019 00:25:28 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 48FA76B000C
	for <linux-mm@kvack.org>; Wed, 24 Jul 2019 00:25:28 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id 91so23301063pla.7
        for <linux-mm@kvack.org>; Tue, 23 Jul 2019 21:25:28 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=VoKYI+UUiS6YcrnvVkznU7iujzeTV7cPJsbn4q5uYok=;
        b=PvUjK5GVsRtJRy+Mkl+QJAjI9FxFIdkFyQDaUyKG9mvmx2sQC+FeMAPxD2tbBstkr1
         ftMXaqrz3iJlUocbFhj6son3Z6JAaA0BVLY8CA5qTg1zx75kv0aobNuRwWaC11EoTqf7
         nyym5KQKujERbucRk1c3+h6dAClTP0WN3rJENpz0ocFRbc1+WVntZroOX47kWawXphte
         0EBW30d2g0FjVkYFukOQt89jvsluma/VIo2ju14XXHw/MRW3xJAXxatsxa1z5SBbJ/AG
         L24vRrfXsI0rXtLC52acjuMNLWf3FhuCS4teE/7bA7ojSjO5MQPSo7NtiCywlnZqKR2J
         k3cg==
X-Gm-Message-State: APjAAAW6FaApd2XTks5ew9Ljw6Uv7qugEKxEd4QUO9h/Fmn+J3B0VXXj
	663EuqX7J3xWazH5M8B85NpwdmIQKKsiIU04vrM8McTGdDli/T2KCB+feZzcQpFXeThSFRxW3Wj
	kpNKbYNJserozpadEFwNCNa9jWNlwGAgpAKGBig1uQlcYQKwOdgicobz+obMdVkM8EA==
X-Received: by 2002:aa7:989a:: with SMTP id r26mr8878913pfl.232.1563942327966;
        Tue, 23 Jul 2019 21:25:27 -0700 (PDT)
X-Received: by 2002:aa7:989a:: with SMTP id r26mr8878874pfl.232.1563942327263;
        Tue, 23 Jul 2019 21:25:27 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563942327; cv=none;
        d=google.com; s=arc-20160816;
        b=nWHATWa00K1Wq2VusiJmrDeQEyYz62PpkJs2B23W3ywoiPR4JLCYZwnbx9wnm2njiD
         XzpBB87GN01ZIdnyA7rT7vKs7fflGS/FJh1rcwniJlrVyMo373lsmkH9ZFRYmkKHOEnT
         2t0wpmmN8VTXEr6tH7gFg9PsvvjgO/w97ZBe6x7jm/cESv524w9q+UwiZG1UEz9SYVhb
         wT0Toko+pf5/fgpBIwULtT9GR2IGfZjazya/0YlNLZrvUrbAm99MU3/a8TfwoishQ0NN
         zJxl/9RwMuGKNJHADTZjzTLIOunHBDikE1FdawFJkLDPj4T08QJdgzWnsmybklkz/3vO
         SXMA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=VoKYI+UUiS6YcrnvVkznU7iujzeTV7cPJsbn4q5uYok=;
        b=snFaEPtnF7GbsnBWUMWC5xfugkVy7GM6oUoc4+cPBh+JaqrDg5KR4HkX/hgrRNso8q
         FT1IB1M1X0pPwqCS2ftB2iaSJMS+IWU0pGuCkH4vInXGMlP9JP9xmW2kh34jTap8UjII
         6l+8Ja0Hn+U7GONjEToLrfLwZCLs+6mad/+uFxNnuFrY+W+qgHmnPpOHSSQ0tvjL5EmA
         TyIb2Q9PHDIe/2+aFflqltlw/wxL1GF/ERBBAKZEmH78YvSmJSMCePEApApgQzinhOeK
         gmXDGe4EGNzdK3qfoXj/HusHG6+vQq1lhB7EMDomr4O9EB466XnjoapcBWG5aEv/Hi/Z
         tjig==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=srCEjuKd;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 75sor26174545pfv.11.2019.07.23.21.25.27
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 23 Jul 2019 21:25:27 -0700 (PDT)
Received-SPF: pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=srCEjuKd;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=VoKYI+UUiS6YcrnvVkznU7iujzeTV7cPJsbn4q5uYok=;
        b=srCEjuKdmgTtGGJA378IGBXmCqyTbsbIjMqfoeenayBrGBy5vehEwtDrFvuijZFoTd
         rScSFUBXDFgZSITel7jOkrOPuVU8F5rry3vtfpMM2D7CeG0RrJuH7hgFj+PRndl7N1gW
         deZirUtKYKLuIRRXAf1U+l262rmyF1+wQhnXfVmQ91LL1+9RzmuQ9g6DIyRbodwSmwkf
         luAgCx4Jh2U/kIoDrgk0a2bpkEIwsDMjxtnPpArcF/E8dH/PwetBRncfIHEHnvxafXic
         wOzPw8hX8ys1ZDuhUpTDpwmfZFOimd4ZZ9s54WJn7/lu6Or6c+DjhaXkLZqlThRstapF
         vwMg==
X-Google-Smtp-Source: APXvYqyK6xSNDGD+vqS3B3uhhp2vi85DZLeiUnQNXlrooXu4OGV2TbsZCsKTXuxuk/1vZZ0xEw9zNg==
X-Received: by 2002:aa7:9834:: with SMTP id q20mr9351362pfl.196.1563942326983;
        Tue, 23 Jul 2019 21:25:26 -0700 (PDT)
Received: from blueforge.nvidia.com (searspoint.nvidia.com. [216.228.112.21])
        by smtp.gmail.com with ESMTPSA id a15sm34153364pgw.3.2019.07.23.21.25.25
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Tue, 23 Jul 2019 21:25:26 -0700 (PDT)
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
	Christoph Hellwig <hch@infradead.org>,
	Minwoo Im <minwoo.im.dev@gmail.com>
Subject: [PATCH 04/12] block: bio_release_pages: convert put_page() to put_user_page*()
Date: Tue, 23 Jul 2019 21:25:10 -0700
Message-Id: <20190724042518.14363-5-jhubbard@nvidia.com>
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
via the new put_user_page*() routines, instead of via put_page() or
release_pages().

This is part a tree-wide conversion, as described in commit fc1d8e7cca2d
("mm: introduce put_user_page*(), placeholder versions").

Changes from Jérôme's original patch:
    * reworked to be compatible with recent bio_release_pages() changes,
    * refactored slightly to remove some code duplication,
    * use an approach that changes fewer bio_check_pages_dirty()
      callers.

Signed-off-by: Jérôme Glisse <jglisse@redhat.com>
Signed-off-by: John Hubbard <jhubbard@nvidia.com>
Cc: Christoph Hellwig <hch@infradead.org>
Cc: Minwoo Im <minwoo.im.dev@gmail.com>
Cc: Jens Axboe <axboe@kernel.dk>
---
 block/bio.c         | 60 ++++++++++++++++++++++++++++++++++++---------
 include/linux/bio.h |  1 +
 2 files changed, 49 insertions(+), 12 deletions(-)

diff --git a/block/bio.c b/block/bio.c
index 7675e2de509d..74f9eba2583b 100644
--- a/block/bio.c
+++ b/block/bio.c
@@ -844,7 +844,11 @@ void bio_release_pages(struct bio *bio, enum bio_rp_flags_t flags)
 	bio_for_each_segment_all(bvec, bio, iter_all) {
 		if ((flags & BIO_RP_MARK_DIRTY) && !PageCompound(bvec->bv_page))
 			set_page_dirty_lock(bvec->bv_page);
-		put_page(bvec->bv_page);
+
+		if (flags & BIO_RP_FROM_GUP)
+			put_user_page(bvec->bv_page);
+		else
+			put_page(bvec->bv_page);
 	}
 }
 
@@ -1667,28 +1671,50 @@ static void bio_dirty_fn(struct work_struct *work);
 static DECLARE_WORK(bio_dirty_work, bio_dirty_fn);
 static DEFINE_SPINLOCK(bio_dirty_lock);
 static struct bio *bio_dirty_list;
+static struct bio *bio_gup_dirty_list;
 
-/*
- * This runs in process context
- */
-static void bio_dirty_fn(struct work_struct *work)
+static void __bio_dirty_fn(struct work_struct *work,
+			   struct bio **dirty_list,
+			   enum bio_rp_flags_t flags)
 {
 	struct bio *bio, *next;
 
 	spin_lock_irq(&bio_dirty_lock);
-	next = bio_dirty_list;
-	bio_dirty_list = NULL;
+	next = *dirty_list;
+	*dirty_list = NULL;
 	spin_unlock_irq(&bio_dirty_lock);
 
 	while ((bio = next) != NULL) {
 		next = bio->bi_private;
 
-		bio_release_pages(bio, BIO_RP_MARK_DIRTY);
+		bio_release_pages(bio, BIO_RP_MARK_DIRTY | flags);
 		bio_put(bio);
 	}
 }
 
-void bio_check_pages_dirty(struct bio *bio)
+/*
+ * This runs in process context
+ */
+static void bio_dirty_fn(struct work_struct *work)
+{
+	__bio_dirty_fn(work, &bio_dirty_list,     BIO_RP_NORMAL);
+	__bio_dirty_fn(work, &bio_gup_dirty_list, BIO_RP_FROM_GUP);
+}
+
+/**
+ * __bio_check_pages_dirty() - queue up pages on a workqueue to dirty them
+ * @bio: the bio struct containing the pages we should dirty
+ * @from_gup: did the pages in the bio came from GUP (get_user_pages*())
+ *
+ * This will go over all pages in the bio, and for each non dirty page, the
+ * bio is added to a list of bio's that need to get their pages dirtied.
+ *
+ * We also need to know if the pages in the bio are coming from GUP or not,
+ * as GUPed pages need to be released via put_user_page(), instead of
+ * put_page(). Please see Documentation/vm/get_user_pages.rst for details
+ * on that.
+ */
+void __bio_check_pages_dirty(struct bio *bio, bool from_gup)
 {
 	struct bio_vec *bvec;
 	unsigned long flags;
@@ -1699,17 +1725,27 @@ void bio_check_pages_dirty(struct bio *bio)
 			goto defer;
 	}
 
-	bio_release_pages(bio, BIO_RP_NORMAL);
+	bio_release_pages(bio, from_gup ? BIO_RP_FROM_GUP : BIO_RP_NORMAL);
 	bio_put(bio);
 	return;
 defer:
 	spin_lock_irqsave(&bio_dirty_lock, flags);
-	bio->bi_private = bio_dirty_list;
-	bio_dirty_list = bio;
+	if (from_gup) {
+		bio->bi_private = bio_gup_dirty_list;
+		bio_gup_dirty_list = bio;
+	} else {
+		bio->bi_private = bio_dirty_list;
+		bio_dirty_list = bio;
+	}
 	spin_unlock_irqrestore(&bio_dirty_lock, flags);
 	schedule_work(&bio_dirty_work);
 }
 
+void bio_check_pages_dirty(struct bio *bio)
+{
+	__bio_check_pages_dirty(bio, false);
+}
+
 void update_io_ticks(struct hd_struct *part, unsigned long now)
 {
 	unsigned long stamp;
diff --git a/include/linux/bio.h b/include/linux/bio.h
index 2715e55679c1..d68a40c2c9d4 100644
--- a/include/linux/bio.h
+++ b/include/linux/bio.h
@@ -444,6 +444,7 @@ int bio_iov_iter_get_pages(struct bio *bio, struct iov_iter *iter);
 enum bio_rp_flags_t {
 	BIO_RP_NORMAL		= 0,
 	BIO_RP_MARK_DIRTY	= 1,
+	BIO_RP_FROM_GUP		= 2,
 };
 
 static inline enum bio_rp_flags_t bio_rp_dirty_flag(bool mark_dirty)
-- 
2.22.0

