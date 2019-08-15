Return-Path: <SRS0=30+Z=WL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 67282C3A589
	for <linux-mm@archiver.kernel.org>; Thu, 15 Aug 2019 19:59:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0F5382084D
	for <linux-mm@archiver.kernel.org>; Thu, 15 Aug 2019 19:59:06 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="ReQZ+Ab0"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0F5382084D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B7BFE6B0275; Thu, 15 Aug 2019 15:59:05 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B2D956B027A; Thu, 15 Aug 2019 15:59:05 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A43056B027C; Thu, 15 Aug 2019 15:59:05 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0081.hostedemail.com [216.40.44.81])
	by kanga.kvack.org (Postfix) with ESMTP id 844D46B0275
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 15:59:05 -0400 (EDT)
Received: from smtpin18.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id 387B32809
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 19:59:05 +0000 (UTC)
X-FDA: 75825725850.18.pets93_151557b942447
X-HE-Tag: pets93_151557b942447
X-Filterd-Recvd-Size: 5939
Received: from mail-qk1-f193.google.com (mail-qk1-f193.google.com [209.85.222.193])
	by imf27.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 19:59:04 +0000 (UTC)
Received: by mail-qk1-f193.google.com with SMTP id w18so2136367qki.0
        for <linux-mm@kvack.org>; Thu, 15 Aug 2019 12:59:04 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=LTjjxYDcINav7DiTg3r+K5uyvclxft6ApAzOA1thajw=;
        b=ReQZ+Ab0hATpZtDXOA2ejtpPxUouA+/1xRBT9pTb1ePOZTo2VSyRKjTL2j3RzOyJ7S
         mlcrNaILH3zXXtOaaBVm+e5yQG01QhwfI90xWoTHI3jXtQ8RPEbodPybOVmvjN9wSaPt
         EaJaVv1bmqhFDi+MaB4fvT5nUovo3hGXJ52wdQU56ZxArTR0gW5bs5CDYoWb8QHWBjEq
         +xWRzvOeKJ1HPiDh+Zawly8QwcsWoCzCpWbL/+Ca7PTd1evz6glff1DdWU4lNTP+/Gm6
         utFTGkkDos6KzH8N0RhsbOYj9FshB3Uth+gddwFR0l77/gvDZnCzRj2R/DXN380JqxnN
         7XWg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:date:from:to:cc:subject:message-id
         :references:mime-version:content-disposition:in-reply-to:user-agent;
        bh=LTjjxYDcINav7DiTg3r+K5uyvclxft6ApAzOA1thajw=;
        b=C1Og2ENDkkawy39iYfSaNszmjTeImpP3CWUJQTUIyrGBy7DqbdG8H0afeYondm3Mlw
         J/qLKoZQdRc1LVwYpdwzi8DhzB1hn5AUqGDTGvi3VX8c9yeuIBAQhSo3Iohr6SsD1XBS
         e6lKzAGFX5f//KqJqkskfitFFrhX/+LlozccBWJ0W7lMqwAP+SAqKdci6khRmIOMZeBv
         4a2Orj7bYTECzgU5Mp7G/8RPIMic0bEyL1cKIPIRYikOTVPXfHCIG+0qbNrx2UqYuh86
         xdF7Q3K+ufNYdy2y0m5V7oCq6zy5jye+v2AwA9U8r24HmYVTVYClvRxVzAMKmFFtUKdp
         d5Rw==
X-Gm-Message-State: APjAAAVSrho4/NehgsNFVkZAGspz9M/YZ0DQDsvq7dDKt2+bFCGgcH0y
	cRpj7oXRWVn+RMBiRnWPI+Y=
X-Google-Smtp-Source: APXvYqz/lIOxVe5nWX7K5sBLu6KzXtCB0IqgPNj3VAKGjq1GOg0HMbdZXFb4fh326h7juBrH2FnOjw==
X-Received: by 2002:a05:620a:342:: with SMTP id t2mr5109727qkm.283.1565899144144;
        Thu, 15 Aug 2019 12:59:04 -0700 (PDT)
Received: from localhost ([2620:10d:c091:500::1:25cd])
        by smtp.gmail.com with ESMTPSA id n46sm2333045qtk.14.2019.08.15.12.59.03
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 15 Aug 2019 12:59:03 -0700 (PDT)
Date: Thu, 15 Aug 2019 12:59:02 -0700
From: Tejun Heo <tj@kernel.org>
To: axboe@kernel.dk, jack@suse.cz, hannes@cmpxchg.org, mhocko@kernel.org,
	vdavydov.dev@gmail.com
Cc: cgroups@vger.kernel.org, linux-mm@kvack.org,
	linux-block@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel-team@fb.com, guro@fb.com, akpm@linux-foundation.org
Subject: [PATCH 4/5] writeback, memcg: Implement cgroup_writeback_by_id()
Message-ID: <20190815195902.GE2263813@devbig004.ftw2.facebook.com>
References: <20190815195619.GA2263813@devbig004.ftw2.facebook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190815195619.GA2263813@devbig004.ftw2.facebook.com>
User-Agent: Mutt/1.5.21 (2010-09-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Implement cgroup_writeback_by_id() which initiates cgroup writeback
from bdi and memcg IDs.  This will be used by memcg foreign inode
flushing.

Signed-off-by: Tejun Heo <tj@kernel.org>
---
 fs/fs-writeback.c         |   67 ++++++++++++++++++++++++++++++++++++++++++++++
 include/linux/writeback.h |    2 +
 2 files changed, 69 insertions(+)

--- a/fs/fs-writeback.c
+++ b/fs/fs-writeback.c
@@ -892,6 +892,73 @@ restart:
 }
 
 /**
+ * cgroup_writeback_by_id - initiate cgroup writeback from bdi and memcg IDs
+ * @bdi_id: target bdi id
+ * @memcg_id: target memcg css id
+ * @nr_pages: number of pages to write
+ * @reason: reason why some writeback work initiated
+ * @done: target wb_completion
+ *
+ * Initiate flush of the bdi_writeback identified by @bdi_id and @memcg_id
+ * with the specified parameters.
+ */
+int cgroup_writeback_by_id(u64 bdi_id, int memcg_id, unsigned long nr,
+			   enum wb_reason reason, struct wb_completion *done)
+{
+	struct backing_dev_info *bdi;
+	struct cgroup_subsys_state *memcg_css;
+	struct bdi_writeback *wb;
+	struct wb_writeback_work *work;
+	int ret;
+
+	/* lookup bdi and memcg */
+	bdi = bdi_get_by_id(bdi_id);
+	if (!bdi)
+		return -ENOENT;
+
+	rcu_read_lock();
+	memcg_css = css_from_id(memcg_id, &memory_cgrp_subsys);
+	if (memcg_css && !css_tryget(memcg_css))
+		memcg_css = NULL;
+	rcu_read_unlock();
+	if (!memcg_css) {
+		ret = -ENOENT;
+		goto out_bdi_put;
+	}
+
+	/*
+	 * And find the associated wb.  If the wb isn't there already
+	 * there's nothing to flush, don't create one.
+	 */
+	wb = wb_get_lookup(bdi, memcg_css);
+	if (!wb) {
+		ret = -ENOENT;
+		goto out_css_put;
+	}
+
+	/* issue the writeback work */
+	work = kzalloc(sizeof(*work), GFP_NOWAIT | __GFP_NOWARN);
+	if (work) {
+		work->nr_pages = nr;
+		work->sync_mode = WB_SYNC_NONE;
+		work->reason = reason;
+		work->done = done;
+		work->auto_free = 1;
+		wb_queue_work(wb, work);
+		ret = 0;
+	} else {
+		ret = -ENOMEM;
+	}
+
+	wb_put(wb);
+out_css_put:
+	css_put(memcg_css);
+out_bdi_put:
+	bdi_put(bdi);
+	return ret;
+}
+
+/**
  * cgroup_writeback_umount - flush inode wb switches for umount
  *
  * This function is called when a super_block is about to be destroyed and
--- a/include/linux/writeback.h
+++ b/include/linux/writeback.h
@@ -217,6 +217,8 @@ void wbc_attach_and_unlock_inode(struct
 void wbc_detach_inode(struct writeback_control *wbc);
 void wbc_account_cgroup_owner(struct writeback_control *wbc, struct page *page,
 			      size_t bytes);
+int cgroup_writeback_by_id(u64 bdi_id, int memcg_id, unsigned long nr_pages,
+			   enum wb_reason reason, struct wb_completion *done);
 void cgroup_writeback_umount(void);
 
 /**

