Return-Path: <SRS0=U/7Q=V7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C4F03C31E40
	for <linux-mm@archiver.kernel.org>; Sat,  3 Aug 2019 14:02:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7BE622166E
	for <linux-mm@archiver.kernel.org>; Sat,  3 Aug 2019 14:02:07 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="DJEr2Am8"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7BE622166E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1A8336B000C; Sat,  3 Aug 2019 10:02:07 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 17C296B000D; Sat,  3 Aug 2019 10:02:07 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 06A196B000E; Sat,  3 Aug 2019 10:02:06 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id D8FB86B000C
	for <linux-mm@kvack.org>; Sat,  3 Aug 2019 10:02:06 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id r58so70911256qtb.5
        for <linux-mm@kvack.org>; Sat, 03 Aug 2019 07:02:06 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:sender:from:to:cc:subject:date
         :message-id:in-reply-to:references;
        bh=JC5z+niHC2ys8Ss7xrjM0YoJZI8L5s31HXoeqm/We84=;
        b=RPKk8i+JMX2a6/aYq5nxe14Mtb7QtIWYuOp6flCPoojyL3dvRn4E/8yxhWitZ0Xsni
         D0sn1/mlio0MadDBwn6V8zLTbe7VXTNjaLb/OG3YIeJQwvGPgF/nQ+5td1eCBnn9S3H4
         1If/iz5hL0RMoWV7BybpBNovihdUrhBPb+dv3wr5GY38sA9Cblb7K8sHoDW44s4/6Kkx
         0JovAG1FIdAgpnJFeWMZLgtfW06ZPrLoJlgTXT9dN2ziGxUZ89mvKLCU+P/sK9YyJJyz
         Y64ydTdlfJSh+qMiDlbG4CiMxb1iQg9xfxA3RUsfe4ZIs3awxMtmVE9pRzzGsvsGDvyo
         fvww==
X-Gm-Message-State: APjAAAWEb5WsECVhZfkIuIIOguN90NaXT9rGogI405COR2VPna50ovoj
	DFa9B3U8WYWjL8V/1/3yEourEIccWthmlx2BspWUDLRHa7+ZFtallI6g83rCRTGC1eCp3tqM9Yl
	QBESXT9k7ieXuxT58XFFs7rDjvz+pe+tpjfn63JHPJKKU4fKscOsEixwyCir/Nig=
X-Received: by 2002:a05:620a:1456:: with SMTP id i22mr92912167qkl.170.1564840926609;
        Sat, 03 Aug 2019 07:02:06 -0700 (PDT)
X-Received: by 2002:a05:620a:1456:: with SMTP id i22mr92912027qkl.170.1564840925049;
        Sat, 03 Aug 2019 07:02:05 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564840925; cv=none;
        d=google.com; s=arc-20160816;
        b=YWxQG2t3emzrdTtqhUq1mbcCIkPLH0GhJHqPuWcIOrG4hx2Qx8MQ8qPTjRMuplOqqR
         jvcCsPJWtvrvppbKNTbhfa+SL4oQ6OAGpL7I6pY/C1W5v4hG3QA1mR+XBG6jVyHLpXYM
         b/SWqotTTks3TkT36EDfV2GnEbowEi7alUx3MgNGcJSl8il6O41Ems2NRLauog2WVTZv
         ynF1xpW2DCfzrxoj980VqOryZkVsh7hA0vMJaNe6e2TZB3VQQpK0Gs5CjZx0NTjyMtod
         PVUbIn3QvoG4I8qqpVgxmd6sca6NJbDMdZLZkKUfLHKX89xhJacKAwdUUXbpNSWgm6pW
         jM3Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from:sender
         :dkim-signature;
        bh=JC5z+niHC2ys8Ss7xrjM0YoJZI8L5s31HXoeqm/We84=;
        b=0W0eYimZnv2f1+T+HUEiAopxGL+FvZKesCV10CxmXG/gfBfRMTHnATywRuslTRUG8N
         7pXrc9NKrRDtWpHZkI6698uYAE6jm2Q0JU8uPCQp5SknaYqTQgDzJf0lRgrcD6E17Btx
         5A90ohRPGqw1KhF2FGpggZZtKVChcjnEyOtaYri/IySIxjWblDRTwJhPugvSWWH1bugA
         Dd8RBIQYbze1tnar8ehvW0mMEahlwRr++UgJCjG+ribCmIxgEos+4Av8UIR7OW0b1mLk
         zxNhuJL/U5fVna4ERHboX7u9JKqyadKiR8GhZKcAlhUekhrICNz+d0wGtIqzWshtHEYb
         75PA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=DJEr2Am8;
       spf=pass (google.com: domain of htejun@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=htejun@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id c77sor44751194qkg.24.2019.08.03.07.02.05
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 03 Aug 2019 07:02:05 -0700 (PDT)
Received-SPF: pass (google.com: domain of htejun@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=DJEr2Am8;
       spf=pass (google.com: domain of htejun@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=htejun@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:from:to:cc:subject:date:message-id:in-reply-to:references;
        bh=JC5z+niHC2ys8Ss7xrjM0YoJZI8L5s31HXoeqm/We84=;
        b=DJEr2Am8aUs/Bxqbf8Oe1iNAGSg2kMKLdQ1AG21tQFIdXSnuJzMrosYcYzf2ROze8q
         4YFxAny8N5FSx8a9UauG8ni7CRArp5pGSkfNJRKfGu8oQzlfzzVKCAEt+vO4W/RpE9Dx
         lrqdPORRoI6J1OSpz7UB36KWiMg0Xksy51goxvY6Sv2uO2Jdx2b2nzslAQekssUa/WZz
         G/HYMZPcaLxsVH3jXbGhlN5J2hG8HxvRWM6XJJHS7T2cyi89iPkOERZFo/bjgewLN7gG
         W2sjjgE9Ztufd2wWKhxBY0zmqn0yMHZ/FlnMpz0mdXg4p+E8JbMfNy+IumRdWrnn1u4E
         0Zng==
X-Google-Smtp-Source: APXvYqx6kDOVLownb5M9dvvva0Pt9lpYX5+xnbJUF0bi4bWBczYyE77hErwO6xWSYUie2OGNdCdh/w==
X-Received: by 2002:a05:620a:12c4:: with SMTP id e4mr4463975qkl.81.1564840924616;
        Sat, 03 Aug 2019 07:02:04 -0700 (PDT)
Received: from localhost ([2620:10d:c091:480::efce])
        by smtp.gmail.com with ESMTPSA id t76sm34716927qke.79.2019.08.03.07.02.03
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 03 Aug 2019 07:02:03 -0700 (PDT)
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
Subject: [PATCH 1/4] writeback: Generalize and expose wb_completion
Date: Sat,  3 Aug 2019 07:01:52 -0700
Message-Id: <20190803140155.181190-2-tj@kernel.org>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190803140155.181190-1-tj@kernel.org>
References: <20190803140155.181190-1-tj@kernel.org>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

wb_completion is used to track writeback completions.  We want to use
it from memcg side for foreign inode flushes.  This patch updates it
to remember the target waitq instead of assuming bdi->wb_waitq and
expose it outside of fs-writeback.c.

Signed-off-by: Tejun Heo <tj@kernel.org>
---
 fs/fs-writeback.c                | 47 ++++++++++----------------------
 include/linux/backing-dev-defs.h | 20 ++++++++++++++
 include/linux/backing-dev.h      |  2 ++
 3 files changed, 36 insertions(+), 33 deletions(-)

diff --git a/fs/fs-writeback.c b/fs/fs-writeback.c
index 542b02d170f8..6129debdc938 100644
--- a/fs/fs-writeback.c
+++ b/fs/fs-writeback.c
@@ -36,10 +36,6 @@
  */
 #define MIN_WRITEBACK_PAGES	(4096UL >> (PAGE_SHIFT - 10))
 
-struct wb_completion {
-	atomic_t		cnt;
-};
-
 /*
  * Passed into wb_writeback(), essentially a subset of writeback_control
  */
@@ -60,19 +56,6 @@ struct wb_writeback_work {
 	struct wb_completion *done;	/* set if the caller waits */
 };
 
-/*
- * If one wants to wait for one or more wb_writeback_works, each work's
- * ->done should be set to a wb_completion defined using the following
- * macro.  Once all work items are issued with wb_queue_work(), the caller
- * can wait for the completion of all using wb_wait_for_completion().  Work
- * items which are waited upon aren't freed automatically on completion.
- */
-#define DEFINE_WB_COMPLETION_ONSTACK(cmpl)				\
-	struct wb_completion cmpl = {					\
-		.cnt		= ATOMIC_INIT(1),			\
-	}
-
-
 /*
  * If an inode is constantly having its pages dirtied, but then the
  * updates stop dirtytime_expire_interval seconds in the past, it's
@@ -182,7 +165,7 @@ static void finish_writeback_work(struct bdi_writeback *wb,
 	if (work->auto_free)
 		kfree(work);
 	if (done && atomic_dec_and_test(&done->cnt))
-		wake_up_all(&wb->bdi->wb_waitq);
+		wake_up_all(done->waitq);
 }
 
 static void wb_queue_work(struct bdi_writeback *wb,
@@ -206,20 +189,18 @@ static void wb_queue_work(struct bdi_writeback *wb,
 
 /**
  * wb_wait_for_completion - wait for completion of bdi_writeback_works
- * @bdi: bdi work items were issued to
  * @done: target wb_completion
  *
  * Wait for one or more work items issued to @bdi with their ->done field
- * set to @done, which should have been defined with
- * DEFINE_WB_COMPLETION_ONSTACK().  This function returns after all such
- * work items are completed.  Work items which are waited upon aren't freed
+ * set to @done, which should have been initialized with
+ * DEFINE_WB_COMPLETION().  This function returns after all such work items
+ * are completed.  Work items which are waited upon aren't freed
  * automatically on completion.
  */
-static void wb_wait_for_completion(struct backing_dev_info *bdi,
-				   struct wb_completion *done)
+void wb_wait_for_completion(struct wb_completion *done)
 {
 	atomic_dec(&done->cnt);		/* put down the initial count */
-	wait_event(bdi->wb_waitq, !atomic_read(&done->cnt));
+	wait_event(*done->waitq, !atomic_read(&done->cnt));
 }
 
 #ifdef CONFIG_CGROUP_WRITEBACK
@@ -843,7 +824,7 @@ static void bdi_split_work_to_wbs(struct backing_dev_info *bdi,
 restart:
 	rcu_read_lock();
 	list_for_each_entry_continue_rcu(wb, &bdi->wb_list, bdi_node) {
-		DEFINE_WB_COMPLETION_ONSTACK(fallback_work_done);
+		DEFINE_WB_COMPLETION(fallback_work_done, bdi);
 		struct wb_writeback_work fallback_work;
 		struct wb_writeback_work *work;
 		long nr_pages;
@@ -890,7 +871,7 @@ static void bdi_split_work_to_wbs(struct backing_dev_info *bdi,
 		last_wb = wb;
 
 		rcu_read_unlock();
-		wb_wait_for_completion(bdi, &fallback_work_done);
+		wb_wait_for_completion(&fallback_work_done);
 		goto restart;
 	}
 	rcu_read_unlock();
@@ -2362,7 +2343,8 @@ static void wait_sb_inodes(struct super_block *sb)
 static void __writeback_inodes_sb_nr(struct super_block *sb, unsigned long nr,
 				     enum wb_reason reason, bool skip_if_busy)
 {
-	DEFINE_WB_COMPLETION_ONSTACK(done);
+	struct backing_dev_info *bdi = sb->s_bdi;
+	DEFINE_WB_COMPLETION(done, bdi);
 	struct wb_writeback_work work = {
 		.sb			= sb,
 		.sync_mode		= WB_SYNC_NONE,
@@ -2371,14 +2353,13 @@ static void __writeback_inodes_sb_nr(struct super_block *sb, unsigned long nr,
 		.nr_pages		= nr,
 		.reason			= reason,
 	};
-	struct backing_dev_info *bdi = sb->s_bdi;
 
 	if (!bdi_has_dirty_io(bdi) || bdi == &noop_backing_dev_info)
 		return;
 	WARN_ON(!rwsem_is_locked(&sb->s_umount));
 
 	bdi_split_work_to_wbs(sb->s_bdi, &work, skip_if_busy);
-	wb_wait_for_completion(bdi, &done);
+	wb_wait_for_completion(&done);
 }
 
 /**
@@ -2440,7 +2421,8 @@ EXPORT_SYMBOL(try_to_writeback_inodes_sb);
  */
 void sync_inodes_sb(struct super_block *sb)
 {
-	DEFINE_WB_COMPLETION_ONSTACK(done);
+	struct backing_dev_info *bdi = sb->s_bdi;
+	DEFINE_WB_COMPLETION(done, bdi);
 	struct wb_writeback_work work = {
 		.sb		= sb,
 		.sync_mode	= WB_SYNC_ALL,
@@ -2450,7 +2432,6 @@ void sync_inodes_sb(struct super_block *sb)
 		.reason		= WB_REASON_SYNC,
 		.for_sync	= 1,
 	};
-	struct backing_dev_info *bdi = sb->s_bdi;
 
 	/*
 	 * Can't skip on !bdi_has_dirty() because we should wait for !dirty
@@ -2464,7 +2445,7 @@ void sync_inodes_sb(struct super_block *sb)
 	/* protect against inode wb switch, see inode_switch_wbs_work_fn() */
 	bdi_down_write_wb_switch_rwsem(bdi);
 	bdi_split_work_to_wbs(bdi, &work, false);
-	wb_wait_for_completion(bdi, &done);
+	wb_wait_for_completion(&done);
 	bdi_up_write_wb_switch_rwsem(bdi);
 
 	wait_sb_inodes(sb);
diff --git a/include/linux/backing-dev-defs.h b/include/linux/backing-dev-defs.h
index 6a1a8a314d85..8fb740178d5d 100644
--- a/include/linux/backing-dev-defs.h
+++ b/include/linux/backing-dev-defs.h
@@ -67,6 +67,26 @@ enum wb_reason {
 	WB_REASON_MAX,
 };
 
+struct wb_completion {
+	atomic_t		cnt;
+	wait_queue_head_t	*waitq;
+};
+
+#define __WB_COMPLETION_INIT(_waitq)	\
+	(struct wb_completion){ .cnt = ATOMIC_INIT(1), .waitq = (_waitq) }
+
+/*
+ * If one wants to wait for one or more wb_writeback_works, each work's
+ * ->done should be set to a wb_completion defined using the following
+ * macro.  Once all work items are issued with wb_queue_work(), the caller
+ * can wait for the completion of all using wb_wait_for_completion().  Work
+ * items which are waited upon aren't freed automatically on completion.
+ */
+#define WB_COMPLETION_INIT(bdi)		__WB_COMPLETION_INIT(&(bdi)->wb_waitq)
+
+#define DEFINE_WB_COMPLETION(cmpl, bdi)	\
+	struct wb_completion cmpl = WB_COMPLETION_INIT(bdi)
+
 /*
  * For cgroup writeback, multiple wb's may map to the same blkcg.  Those
  * wb's can operate mostly independently but should share the congested
diff --git a/include/linux/backing-dev.h b/include/linux/backing-dev.h
index 35b31d176f74..02650b1253a2 100644
--- a/include/linux/backing-dev.h
+++ b/include/linux/backing-dev.h
@@ -44,6 +44,8 @@ void wb_start_background_writeback(struct bdi_writeback *wb);
 void wb_workfn(struct work_struct *work);
 void wb_wakeup_delayed(struct bdi_writeback *wb);
 
+void wb_wait_for_completion(struct wb_completion *done);
+
 extern spinlock_t bdi_lock;
 extern struct list_head bdi_list;
 
-- 
2.17.1

