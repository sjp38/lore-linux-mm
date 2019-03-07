Return-Path: <SRS0=NBIx=RK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 974F3C4360F
	for <linux-mm@archiver.kernel.org>; Thu,  7 Mar 2019 18:09:38 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5775220854
	for <linux-mm@archiver.kernel.org>; Thu,  7 Mar 2019 18:09:38 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5775220854
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=canonical.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C5C958E0006; Thu,  7 Mar 2019 13:09:35 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C123A8E0002; Thu,  7 Mar 2019 13:09:35 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AB5948E0006; Thu,  7 Mar 2019 13:09:35 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f72.google.com (mail-wm1-f72.google.com [209.85.128.72])
	by kanga.kvack.org (Postfix) with ESMTP id 53D7A8E0002
	for <linux-mm@kvack.org>; Thu,  7 Mar 2019 13:09:35 -0500 (EST)
Received: by mail-wm1-f72.google.com with SMTP id b197so3283005wmb.9
        for <linux-mm@kvack.org>; Thu, 07 Mar 2019 10:09:35 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=CNOTSLqaS5V7TljZnZkBn/fAkhgWZBqkz11C4gbNPOw=;
        b=kQgv/PnUpUzivmPd9AEXrdf+wEiRZdLiiBTQWj4ggH13lTmVOfYkrvGjttF17nnxJu
         b1bxwUUfpauUqXX42QQJI9f/sm2f1kkoL9MhOGunkZbBZTMvvMOQ2/0Q1zqlsiub5RZD
         M90l53dmn4qkwS6fju3EzOGapTJtfyqJBRIhA5vj0lgKryaUO/GszT99vLPYcqyDrp98
         karwPZH1pag6UdAeMa/Nfmf0hefzHeSdZn1tcvnfvJhYxFszqD9kn1OHf4ADrEhx9OWh
         u+Ft+px9olG0pOI3LVy/SjG7e9bp5qpgufFZi6Ir03dSFlwtFnG7f59XUt9IM+ARr2Fm
         3Fgg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of andrea.righi@canonical.com designates 91.189.89.112 as permitted sender) smtp.mailfrom=andrea.righi@canonical.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=canonical.com
X-Gm-Message-State: APjAAAXnxRxHndVIAB595rAENQoxV2APhzpVhiZRnzYNhUdUME6mO0Fr
	lSQDGnvqQS4C6tl+QtXvAKwkVgu9AP94l3FhacZ70jZCEb9oRpuZ13WaS8YyaB5QC7Ub2heCK66
	164qwMrz5/1DouNlaOTBB58uP1BqcCnyKiwMIEwzThu7qy3APajjH6kN7HJMqyF4P9YX+89X8G7
	rVamsJQ3YMk3kHeog3ZAZGbyIELD5eCjJCcgVNRtl+0wUXvQz3WTIxFxX75kiHi38pmhwqUmjCY
	dUGmIbypzh44C/VEI1MfFoK2LlclDR/a7Lqad3o6UFse/C6iBErQy4hf6rjxw8jkCjFIAil+NI6
	xtSr8TMcwicaBRG2EFBWVquNbW5oq8HXz6aZYeooqv/bplcMuNXOYkKoUnY19fGhNfS5b4xRqOI
	wOf1FI+rVqOT8v2YCVh+kNPHEFgiGdAeU1Bixi1XROX4k+v93/g5s4c8RmC43Kkwr7sjYWwJgBZ
	nJzfQh2JuNZ5tOcnzdHHaqSdfuD6U77Re/nZwZOhXbXXm0562wJzhZc1MPQ+fXwInXl4YKy77cn
	UEv5ZOuqAr0kuaB8kdmyeIdbXTFGrqwZ5qCBV/VSY50t81Wum2tis3iZVvxLve5+Vgh3j59ZekA
	00BDq8S9BgJP
X-Received: by 2002:a1c:55c3:: with SMTP id j186mr6922746wmb.5.1551982174515;
        Thu, 07 Mar 2019 10:09:34 -0800 (PST)
X-Google-Smtp-Source: APXvYqyY4SX5UFDWMtG/A3g54MZrvVuwZzJVhBeeg6Dp1AU7xps0XrEfb5KzV+xEsn7cbg0GFgjj
X-Received: by 2002:a1c:55c3:: with SMTP id j186mr6922645wmb.5.1551982172533;
        Thu, 07 Mar 2019 10:09:32 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551982172; cv=none;
        d=google.com; s=arc-20160816;
        b=nDJHYmft0t+yj6Sw052lP2u4sJZateEnVBp7Sdo8wFSxXI0SkDqhq2dAEuhtTXK2Rs
         0gxN3UIDEXieJz4CTXe3u2O3FrixiJVo7Ui+YCpa6U8lophfZOaV0/2IicWo7WAOR1Qk
         edEDA8UQD77QTnr6r9Z9txXS+Mm3jRNa+MLPSzJaYxLdO3cfMHx3zgQkfjpn7+n66KNn
         oM4OQj1X+8NNwetL/yRNJyrkoKVZzg761+qYI0azS4GEC+dycyhhKT2EHPmTXlFGgwgF
         1zOuBTDjzDjl0OLS1A80Z6RV95Lb1rwTPx2e85HiHmRljjvC4rBu9LWrt9GyeDn4FvMP
         nGvw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=CNOTSLqaS5V7TljZnZkBn/fAkhgWZBqkz11C4gbNPOw=;
        b=MvSf3ZWe3psM2hiqFC366S2KpSJqGqliT25pZwISWFxEsoLc+0rBMsvXdA87JyJC/C
         SFJoMJ3f6rIglO0uMPh7eCFGigsHX5ZCfhnl0v0clbSk2pulY6KY5kLLyriJCZkdfsGq
         DtWi3jiUsYN04CCzTIzMn4V4IQlepP3/JMR460Ps0N/O2dDjWG7eXAQ8xwkHjFdMy7M5
         vgoYmj8iY0a/B0gILhA7ngcH7UtNT9eG8PmZJ3ta94YqGLqt+ZyoLHNlHvB4N5fSqNJV
         tkRFwwyXvE2Hz2YMRRmSyC2RROVtingCm0vndF8SploJ+PdF95RfKn0li7GtbHl+x9FU
         U5ng==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of andrea.righi@canonical.com designates 91.189.89.112 as permitted sender) smtp.mailfrom=andrea.righi@canonical.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=canonical.com
Received: from youngberry.canonical.com (youngberry.canonical.com. [91.189.89.112])
        by mx.google.com with ESMTPS id r5si3214577wme.163.2019.03.07.10.09.32
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 07 Mar 2019 10:09:32 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of andrea.righi@canonical.com designates 91.189.89.112 as permitted sender) client-ip=91.189.89.112;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of andrea.righi@canonical.com designates 91.189.89.112 as permitted sender) smtp.mailfrom=andrea.righi@canonical.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=canonical.com
Received: from mail-wr1-f71.google.com ([209.85.221.71])
	by youngberry.canonical.com with esmtps (TLS1.0:RSA_AES_128_CBC_SHA1:16)
	(Exim 4.76)
	(envelope-from <andrea.righi@canonical.com>)
	id 1h1xSW-0001lX-0f
	for linux-mm@kvack.org; Thu, 07 Mar 2019 18:09:32 +0000
Received: by mail-wr1-f71.google.com with SMTP id e18so8927692wrw.10
        for <linux-mm@kvack.org>; Thu, 07 Mar 2019 10:09:32 -0800 (PST)
X-Received: by 2002:a1c:a186:: with SMTP id k128mr6422924wme.54.1551982171147;
        Thu, 07 Mar 2019 10:09:31 -0800 (PST)
X-Received: by 2002:a1c:a186:: with SMTP id k128mr6422908wme.54.1551982170847;
        Thu, 07 Mar 2019 10:09:30 -0800 (PST)
Received: from localhost.localdomain (host22-124-dynamic.46-79-r.retail.telecomitalia.it. [79.46.124.22])
        by smtp.gmail.com with ESMTPSA id a74sm7872747wma.22.2019.03.07.10.09.29
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Mar 2019 10:09:30 -0800 (PST)
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
Subject: [PATCH v2 3/3] blkcg: implement sync() isolation
Date: Thu,  7 Mar 2019 19:08:34 +0100
Message-Id: <20190307180834.22008-4-andrea.righi@canonical.com>
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

Keep track of the inodes that have been dirtied by each blkcg cgroup and
make sure that a blkcg issuing a sync() can trigger the writeback + wait
of only those pages that belong to the cgroup itself.

This behavior is applied only when io.sync_isolation is enabled in the
cgroup, otherwise the old behavior is applied: sync() triggers the
writeback of any dirty page.

Signed-off-by: Andrea Righi <andrea.righi@canonical.com>
---
 block/blk-cgroup.c         | 47 ++++++++++++++++++++++++++++++++++
 fs/fs-writeback.c          | 52 +++++++++++++++++++++++++++++++++++---
 fs/inode.c                 |  1 +
 include/linux/blk-cgroup.h | 22 ++++++++++++++++
 include/linux/fs.h         |  4 +++
 mm/page-writeback.c        |  1 +
 6 files changed, 124 insertions(+), 3 deletions(-)

diff --git a/block/blk-cgroup.c b/block/blk-cgroup.c
index 4305e78d1bb2..7d3b26ba4575 100644
--- a/block/blk-cgroup.c
+++ b/block/blk-cgroup.c
@@ -1480,6 +1480,53 @@ void blkcg_stop_wb_wait_on_bdi(struct backing_dev_info *bdi)
 	spin_unlock(&blkcg_wb_sleeper_lock);
 	rcu_read_unlock();
 }
+
+/**
+ * blkcg_set_mapping_dirty - set owner of a dirty mapping
+ * @mapping: target address space
+ *
+ * Set the current blkcg as the owner of the address space @mapping (the first
+ * blkcg that dirties @mapping becomes the owner).
+ */
+void blkcg_set_mapping_dirty(struct address_space *mapping)
+{
+	struct blkcg *curr_blkcg, *blkcg;
+
+	if (mapping_tagged(mapping, PAGECACHE_TAG_WRITEBACK) ||
+	    mapping_tagged(mapping, PAGECACHE_TAG_DIRTY))
+		return;
+
+	rcu_read_lock();
+	curr_blkcg = blkcg_from_current();
+	blkcg = blkcg_from_mapping(mapping);
+	if (curr_blkcg != blkcg) {
+		if (blkcg)
+			css_put(&blkcg->css);
+		css_get(&curr_blkcg->css);
+		rcu_assign_pointer(mapping->i_blkcg, curr_blkcg);
+	}
+	rcu_read_unlock();
+}
+
+/**
+ * blkcg_set_mapping_clean - clear the owner of a dirty mapping
+ * @mapping: target address space
+ *
+ * Unset the owner of @mapping when it becomes clean.
+ */
+
+void blkcg_set_mapping_clean(struct address_space *mapping)
+{
+	struct blkcg *blkcg;
+
+	rcu_read_lock();
+	blkcg = rcu_dereference(mapping->i_blkcg);
+	if (blkcg) {
+		css_put(&blkcg->css);
+		RCU_INIT_POINTER(mapping->i_blkcg, NULL);
+	}
+	rcu_read_unlock();
+}
 #endif
 
 /**
diff --git a/fs/fs-writeback.c b/fs/fs-writeback.c
index 77c039a0ec25..d003d0593f41 100644
--- a/fs/fs-writeback.c
+++ b/fs/fs-writeback.c
@@ -58,6 +58,9 @@ struct wb_writeback_work {
 
 	struct list_head list;		/* pending work list */
 	struct wb_completion *done;	/* set if the caller waits */
+#ifdef CONFIG_CGROUP_WRITEBACK
+	struct blkcg *blkcg;
+#endif
 };
 
 /*
@@ -916,6 +919,29 @@ static int __init cgroup_writeback_init(void)
 }
 fs_initcall(cgroup_writeback_init);
 
+static void blkcg_set_sync_domain(struct wb_writeback_work *work)
+{
+	rcu_read_lock();
+	work->blkcg = blkcg_from_current();
+	rcu_read_unlock();
+}
+
+static bool blkcg_same_sync_domain(struct wb_writeback_work *work,
+				   struct address_space *mapping)
+{
+	struct blkcg *blkcg;
+
+	if (!work->blkcg || work->blkcg == &blkcg_root)
+		return true;
+	if (!test_bit(BLKCG_SYNC_ISOLATION, &work->blkcg->flags))
+		return true;
+	rcu_read_lock();
+	blkcg = blkcg_from_mapping(mapping);
+	rcu_read_unlock();
+
+	return blkcg == work->blkcg;
+}
+
 #else	/* CONFIG_CGROUP_WRITEBACK */
 
 static void bdi_down_write_wb_switch_rwsem(struct backing_dev_info *bdi) { }
@@ -959,6 +985,15 @@ static void bdi_split_work_to_wbs(struct backing_dev_info *bdi,
 	}
 }
 
+static void blkcg_set_sync_domain(struct wb_writeback_work *work)
+{
+}
+
+static bool blkcg_same_sync_domain(struct wb_writeback_work *work,
+				   struct address_space *mapping)
+{
+	return true;
+}
 #endif	/* CONFIG_CGROUP_WRITEBACK */
 
 /*
@@ -1131,7 +1166,7 @@ static int move_expired_inodes(struct list_head *delaying_queue,
 	LIST_HEAD(tmp);
 	struct list_head *pos, *node;
 	struct super_block *sb = NULL;
-	struct inode *inode;
+	struct inode *inode, *next;
 	int do_sb_sort = 0;
 	int moved = 0;
 
@@ -1141,11 +1176,12 @@ static int move_expired_inodes(struct list_head *delaying_queue,
 		expire_time = jiffies - (dirtytime_expire_interval * HZ);
 		older_than_this = &expire_time;
 	}
-	while (!list_empty(delaying_queue)) {
-		inode = wb_inode(delaying_queue->prev);
+	list_for_each_entry_safe(inode, next, delaying_queue, i_io_list) {
 		if (older_than_this &&
 		    inode_dirtied_after(inode, *older_than_this))
 			break;
+		if (!blkcg_same_sync_domain(work, inode->i_mapping))
+			continue;
 		list_move(&inode->i_io_list, &tmp);
 		moved++;
 		if (flags & EXPIRE_DIRTY_ATIME)
@@ -1560,6 +1596,15 @@ static long writeback_sb_inodes(struct super_block *sb,
 			break;
 		}
 
+		/*
+		 * Only write out inodes that belong to the blkcg that issued
+		 * the sync().
+		 */
+		if (!blkcg_same_sync_domain(work, inode->i_mapping)) {
+			redirty_tail(inode, wb);
+			continue;
+		}
+
 		/*
 		 * Don't bother with new inodes or inodes being freed, first
 		 * kind does not need periodic writeout yet, and for the latter
@@ -2447,6 +2492,7 @@ void sync_inodes_sb(struct super_block *sb)
 		return;
 	WARN_ON(!rwsem_is_locked(&sb->s_umount));
 
+	blkcg_set_sync_domain(&work);
 	blkcg_start_wb_wait_on_bdi(bdi);
 
 	/* protect against inode wb switch, see inode_switch_wbs_work_fn() */
diff --git a/fs/inode.c b/fs/inode.c
index e9d97add2b36..b9659aaa8546 100644
--- a/fs/inode.c
+++ b/fs/inode.c
@@ -564,6 +564,7 @@ static void evict(struct inode *inode)
 		bd_forget(inode);
 	if (S_ISCHR(inode->i_mode) && inode->i_cdev)
 		cd_forget(inode);
+	blkcg_set_mapping_clean(&inode->i_data);
 
 	remove_inode_hash(inode);
 
diff --git a/include/linux/blk-cgroup.h b/include/linux/blk-cgroup.h
index 6ac5aa049334..a2bcc83c8c3e 100644
--- a/include/linux/blk-cgroup.h
+++ b/include/linux/blk-cgroup.h
@@ -441,6 +441,15 @@ extern void blkcg_destroy_blkgs(struct blkcg *blkcg);
 
 #ifdef CONFIG_CGROUP_WRITEBACK
 
+static inline struct blkcg *blkcg_from_mapping(struct address_space *mapping)
+{
+	WARN_ON_ONCE(!rcu_read_lock_held());
+	return rcu_dereference(mapping->i_blkcg);
+}
+
+void blkcg_set_mapping_dirty(struct address_space *mapping);
+void blkcg_set_mapping_clean(struct address_space *mapping);
+
 /**
  * blkcg_cgwb_get - get a reference for blkcg->cgwb_list
  * @blkcg: blkcg of interest
@@ -474,6 +483,19 @@ void blkcg_stop_wb_wait_on_bdi(struct backing_dev_info *bdi);
 
 #else
 
+static inline struct blkcg *blkcg_from_mapping(struct address_space *mapping)
+{
+	return NULL;
+}
+
+static inline void blkcg_set_mapping_dirty(struct address_space *mapping)
+{
+}
+
+static inline void blkcg_set_mapping_clean(struct address_space *mapping)
+{
+}
+
 static inline void blkcg_cgwb_get(struct blkcg *blkcg) { }
 
 static inline void blkcg_cgwb_put(struct blkcg *blkcg)
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 08f26046233e..19e99b4a9fa2 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -420,6 +420,7 @@ int pagecache_write_end(struct file *, struct address_space *mapping,
  * @nrpages: Number of page entries, protected by the i_pages lock.
  * @nrexceptional: Shadow or DAX entries, protected by the i_pages lock.
  * @writeback_index: Writeback starts here.
+ * @i_blkcg: blkcg owner (that dirtied the address_space)
  * @a_ops: Methods.
  * @flags: Error bits and flags (AS_*).
  * @wb_err: The most recent error which has occurred.
@@ -438,6 +439,9 @@ struct address_space {
 	unsigned long		nrexceptional;
 	pgoff_t			writeback_index;
 	const struct address_space_operations *a_ops;
+#ifdef CONFIG_CGROUP_WRITEBACK
+	struct blkcg __rcu	*i_blkcg;
+#endif
 	unsigned long		flags;
 	errseq_t		wb_err;
 	spinlock_t		private_lock;
diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index 9f61dfec6a1f..e16574f946a7 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -2418,6 +2418,7 @@ void account_page_dirtied(struct page *page, struct address_space *mapping)
 		inode_attach_wb(inode, page);
 		wb = inode_to_wb(inode);
 
+		blkcg_set_mapping_dirty(mapping);
 		__inc_lruvec_page_state(page, NR_FILE_DIRTY);
 		__inc_zone_page_state(page, NR_ZONE_WRITE_PENDING);
 		__inc_node_page_state(page, NR_DIRTIED);
-- 
2.19.1

