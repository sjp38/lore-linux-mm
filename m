Return-Path: <SRS0=P3wr=RM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E50C8C4360F
	for <linux-mm@archiver.kernel.org>; Sat,  9 Mar 2019 21:42:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8F74F20657
	for <linux-mm@archiver.kernel.org>; Sat,  9 Mar 2019 21:42:36 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8F74F20657
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=canonical.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 51DE18E0003; Sat,  9 Mar 2019 16:42:36 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4A5878E0002; Sat,  9 Mar 2019 16:42:36 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 36F098E0003; Sat,  9 Mar 2019 16:42:36 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id D32E08E0002
	for <linux-mm@kvack.org>; Sat,  9 Mar 2019 16:42:35 -0500 (EST)
Received: by mail-wr1-f72.google.com with SMTP id y1so622766wrh.21
        for <linux-mm@kvack.org>; Sat, 09 Mar 2019 13:42:35 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=A0PGKAOGAWEyIU2MwZgcDLodb1JVvAVCaAK3XCNp/gs=;
        b=EMh/R8y9O+Ax8AnyUAzXJ+5E/wwxKcPEgWXyeH9CvglgmpPspVOC02GHluW4Yj3g0T
         /I5SmmivJxqYmb/Mry+E6y6+apegTMleWaoNbjF/aGRV+fR15mgpH2NbXmw+xkjd1+kd
         LhkLGdiZoXy/GUg6qcVK1ozAC3zddTBC3v5FDoH1LCU5D8eDvDppqgOBz0c4ROrLNM54
         TfcV3rv79MtvGlO+QbA80nZMIuchtDooSGHqO7SVaVSW/Lz1+qaaJX7VqkrcThsuYoeh
         fA1rCq3I/KcYRcw15QJpbYyA4FG+LG+AVvnlarOIwCpuiUoJpmqJiHA0lFvGYUlLWnO6
         kstg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of andrea.righi@canonical.com designates 91.189.89.112 as permitted sender) smtp.mailfrom=andrea.righi@canonical.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=canonical.com
X-Gm-Message-State: APjAAAUxvNQnBsUFQTKlWQSHJi25dU7lACGUXtrEGBN5nlGTa8dcHvZ1
	CS8QlxpmqgrLwt98X6BRO9/J1/Heluf5TrXsHpbAu47DVBEfkXcbgO0kSUE9162Su/6lczhsKW4
	zvdxEymNvbEn1nFE77RMLWeoQeUfnEQ1tHNrWFddNOnb9Zo4RAt+I21zat7nh0jNsOC5PwGuKPk
	7KcRUeMJ3FtwRgvGMDLF6F24Cthn/VQSNok5RyjMXcCdfspr0xxgBvjhGUek4Lcjhs4WhDKte1H
	o2Wp1qRyhIQTBuPLBXEidCXQdGjNAq9IZI3mez3ccs+uz2C9PWinF4DaZvvnDkmAxOfEs6Je5tQ
	ZGRDKlUzfGXeBx5DOKQ6y5n1yu4W27Jek7vz7xSFlmCW45sYqoRa3uXHnx1PKl5bCZVS0r+p0Iq
	en3HrXvQjDk/ZPojqVt6qd9gl2Lp6+to7fi+sXnr6nHd9RN4yoMPNOyAqH6KheKulqblilFvt8b
	CFaSex0IsWLglywMhVII0h1R/hPMmcxKBqDTzZWvHBwrtChMcJ3XNx0ymp22It+UrVfCxIadKb+
	LkJPsRE7FmErsOv3bmWxDLTeQPBkOlTpGIHn1r//N1FZilEuCK9zxjP0o6AByCWDmZ6HeSoy3Eo
	7Rn3YAlOsfEY
X-Received: by 2002:adf:9e0c:: with SMTP id u12mr15076218wre.216.1552167755364;
        Sat, 09 Mar 2019 13:42:35 -0800 (PST)
X-Google-Smtp-Source: APXvYqxc9ArVrvXUU9M7KyEirQolrA9uVqQknYKwnYCY42pAIBoXznAsTK72nQnOqNbNHKlC08Eb
X-Received: by 2002:adf:9e0c:: with SMTP id u12mr15076188wre.216.1552167754113;
        Sat, 09 Mar 2019 13:42:34 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1552167754; cv=none;
        d=google.com; s=arc-20160816;
        b=Bm9/NyiWMJRNPAgyid0OJoJOWIRZnx9EiDxKVRL7UoRIcJkp3+tfXAOgLXG6meAPtf
         fQ9ITbzt6nZSnYi3ApxZE1vGYk+8SO5OWSyrUym7ulVp0srSOGV23laZPoJWAm6qDc8L
         AGuYm7/Pa1BtIcz81leOyesmgUyUW4+Y9sKUI0o+Y78KmQmdVKVl/WbyTyVhWoIcQFQS
         05QfiVRE+EpouBDXLpBswxVOCHpmZ1Po+TIUuEr+bZKatU4K8YGX1k0ZkLp0wlKdCvwz
         maGSpGhdke4BdLa0TdJul58g6Ymg1hxgPDJMd//qtDsT1cs8Rik1TjMEfE5KP3jL+A0y
         ZJ0Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=A0PGKAOGAWEyIU2MwZgcDLodb1JVvAVCaAK3XCNp/gs=;
        b=nP9S+Vzadsa3hmev9hGuxtjllzoxKXK5AHxmPEdfyoG7u/vOq8tnpDDKvNh2aVz6qZ
         73yNwj84kFqyEN7476hCw4Wqmo1SnWWmFgRZMIJ58qtRjfSGRO7ffILtCNi6BFPayMt5
         4StA6kjlstu7UA2QL6rwbX2WFQSaeEx7n0PDQq5ULQWk8VzziLrHjg/I7SArqPLcmSZQ
         4EkS1ytTfycxTX1G9OaNyHH29uVgU/U8YaPzI3reBUMtf+FrV/tcNrYIMeiZ77ejrZuo
         J7V8m3ybxIACJltjYNT0oBhDKEb8Q8Tj7jhID3kaoh36FcDsO8azX8c43IhBhi0EceCZ
         p1yA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of andrea.righi@canonical.com designates 91.189.89.112 as permitted sender) smtp.mailfrom=andrea.righi@canonical.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=canonical.com
Received: from youngberry.canonical.com (youngberry.canonical.com. [91.189.89.112])
        by mx.google.com with ESMTPS id n23si6686656wmc.159.2019.03.09.13.42.33
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sat, 09 Mar 2019 13:42:34 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of andrea.righi@canonical.com designates 91.189.89.112 as permitted sender) client-ip=91.189.89.112;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of andrea.righi@canonical.com designates 91.189.89.112 as permitted sender) smtp.mailfrom=andrea.righi@canonical.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=canonical.com
Received: from mail-wr1-f72.google.com ([209.85.221.72])
	by youngberry.canonical.com with esmtps (TLS1.0:RSA_AES_128_CBC_SHA1:16)
	(Exim 4.76)
	(envelope-from <andrea.righi@canonical.com>)
	id 1h2jjl-0000sN-Ke
	for linux-mm@kvack.org; Sat, 09 Mar 2019 21:42:33 +0000
Received: by mail-wr1-f72.google.com with SMTP id i9so645315wrx.4
        for <linux-mm@kvack.org>; Sat, 09 Mar 2019 13:42:33 -0800 (PST)
X-Received: by 2002:a1c:4d17:: with SMTP id o23mr13190532wmh.53.1552167753156;
        Sat, 09 Mar 2019 13:42:33 -0800 (PST)
X-Received: by 2002:a1c:4d17:: with SMTP id o23mr13190510wmh.53.1552167752687;
        Sat, 09 Mar 2019 13:42:32 -0800 (PST)
Received: from localhost (host157-124-dynamic.27-79-r.retail.telecomitalia.it. [79.27.124.157])
        by smtp.gmail.com with ESMTPSA id 26sm16155708wmg.42.2019.03.09.13.42.31
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sat, 09 Mar 2019 13:42:32 -0800 (PST)
Date: Sat, 9 Mar 2019 22:42:31 +0100
From: Andrea Righi <andrea.righi@canonical.com>
To: Josef Bacik <josef@toxicpanda.com>, Tejun Heo <tj@kernel.org>
Cc: Li Zefan <lizefan@huawei.com>, Paolo Valente <paolo.valente@linaro.org>,
	Johannes Weiner <hannes@cmpxchg.org>, Jens Axboe <axboe@kernel.dk>,
	Vivek Goyal <vgoyal@redhat.com>, Dennis Zhou <dennis@kernel.org>,
	cgroups@vger.kernel.org, linux-block@vger.kernel.org,
	linux-mm@kvack.org, linux-kernel@vger.kernel.org
Subject: [PATCH v4] blkcg: prevent priority inversion problem during sync()
Message-ID: <20190309214230.GA1730@xps-13>
References: <20190308212806.GA1172@xps-13>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190308212806.GA1172@xps-13>
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
Changes in v4:
  - fix a build bug when CONFIG_BLOCK is unset

 block/blk-cgroup.c               | 130 +++++++++++++++++++++++++++++++
 block/blk-throttle.c             |  11 ++-
 fs/fs-writeback.c                |   5 ++
 fs/sync.c                        |   8 +-
 include/linux/backing-dev-defs.h |   2 +
 include/linux/blk-cgroup.h       |  35 ++++++++-
 mm/backing-dev.c                 |   2 +
 7 files changed, 188 insertions(+), 5 deletions(-)

diff --git a/block/blk-cgroup.c b/block/blk-cgroup.c
index 77f37ef8ef06..5334cb3acd22 100644
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
index 76c61318fda5..05e774d55624 100644
--- a/include/linux/blk-cgroup.h
+++ b/include/linux/blk-cgroup.h
@@ -29,6 +29,27 @@
 /* Max limits for throttle policy */
 #define THROTL_IOPS_MAX		UINT_MAX
 
+struct blkcg;
+
+#ifdef CONFIG_CGROUP_WRITEBACK
+
+bool blkcg_wb_waiters_on_bdi(struct blkcg *blkcg, struct backing_dev_info *bdi);
+void blkcg_start_wb_wait_on_bdi(struct backing_dev_info *bdi);
+void blkcg_stop_wb_wait_on_bdi(struct backing_dev_info *bdi);
+
+#else /* CONFIG_CGROUP_WRITEBACK */
+
+static inline bool
+blkcg_wb_waiters_on_bdi(struct blkcg *blkcg, struct backing_dev_info *bdi)
+{
+	return false;
+}
+
+static inline void blkcg_start_wb_wait_on_bdi(struct backing_dev_info *bdi) { }
+static inline void blkcg_stop_wb_wait_on_bdi(struct backing_dev_info *bdi) { }
+#endif /* CONFIG_CGROUP_WRITEBACK */
+
+
 #ifdef CONFIG_BLK_CGROUP
 
 enum blkg_rwstat_type {
@@ -56,6 +77,7 @@ struct blkcg {
 
 	struct list_head		all_blkcgs_node;
 #ifdef CONFIG_CGROUP_WRITEBACK
+	struct list_head		cgwb_wait_node;
 	struct list_head		cgwb_list;
 	refcount_t			cgwb_refcnt;
 #endif
@@ -252,6 +274,12 @@ static inline struct blkcg *css_to_blkcg(struct cgroup_subsys_state *css)
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
@@ -463,7 +491,6 @@ static inline void blkcg_cgwb_put(struct blkcg *blkcg)
 	/* wb isn't being accounted, so trigger destruction right away */
 	blkcg_destroy_blkgs(blkcg);
 }
-
 #endif
 
 /**
@@ -772,6 +799,7 @@ static inline void blkcg_bio_issue_init(struct bio *bio)
 static inline bool blkcg_bio_issue_check(struct request_queue *q,
 					 struct bio *bio)
 {
+	struct backing_dev_info *bdi = q->backing_dev_info;
 	struct blkcg_gq *blkg;
 	bool throtl = false;
 
@@ -788,6 +816,11 @@ static inline bool blkcg_bio_issue_check(struct request_queue *q,
 
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
2.19.1

