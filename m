Return-Path: <SRS0=U/7Q=V7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B1113C433FF
	for <linux-mm@archiver.kernel.org>; Sat,  3 Aug 2019 14:02:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 683EA21726
	for <linux-mm@archiver.kernel.org>; Sat,  3 Aug 2019 14:02:12 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="cYPLPoMt"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 683EA21726
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8A8EB6B000E; Sat,  3 Aug 2019 10:02:11 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 881626B0010; Sat,  3 Aug 2019 10:02:11 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 770B66B0266; Sat,  3 Aug 2019 10:02:11 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 4D80F6B000E
	for <linux-mm@kvack.org>; Sat,  3 Aug 2019 10:02:11 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id 199so67648131qkj.9
        for <linux-mm@kvack.org>; Sat, 03 Aug 2019 07:02:11 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:sender:from:to:cc:subject:date
         :message-id:in-reply-to:references;
        bh=D9orjRjfDP9pgbxu2ifvLHy1ukGCDC2EnGjf/tPTneg=;
        b=oTPA7Qexkeiq4pY8qRtR96BHj6gYFf+o1RKZUjbkNMVrEn7GL4lKQlQw6Csqg2bAAF
         0qP2l6dh/tZGy5SVYmZmnJO8BnDm3Uas1DzrBV5dksQIsEEF1NOSPJf1m/dtLnqgQ1tE
         vX4I97cvX2TAO6YmcOT54zDUmUlTBeaJAR3EdYZT+AmbH4Zof6o5e9/kcAvwwdmmpRxZ
         Ya9QP1Z1IhytM9GryspmNNUtGUa7QKOCUPLYrtnLRXjme6n7swS2wpwGiWR9TkWIDXji
         ldwxbkvJHsH6RksjuLLkiOnGxPYF7jg7eKomIQkVrjS2y3iplqIS2Qq8NlZ2dwpuBwuO
         7HaQ==
X-Gm-Message-State: APjAAAXONW1vOav8sbX4YNQL8/OK8nfd6FiA7N4PwY60nIM623IucGDU
	jtT305fKKCSzi2xOG8pVDUNZ7WS6wY5SDK9mm8Jbn2ATlm9ZPvcWBCAf5efyaXT43UYvuHSblqB
	oKxQ7AsT1wqu+tfi0ulCwxQzbd/kMLUY8Fps5YWV8GbPdLKgqq+B5nzDWQohPjio=
X-Received: by 2002:a0c:9891:: with SMTP id f17mr103091367qvd.49.1564840931056;
        Sat, 03 Aug 2019 07:02:11 -0700 (PDT)
X-Received: by 2002:a0c:9891:: with SMTP id f17mr103091240qvd.49.1564840929726;
        Sat, 03 Aug 2019 07:02:09 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564840929; cv=none;
        d=google.com; s=arc-20160816;
        b=Z6d14RWy6lFKRl3izdZ743qPamj/wYre0cE6Qs6SJkE/BQBoYX3QUtmnee+ntX4EO3
         A6bW47cwYVM/ut1aL44mLkkVKd7JWNFH+IwGrpU+dm6C9g8aXeUEL2hKepqaONJo/k3b
         OxCqtoLNauVi/Yf9vk+WUh5J/8TeZHgK7fm/kio9uLqPaMPrO09xa9MEqhd6KPe2tkfX
         nWeVaFHi1RFj0wkPhN6UdZublYF86olzkK69J3AnhVE739SwQPypgqFGPYspSaXzH9OD
         Uvielk0nHVrTkf6i6Wp89BNaTf8BEIfgjRu7k3d6RrqqSaPnOtn/lp0cQ/jcSE26cSpt
         d2HQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from:sender
         :dkim-signature;
        bh=D9orjRjfDP9pgbxu2ifvLHy1ukGCDC2EnGjf/tPTneg=;
        b=DGXJv4GwhhuSsigUK1Sevta3sEBkEmYsP1jLaL1CU5x2emMIWmRQFyupDiVz7HhGp6
         1uKiU20p4MHHMPrqgy0MNW6nzZNgdevNr+GYpcKM+JFLOsUBTJrxmNw6cwmhbVCiLA2G
         7CwcRQ9VlRmXbciWxU/NMjDh9McmKfhL1He5xFNYHZvKP5oY4IqJEDUjdSHyrrl5NHo0
         9KichTirT1aahkmYKcJrbG+toyVSvTTng7mBwP54FPpHfpXJkLVxHhqtqL5X+6OqTjSV
         moirVaFqCpGtfjKuLAkvDMadULd+avCjQS/cb2JVCNyT9tpxRT9wHkyE/JyEfOt39/GS
         eM8A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=cYPLPoMt;
       spf=pass (google.com: domain of htejun@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=htejun@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id c8sor103963910qtc.13.2019.08.03.07.02.09
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 03 Aug 2019 07:02:09 -0700 (PDT)
Received-SPF: pass (google.com: domain of htejun@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=cYPLPoMt;
       spf=pass (google.com: domain of htejun@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=htejun@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:from:to:cc:subject:date:message-id:in-reply-to:references;
        bh=D9orjRjfDP9pgbxu2ifvLHy1ukGCDC2EnGjf/tPTneg=;
        b=cYPLPoMt3nONdxSxEBH2DXkIoLL+c9kekNeZLQCrDU7eCfsa88/QnKRrpo2uMjGpnt
         8yr36k8tiB7bRtBvd+j8pp9LWfqhmue6miSiyxYELzY5FOgfWc3t58Snbg5xMh32u7rt
         53KM77N+vC78kPnMnfPjHh98M4fvvJg+TDfRrGu/otL4kB49lI+RXnGcUJn6ggTljn6T
         9eY1HB5jWO32Zsqkc6HchBQ3JKLeJC5KoocZEgyb7QzmFt3SrF//DO0yYyQMG7d5kpQr
         HLMxXYD/noRAOoXbQ7C1kXaOd/Rh95WKAb4novdD59drxwXue25gMwWDx4RmQHus7pYV
         t6ug==
X-Google-Smtp-Source: APXvYqzq4ivE4tAq5lf09J8xU7TbLV1kaIEe1KkD0cgBL2Q8YLk017OZlnCCIbvPhSic+6Qi+z3/Ew==
X-Received: by 2002:ac8:c45:: with SMTP id l5mr96088707qti.63.1564840929275;
        Sat, 03 Aug 2019 07:02:09 -0700 (PDT)
Received: from localhost ([2620:10d:c091:480::efce])
        by smtp.gmail.com with ESMTPSA id 18sm35265973qkh.77.2019.08.03.07.02.08
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 03 Aug 2019 07:02:08 -0700 (PDT)
From: Tejun Heo <tj@kernel.org>
To: axboe@kernel.dk,
	jack@suse.cz,
	hannes@cmpxchg.org,
	mhocko@kernel.org,
	vdavydov.dev@gmail.com
Cc: cgroups@vger.kernel.org,
	linux-mm@kvack.org,
	linux-block@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	kernel-team@fb.com,
	guro@fb.com,
	akpm@linux-foundation.org,
	Tejun Heo <tj@kernel.org>
Subject: [PATCH 3/4] writeback, memcg: Implement cgroup_writeback_by_id()
Date: Sat,  3 Aug 2019 07:01:54 -0700
Message-Id: <20190803140155.181190-4-tj@kernel.org>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190803140155.181190-1-tj@kernel.org>
References: <20190803140155.181190-1-tj@kernel.org>
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
 fs/fs-writeback.c         | 64 +++++++++++++++++++++++++++++++++++++++
 include/linux/writeback.h |  4 +++
 2 files changed, 68 insertions(+)

diff --git a/fs/fs-writeback.c b/fs/fs-writeback.c
index 6129debdc938..5c79d7acefdb 100644
--- a/fs/fs-writeback.c
+++ b/fs/fs-writeback.c
@@ -880,6 +880,70 @@ static void bdi_split_work_to_wbs(struct backing_dev_info *bdi,
 		wb_put(last_wb);
 }
 
+/**
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
+	/* and find the associated wb */
+	wb = wb_get_create(bdi, memcg_css, GFP_NOWAIT | __GFP_NOWARN);
+	if (!wb) {
+		ret = -ENOMEM;
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
 /**
  * cgroup_writeback_umount - flush inode wb switches for umount
  *
diff --git a/include/linux/writeback.h b/include/linux/writeback.h
index 8945aac31392..ad794f2a7d42 100644
--- a/include/linux/writeback.h
+++ b/include/linux/writeback.h
@@ -217,6 +217,10 @@ void wbc_attach_and_unlock_inode(struct writeback_control *wbc,
 void wbc_detach_inode(struct writeback_control *wbc);
 void wbc_account_cgroup_owner(struct writeback_control *wbc, struct page *page,
 			      size_t bytes);
+int cgroup_writeback_by_id(u64 bdi_id, int memcg_id, unsigned long nr_pages,
+			   enum wb_reason reason, struct wb_completion *done);
+int writeback_by_id(int id, unsigned long nr, enum wb_reason reason,
+		    struct wb_completion *done);
 void cgroup_writeback_umount(void);
 
 /**
-- 
2.17.1

