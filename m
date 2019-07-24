Return-Path: <SRS0=cVar=VV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 26E07C76191
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 04:25:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D2997229ED
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 04:25:29 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="ebcJECgW"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D2997229ED
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7DC126B000A; Wed, 24 Jul 2019 00:25:27 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 768218E0003; Wed, 24 Jul 2019 00:25:27 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6559E8E0002; Wed, 24 Jul 2019 00:25:27 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 2A69E6B000A
	for <linux-mm@kvack.org>; Wed, 24 Jul 2019 00:25:27 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id a20so27668541pfn.19
        for <linux-mm@kvack.org>; Tue, 23 Jul 2019 21:25:27 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=KTRb5TwAvlEMgKUD4ybaWyu+OqmkL6O8558wldZQN2o=;
        b=Th/UfOWRlej9n1XOMTt0UsV1OW+iGhTov+shcEN6n562Nw6TStYV+DyTc+d66nAsa/
         2ns/GUe4kHNsaJTLesUzcoc5t/3PsFlonHIpKQKvup/7HKpO4eb8xFlxtiiYXCOD9LMN
         Wel8voe0U+X8JozWfpNVEylpk5VLHi+ZAFb4J+YDzmAqcHRlNBCdV6aif6PLiOtr+Tsl
         bvjUQG0npbzfLE826NXOLPo17CDYL6sskGtc1PahW3HVr87g7lXsxeUIOVlGJ1IqNwwe
         +EurTTpCiE2pg4l8csAV1Gt3SAuwGTdDxG30fRryObxpW71y1U27jqp3JB3b5qUklg80
         9uLg==
X-Gm-Message-State: APjAAAUNra8gSz9N1HB4ZlsrSCIouoojbVX0//ErSg+GD7ularVfLPvf
	7A2a3WRWNt8jOrzD4EIsHubcqo8g99EJVdTPW0qSaeBl/qOpCGqxHBPkSCA3eehQzzauGy39xrv
	VBhBlTiyzVQfd1XEZSaw2cLkTpgisXk/lR4ZvL2VeJVyLDyRTrpI5+5GCRBRBJg91Pw==
X-Received: by 2002:a17:90a:37ac:: with SMTP id v41mr81896940pjb.6.1563942326790;
        Tue, 23 Jul 2019 21:25:26 -0700 (PDT)
X-Received: by 2002:a17:90a:37ac:: with SMTP id v41mr81896897pjb.6.1563942326057;
        Tue, 23 Jul 2019 21:25:26 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563942326; cv=none;
        d=google.com; s=arc-20160816;
        b=kFPpcpe9C3DwCmGmTJu9ClGy/hYg13ZJaQx8AqWY0ltxCTD319MJOsKnFpl6XG/5jl
         p1TH8hVFgLMZZ8qS8gGGpTwhnnWi4d/bTgJmik9RFtFfkQHJDDscOBop6HotFunYFVAn
         mCbRvpklTFUvTCMo7fJ72frkjP3XVbWhTDrkzOG9h70/cO8rIsLeBwy+cAglqIxwHIWa
         gFFWu3R2lo3azX9roR2hWPMrBUceY4f8jVvtmFPIA7ggjl6hOzEaJ33bgHvGSLWAJ3jA
         w6J1nTGXxNA6w36gXGmxz3MSyd5JpAK2JgFzZK194e9dZAteFevOaQ7X8TIeji2836SD
         O6fQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=KTRb5TwAvlEMgKUD4ybaWyu+OqmkL6O8558wldZQN2o=;
        b=nlVbbyfTZxpj/FCe43vCnNc1gEItYffpJOnLD9MyZ2i1VP/eVKWz//AWDv7LSnmZxr
         8xUnjOF9JphEGqCiEY0B0Y4CQcDgSb1pr8jVhx8a4WkDMH85qpxNVX53FYERTiQsRx5Z
         WW5adS9mEtcIhA+qcvGR6RjhyxUmcL2GkAWj1nwibxARiD8VU3EChGSIsnQlCg4cpUaK
         rU9rghK9xH7Zz5+2eP0hTqekzIoADeJHuoWIF0JZgp2lytYGJzHQp34QlLycJy3mfusx
         0s8kkRUzFGNt2LQeV6CXUHkVDvfXBJ3tYf9BuyEe44JPoWFVGn6IRR82prIsrp2m+fB5
         FOoA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=ebcJECgW;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b84sor26256147pfb.57.2019.07.23.21.25.25
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 23 Jul 2019 21:25:26 -0700 (PDT)
Received-SPF: pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=ebcJECgW;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=KTRb5TwAvlEMgKUD4ybaWyu+OqmkL6O8558wldZQN2o=;
        b=ebcJECgWyU9zYGN2pJY78eWtcvtnox+Oa1zooAOzP6xSmTu5g5nerb6ZfvRSMWFmb+
         nprY3fdZfkPasdJ9q4KtJrJq8tRNMrlLU/iHYusPMn3+9BiXMb/qeZvJ3C/ltb4T4DOy
         ur2oHnU3+1kwTjn9nSXg+vBXMtZIrJ+7IxZcmGAs0pw/RJBl9ZFjfw+QBa7rsXW2W9lk
         0w+ANgMMW5FgsBW5Bc0ygGww1qHrY3+ToVb43K1oJqh8E1qTVYlCJnF6+no0vWLUn6Ku
         wUWcMe8XiTWbkXVO+hHw3kXkBi6lbd9CK09V0F+9Edlqf99NXHcyx09tJPd3+4Lpdei7
         xJTg==
X-Google-Smtp-Source: APXvYqzBe/J5Vy13pSVSxifZgvBoznxAqrjVmFcElFPWOR9wwqxoPED73uSDyHAUwm8NHJdocMjUeA==
X-Received: by 2002:a62:7641:: with SMTP id r62mr9177588pfc.35.1563942325690;
        Tue, 23 Jul 2019 21:25:25 -0700 (PDT)
Received: from blueforge.nvidia.com (searspoint.nvidia.com. [216.228.112.21])
        by smtp.gmail.com with ESMTPSA id a15sm34153364pgw.3.2019.07.23.21.25.24
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Tue, 23 Jul 2019 21:25:25 -0700 (PDT)
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
	John Hubbard <jhubbard@nvidia.com>,
	Christoph Hellwig <hch@infradead.org>,
	=?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>,
	Minwoo Im <minwoo.im.dev@gmail.com>
Subject: [PATCH 03/12] block: bio_release_pages: use flags arg instead of bool
Date: Tue, 23 Jul 2019 21:25:09 -0700
Message-Id: <20190724042518.14363-4-jhubbard@nvidia.com>
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

From: John Hubbard <jhubbard@nvidia.com>

In commit d241a95f3514 ("block: optionally mark pages dirty in
bio_release_pages"), new "bool mark_dirty" argument was added to
bio_release_pages.

In upcoming work, another bool argument (to indicate that the pages came
from get_user_pages) is going to be added. That's one bool too many,
because it's not desirable have calls of the form:

    foo(true, false, true, etc);

In order to prepare for that, change the argument from a bool, to a
typesafe (enum-based) flags argument.

Cc: Christoph Hellwig <hch@infradead.org>
Cc: Jérôme Glisse <jglisse@redhat.com>
Cc: Minwoo Im <minwoo.im.dev@gmail.com>
Cc: Jens Axboe <axboe@kernel.dk>
Signed-off-by: John Hubbard <jhubbard@nvidia.com>
---
 block/bio.c         | 12 ++++++------
 fs/block_dev.c      |  4 ++--
 fs/direct-io.c      |  2 +-
 include/linux/bio.h | 13 ++++++++++++-
 4 files changed, 21 insertions(+), 10 deletions(-)

diff --git a/block/bio.c b/block/bio.c
index 299a0e7651ec..7675e2de509d 100644
--- a/block/bio.c
+++ b/block/bio.c
@@ -833,7 +833,7 @@ int bio_add_page(struct bio *bio, struct page *page,
 }
 EXPORT_SYMBOL(bio_add_page);
 
-void bio_release_pages(struct bio *bio, bool mark_dirty)
+void bio_release_pages(struct bio *bio, enum bio_rp_flags_t flags)
 {
 	struct bvec_iter_all iter_all;
 	struct bio_vec *bvec;
@@ -842,7 +842,7 @@ void bio_release_pages(struct bio *bio, bool mark_dirty)
 		return;
 
 	bio_for_each_segment_all(bvec, bio, iter_all) {
-		if (mark_dirty && !PageCompound(bvec->bv_page))
+		if ((flags & BIO_RP_MARK_DIRTY) && !PageCompound(bvec->bv_page))
 			set_page_dirty_lock(bvec->bv_page);
 		put_page(bvec->bv_page);
 	}
@@ -1421,7 +1421,7 @@ struct bio *bio_map_user_iov(struct request_queue *q,
 	return bio;
 
  out_unmap:
-	bio_release_pages(bio, false);
+	bio_release_pages(bio, BIO_RP_NORMAL);
 	bio_put(bio);
 	return ERR_PTR(ret);
 }
@@ -1437,7 +1437,7 @@ struct bio *bio_map_user_iov(struct request_queue *q,
  */
 void bio_unmap_user(struct bio *bio)
 {
-	bio_release_pages(bio, bio_data_dir(bio) == READ);
+	bio_release_pages(bio, bio_rp_dirty_flag(bio_data_dir(bio) == READ));
 	bio_put(bio);
 	bio_put(bio);
 }
@@ -1683,7 +1683,7 @@ static void bio_dirty_fn(struct work_struct *work)
 	while ((bio = next) != NULL) {
 		next = bio->bi_private;
 
-		bio_release_pages(bio, true);
+		bio_release_pages(bio, BIO_RP_MARK_DIRTY);
 		bio_put(bio);
 	}
 }
@@ -1699,7 +1699,7 @@ void bio_check_pages_dirty(struct bio *bio)
 			goto defer;
 	}
 
-	bio_release_pages(bio, false);
+	bio_release_pages(bio, BIO_RP_NORMAL);
 	bio_put(bio);
 	return;
 defer:
diff --git a/fs/block_dev.c b/fs/block_dev.c
index 4707dfff991b..9fe6616f8788 100644
--- a/fs/block_dev.c
+++ b/fs/block_dev.c
@@ -259,7 +259,7 @@ __blkdev_direct_IO_simple(struct kiocb *iocb, struct iov_iter *iter,
 	}
 	__set_current_state(TASK_RUNNING);
 
-	bio_release_pages(&bio, should_dirty);
+	bio_release_pages(&bio, bio_rp_dirty_flag(should_dirty));
 	if (unlikely(bio.bi_status))
 		ret = blk_status_to_errno(bio.bi_status);
 
@@ -329,7 +329,7 @@ static void blkdev_bio_end_io(struct bio *bio)
 	if (should_dirty) {
 		bio_check_pages_dirty(bio);
 	} else {
-		bio_release_pages(bio, false);
+		bio_release_pages(bio, BIO_RP_NORMAL);
 		bio_put(bio);
 	}
 }
diff --git a/fs/direct-io.c b/fs/direct-io.c
index ae196784f487..423ef431ddda 100644
--- a/fs/direct-io.c
+++ b/fs/direct-io.c
@@ -551,7 +551,7 @@ static blk_status_t dio_bio_complete(struct dio *dio, struct bio *bio)
 	if (dio->is_async && should_dirty) {
 		bio_check_pages_dirty(bio);	/* transfers ownership */
 	} else {
-		bio_release_pages(bio, should_dirty);
+		bio_release_pages(bio, bio_rp_dirty_flag(should_dirty));
 		bio_put(bio);
 	}
 	return err;
diff --git a/include/linux/bio.h b/include/linux/bio.h
index 3cdb84cdc488..2715e55679c1 100644
--- a/include/linux/bio.h
+++ b/include/linux/bio.h
@@ -440,7 +440,18 @@ bool __bio_try_merge_page(struct bio *bio, struct page *page,
 void __bio_add_page(struct bio *bio, struct page *page,
 		unsigned int len, unsigned int off);
 int bio_iov_iter_get_pages(struct bio *bio, struct iov_iter *iter);
-void bio_release_pages(struct bio *bio, bool mark_dirty);
+
+enum bio_rp_flags_t {
+	BIO_RP_NORMAL		= 0,
+	BIO_RP_MARK_DIRTY	= 1,
+};
+
+static inline enum bio_rp_flags_t bio_rp_dirty_flag(bool mark_dirty)
+{
+	return mark_dirty ? BIO_RP_MARK_DIRTY : BIO_RP_NORMAL;
+}
+
+void bio_release_pages(struct bio *bio, enum bio_rp_flags_t flags);
 struct rq_map_data;
 extern struct bio *bio_map_user_iov(struct request_queue *,
 				    struct iov_iter *, gfp_t);
-- 
2.22.0

