Return-Path: <SRS0=Z+ZU=Q2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 03EC9C4360F
	for <linux-mm@archiver.kernel.org>; Tue, 19 Feb 2019 15:27:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A6B0421736
	for <linux-mm@archiver.kernel.org>; Tue, 19 Feb 2019 15:27:51 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="P+6GFnyV"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A6B0421736
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E16F08E0006; Tue, 19 Feb 2019 10:27:47 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D9EA48E0002; Tue, 19 Feb 2019 10:27:47 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CB5558E0006; Tue, 19 Feb 2019 10:27:47 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id 74CE78E0002
	for <linux-mm@kvack.org>; Tue, 19 Feb 2019 10:27:47 -0500 (EST)
Received: by mail-wr1-f70.google.com with SMTP id b9so9394630wrw.14
        for <linux-mm@kvack.org>; Tue, 19 Feb 2019 07:27:47 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references;
        bh=c98WFQKqSGewnmjGR+VAUu2jdbTDTi2eXPqlfHCbeCU=;
        b=p/Ao3ZV5IKKLWFNfBrF33yaxhRZBcDwq7gN6J338Rhnj3L9ya5cJLMhKVILeRRSv6y
         d0SG80E1p7jn20OLGeQnrGal/OEuziT9/bPF1mPfIwMnCEKjBPiGZp0O0SXnPk4d0tsk
         SGR3KGps8c1c+Rz/AgEj8DLopUHzsP/08oLE1XubQ5QHVPI4hnOxHeQAnLhrdaVrSl5A
         e+Ge41/YaHBtMBGau3Id7rMIT7M5pgcZorvgImqoi5Z35+mBVcVRHp2A5DvZzVNa7vSp
         NPFVqdseU0mF0hDl+k4YWVz9+gYZXxh1KdjjbAmx11QqvsT/B7HMx3p1gEcbqmh23ArQ
         +ncg==
X-Gm-Message-State: AHQUAubXnGx1Ypg7wVL6iPq3lz8Pggj9JeZi+1Eb5CvWehXfADhIu1uk
	ooHFA8vnGoIIAlJPMITJgaYD5z3gfoWQN7Up7X27A9DWybREDFrCVrnrG1d2WnPYnzygcNZ9Mxe
	DzbSJdOeJhMESaBtkmAfSdH2dX/prHJoT/tToJF8ArBX1UrKw2TtO9vFBkDTw0rzW0mwb+HQChP
	uy9Hbz4AP2dgV9aX8wDiA8cko3Owzo/dq8H1QGM4ymtR47bRsrUsQdI88IphBkceyMXJrGC+Vb7
	DbmOzLN+tlQ4P7v+/hv9KdBy47JONzKeQ6T/9X+zrQyrO25NQDAAo9UAsqmpfUX68dELZjDDkQN
	Xbhe1M/8qTK45N0B/26G3H2VBuMnJL7LdLR7U1VrJZ6ryDfTN+Vv/uqW+RR1rXFWDxht+cI75yf
	s
X-Received: by 2002:a5d:5585:: with SMTP id i5mr22050387wrv.239.1550590066976;
        Tue, 19 Feb 2019 07:27:46 -0800 (PST)
X-Received: by 2002:a5d:5585:: with SMTP id i5mr22050323wrv.239.1550590065782;
        Tue, 19 Feb 2019 07:27:45 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550590065; cv=none;
        d=google.com; s=arc-20160816;
        b=shWkQQAukN6GagwPAz3ePH33ZrulDVPUcM/90XKge5QSh0K3ijNfSgTY0HNTPIpO7H
         BWc23ei5YfBIeOMrSTaXy1h/acKQ4uQqOi0nk8P22LSkwc7pTdzZI2k3yynraSxX0lrR
         cb101yjVIBiamppjB2o0sk748X5hR33SiRR8PLbFGkoZiVgDp6wtqbWktIV4IxQa82Hc
         nmmcjFu6rf1CJWogUsYUxxJLH4xGMrn6uLvbT3jo/y6hB+S8AWEPMy9pTHyQ749YYN+k
         h7BMRlowJ1f/zlZeh0YuInpIjncoQHpuKqLwbhuFI7RBMGZ9q1Vdi/07zJVmro2UMcnK
         Xe2A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from
         :dkim-signature;
        bh=c98WFQKqSGewnmjGR+VAUu2jdbTDTi2eXPqlfHCbeCU=;
        b=iumqHM1F5NsjO6/op2J2Fs24R3/3ntxR2Y8OjUFU36k/rxc7/N5JOdHJmaF2rgmjnd
         OMnWsi8Ksf9/wLBSshLP+y5YE3HOb8SfQhdcztHc7zYUITTvDi+BitxSxVXMmP6AJPVn
         pNsoTdrd3eOUZEBbrxSUdqxMpAeKm0H1YWGIEgeozJ+yUotpSZ+LDqj9/T6ac/NxoJUU
         +yL5U7Ci3odbVDs9EIBactgy24TPpyNDpRb05h0S4AFE6xfGQrnUKLhKUAx7WRom63C7
         S5Q10DVuOrSf+fLUHV0FBUfzQvaa7I2uOcaUx0H/B1b0oXzMQ3EHiAcL96ptTZqwipVJ
         z7Jg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=P+6GFnyV;
       spf=pass (google.com: domain of righi.andrea@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=righi.andrea@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f16sor1836289wmb.3.2019.02.19.07.27.45
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 19 Feb 2019 07:27:45 -0800 (PST)
Received-SPF: pass (google.com: domain of righi.andrea@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=P+6GFnyV;
       spf=pass (google.com: domain of righi.andrea@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=righi.andrea@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references;
        bh=c98WFQKqSGewnmjGR+VAUu2jdbTDTi2eXPqlfHCbeCU=;
        b=P+6GFnyVpg2KZGAIvcNuVcwUz8RKDcIJqgGs+wbGQMM/EqhXUxwX0boLM2h38zYuKH
         JF9igYIFbiaVwv+rzAwyq7wRD9ltKKasUpaIRHZ6Hm2O5/Y18QXHx7oGN9B++3bG5TTM
         iR4i8+mu3M4JEDaNSPlMQK2UhFh8TXwA2SoNePLRKuB/mRqi8wRVmNegc4+Pp+gcgwyn
         IpeueEJ9cFjHGFbFu8O9LTE1svbaOhLrjToACAJNmeAqYoklqRiHW/iaaCY6LQjEd4BB
         ulyYxlxqpdpIOshBcPLOp2qUuAOuOawp/lApQMoTcO9XLjXxH1feNEUAYwYmLn9G2FEL
         uRtQ==
X-Google-Smtp-Source: AHgI3IZ5u7DQFM6uWNRQR5JFQTc+Kv+c+ywfGCH879D8R7gLQYbXK7hv5L2JhfRHOL0qscx2Es6Q+Q==
X-Received: by 2002:a1c:1902:: with SMTP id 2mr3384191wmz.150.1550590065159;
        Tue, 19 Feb 2019 07:27:45 -0800 (PST)
Received: from xps-13.homenet.telecomitalia.it (host117-125-dynamic.33-79-r.retail.telecomitalia.it. [79.33.125.117])
        by smtp.gmail.com with ESMTPSA id v6sm29029503wrd.88.2019.02.19.07.27.43
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Feb 2019 07:27:44 -0800 (PST)
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
Subject: [PATCH 3/3] blkcg: implement sync() isolation
Date: Tue, 19 Feb 2019 16:27:12 +0100
Message-Id: <20190219152712.9855-4-righi.andrea@gmail.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190219152712.9855-1-righi.andrea@gmail.com>
References: <20190219152712.9855-1-righi.andrea@gmail.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Keep track of the inodes that have been dirtied by each blkcg cgroup and
make sure that a blkcg issuing a sync() can trigger the writeback + wait
of only those pages that belong to the cgroup itself.

This behavior is enabled only when io.sync_isolation is enabled in the
cgroup, otherwise the old behavior is applied: sync() triggers the
writeback of any dirty page.

Signed-off-by: Andrea Righi <righi.andrea@gmail.com>
---
 block/blk-cgroup.c         | 47 ++++++++++++++++++++++++++++++++++
 fs/fs-writeback.c          | 52 +++++++++++++++++++++++++++++++++++---
 fs/inode.c                 |  1 +
 include/linux/blk-cgroup.h | 22 ++++++++++++++++
 include/linux/fs.h         |  4 +++
 mm/page-writeback.c        |  1 +
 6 files changed, 124 insertions(+), 3 deletions(-)

diff --git a/block/blk-cgroup.c b/block/blk-cgroup.c
index fb3c39eadf92..c6ddf9eeab37 100644
--- a/block/blk-cgroup.c
+++ b/block/blk-cgroup.c
@@ -1422,6 +1422,53 @@ void blkcg_stop_wb_wait_on_bdi(struct backing_dev_info *bdi)
 	rcu_read_unlock();
 	synchronize_rcu();
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
+ * blkcg_set_mapping_dirty - clear the owner of a dirty mapping
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
index 73432e64f874..d60a2042d39a 100644
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
index 29d8e2cfed0e..502a2b94f183 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -414,6 +414,7 @@ int pagecache_write_end(struct file *, struct address_space *mapping,
  * @nrpages: Number of page entries, protected by the i_pages lock.
  * @nrexceptional: Shadow or DAX entries, protected by the i_pages lock.
  * @writeback_index: Writeback starts here.
+ * @i_blkcg: blkcg owner (that dirtied the address_space)
  * @a_ops: Methods.
  * @flags: Error bits and flags (AS_*).
  * @wb_err: The most recent error which has occurred.
@@ -432,6 +433,9 @@ struct address_space {
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
index 7d1010453fb9..a58071ee5f1c 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -2410,6 +2410,7 @@ void account_page_dirtied(struct page *page, struct address_space *mapping)
 		inode_attach_wb(inode, page);
 		wb = inode_to_wb(inode);
 
+		blkcg_set_mapping_dirty(mapping);
 		__inc_lruvec_page_state(page, NR_FILE_DIRTY);
 		__inc_zone_page_state(page, NR_ZONE_WRITE_PENDING);
 		__inc_node_page_state(page, NR_DIRTIED);
-- 
2.17.1

