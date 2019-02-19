Return-Path: <SRS0=Z+ZU=Q2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1DF20C10F00
	for <linux-mm@archiver.kernel.org>; Tue, 19 Feb 2019 15:27:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B394D21738
	for <linux-mm@archiver.kernel.org>; Tue, 19 Feb 2019 15:27:45 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="RNxlnxyj"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B394D21738
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3DE3D8E0004; Tue, 19 Feb 2019 10:27:45 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 365C48E0002; Tue, 19 Feb 2019 10:27:45 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 207678E0004; Tue, 19 Feb 2019 10:27:45 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id B41DE8E0002
	for <linux-mm@kvack.org>; Tue, 19 Feb 2019 10:27:44 -0500 (EST)
Received: by mail-wr1-f70.google.com with SMTP id l5so9372859wrv.19
        for <linux-mm@kvack.org>; Tue, 19 Feb 2019 07:27:44 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references;
        bh=aLP28lQlfvEaj5P3lTxct6bkK1WmE36USMTehJ7l8S0=;
        b=dX6Jn4Jc9fFjDc6Zwboz8N71Gu0dBUfFgtSVFFnLCJdyaF/l8OTas4rjQ1oZJOiMt5
         A85luIy+pt/ribLnrKOrMngCth0Lv4KZOWdpHkXFLoP33RjpZ+lHPhNPjW4oL+R/KUki
         GmZiKLD0tBn3oNza1QRfrfis7wiRCb3hU1Jl9PmgLR7yWEt29L4kqGoAtV+ftWbV6tnj
         h+0eNv6Hetok77f1BoFQvw3xyv+3dIJL8o6gnijMLB2fCgYD67KAQ29FpVzs1osDKg+y
         vnknS4690Z8U4WKl5edCW8fdqs/CiZQFNFLstfqn6+AsA0/vpHCAPim5bJ2zJtAPWB8r
         zYtA==
X-Gm-Message-State: AHQUAuaJgkDedOlZ02xteqqm2talGVq2XmUvlpOtSx6fdnLJ2piG2YCF
	gpnJgjyBsBcnRUmvRNmLGqhzLOtPylyOTdffP5wPHD4bGLny55r8OgqPV6S0uzL6BMS9iyXuf3p
	vMTSkrpRWKG5+kYd+vPfJdQh+DIzJRThjyR9MWX6oMeaQPEF6ccS+Ew9A/HV2fPCp3I0eCtqfkf
	+vcNy6uc2j2BGwY9shtoFI7sL8qVB05WEDhQ4o4hbK1XaaHWpYA8IJOO3AmhYvir9sgnDDFoLoc
	3MlQ3rCuZ9Iql5ycxf4BGgzGtq/U6ocvuKBlN1mI3bblVKFNKhFaFtVGYYI+ViXlA6cGLoyENWU
	YYk/B3RuwJ1QqPJaj/EQ7d3nRDqrjim1ou2vgWZj5gDmxQq7NsG3CAd/BAbV8q7zTCRHJQEmA6+
	i
X-Received: by 2002:a7b:c00f:: with SMTP id c15mr3271048wmb.14.1550590064199;
        Tue, 19 Feb 2019 07:27:44 -0800 (PST)
X-Received: by 2002:a7b:c00f:: with SMTP id c15mr3270982wmb.14.1550590062916;
        Tue, 19 Feb 2019 07:27:42 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550590062; cv=none;
        d=google.com; s=arc-20160816;
        b=q0PfpI64rVrMNLkiSfR86u88zaaYcc47o9cCbM4yHcIBqZ4rnpI4E+uZz+5LsV778s
         YUtGHJIwBk5aHDYK1NqX5GxMiATD5i4Iw93A8HoERsIkemcvDy0gjBlhJ0/WpRjOo42n
         j2j6Os1h4Gczl5RAu09DE0zlVx6p1ZNYYdP9jv5Sq+iESEldNDpqtkDU2JwhE3V2rJ6D
         mTou/bVbUMc572At0uEUkH5MjeiexKAjlCCuvUNwMFjTI65qKiyYoD37hSKa5/bc8xJv
         gZezbvR7XObh3nPaBPb/IxHULVn3zIS7b/dB8KoMkjyAKhkuII92Z7Jmw4b9eutmeMEq
         AZug==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from
         :dkim-signature;
        bh=aLP28lQlfvEaj5P3lTxct6bkK1WmE36USMTehJ7l8S0=;
        b=OjlWr+W5Kp0CdO3W0cB9TXQdkXIgDnnX4YtczNe1OxR07eUSOSc0WeY+B8CLkgEUab
         cf9Z43bEHx2ij90tBF64XXtx8udgVmL/yZ1xHzUxS3kKTDFSug1vmewoRlJUe+rSvtr2
         s48pREU926cqz+aGy3Pe4ElQ4Ej190KnKGMoqa4tMgD3/HgzrO2PFDjqwa5mytAzs6mJ
         /WXAz7mNFyD+Yrh+FNp9kDbdd1D6s0imEEKcISQerIWlWNs8ueL8Zx5bwlsIaRGliKAM
         IFYRhXNYM3AkXHb+gcZNA6lcHolM7oq03XjzMmrfdun99r++c0vl2QjjlK8uHHGWHbjt
         5U0Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=RNxlnxyj;
       spf=pass (google.com: domain of righi.andrea@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=righi.andrea@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g13sor11155082wrq.7.2019.02.19.07.27.42
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 19 Feb 2019 07:27:42 -0800 (PST)
Received-SPF: pass (google.com: domain of righi.andrea@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=RNxlnxyj;
       spf=pass (google.com: domain of righi.andrea@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=righi.andrea@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references;
        bh=aLP28lQlfvEaj5P3lTxct6bkK1WmE36USMTehJ7l8S0=;
        b=RNxlnxyjZtrg+yoazOslRL0f8IqYDEOH6oa6Q9YE0VVpT2JKBSumhyXCv7JTOfIVCJ
         PMb7RLbw1++BkSYzD0hZTW4WrOK7rRb+1mdxXhiwpli1bmaphZuU9HrhgjRrHUGXMuhh
         KziJfX4fO5IJVPy+NL0FfxQ6WftWqijXsQZQeYK0T4P34oaNCloUy5VzPVZvNmhpBUqT
         h47Q3GxpupqK5eK2ltM6Fyo3eU7SGA/0ytwonNDNp8tiJg4kzKwvJbMZonG5fg97ANGE
         fruzVKQBdo7nTs+4cqxwHvlmVVgIaTySixjUX8llkoxDZRCOnBPkyZQJIHHj3CCViZ3R
         6KnQ==
X-Google-Smtp-Source: AHgI3IbjuIduBGr6mwILzL8HCjCozk4cl5g64v4dZ/Lk7Y41wwIt/QjSC9z0rkisQSwGionyCA9OpA==
X-Received: by 2002:adf:8273:: with SMTP id 106mr21900010wrb.34.1550590062342;
        Tue, 19 Feb 2019 07:27:42 -0800 (PST)
Received: from xps-13.homenet.telecomitalia.it (host117-125-dynamic.33-79-r.retail.telecomitalia.it. [79.33.125.117])
        by smtp.gmail.com with ESMTPSA id v6sm29029503wrd.88.2019.02.19.07.27.40
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Feb 2019 07:27:41 -0800 (PST)
From: Andrea Righi <righi.andrea@gmail.com>
To: Josef Bacik <josef@toxicpanda.com>,
	Tejun Heo <tj@kernel.org>
Cc: Li Zefan <lizefan@huawei.com>,
	Paolo Valente <paolo.valente@linaro.org>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Jens Axboe <axboe@kernel.dk>,
	Vivek Goyal <vgoyal@redhat.com>,
	Dennis Zhou <dennis@kernel.org>,
	cgroups@vger.kernel.org,
	linux-block@vger.kernel.org,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH 1/3] blkcg: prevent priority inversion problem during sync()
Date: Tue, 19 Feb 2019 16:27:10 +0100
Message-Id: <20190219152712.9855-2-righi.andrea@gmail.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190219152712.9855-1-righi.andrea@gmail.com>
References: <20190219152712.9855-1-righi.andrea@gmail.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Prevent priority inversion problem when a high-priority blkcg issues a
sync() and it is forced to wait the completion of all the writeback I/O
generated by any other low-priority blkcg, causing massive latencies to
processes that shouldn't be I/O-throttled at all.

The idea is to save a list of blkcg's that are waiting for writeback:
every time a sync() is executed the current blkcg is added to the list.

Then, when I/O is throttled, if there's a blkcg waiting for writeback
different than the current blkcg, no throttling is applied (we can
probably refine this logic later, i.e., a better policy could be to
adjust the throttling I/O rate using the blkcg with the highest speed
from the list of waiters - priority inheritance, kinda).

Signed-off-by: Andrea Righi <righi.andrea@gmail.com>
---
 block/blk-cgroup.c               | 73 ++++++++++++++++++++++++++++++++
 block/blk-throttle.c             | 11 +++--
 fs/fs-writeback.c                |  5 +++
 fs/sync.c                        |  8 +++-
 include/linux/backing-dev-defs.h |  2 +
 include/linux/blk-cgroup.h       | 23 ++++++++++
 mm/backing-dev.c                 |  2 +
 7 files changed, 120 insertions(+), 4 deletions(-)

diff --git a/block/blk-cgroup.c b/block/blk-cgroup.c
index 2bed5725aa03..fb3c39eadf92 100644
--- a/block/blk-cgroup.c
+++ b/block/blk-cgroup.c
@@ -1351,6 +1351,79 @@ struct cgroup_subsys io_cgrp_subsys = {
 };
 EXPORT_SYMBOL_GPL(io_cgrp_subsys);
 
+#ifdef CONFIG_CGROUP_WRITEBACK
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
+	blkcg = blkcg_from_current();
+	if (blkcg) {
+		css_get(&blkcg->css);
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
+	blkcg = blkcg_from_current();
+	if (blkcg) {
+		spin_lock(&bdi->cgwb_waiters_lock);
+		list_del_rcu(&blkcg->cgwb_wait_node);
+		spin_unlock(&bdi->cgwb_waiters_lock);
+		css_put(&blkcg->css);
+	}
+	rcu_read_unlock();
+	synchronize_rcu();
+}
+#endif
+
 /**
  * blkcg_activate_policy - activate a blkcg policy on a request_queue
  * @q: request_queue of interest
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
index 36855c1f8daf..77c039a0ec25 100644
--- a/fs/fs-writeback.c
+++ b/fs/fs-writeback.c
@@ -28,6 +28,7 @@
 #include <linux/tracepoint.h>
 #include <linux/device.h>
 #include <linux/memcontrol.h>
+#include <linux/blk-cgroup.h>
 #include "internal.h"
 
 /*
@@ -2446,6 +2447,8 @@ void sync_inodes_sb(struct super_block *sb)
 		return;
 	WARN_ON(!rwsem_is_locked(&sb->s_umount));
 
+	blkcg_start_wb_wait_on_bdi(bdi);
+
 	/* protect against inode wb switch, see inode_switch_wbs_work_fn() */
 	bdi_down_write_wb_switch_rwsem(bdi);
 	bdi_split_work_to_wbs(bdi, &work, false);
@@ -2453,6 +2456,8 @@ void sync_inodes_sb(struct super_block *sb)
 	bdi_up_write_wb_switch_rwsem(bdi);
 
 	wait_sb_inodes(sb);
+
+	blkcg_stop_wb_wait_on_bdi(bdi);
 }
 EXPORT_SYMBOL(sync_inodes_sb);
 
diff --git a/fs/sync.c b/fs/sync.c
index b54e0541ad89..3958b8f98b85 100644
--- a/fs/sync.c
+++ b/fs/sync.c
@@ -16,6 +16,7 @@
 #include <linux/pagemap.h>
 #include <linux/quotaops.h>
 #include <linux/backing-dev.h>
+#include <linux/blk-cgroup.h>
 #include "internal.h"
 
 #define VALID_FLAGS (SYNC_FILE_RANGE_WAIT_BEFORE|SYNC_FILE_RANGE_WRITE| \
@@ -76,8 +77,13 @@ static void sync_inodes_one_sb(struct super_block *sb, void *arg)
 
 static void sync_fs_one_sb(struct super_block *sb, void *arg)
 {
-	if (!sb_rdonly(sb) && sb->s_op->sync_fs)
+	struct backing_dev_info *bdi = sb->s_bdi;
+
+	if (!sb_rdonly(sb) && sb->s_op->sync_fs) {
+		blkcg_start_wb_wait_on_bdi(bdi);
 		sb->s_op->sync_fs(sb, *(int *)arg);
+		blkcg_stop_wb_wait_on_bdi(bdi);
+	}
 }
 
 static void fdatawrite_one_bdev(struct block_device *bdev, void *arg)
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
index 76c61318fda5..0f7dcb70e922 100644
--- a/include/linux/blk-cgroup.h
+++ b/include/linux/blk-cgroup.h
@@ -56,6 +56,7 @@ struct blkcg {
 
 	struct list_head		all_blkcgs_node;
 #ifdef CONFIG_CGROUP_WRITEBACK
+	struct list_head		cgwb_wait_node;
 	struct list_head		cgwb_list;
 	refcount_t			cgwb_refcnt;
 #endif
@@ -252,6 +253,12 @@ static inline struct blkcg *css_to_blkcg(struct cgroup_subsys_state *css)
 	return css ? container_of(css, struct blkcg, css) : NULL;
 }
 
+static inline struct blkcg *blkcg_from_current(void)
+{
+	WARN_ON_ONCE(!rcu_read_lock_held());
+	return css_to_blkcg(blkcg_css());
+}
+
 /**
  * __bio_blkcg - internal, inconsistent version to get blkcg
  *
@@ -454,6 +461,10 @@ static inline void blkcg_cgwb_put(struct blkcg *blkcg)
 		blkcg_destroy_blkgs(blkcg);
 }
 
+bool blkcg_wb_waiters_on_bdi(struct blkcg *blkcg, struct backing_dev_info *bdi);
+void blkcg_start_wb_wait_on_bdi(struct backing_dev_info *bdi);
+void blkcg_stop_wb_wait_on_bdi(struct backing_dev_info *bdi);
+
 #else
 
 static inline void blkcg_cgwb_get(struct blkcg *blkcg) { }
@@ -464,6 +475,14 @@ static inline void blkcg_cgwb_put(struct blkcg *blkcg)
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
@@ -772,6 +791,7 @@ static inline void blkcg_bio_issue_init(struct bio *bio)
 static inline bool blkcg_bio_issue_check(struct request_queue *q,
 					 struct bio *bio)
 {
+	struct backing_dev_info *bdi = q->backing_dev_info;
 	struct blkcg_gq *blkg;
 	bool throtl = false;
 
@@ -788,6 +808,9 @@ static inline bool blkcg_bio_issue_check(struct request_queue *q,
 
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

