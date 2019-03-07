Return-Path: <SRS0=NBIx=RK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2327BC43381
	for <linux-mm@archiver.kernel.org>; Thu,  7 Mar 2019 18:09:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CA0B520840
	for <linux-mm@archiver.kernel.org>; Thu,  7 Mar 2019 18:09:32 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CA0B520840
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=canonical.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 531A78E0004; Thu,  7 Mar 2019 13:09:32 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 41D238E0002; Thu,  7 Mar 2019 13:09:32 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2E5228E0004; Thu,  7 Mar 2019 13:09:32 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id CD54E8E0002
	for <linux-mm@kvack.org>; Thu,  7 Mar 2019 13:09:31 -0500 (EST)
Received: by mail-wr1-f71.google.com with SMTP id n2so1017804wrs.15
        for <linux-mm@kvack.org>; Thu, 07 Mar 2019 10:09:31 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=E1LOBPaoUcwq7EBh5jwmgNQUJ5Ql4uc2em7Nrd4127w=;
        b=aj1Hkfw1NneMbh4OMd+ea7yqYhv3AD2aGetW5xpjy1qZ5fSvOwOGU0plClc3gtpa3m
         3eBZCHc7o6G5Z3jTQQ8yVwt0lAkBmDzBL+gnqKp+YJbKPlsYyZkxhayHRlp1DQ5ZsueT
         7zOU9DZauUWHj/jvB3eeEnTM0e31RUctckLFRsN92BHehHd4j4ihT1L0fwMDIendFuSC
         Gems4nIc7xFUTFx5e6d0IejD3ZnIs5nIAE7zk8AxniALAZeR0z60/hYmlCNz/TSFk99R
         XFXxcZpKxpv9g1o3Z28Izz7zUZQdiT8BVNAP4lxiec6pXOk1DWqVktfdsjJStH5AEKUy
         qcqA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of andrea.righi@canonical.com designates 91.189.89.112 as permitted sender) smtp.mailfrom=andrea.righi@canonical.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=canonical.com
X-Gm-Message-State: APjAAAXDmHdlXaiCAVRvkdnZFrzHvV3LceQHCdIYBd7u4S7e6/Xtr+IP
	fY3iwvYPigbdvl2f32Io3Dgd/atyq4n214CFL6AAB4MXRySSqy4fLq4Rug/MqtgreAu/S8HHvM1
	cCtPOHPKqvCPKlTPTYUIxma30Z4uUMGO/LRkpWiqK3faBhEnZdm2abZX/sBYs+ZTFoFdBcsGmQA
	6jnxSUpV8q4L7H2rTfH+Z+4Tc0jnk56xLR9kJ725mOQLC9hnKWWSG8GQiFalIWPTr2gAj5UghOd
	STbw9rmFP5hB/+iJMmFDCcn2xqJyfiN6Zm+l4d0ASs9ZHJLQwxG3sdEEjN0kBklcGXu8JKYC6aU
	15y7+3AZDbu6Qgx79c8iEFGm7SSKgrueW0Mh0tsiEnkbRLVzJqWOe4lKS1hKlU0NJrUrHtD3zgc
	Lp+eUfpQU3HN+jpaHz1rUZgBfri9ncyOWCjE1QpMQBfwUWeBnDxLYDwqsFyqEetjborj7BBbW5t
	zQGG8rZyKgRdbfZB6vJ+cg+cMPYsl7J1A0ptq9GVw+bB5mJZI6mv9sQxFhNp3Uru0JIvU49n6l6
	zhxBfTlqUZeTX3WjmbpegUdL94ccTlNbgRHtVGo2OEB8rF+aEbh8PwjQdYghKUyCnHBziu6iKOi
	WKGdT1GL+AEm
X-Received: by 2002:a5d:4090:: with SMTP id o16mr7646368wrp.208.1551982171122;
        Thu, 07 Mar 2019 10:09:31 -0800 (PST)
X-Google-Smtp-Source: APXvYqyqzNbWOJoYqQpNNB3b39OmjVJX8fMudv/wdfPkvpD06Oq/B3GvtJqmAv6TdCgsJZXAk7+f
X-Received: by 2002:a5d:4090:: with SMTP id o16mr7646288wrp.208.1551982169686;
        Thu, 07 Mar 2019 10:09:29 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551982169; cv=none;
        d=google.com; s=arc-20160816;
        b=wqKxUg01PFsU/JkDo2Jb6R/y1DbjYdemfyA9gzX3zfYb5/v+9XtaonBBTcXfawSVvw
         wNL1fqdJHA8pBjoIqTH7p9vNAP+cDMW7sqrEcTwFn3CzrNm9sOwcgnWQXFkkVMnrknzi
         6FsXUmDYkNo9ij4bhRMViXgl467GtUtYEjFRDgX+ghnitgovkg33WkDy96Fi6xwu7sGA
         T5ZEmtGcmFhrrg0M60lr1phcytCnM7gnOvZ55lnwNwcuDfjTq8JMcsMvrnaEXmSTLZy9
         hnpYHgYUcQrAzDAtM5E3aFEl//x/y6a9hT1WlYeLObKaJN7mAEe2xQ31nWsiJ53X2bvr
         rS+Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=E1LOBPaoUcwq7EBh5jwmgNQUJ5Ql4uc2em7Nrd4127w=;
        b=RHDgh0ET5iXFjVc/h4CvjYIHl3r0NBBV7RUzqKBHdFhtFg7O7TPulKwMbvqgvPL9BQ
         vw9fdWgo4yiI3smmeWMBU6pyhyM8Im/aN3ljTp4ZGnP45KoNDd6qMJf6TWtOTSPR8rTI
         JiFqJcxn7G6GZ+/f2Cvdxs4aZdmVTkev6HeqMbkDMmfrtIsZ6p3CQ8dYx+atQJo/J/i9
         l9B400F73snYSvUM5CJdeui/T8fOoM4JMwl16jzY45Tsx7XYaiWQLEFbDz2AOyg5dPmI
         SY6NaIJw30iB+MlLB645i0g5BgjNOvrVoZwKtLrv1Egwhs0IjlnNKNewkoClVImReEOJ
         uAEQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of andrea.righi@canonical.com designates 91.189.89.112 as permitted sender) smtp.mailfrom=andrea.righi@canonical.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=canonical.com
Received: from youngberry.canonical.com (youngberry.canonical.com. [91.189.89.112])
        by mx.google.com with ESMTPS id x9si3413134wru.443.2019.03.07.10.09.29
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 07 Mar 2019 10:09:29 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of andrea.righi@canonical.com designates 91.189.89.112 as permitted sender) client-ip=91.189.89.112;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of andrea.righi@canonical.com designates 91.189.89.112 as permitted sender) smtp.mailfrom=andrea.righi@canonical.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=canonical.com
Received: from mail-wr1-f71.google.com ([209.85.221.71])
	by youngberry.canonical.com with esmtps (TLS1.0:RSA_AES_128_CBC_SHA1:16)
	(Exim 4.76)
	(envelope-from <andrea.righi@canonical.com>)
	id 1h1xSS-0001kE-Rh
	for linux-mm@kvack.org; Thu, 07 Mar 2019 18:09:28 +0000
Received: by mail-wr1-f71.google.com with SMTP id b9so8962701wrw.14
        for <linux-mm@kvack.org>; Thu, 07 Mar 2019 10:09:28 -0800 (PST)
X-Received: by 2002:a1c:df07:: with SMTP id w7mr6623160wmg.23.1551982168470;
        Thu, 07 Mar 2019 10:09:28 -0800 (PST)
X-Received: by 2002:a1c:df07:: with SMTP id w7mr6623133wmg.23.1551982168042;
        Thu, 07 Mar 2019 10:09:28 -0800 (PST)
Received: from localhost.localdomain (host22-124-dynamic.46-79-r.retail.telecomitalia.it. [79.46.124.22])
        by smtp.gmail.com with ESMTPSA id a74sm7872747wma.22.2019.03.07.10.09.26
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Mar 2019 10:09:27 -0800 (PST)
From: Andrea Righi <andrea.righi@canonical.com>
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
Subject: [PATCH v2 1/3] blkcg: prevent priority inversion problem during sync()
Date: Thu,  7 Mar 2019 19:08:32 +0100
Message-Id: <20190307180834.22008-2-andrea.righi@canonical.com>
X-Mailer: git-send-email 2.19.1
In-Reply-To: <20190307180834.22008-1-andrea.righi@canonical.com>
References: <20190307180834.22008-1-andrea.righi@canonical.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
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

Signed-off-by: Andrea Righi <andrea.righi@canonical.com>
---
 block/blk-cgroup.c               | 131 +++++++++++++++++++++++++++++++
 block/blk-throttle.c             |  11 ++-
 fs/fs-writeback.c                |   5 ++
 fs/sync.c                        |   8 +-
 include/linux/backing-dev-defs.h |   2 +
 include/linux/blk-cgroup.h       |  23 ++++++
 mm/backing-dev.c                 |   2 +
 7 files changed, 178 insertions(+), 4 deletions(-)

diff --git a/block/blk-cgroup.c b/block/blk-cgroup.c
index 2bed5725aa03..4305e78d1bb2 100644
--- a/block/blk-cgroup.c
+++ b/block/blk-cgroup.c
@@ -1351,6 +1351,137 @@ struct cgroup_subsys io_cgrp_subsys = {
 };
 EXPORT_SYMBOL_GPL(io_cgrp_subsys);
 
+#ifdef CONFIG_CGROUP_WRITEBACK
+struct blkcg_wb_sleeper {
+	struct backing_dev_info *bdi;
+	struct blkcg *blkcg;
+	refcount_t refcnt;
+	struct list_head node;
+};
+
+static DEFINE_SPINLOCK(blkcg_wb_sleeper_lock);
+static LIST_HEAD(blkcg_wb_sleeper_list);
+
+static struct blkcg_wb_sleeper *
+blkcg_wb_sleeper_find(struct blkcg *blkcg, struct backing_dev_info *bdi)
+{
+	struct blkcg_wb_sleeper *bws;
+
+	list_for_each_entry(bws, &blkcg_wb_sleeper_list, node)
+		if (bws->blkcg == blkcg && bws->bdi == bdi)
+			return bws;
+	return NULL;
+}
+
+static void blkcg_wb_sleeper_add(struct blkcg_wb_sleeper *bws)
+{
+	list_add(&bws->node, &blkcg_wb_sleeper_list);
+}
+
+static void blkcg_wb_sleeper_del(struct blkcg_wb_sleeper *bws)
+{
+	list_del_init(&bws->node);
+}
+
+/**
+ * blkcg_wb_waiters_on_bdi - check for writeback waiters on a block device
+ * @blkcg: current blkcg cgroup
+ * @bdi: block device to check
+ *
+ * Return true if any other blkcg different than the current one is waiting for
+ * writeback on the target block device, false otherwise.
+ */
+bool blkcg_wb_waiters_on_bdi(struct blkcg *blkcg, struct backing_dev_info *bdi)
+{
+	struct blkcg_wb_sleeper *bws;
+	bool ret = false;
+
+	spin_lock(&blkcg_wb_sleeper_lock);
+	list_for_each_entry(bws, &blkcg_wb_sleeper_list, node)
+		if (bws->bdi == bdi && bws->blkcg != blkcg) {
+			ret = true;
+			break;
+		}
+	spin_unlock(&blkcg_wb_sleeper_lock);
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
+	struct blkcg_wb_sleeper *new_bws, *bws;
+	struct blkcg *blkcg;
+
+	new_bws = kzalloc(sizeof(*new_bws), GFP_KERNEL);
+	if (unlikely(!new_bws))
+		return;
+
+	rcu_read_lock();
+	blkcg = blkcg_from_current();
+	if (likely(blkcg)) {
+		/* Check if blkcg is already sleeping on bdi */
+		spin_lock(&blkcg_wb_sleeper_lock);
+		bws = blkcg_wb_sleeper_find(blkcg, bdi);
+		if (bws) {
+			refcount_inc(&bws->refcnt);
+		} else {
+			/* Add current blkcg as a new wb sleeper on bdi */
+			css_get(&blkcg->css);
+			new_bws->blkcg = blkcg;
+			new_bws->bdi = bdi;
+			refcount_set(&new_bws->refcnt, 1);
+			blkcg_wb_sleeper_add(new_bws);
+			new_bws = NULL;
+		}
+		spin_unlock(&blkcg_wb_sleeper_lock);
+	}
+	rcu_read_unlock();
+
+	kfree(new_bws);
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
+	struct blkcg_wb_sleeper *bws = NULL;
+	struct blkcg *blkcg;
+
+	rcu_read_lock();
+	blkcg = blkcg_from_current();
+	if (!blkcg) {
+		rcu_read_unlock();
+		return;
+	}
+	spin_lock(&blkcg_wb_sleeper_lock);
+	bws = blkcg_wb_sleeper_find(blkcg, bdi);
+	if (unlikely(!bws)) {
+		/* blkcg_start/stop_wb_wait_on_bdi() mismatch */
+		WARN_ON(1);
+		goto out_unlock;
+	}
+	if (refcount_dec_and_test(&bws->refcnt)) {
+		blkcg_wb_sleeper_del(bws);
+		css_put(&blkcg->css);
+		kfree(bws);
+	}
+out_unlock:
+	spin_unlock(&blkcg_wb_sleeper_lock);
+	rcu_read_unlock();
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
2.19.1

