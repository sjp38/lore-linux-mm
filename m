Return-Path: <SRS0=VMr4=QW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E298BC4151A
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 02:10:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6E515222D0
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 02:10:24 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="iO7EkztH"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6E515222D0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 009B78E0002; Thu, 14 Feb 2019 21:10:24 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EFA988E0001; Thu, 14 Feb 2019 21:10:23 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D9CE18E0002; Thu, 14 Feb 2019 21:10:23 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 944508E0001
	for <linux-mm@kvack.org>; Thu, 14 Feb 2019 21:10:23 -0500 (EST)
Received: by mail-pf1-f198.google.com with SMTP id w16so6365878pfn.3
        for <linux-mm@kvack.org>; Thu, 14 Feb 2019 18:10:23 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=Qh34yj/BF1xtDZNSc4yllRfut6YYSlPHZcvjSSUjgyQ=;
        b=gxVWO0VKu5tG4Ufyg836EW3Nzb7wtxyJgp9F6HYP3W7zStAJmXuk/aL+VIHHMoserr
         HjASIfiJcgLQ0LmfsdlAOqneEMnLneZNZFdNqk+JYzJeby58okG97vSQ6bLP7++cL0/A
         zHVyW4Hb76WAE5c8c6bgY/Q7XA4RW07L8cDQ2qtxkHCQ41T44Juao/Bn1qgryR+KUNfo
         qosku6+17GOwu+x6FO8w62ef8d64s2uG0dd6kEx87ZY69h55nzV5KTPeiIlZRjOrTF0M
         S22pQQLjfy4sF6Hb667g4RNMJRT+s74tzgoJ0MXhMYOYlKl9kRwv22s8mlFUSUdzp51B
         fnPA==
X-Gm-Message-State: AHQUAuZJHi7xJ4itIRo61YZ4IeoYjuxZpmbR8fjNRk6JO2SL7mZiRQgQ
	0kyDw6s0dh4ExUONK5QBJJh6VruHYAIxbVhHMI9l6uycXDFqpBhxwFdDuvDzzAmLaI8KDT0oHmn
	6GLPIpkxTkWJzX6naske/DZ1O9YZSgOJdavSb1Pcy+r+VqhaY0xptguilILK+png4qg==
X-Received: by 2002:a62:4641:: with SMTP id t62mr7226215pfa.141.1550196623144;
        Thu, 14 Feb 2019 18:10:23 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYitlJAZX94e3379XwbkcDdPBNuPOBviE0u5i6/iEdAn4pmrBniaCsa6mzTym/qx+oYqoxW
X-Received: by 2002:a62:4641:: with SMTP id t62mr7226152pfa.141.1550196622314;
        Thu, 14 Feb 2019 18:10:22 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550196622; cv=none;
        d=google.com; s=arc-20160816;
        b=tEzQxdDPiP48Dn3z4JmrgJJUq94qCqXmXiKzLUNtC359JtCVXoyqyv1Gh5eZmmJPRh
         h5tw2wEdA9iDHH63cr2yHjnviGYPbymRr18+cFLLqKid+0vszrLklJAhqx965VcrVT/Q
         HD4tpzTo8aSnGDNnSnq48q091XHH+L3i/c3esajPniwTugj/0m/hSBJfq9zZsE0XW3oH
         Q38X0hegjHQhoDZJTd0qyuNqSezG9a1f1TXGvCMzU6szAHoQe2tPpigZ/SY3pCQmatq3
         sDlsYQ+2UWeJdFB15HvhjuZa9aH6MS4CX2fGDF8tADQ/MlAXYogdhDaWWy67/OvEZQjh
         qn/A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=Qh34yj/BF1xtDZNSc4yllRfut6YYSlPHZcvjSSUjgyQ=;
        b=DDNqUH0KXq8j9U/Jsg/ugQ13pb9rGJaaVxSy+uZgTYT1wyJeAGCDSHsAGPZIN6Fomd
         fV2glH1W1shqbIEaecyIp5YghQUr8PVy86abE9v/zeLXZrcgu4aOGgwO45N84Y1s9TD9
         grpugLLIEcLWHVZ4eyS6HMoTXYAQJ51kzGF8p1VvPSJSnaxPMe5+O+d/DN6lks8FMT4i
         BVuUn/XtVk06YdhclxSh7ifPK87IbxYcLcR+cZl/UYhaAzMKf7MqgH7rUyIYYEH8WiMg
         ITxp4wFgtdMP8BEtKQdaKG2PnTc1MvKvO1SEjTYgXcpmLi6QHqhCdFydK5o1ZaoM6HN4
         miVg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=iO7EkztH;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id d21si4147831pfj.98.2019.02.14.18.10.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Feb 2019 18:10:22 -0800 (PST)
Received-SPF: pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=iO7EkztH;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from sasha-vm.mshome.net (c-73-47-72-35.hsd1.nh.comcast.net [73.47.72.35])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id EBBBF2229F;
	Fri, 15 Feb 2019 02:10:20 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1550196621;
	bh=d4gbIeZC91ZTxIDuoQcQgg9PCqtubcjoweccGLNMwDQ=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=iO7EkztHBD9GWEJ0uxToewUhfzk933AX6iyl3yytlIkqJ11u82EQMgtUgrBKQP2YF
	 Cerlyj/r14BK8H5nEoysN/LLWVqeGgsvLoIfzU7gX5BntfJ7wEjv+lLsm6Af8+tCVz
	 JazRcTxRuQtE9wBEBTHXZGKzZEJTioSpkVL0WlO8=
From: Sasha Levin <sashal@kernel.org>
To: linux-kernel@vger.kernel.org,
	stable@vger.kernel.org
Cc: Tejun Heo <tj@kernel.org>,
	Jens Axboe <axboe@kernel.dk>,
	Sasha Levin <sashal@kernel.org>,
	linux-fsdevel@vger.kernel.org,
	linux-mm@kvack.org
Subject: [PATCH AUTOSEL 4.20 50/77] writeback: synchronize sync(2) against cgroup writeback membership switches
Date: Thu, 14 Feb 2019 21:08:28 -0500
Message-Id: <20190215020855.176727-50-sashal@kernel.org>
X-Mailer: git-send-email 2.19.1
In-Reply-To: <20190215020855.176727-1-sashal@kernel.org>
References: <20190215020855.176727-1-sashal@kernel.org>
MIME-Version: 1.0
X-Patchwork-Hint: Ignore
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Tejun Heo <tj@kernel.org>

[ Upstream commit 7fc5854f8c6efae9e7624970ab49a1eac2faefb1 ]

sync_inodes_sb() can race against cgwb (cgroup writeback) membership
switches and fail to writeback some inodes.  For example, if an inode
switches to another wb while sync_inodes_sb() is in progress, the new
wb might not be visible to bdi_split_work_to_wbs() at all or the inode
might jump from a wb which hasn't issued writebacks yet to one which
already has.

This patch adds backing_dev_info->wb_switch_rwsem to synchronize cgwb
switch path against sync_inodes_sb() so that sync_inodes_sb() is
guaranteed to see all the target wbs and inodes can't jump wbs to
escape syncing.

v2: Fixed misplaced rwsem init.  Spotted by Jiufei.

Signed-off-by: Tejun Heo <tj@kernel.org>
Reported-by: Jiufei Xue <xuejiufei@gmail.com>
Link: http://lkml.kernel.org/r/dc694ae2-f07f-61e1-7097-7c8411cee12d@gmail.com
Acked-by: Jan Kara <jack@suse.cz>
Signed-off-by: Jens Axboe <axboe@kernel.dk>
Signed-off-by: Sasha Levin <sashal@kernel.org>
---
 fs/fs-writeback.c                | 40 ++++++++++++++++++++++++++++++--
 include/linux/backing-dev-defs.h |  1 +
 mm/backing-dev.c                 |  1 +
 3 files changed, 40 insertions(+), 2 deletions(-)

diff --git a/fs/fs-writeback.c b/fs/fs-writeback.c
index b40168fcc94a..36855c1f8daf 100644
--- a/fs/fs-writeback.c
+++ b/fs/fs-writeback.c
@@ -331,11 +331,22 @@ struct inode_switch_wbs_context {
 	struct work_struct	work;
 };
 
+static void bdi_down_write_wb_switch_rwsem(struct backing_dev_info *bdi)
+{
+	down_write(&bdi->wb_switch_rwsem);
+}
+
+static void bdi_up_write_wb_switch_rwsem(struct backing_dev_info *bdi)
+{
+	up_write(&bdi->wb_switch_rwsem);
+}
+
 static void inode_switch_wbs_work_fn(struct work_struct *work)
 {
 	struct inode_switch_wbs_context *isw =
 		container_of(work, struct inode_switch_wbs_context, work);
 	struct inode *inode = isw->inode;
+	struct backing_dev_info *bdi = inode_to_bdi(inode);
 	struct address_space *mapping = inode->i_mapping;
 	struct bdi_writeback *old_wb = inode->i_wb;
 	struct bdi_writeback *new_wb = isw->new_wb;
@@ -343,6 +354,12 @@ static void inode_switch_wbs_work_fn(struct work_struct *work)
 	struct page *page;
 	bool switched = false;
 
+	/*
+	 * If @inode switches cgwb membership while sync_inodes_sb() is
+	 * being issued, sync_inodes_sb() might miss it.  Synchronize.
+	 */
+	down_read(&bdi->wb_switch_rwsem);
+
 	/*
 	 * By the time control reaches here, RCU grace period has passed
 	 * since I_WB_SWITCH assertion and all wb stat update transactions
@@ -428,6 +445,8 @@ static void inode_switch_wbs_work_fn(struct work_struct *work)
 	spin_unlock(&new_wb->list_lock);
 	spin_unlock(&old_wb->list_lock);
 
+	up_read(&bdi->wb_switch_rwsem);
+
 	if (switched) {
 		wb_wakeup(new_wb);
 		wb_put(old_wb);
@@ -468,9 +487,18 @@ static void inode_switch_wbs(struct inode *inode, int new_wb_id)
 	if (inode->i_state & I_WB_SWITCH)
 		return;
 
+	/*
+	 * Avoid starting new switches while sync_inodes_sb() is in
+	 * progress.  Otherwise, if the down_write protected issue path
+	 * blocks heavily, we might end up starting a large number of
+	 * switches which will block on the rwsem.
+	 */
+	if (!down_read_trylock(&bdi->wb_switch_rwsem))
+		return;
+
 	isw = kzalloc(sizeof(*isw), GFP_ATOMIC);
 	if (!isw)
-		return;
+		goto out_unlock;
 
 	/* find and pin the new wb */
 	rcu_read_lock();
@@ -504,12 +532,14 @@ static void inode_switch_wbs(struct inode *inode, int new_wb_id)
 	 * Let's continue after I_WB_SWITCH is guaranteed to be visible.
 	 */
 	call_rcu(&isw->rcu_head, inode_switch_wbs_rcu_fn);
-	return;
+	goto out_unlock;
 
 out_free:
 	if (isw->new_wb)
 		wb_put(isw->new_wb);
 	kfree(isw);
+out_unlock:
+	up_read(&bdi->wb_switch_rwsem);
 }
 
 /**
@@ -887,6 +917,9 @@ fs_initcall(cgroup_writeback_init);
 
 #else	/* CONFIG_CGROUP_WRITEBACK */
 
+static void bdi_down_write_wb_switch_rwsem(struct backing_dev_info *bdi) { }
+static void bdi_up_write_wb_switch_rwsem(struct backing_dev_info *bdi) { }
+
 static struct bdi_writeback *
 locked_inode_to_wb_and_lock_list(struct inode *inode)
 	__releases(&inode->i_lock)
@@ -2413,8 +2446,11 @@ void sync_inodes_sb(struct super_block *sb)
 		return;
 	WARN_ON(!rwsem_is_locked(&sb->s_umount));
 
+	/* protect against inode wb switch, see inode_switch_wbs_work_fn() */
+	bdi_down_write_wb_switch_rwsem(bdi);
 	bdi_split_work_to_wbs(bdi, &work, false);
 	wb_wait_for_completion(bdi, &done);
+	bdi_up_write_wb_switch_rwsem(bdi);
 
 	wait_sb_inodes(sb);
 }
diff --git a/include/linux/backing-dev-defs.h b/include/linux/backing-dev-defs.h
index c31157135598..07e02d6df5ad 100644
--- a/include/linux/backing-dev-defs.h
+++ b/include/linux/backing-dev-defs.h
@@ -190,6 +190,7 @@ struct backing_dev_info {
 	struct radix_tree_root cgwb_tree; /* radix tree of active cgroup wbs */
 	struct rb_root cgwb_congested_tree; /* their congested states */
 	struct mutex cgwb_release_mutex;  /* protect shutdown of wb structs */
+	struct rw_semaphore wb_switch_rwsem; /* no cgwb switch while syncing */
 #else
 	struct bdi_writeback_congested *wb_congested;
 #endif
diff --git a/mm/backing-dev.c b/mm/backing-dev.c
index 8a8bb8796c6c..72e6d0c55cfa 100644
--- a/mm/backing-dev.c
+++ b/mm/backing-dev.c
@@ -689,6 +689,7 @@ static int cgwb_bdi_init(struct backing_dev_info *bdi)
 	INIT_RADIX_TREE(&bdi->cgwb_tree, GFP_ATOMIC);
 	bdi->cgwb_congested_tree = RB_ROOT;
 	mutex_init(&bdi->cgwb_release_mutex);
+	init_rwsem(&bdi->wb_switch_rwsem);
 
 	ret = wb_init(&bdi->wb, bdi, 1, GFP_KERNEL);
 	if (!ret) {
-- 
2.19.1

