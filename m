Return-Path: <SRS0=K2Kt=QQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.4 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_MUTT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 57C58C282C4
	for <linux-mm@archiver.kernel.org>; Sat,  9 Feb 2019 14:07:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 058F02084D
	for <linux-mm@archiver.kernel.org>; Sat,  9 Feb 2019 14:07:54 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="Jptnm/0T"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 058F02084D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9830F8E00CB; Sat,  9 Feb 2019 09:07:54 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 933008E00C5; Sat,  9 Feb 2019 09:07:54 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 820DC8E00CB; Sat,  9 Feb 2019 09:07:54 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f70.google.com (mail-wm1-f70.google.com [209.85.128.70])
	by kanga.kvack.org (Postfix) with ESMTP id 2C0CD8E00C5
	for <linux-mm@kvack.org>; Sat,  9 Feb 2019 09:07:54 -0500 (EST)
Received: by mail-wm1-f70.google.com with SMTP id v25so3084445wml.3
        for <linux-mm@kvack.org>; Sat, 09 Feb 2019 06:07:54 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:mime-version:content-disposition:user-agent;
        bh=qhFJHI0MUpB/qkZtdC4zNEo5CgNcks1YjBBXggGnxos=;
        b=G0UG49nWXLOlB1EGakPklrzRbGZQnHBdv7zzIzbzBrcNGfVY0bnHeFqc24AVrQVY01
         h6U6inw6z/E02CYzwRNT3hU5rVt94QB4bSZ3DHEI+ON+iQxfedZaj2uwa4eR9zOEU428
         jTD97Y4ibWcdsTA2evGizK5NLGOJSFGoiw+Kj158JCLwPcafRURktgnYpQA5A4jF8BvL
         9wUT6l/qzfRXNzO41J46Obl+J9HxMHl1UqRtqiHrEJTWOTu/CtRsn47EMmlGHVKtrvJB
         hHse7Wav69WA7pKKDmxJImVFENAMm8GVI+cUYI5BLC9+D76pYjhdm8xlgn9ZRqsrOSfd
         Wcfg==
X-Gm-Message-State: AHQUAuYA9wUbBoBpo8DEwnCg6IYlkwiv3QgSiEQg6fi3hwmWj8zVrs/A
	mmyTJ7ieFw1kczVGVmomh+cQWNo89ClAzmeZeyJw5Ik+eR1o8eBcz50uu4o8fArI1PiicTCeISx
	HuCbsoSMhrzy4uk+4f6S0KCv+sytgZj8ZBaLa74bzA2d0+dFyk4ELE5GxFG3kFuY3IecIzPBJBy
	ml4qPZNTzwcr2sIrR0q/oK6dAFW023O15Nkf0/Ol9mebED4paGpmuiZG2L1o0vDnLjbonBmnpFb
	vBvquezwvERo657c32aDvEAUT6nAMIEQcWlQUdspGt8AhXihOUncFfq34pxbjWC++w4eE3aBHdC
	xGeh+PLd5f2zto9tT9OV5pAEYOqhkIkWRIUIlCjjlsXWnDDXBhz+0ILi5sNe/hPXr2mJN1ex3nE
	n
X-Received: by 2002:a1c:7601:: with SMTP id r1mr2790990wmc.123.1549721273678;
        Sat, 09 Feb 2019 06:07:53 -0800 (PST)
X-Received: by 2002:a1c:7601:: with SMTP id r1mr2790954wmc.123.1549721272406;
        Sat, 09 Feb 2019 06:07:52 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549721272; cv=none;
        d=google.com; s=arc-20160816;
        b=X7ceJPyNnoqX+2TeosE6wNVUiDytnDGM2N0CcuCtEFiAqJK3Vfg6PlQC2cZKHQB4M6
         uBm5ao37+h1Cu4dAxtboxfqJe6Q2p4g6xlfecwBgyLrME44BqNqZfmsTSnbsEoY/mAeE
         JwIKC9DvU0ppaxMBuJMnJO/zyYmJCrv+gkEUODx26oAV3k8dDwRMERei0lHjPm8CPsOC
         kZuub4LRBxPcnKUgtffCh/Hp73P8mSRP/xVDIeQGU7w6oTYZOdrIBGUm1JWp1SbpSs7K
         5Wqf2AgYCYD34uVICWupqg4lxVDMSoSGKIISEH11e7zTl7JNnyu3ioBnXbXTGG3z3mHn
         SwdQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:content-disposition:mime-version:message-id:subject:cc
         :to:from:date:dkim-signature;
        bh=qhFJHI0MUpB/qkZtdC4zNEo5CgNcks1YjBBXggGnxos=;
        b=r2fPszXfR/H8mLDVPs0v8qbyyf0LR/JqmcACr2D2Busng2iv0SByP2G+5qbKRP5qHo
         SFzp9JYgqeSMlH4sURedWjamdo8d4BoYwlBtUYSJxWlvo4q9BKsc9uGBW3UGxjStCV76
         OBLyNyyfYxlqfbhCwj1xg/e0kfOD7XuCH9LUK770Z7pon2SKftsdZdrjxKtZ3YYur+k1
         RopkJLCz479JgeB8uLPY7eC6iluLbZpOLjFHYEBdrJM9XonztyuZtu+s6vV8WWBFy2yC
         jKGZMgsvFfA+7I5vZxU4eMsbg8tNqBn1DYgkxyxjtThSmvKAZcq56GmKYUKXZo5+dStf
         xXug==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="Jptnm/0T";
       spf=pass (google.com: domain of righi.andrea@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=righi.andrea@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 93sor3192499wrb.13.2019.02.09.06.07.52
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 09 Feb 2019 06:07:52 -0800 (PST)
Received-SPF: pass (google.com: domain of righi.andrea@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="Jptnm/0T";
       spf=pass (google.com: domain of righi.andrea@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=righi.andrea@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=date:from:to:cc:subject:message-id:mime-version:content-disposition
         :user-agent;
        bh=qhFJHI0MUpB/qkZtdC4zNEo5CgNcks1YjBBXggGnxos=;
        b=Jptnm/0TSLN+0SqgSQcv/qmGWDPk2bgkA90HtnL52WCtRaFsgUL/hE044Oh03h5Riz
         3DSMOGQiOEKQsy6cNPhGtBOhAl4lMRPUGuCKcxlni/yfmSzBMBqmeFBY2a6buSJw/Tkh
         NvDB4r/YQ1AvqzpqCmqCzC3jXxZWVv5eDCUM3nK3IFxbkPx2zSY8ZXL1nFRz6BCnHgbU
         4w2s2TVQ2wr7jiLEHBamGqShRfVF2Ow1QGObwf7yj1+dQk68WJEhotkjVXLTlqnub7+n
         NiP+3H9UH/c7+dZY9iGFfj2c18GC70BLCpsVStGrpYuxr/9QI3cdCxsUWohWTxbikMbM
         aZLg==
X-Google-Smtp-Source: AHgI3Ib9PDRfAgJ2+g56cDO5j4jKS9mElHxCE7/XIbGMq9RSFhMR4Kpz7RtE6yAYs6+ycK+0WFJGiA==
X-Received: by 2002:a5d:438a:: with SMTP id i10mr20490432wrq.111.1549721271711;
        Sat, 09 Feb 2019 06:07:51 -0800 (PST)
Received: from localhost ([95.238.120.247])
        by smtp.gmail.com with ESMTPSA id q9sm2805351wmc.10.2019.02.09.06.07.50
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sat, 09 Feb 2019 06:07:50 -0800 (PST)
Date: Sat, 9 Feb 2019 15:07:49 +0100
From: Andrea Righi <righi.andrea@gmail.com>
To: Josef Bacik <josef@toxicpanda.com>
Cc: Paolo Valente <paolo.valente@linaro.org>, Tejun Heo <tj@kernel.org>,
	Li Zefan <lizefan@huawei.com>, Johannes Weiner <hannes@cmpxchg.org>,
	Jens Axboe <axboe@kernel.dk>, Vivek Goyal <vgoyal@redhat.com>,
	Dennis Zhou <dennis@kernel.org>, cgroups@vger.kernel.org,
	linux-block@vger.kernel.org, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: [RFC PATCH v2] blkcg: prevent priority inversion problem during
 sync()
Message-ID: <20190209140749.GB1910@xps-13>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This is an attempt to mitigate the priority inversion problem of a
high-priority blkcg issuing a sync() and being forced to wait the
completion of all the writeback I/O generated by any other low-priority
blkcg, causing massive latencies to processes that shouldn't be
I/O-throttled at all.

The idea is to save a list of blkcg's that are waiting for writeback:
every time a sync() is executed the current blkcg is added to the list.

Then, when I/O is throttled, if there's a blkcg waiting for writeback
different than the current blkcg, no throttling is applied (we can
probably refine this logic later, i.e., a better policy could be to
adjust the throttling I/O rate using the blkcg with the highest speed
from the list of waiters - priority inheritance, kinda).

This topic has been discussed here:
https://lwn.net/ml/cgroups/20190118103127.325-1-righi.andrea@gmail.com/

But we didn't come up with any definitive solution.

This patch is not a definitive solution either, but it's an attempt to
continue addressing this issue and handling the priority inversion
problem with sync() in a better way.

Signed-off-by: Andrea Righi <righi.andrea@gmail.com>
---
Changes in v2:
 - fix: use the proper current blkcg in blkcg_wb_waiters_on_bdi()

 block/blk-cgroup.c               | 69 ++++++++++++++++++++++++++++++++
 block/blk-throttle.c             | 11 +++--
 fs/fs-writeback.c                |  4 ++
 include/linux/backing-dev-defs.h |  2 +
 include/linux/blk-cgroup.h       | 18 ++++++++-
 mm/backing-dev.c                 |  2 +
 6 files changed, 102 insertions(+), 4 deletions(-)

diff --git a/block/blk-cgroup.c b/block/blk-cgroup.c
index 2bed5725aa03..21f14148a9c6 100644
--- a/block/blk-cgroup.c
+++ b/block/blk-cgroup.c
@@ -1635,6 +1635,75 @@ static void blkcg_scale_delay(struct blkcg_gq *blkg, u64 now)
 	}
 }
 
+/**
+ * blkcg_wb_waiters_on_bdi - check for writeback waiters on a block device
+ * @blkcg: current blkcg cgroup
+ * @bdi: block device to check
+ *
+ * Return true if any other blkcg is waiting for writeback on the target block
+ * device, false otherwise.
+ */
+bool blkcg_wb_waiters_on_bdi(struct blkcg *blkcg, struct backing_dev_info *bdi)
+{
+	struct blkcg *wait_blkcg;
+	bool ret = false;
+
+	if (unlikely(!bdi))
+		return false;
+
+	rcu_read_lock();
+	list_for_each_entry_rcu(wait_blkcg, &bdi->cgwb_waiters, cgwb_wait_node)
+		if (wait_blkcg != blkcg) {
+			ret = true;
+			break;
+		}
+	rcu_read_unlock();
+
+	return ret;
+}
+
+/**
+ * blkcg_start_wb_wait_on_bdi - add current blkcg to writeback waiters list
+ * @bdi: target block device
+ *
+ * Add current blkcg to the list of writeback waiters on target block device.
+ */
+void blkcg_start_wb_wait_on_bdi(struct backing_dev_info *bdi)
+{
+	struct blkcg *blkcg;
+
+	rcu_read_lock();
+	blkcg = css_to_blkcg(task_css(current, io_cgrp_id));
+	if (blkcg) {
+		spin_lock(&bdi->cgwb_waiters_lock);
+		list_add_rcu(&blkcg->cgwb_wait_node, &bdi->cgwb_waiters);
+		spin_unlock(&bdi->cgwb_waiters_lock);
+	}
+	rcu_read_unlock();
+}
+
+/**
+ * blkcg_stop_wb_wait_on_bdi - remove current blkcg from writeback waiters list
+ * @bdi: target block device
+ *
+ * Remove current blkcg from the list of writeback waiters on target block
+ * device.
+ */
+void blkcg_stop_wb_wait_on_bdi(struct backing_dev_info *bdi)
+{
+	struct blkcg *blkcg;
+
+	rcu_read_lock();
+	blkcg = css_to_blkcg(task_css(current, io_cgrp_id));
+	if (blkcg) {
+		spin_lock(&bdi->cgwb_waiters_lock);
+		list_del_rcu(&blkcg->cgwb_wait_node);
+		spin_unlock(&bdi->cgwb_waiters_lock);
+	}
+	rcu_read_unlock();
+	synchronize_rcu();
+}
+
 /*
  * This is called when we want to actually walk up the hierarchy and check to
  * see if we need to throttle, and then actually throttle if there is some
diff --git a/block/blk-throttle.c b/block/blk-throttle.c
index 1b97a73d2fb1..da817896cded 100644
--- a/block/blk-throttle.c
+++ b/block/blk-throttle.c
@@ -970,9 +970,13 @@ static bool tg_may_dispatch(struct throtl_grp *tg, struct bio *bio,
 {
 	bool rw = bio_data_dir(bio);
 	unsigned long bps_wait = 0, iops_wait = 0, max_wait = 0;
+	struct throtl_data *td = tg->td;
+	struct request_queue *q = td->queue;
+	struct backing_dev_info *bdi = q->backing_dev_info;
+	struct blkcg_gq *blkg = tg_to_blkg(tg);
 
 	/*
- 	 * Currently whole state machine of group depends on first bio
+	 * Currently whole state machine of group depends on first bio
 	 * queued in the group bio list. So one should not be calling
 	 * this function with a different bio if there are other bios
 	 * queued.
@@ -981,8 +985,9 @@ static bool tg_may_dispatch(struct throtl_grp *tg, struct bio *bio,
 	       bio != throtl_peek_queued(&tg->service_queue.queued[rw]));
 
 	/* If tg->bps = -1, then BW is unlimited */
-	if (tg_bps_limit(tg, rw) == U64_MAX &&
-	    tg_iops_limit(tg, rw) == UINT_MAX) {
+	if (blkcg_wb_waiters_on_bdi(blkg->blkcg, bdi) ||
+	    (tg_bps_limit(tg, rw) == U64_MAX &&
+	    tg_iops_limit(tg, rw) == UINT_MAX)) {
 		if (wait)
 			*wait = 0;
 		return true;
diff --git a/fs/fs-writeback.c b/fs/fs-writeback.c
index 36855c1f8daf..13880774af3c 100644
--- a/fs/fs-writeback.c
+++ b/fs/fs-writeback.c
@@ -2446,6 +2446,8 @@ void sync_inodes_sb(struct super_block *sb)
 		return;
 	WARN_ON(!rwsem_is_locked(&sb->s_umount));
 
+	blkcg_start_wb_wait_on_bdi(bdi);
+
 	/* protect against inode wb switch, see inode_switch_wbs_work_fn() */
 	bdi_down_write_wb_switch_rwsem(bdi);
 	bdi_split_work_to_wbs(bdi, &work, false);
@@ -2453,6 +2455,8 @@ void sync_inodes_sb(struct super_block *sb)
 	bdi_up_write_wb_switch_rwsem(bdi);
 
 	wait_sb_inodes(sb);
+
+	blkcg_stop_wb_wait_on_bdi(bdi);
 }
 EXPORT_SYMBOL(sync_inodes_sb);
 
diff --git a/include/linux/backing-dev-defs.h b/include/linux/backing-dev-defs.h
index 07e02d6df5ad..095e4dd0427b 100644
--- a/include/linux/backing-dev-defs.h
+++ b/include/linux/backing-dev-defs.h
@@ -191,6 +191,8 @@ struct backing_dev_info {
 	struct rb_root cgwb_congested_tree; /* their congested states */
 	struct mutex cgwb_release_mutex;  /* protect shutdown of wb structs */
 	struct rw_semaphore wb_switch_rwsem; /* no cgwb switch while syncing */
+	struct list_head cgwb_waiters; /* list of all waiters for writeback */
+	spinlock_t cgwb_waiters_lock; /* protect cgwb_waiters list */
 #else
 	struct bdi_writeback_congested *wb_congested;
 #endif
diff --git a/include/linux/blk-cgroup.h b/include/linux/blk-cgroup.h
index 76c61318fda5..5ea6b31c1df4 100644
--- a/include/linux/blk-cgroup.h
+++ b/include/linux/blk-cgroup.h
@@ -56,6 +56,7 @@ struct blkcg {
 
 	struct list_head		all_blkcgs_node;
 #ifdef CONFIG_CGROUP_WRITEBACK
+	struct list_head		cgwb_wait_node;
 	struct list_head		cgwb_list;
 	refcount_t			cgwb_refcnt;
 #endif
@@ -454,6 +455,10 @@ static inline void blkcg_cgwb_put(struct blkcg *blkcg)
 		blkcg_destroy_blkgs(blkcg);
 }
 
+bool blkcg_wb_waiters_on_bdi(struct blkcg *blkcg, struct backing_dev_info *bdi);
+void blkcg_start_wb_wait_on_bdi(struct backing_dev_info *bdi);
+void blkcg_stop_wb_wait_on_bdi(struct backing_dev_info *bdi);
+
 #else
 
 static inline void blkcg_cgwb_get(struct blkcg *blkcg) { }
@@ -464,6 +469,14 @@ static inline void blkcg_cgwb_put(struct blkcg *blkcg)
 	blkcg_destroy_blkgs(blkcg);
 }
 
+static inline bool
+blkcg_wb_waiters_on_bdi(struct blkcg *blkcg, struct backing_dev_info *bdi)
+{
+	return false;
+}
+static inline void blkcg_start_wb_wait_on_bdi(struct backing_dev_info *bdi) { }
+static inline void blkcg_stop_wb_wait_on_bdi(struct backing_dev_info *bdi) { }
+
 #endif
 
 /**
@@ -772,6 +785,7 @@ static inline void blkcg_bio_issue_init(struct bio *bio)
 static inline bool blkcg_bio_issue_check(struct request_queue *q,
 					 struct bio *bio)
 {
+	struct backing_dev_info *bdi = q->backing_dev_info;
 	struct blkcg_gq *blkg;
 	bool throtl = false;
 
@@ -785,9 +799,11 @@ static inline bool blkcg_bio_issue_check(struct request_queue *q,
 			  bio_devname(bio, b));
 		bio_associate_blkg(bio);
 	}
-
 	blkg = bio->bi_blkg;
 
+	if (blkcg_wb_waiters_on_bdi(blkg->blkcg, bdi))
+		bio_set_flag(bio, BIO_THROTTLED);
+
 	throtl = blk_throtl_bio(q, blkg, bio);
 
 	if (!throtl) {
diff --git a/mm/backing-dev.c b/mm/backing-dev.c
index 72e6d0c55cfa..8848d26e8bf6 100644
--- a/mm/backing-dev.c
+++ b/mm/backing-dev.c
@@ -686,10 +686,12 @@ static int cgwb_bdi_init(struct backing_dev_info *bdi)
 {
 	int ret;
 
+	INIT_LIST_HEAD(&bdi->cgwb_waiters);
 	INIT_RADIX_TREE(&bdi->cgwb_tree, GFP_ATOMIC);
 	bdi->cgwb_congested_tree = RB_ROOT;
 	mutex_init(&bdi->cgwb_release_mutex);
 	init_rwsem(&bdi->wb_switch_rwsem);
+	spin_lock_init(&bdi->cgwb_waiters_lock);
 
 	ret = wb_init(&bdi->wb, bdi, 1, GFP_KERNEL);
 	if (!ret) {
-- 
2.17.1

