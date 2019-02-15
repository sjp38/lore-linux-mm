Return-Path: <SRS0=VMr4=QW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 50210C4360F
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 11:15:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1B9B021B1C
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 11:15:50 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1B9B021B1C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C2C3B8E0009; Fri, 15 Feb 2019 06:15:49 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BDB468E0001; Fri, 15 Feb 2019 06:15:49 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AF77B8E0009; Fri, 15 Feb 2019 06:15:49 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 811158E0001
	for <linux-mm@kvack.org>; Fri, 15 Feb 2019 06:15:49 -0500 (EST)
Received: by mail-qk1-f199.google.com with SMTP id a199so7661940qkb.23
        for <linux-mm@kvack.org>; Fri, 15 Feb 2019 03:15:49 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=x6GvV3QaY1/jhRE59b51JpwNHXfPk01RcQDzFCAs7ko=;
        b=AyDaS+pkfhDZGOLaaXLrtuCkpQZUZB7BQ2hiQRVzgx/XFZPu5ucfRoVj6kYJGyXeVr
         qJHALPHBntwMc0aQH2sig8pACiFZBuAUQ3ZJoIoIOgfRxqfsaRXQcfOp5kMYok5pnymG
         A+coRz8hi7m9MCFioF4Al6rWyUb8HQQfAc7FdOZnTTbOpuHLPz8/jo9pqLBHw9+2Sqst
         HazO7l7ivWlp1rtzjBsaYIqUz7ftFd4fD7Km30ljzH55n2WsodnTmoJ1nbgoUPfQEcw1
         FsfZAzhkPA3rGQSrGyR6AOj+jPJbntsuLM/o108nGCWDRIcs2GO2azJ/H2jYl8j4Z4Ls
         WrJw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ming.lei@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=ming.lei@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AHQUAuai/0/Pu4QO+lSF3kpSXnPG6l7TQDNnMJmtOUltBYqp6QbAp+CH
	GrmcKkpHnR+6ZdG020ezWIq5jWhb9gpbXfUX4ZircAQs1D+xRDrrMpVPdf8R7J5EmLvMUBWqn76
	dk3xgbNcoI+20gMupMFJBOdq6YlxTE6hkLgiZzeG49ikfm91+3std8+lhMa3dWu80sg==
X-Received: by 2002:a0c:8542:: with SMTP id n60mr6686510qva.205.1550229349274;
        Fri, 15 Feb 2019 03:15:49 -0800 (PST)
X-Google-Smtp-Source: AHgI3Ibok54kefhayiupgcs/h3O/D1oLUYMqY+N92A8RbEN0mCf1xQVUMnHBFb50CjK8y9wZHCY3
X-Received: by 2002:a0c:8542:: with SMTP id n60mr6686483qva.205.1550229348697;
        Fri, 15 Feb 2019 03:15:48 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550229348; cv=none;
        d=google.com; s=arc-20160816;
        b=f3oOT2r7pVxpJ08ugDc+3snxPu4g5asEg692qjrgoHrz4og4aBsaaFJREWDNDhlC/6
         lkfZ9Be3xGtFrfFxE/gZ3WO6EUvM33HjPMIjt5bZmxvSCGGSA/W6uOwjsoSl/FRRYaaL
         Qp4dvafeRQVMKIZZ9gM6Zvf2ldDe345imCWXs4uKV1TLyHXvoS9/285aM860ii7UZ6lr
         xNOV5D2k5E5tkogjVgl7t84JMXH1Tohz1qdBSlHwQFXOII94XoKWjahMzEnPXEXNOnJ7
         Lop+qQXt7TpY0B51MgfW81hw6d9aK3tBYzCUkdYiLVj17QvhravdclQMGDWkLNe2eXNV
         IVvw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=x6GvV3QaY1/jhRE59b51JpwNHXfPk01RcQDzFCAs7ko=;
        b=MNk3Lk840XPYhCNFVwVtUQwA5/pZmMpQQdby43AaU8vyZp0KvhzPuZgpSH6YP8dKwC
         r235YxXoMgjzQ0Mtwo0v8ks0TSK24wH//hjvfEzXC+GwYPGOabTTd2+giom83/f/UHdB
         96HVpiC6w5R0bXYUANzumsrqMi5lCrVPI+hJ/4Ty1ngiHV2ZcUYFRt725Dod6pNeIuEH
         ChAQ5FfsNrzcUfpDlecXTe/Go+OOLfD4RKZ+VfulruDOa36BbIKh/KTfE8tf+2Bfoxh8
         Wq2RpdQVcUnT7j5DEdh5JH6fK6n2RdC7a89Vz8IMRuvQ169o4jWssIxkp5ZNCFIgLyhA
         F8Lw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ming.lei@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=ming.lei@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id b5si3506704qti.147.2019.02.15.03.15.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Feb 2019 03:15:48 -0800 (PST)
Received-SPF: pass (google.com: domain of ming.lei@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ming.lei@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=ming.lei@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.phx2.redhat.com [10.5.11.13])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 9360E124564;
	Fri, 15 Feb 2019 11:15:47 +0000 (UTC)
Received: from localhost (ovpn-8-22.pek2.redhat.com [10.72.8.22])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 81D4760A9C;
	Fri, 15 Feb 2019 11:15:46 +0000 (UTC)
From: Ming Lei <ming.lei@redhat.com>
To: Jens Axboe <axboe@kernel.dk>
Cc: linux-block@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	linux-mm@kvack.org,
	Theodore Ts'o <tytso@mit.edu>,
	Omar Sandoval <osandov@fb.com>,
	Sagi Grimberg <sagi@grimberg.me>,
	Dave Chinner <dchinner@redhat.com>,
	Kent Overstreet <kent.overstreet@gmail.com>,
	Mike Snitzer <snitzer@redhat.com>,
	dm-devel@redhat.com,
	Alexander Viro <viro@zeniv.linux.org.uk>,
	linux-fsdevel@vger.kernel.org,
	linux-raid@vger.kernel.org,
	David Sterba <dsterba@suse.com>,
	linux-btrfs@vger.kernel.org,
	"Darrick J . Wong" <darrick.wong@oracle.com>,
	linux-xfs@vger.kernel.org,
	Gao Xiang <gaoxiang25@huawei.com>,
	Christoph Hellwig <hch@lst.de>,
	linux-ext4@vger.kernel.org,
	Coly Li <colyli@suse.de>,
	linux-bcache@vger.kernel.org,
	Boaz Harrosh <ooo@electrozaur.com>,
	Bob Peterson <rpeterso@redhat.com>,
	cluster-devel@redhat.com,
	Ming Lei <ming.lei@redhat.com>
Subject: [PATCH V15 07/18] block: use bio_for_each_bvec() to map sg
Date: Fri, 15 Feb 2019 19:13:13 +0800
Message-Id: <20190215111324.30129-8-ming.lei@redhat.com>
In-Reply-To: <20190215111324.30129-1-ming.lei@redhat.com>
References: <20190215111324.30129-1-ming.lei@redhat.com>
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.13
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.38]); Fri, 15 Feb 2019 11:15:47 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

It is more efficient to use bio_for_each_bvec() to map sg, meantime
we have to consider splitting multipage bvec as done in blk_bio_segment_split().

Reviewed-by: Omar Sandoval <osandov@fb.com>
Reviewed-by: Christoph Hellwig <hch@lst.de>
Signed-off-by: Ming Lei <ming.lei@redhat.com>
---
 block/blk-merge.c | 70 +++++++++++++++++++++++++++++++++++++++----------------
 1 file changed, 50 insertions(+), 20 deletions(-)

diff --git a/block/blk-merge.c b/block/blk-merge.c
index 4ef56b2d2aa5..1912499b08b7 100644
--- a/block/blk-merge.c
+++ b/block/blk-merge.c
@@ -464,6 +464,54 @@ static int blk_phys_contig_segment(struct request_queue *q, struct bio *bio,
 	return biovec_phys_mergeable(q, &end_bv, &nxt_bv);
 }
 
+static struct scatterlist *blk_next_sg(struct scatterlist **sg,
+		struct scatterlist *sglist)
+{
+	if (!*sg)
+		return sglist;
+
+	/*
+	 * If the driver previously mapped a shorter list, we could see a
+	 * termination bit prematurely unless it fully inits the sg table
+	 * on each mapping. We KNOW that there must be more entries here
+	 * or the driver would be buggy, so force clear the termination bit
+	 * to avoid doing a full sg_init_table() in drivers for each command.
+	 */
+	sg_unmark_end(*sg);
+	return sg_next(*sg);
+}
+
+static unsigned blk_bvec_map_sg(struct request_queue *q,
+		struct bio_vec *bvec, struct scatterlist *sglist,
+		struct scatterlist **sg)
+{
+	unsigned nbytes = bvec->bv_len;
+	unsigned nsegs = 0, total = 0, offset = 0;
+
+	while (nbytes > 0) {
+		unsigned seg_size;
+		struct page *pg;
+		unsigned idx;
+
+		*sg = blk_next_sg(sg, sglist);
+
+		seg_size = get_max_segment_size(q, bvec->bv_offset + total);
+		seg_size = min(nbytes, seg_size);
+
+		offset = (total + bvec->bv_offset) % PAGE_SIZE;
+		idx = (total + bvec->bv_offset) / PAGE_SIZE;
+		pg = nth_page(bvec->bv_page, idx);
+
+		sg_set_page(*sg, pg, seg_size, offset);
+
+		total += seg_size;
+		nbytes -= seg_size;
+		nsegs++;
+	}
+
+	return nsegs;
+}
+
 static inline void
 __blk_segment_map_sg(struct request_queue *q, struct bio_vec *bvec,
 		     struct scatterlist *sglist, struct bio_vec *bvprv,
@@ -481,25 +529,7 @@ __blk_segment_map_sg(struct request_queue *q, struct bio_vec *bvec,
 		(*sg)->length += nbytes;
 	} else {
 new_segment:
-		if (!*sg)
-			*sg = sglist;
-		else {
-			/*
-			 * If the driver previously mapped a shorter
-			 * list, we could see a termination bit
-			 * prematurely unless it fully inits the sg
-			 * table on each mapping. We KNOW that there
-			 * must be more entries here or the driver
-			 * would be buggy, so force clear the
-			 * termination bit to avoid doing a full
-			 * sg_init_table() in drivers for each command.
-			 */
-			sg_unmark_end(*sg);
-			*sg = sg_next(*sg);
-		}
-
-		sg_set_page(*sg, bvec->bv_page, nbytes, bvec->bv_offset);
-		(*nsegs)++;
+		(*nsegs) += blk_bvec_map_sg(q, bvec, sglist, sg);
 	}
 	*bvprv = *bvec;
 }
@@ -521,7 +551,7 @@ static int __blk_bios_map_sg(struct request_queue *q, struct bio *bio,
 	int nsegs = 0;
 
 	for_each_bio(bio)
-		bio_for_each_segment(bvec, bio, iter)
+		bio_for_each_bvec(bvec, bio, iter)
 			__blk_segment_map_sg(q, &bvec, sglist, &bvprv, sg,
 					     &nsegs);
 
-- 
2.9.5

