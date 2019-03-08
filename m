Return-Path: <SRS0=92PK=RL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B96C8C43381
	for <linux-mm@archiver.kernel.org>; Fri,  8 Mar 2019 21:28:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 685B720857
	for <linux-mm@archiver.kernel.org>; Fri,  8 Mar 2019 21:28:13 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 685B720857
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=canonical.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E68868E0004; Fri,  8 Mar 2019 16:28:12 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E16EC8E0002; Fri,  8 Mar 2019 16:28:12 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CE0EA8E0004; Fri,  8 Mar 2019 16:28:12 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id 7768B8E0002
	for <linux-mm@kvack.org>; Fri,  8 Mar 2019 16:28:12 -0500 (EST)
Received: by mail-wr1-f69.google.com with SMTP id z16so10770650wrt.0
        for <linux-mm@kvack.org>; Fri, 08 Mar 2019 13:28:12 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:mime-version:content-disposition:user-agent;
        bh=JaqPMjNUg8YGoZrvXWIJxyaScX79kLBvByC21D5oQZA=;
        b=dDbDgGoDWu09ZQBRh8BzAv4hXQSdU/ewyvg26SJpv/Pu2PJwA9QqLOvNNqcAjI4C7h
         GN8YYdIvRZzU1yM2c1mIIRDZ7Ksk1JQmXNEa+zo2OL0RwV1sm1zvOD4aK6jCM4OoHyjm
         GR6CLbXlxI5B7TjPEpduXHq+SfiqSxGXBG5pXIjepu5dNGpOM+ezEwcNOu3mYCZztwaD
         DiT1Q+utoqxbbIXCg5Jt2Egk+Y/PU/nbb3pcFl4IMChRRESUMg6if+Jbxu5lHOuEdGsG
         a6YaUc59ueX3X75dhD3Jjfvq3VT0MT9n2Zaen3dRkIw24NgU8JDaE9O+sB7QAdmMC+f6
         koAA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of andrea.righi@canonical.com designates 91.189.89.112 as permitted sender) smtp.mailfrom=andrea.righi@canonical.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=canonical.com
X-Gm-Message-State: APjAAAXdNg/prbvMczX62J8HLB6GjlIYb90lbK3M9R41VyQZNq2q9KzZ
	RFlVqSvYeyYHyRheCLlYfdx0fWrxIpYoKOu2gyc88rHVFF6CBZantbn0XOb5Mcivo4Ym+1bPqDO
	KkH8llshPiBP4NGoozgcOoAoB/YftezgAleo83yKyRbcpS/yTavZ9Uj2eNBLNRLYz1DE9epSHsx
	5k0Kja8fF5CFMTNK6PObXuQh6Nstz7Vr5v7eU64iGP/bMa23tR8VFVEs9qMpYKRI5RNO2ZcvT6V
	BiiSyV9dS5jYnDsQmgVLlFFhj1MbOYB2SeJ2yUI/WL9DA44wUb/8OslWuQaLelv1yc8sBSlssxR
	Rapr0gF6LOzHW64gklJYXVEbO36zzxNWhCV7GfPJUz2b8WRza7MRngg/Qk58lTDIiI5C8YKLJDY
	Ay+tKkXRN9v+b7qFws0OzXsF2fz2KxkJC5uPutUe1xn6Eu+8nIQ/zKbNV+zAU9agJAJpYyO0t9q
	+7l11AlkxdyjYlVJQ4Ad3XnxPfzJN8I6yal3g8Oxq95N9qX5yUbqy/DowCjAwR0SOAr/hoVU6wC
	pEAp8qIctwCEcr/eHVKqYN5iaQT/BpVrfCE1+wEBCa6JNNNl6U+bniU0XKo9MawOXFEnGBff/S+
	P9nviIw+oc6C
X-Received: by 2002:a1c:23c4:: with SMTP id j187mr10089732wmj.13.1552080491625;
        Fri, 08 Mar 2019 13:28:11 -0800 (PST)
X-Google-Smtp-Source: APXvYqwOeOJoebFlIq2xeEouiB1sQZ9ZjMFjgG7l7+HcGA05Jhyz+5oPRAe8MFBCFEjOor+APc6t
X-Received: by 2002:a1c:23c4:: with SMTP id j187mr10089684wmj.13.1552080489933;
        Fri, 08 Mar 2019 13:28:09 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1552080489; cv=none;
        d=google.com; s=arc-20160816;
        b=SnDHOxR4h9ZVBkHd+ZrRpy4Q/7dcISWncxhGa7c7cnEc+gYZ8ywkqUBnFxKrTcCelT
         za4AQCNCLdj0Lpi7JP1Xhzz5YBuRRE1qysAkjoZxmKrtnzSblOweXWQG9io4dA3iu1O4
         Vo3KrmpeAqczzYzfC02/hPUss8nwSO2lGASMCE7eXlPS5szrQmoNGuATgX6SsB/6IBqZ
         zmjDlmPbkItbIgTMxLU/96RhKHZk+JpdN1Kn2/c5+eIbpRq0N457X0ZZoSdybIgWnDKL
         5AgHOFi3bAaz6+/iFl0oRUvlOF55BnBCHWF3hjWnCOfEMH8Gb/On8hd0xd7bTIGk0dEc
         6fKg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:content-disposition:mime-version:message-id:subject:cc
         :to:from:date;
        bh=JaqPMjNUg8YGoZrvXWIJxyaScX79kLBvByC21D5oQZA=;
        b=LuuRL8Qrmn04qT5+Hd+9z0DN6NQ0bxBplLfxrNKoPav2Vm0r4GEi9ShzPOFPlHtZv6
         p/+sghHyBf4SwtwJxVt0pDtYLw7S57MI4uJsTM7sz9U2w2DCb3Vc3HvNA4ya0WQg/+AB
         G+8AFm8WtP06Zng8aT5PAM2IHdvBXamzaEtJ39VRMdHvUTtHGvDs9Eq6W690tzld6ZkD
         4hGKiNwBjeFqqZBaLzrcQlnDGc/Yrds/qy1gukJxc4iz2MxHwhz0QDcPBZKxevUF+82h
         FLoxcxC/QsYe4h3XCGTYXtCC8D6yFKdz7KNQj1htaJpB0exnRH/9Ew34vF7AFhoBDZBI
         srZg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of andrea.righi@canonical.com designates 91.189.89.112 as permitted sender) smtp.mailfrom=andrea.righi@canonical.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=canonical.com
Received: from youngberry.canonical.com (youngberry.canonical.com. [91.189.89.112])
        by mx.google.com with ESMTPS id j17si4203669wrr.234.2019.03.08.13.28.09
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 08 Mar 2019 13:28:09 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of andrea.righi@canonical.com designates 91.189.89.112 as permitted sender) client-ip=91.189.89.112;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of andrea.righi@canonical.com designates 91.189.89.112 as permitted sender) smtp.mailfrom=andrea.righi@canonical.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=canonical.com
Received: from mail-wr1-f72.google.com ([209.85.221.72])
	by youngberry.canonical.com with esmtps (TLS1.0:RSA_AES_128_CBC_SHA1:16)
	(Exim 4.76)
	(envelope-from <andrea.righi@canonical.com>)
	id 1h2N2H-0001SV-5R
	for linux-mm@kvack.org; Fri, 08 Mar 2019 21:28:09 +0000
Received: by mail-wr1-f72.google.com with SMTP id b9so10769788wrw.14
        for <linux-mm@kvack.org>; Fri, 08 Mar 2019 13:28:09 -0800 (PST)
X-Received: by 2002:adf:f744:: with SMTP id z4mr4414412wrp.66.1552080488695;
        Fri, 08 Mar 2019 13:28:08 -0800 (PST)
X-Received: by 2002:adf:f744:: with SMTP id z4mr4414388wrp.66.1552080488308;
        Fri, 08 Mar 2019 13:28:08 -0800 (PST)
Received: from localhost (host157-124-dynamic.27-79-r.retail.telecomitalia.it. [79.27.124.157])
        by smtp.gmail.com with ESMTPSA id g3sm5072472wmk.32.2019.03.08.13.28.06
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 08 Mar 2019 13:28:07 -0800 (PST)
Date: Fri, 8 Mar 2019 22:28:06 +0100
From: Andrea Righi <andrea.righi@canonical.com>
To: Josef Bacik <josef@toxicpanda.com>, Tejun Heo <tj@kernel.org>
Cc: Li Zefan <lizefan@huawei.com>, Paolo Valente <paolo.valente@linaro.org>,
	Johannes Weiner <hannes@cmpxchg.org>, Jens Axboe <axboe@kernel.dk>,
	Vivek Goyal <vgoyal@redhat.com>, Dennis Zhou <dennis@kernel.org>,
	cgroups@vger.kernel.org, linux-block@vger.kernel.org,
	linux-mm@kvack.org, linux-kernel@vger.kernel.org
Subject: [PATCH v3] blkcg: prevent priority inversion problem during sync()
Message-ID: <20190308212806.GA1172@xps-13>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

When sync(2) is executed from a high-priority cgroup, the process is
forced to wait the completion of the entire outstanding writeback I/O,
even the I/O that was originally generated by low-priority cgroups
potentially.

This may cause massive latencies to random processes (even those running
in the root cgroup) that shouldn't be I/O-throttled at all, similarly to
a classic priority inversion problem.

Prevent this problem by saving a list of blkcg's that are waiting for
writeback: every time a sync(2) is executed the current blkcg is added
to the list.

Then, when I/O is throttled, if there's a blkcg waiting for writeback
different than the current blkcg, no throttling is applied (we can
probably refine this logic later, i.e., a better policy could be to
adjust the I/O rate using the blkcg with the highest speed from the list
of waiters).

See also:
  https://lkml.org/lkml/2019/3/7/640

Signed-off-by: Andrea Righi <andrea.righi@canonical.com>
---
Changes in v3:
 - drop sync(2) isolation patches (this will be addressed by another
   patch, potentially operating at the fs namespace level)
 - use a per-bdi lock and a per-bdi list instead of a global lock and a
   global list to save the list of sync(2) waiters

 block/blk-cgroup.c               | 130 +++++++++++++++++++++++++++++++
 block/blk-throttle.c             |  11 ++-
 fs/fs-writeback.c                |   5 ++
 fs/sync.c                        |   8 +-
 include/linux/backing-dev-defs.h |   2 +
 include/linux/blk-cgroup.h       |  25 ++++++
 mm/backing-dev.c                 |   2 +
 7 files changed, 179 insertions(+), 4 deletions(-)

diff --git a/block/blk-cgroup.c b/block/blk-cgroup.c
index 2bed5725aa03..b380d678cfc2 100644
--- a/block/blk-cgroup.c
+++ b/block/blk-cgroup.c
@@ -1351,6 +1351,136 @@ struct cgroup_subsys io_cgrp_subsys = {
 };
 EXPORT_SYMBOL_GPL(io_cgrp_subsys);
 
+#ifdef CONFIG_CGROUP_WRITEBACK
+struct blkcg_wb_sleeper {
+	struct blkcg *blkcg;
+	refcount_t refcnt;
+	struct list_head node;
+};
+
+static struct blkcg_wb_sleeper *
+blkcg_wb_sleeper_find(struct blkcg *blkcg, struct backing_dev_info *bdi)
+{
+	struct blkcg_wb_sleeper *bws;
+
+	list_for_each_entry(bws, &bdi->cgwb_waiters, node)
+		if (bws->blkcg == blkcg)
+			return bws;
+	return NULL;
+}
+
+static void
+blkcg_wb_sleeper_add(struct backing_dev_info *bdi, struct blkcg_wb_sleeper *bws)
+{
+	list_add(&bws->node, &bdi->cgwb_waiters);
+}
+
+static void
+blkcg_wb_sleeper_del(struct backing_dev_info *bdi, struct blkcg_wb_sleeper *bws)
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
+	if (likely(list_empty(&bdi->cgwb_waiters)))
+		return false;
+	spin_lock(&bdi->cgwb_waiters_lock);
+	list_for_each_entry(bws, &bdi->cgwb_waiters, node)
+		if (bws->blkcg != blkcg) {
+			ret = true;
+			break;
+		}
+	spin_unlock(&bdi->cgwb_waiters_lock);
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
+		spin_lock_bh(&bdi->cgwb_waiters_lock);
+		bws = blkcg_wb_sleeper_find(blkcg, bdi);
+		if (bws) {
+			refcount_inc(&bws->refcnt);
+		} else {
+			/* Add current blkcg as a new wb sleeper on bdi */
+			css_get(&blkcg->css);
+			new_bws->blkcg = blkcg;
+			refcount_set(&new_bws->refcnt, 1);
+			blkcg_wb_sleeper_add(bdi, new_bws);
+			new_bws = NULL;
+		}
+		spin_unlock_bh(&bdi->cgwb_waiters_lock);
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
+	spin_lock_bh(&bdi->cgwb_waiters_lock);
+	bws = blkcg_wb_sleeper_find(blkcg, bdi);
+	if (unlikely(!bws)) {
+		/* blkcg_start/stop_wb_wait_on_bdi() mismatch */
+		WARN_ON(1);
+		goto out_unlock;
+	}
+	if (refcount_dec_and_test(&bws->refcnt)) {
+		blkcg_wb_sleeper_del(bdi, bws);
+		css_put(&blkcg->css);
+		kfree(bws);
+	}
+out_unlock:
+	spin_unlock_bh(&bdi->cgwb_waiters_lock);
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
index 76c61318fda5..66d7b6901c77 100644
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
 
@@ -788,6 +808,11 @@ static inline bool blkcg_bio_issue_check(struct request_queue *q,
 
 	blkg = bio->bi_blkg;
 
+	local_bh_disable();
+	if (blkcg_wb_waiters_on_bdi(blkg->blkcg, bdi))
+		bio_set_flag(bio, BIO_THROTTLED);
+	local_bh_enable();
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
2.20.1

