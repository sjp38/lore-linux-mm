Return-Path: <SRS0=Ffi5=RF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 532C0C43381
	for <linux-mm@archiver.kernel.org>; Sat,  2 Mar 2019 10:43:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id ECFE120838
	for <linux-mm@archiver.kernel.org>; Sat,  2 Mar 2019 10:43:11 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org ECFE120838
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=huawei.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5C2AC8E0003; Sat,  2 Mar 2019 05:43:11 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 573998E0001; Sat,  2 Mar 2019 05:43:11 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4623F8E0003; Sat,  2 Mar 2019 05:43:11 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f200.google.com (mail-oi1-f200.google.com [209.85.167.200])
	by kanga.kvack.org (Postfix) with ESMTP id 2370C8E0001
	for <linux-mm@kvack.org>; Sat,  2 Mar 2019 05:43:11 -0500 (EST)
Received: by mail-oi1-f200.google.com with SMTP id y145so217166oie.18
        for <linux-mm@kvack.org>; Sat, 02 Mar 2019 02:43:11 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to
         :subject:date:message-id:mime-version;
        bh=6X5ceuELLIFiJjtFBjRuLqO7DrKLaI3t1LpqZ3/WDQQ=;
        b=pRQ/WtfdZdBYeXcHlUxEXCRZwHt6oMkpivCAYYdqabOMnSIDR0tZG2Keb/5/j3DK3V
         jrKyxN5E28an7t3MTXa5vx5iHxAougPOm798G4H93fjuTTtjF5csEeNNgGBHYTmUBYTS
         T9nvua1pLUbqC7mmC1ANLrejPjYQwDb5d9f0Oez3SVRQjRbguqwpMfqqqTDPUlZKM89S
         rxjUkQvaFo6CE1tXLqGQlfOGuu4CSyfmyPZiCwh3d4/Mm1vYhE4IcW6nzJPDPikFVWPn
         CEZR84CV9gyUiNzZYlTjW04F9T+4+6R+kbFjp/hpjQNCkV2jupN2D6a6SdT5cPMMOhIL
         OvSw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yuyufen@huawei.com designates 45.249.212.191 as permitted sender) smtp.mailfrom=yuyufen@huawei.com
X-Gm-Message-State: AHQUAuY2uKBJDneq4vtGY1yhnjSDlkHQwzOC5hlCEg/FOsU6nth0ZSPW
	3FPBHJeuF5Y3KTxRmx+c73ObO52/qcrsE2JcYJOT+HQvmfQIMW5GXPyre0VwN7fBj2rIM4mttF0
	Ln3kT3DSo1Y9OqN3IvrxaAzzICS5dohlf0WsVKP8IxWD2WJCFHyMz2TxsOXfzaNCoXg==
X-Received: by 2002:a05:6808:1d4:: with SMTP id x20mr6246082oic.98.1551523390744;
        Sat, 02 Mar 2019 02:43:10 -0800 (PST)
X-Google-Smtp-Source: AHgI3Ib+Y7jrpeLDMZVf72i0WNn+FJZSt7HbZM/anIfno9Z8ISDLihgKzYvgiupt/5XquWdFmKRI
X-Received: by 2002:a05:6808:1d4:: with SMTP id x20mr6246045oic.98.1551523389319;
        Sat, 02 Mar 2019 02:43:09 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551523389; cv=none;
        d=google.com; s=arc-20160816;
        b=U2ROqhmlGTRvmUExLBJWMEfvi6b8OWbXNxctDLQOWc7pagP454uwzSf3PEKQ+twgYa
         mA/phNftRCyZf9pb1FJR/T9JElw5WDTP2W5OkNgbcloTUtuHhQbW6PKwqJJcS+RD+XHb
         o4GJMPxwKHeM1M/FZwj8vfMyD2SXRM6BBpwP1vaHxqgBU8ijAexaEL6wk4EM0vqVo5Y0
         jCQ8myJatu0cSqemjfSXMIXNP72V2s+LdPG5rzDhUVxaw8jO8BGktNQ1kvhchzeSgpym
         MCweo8N+WVLFyipRGeWz3RPRyyby+1ko16vp7YcS3sWqa08lXiA7F31xh37S4pmTYpXk
         a4sQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:message-id:date:subject:to:from;
        bh=6X5ceuELLIFiJjtFBjRuLqO7DrKLaI3t1LpqZ3/WDQQ=;
        b=mtiLSnta0JLME7Hgy8p1SzMK0UPoQ1nyJ96ScK4rQgrMFqiLSrteFNcjPW5LPMGPwY
         OhI5iUTezaB+FOdjPC/DAIUybZCRE7bp9CJlUMo7vjJrrrB6YsflYzuZNHyAqeFWjedl
         9TXXnlQLNFhqPhLV39fl3i8eE7UypLeH6FQbjftb6EhuMItGtoIiaJFWZM6PcTshCInA
         Z6n9OA8KfAEqo6V06wVymk2gtlFU1RqfuoCxqELJXUjQiCCSGHSFY00OLGX1SaYoGm4h
         7r7YZgcwgmBvbn9bmHFDm36fIpeG70QUqC8/WBn/CZPYrgUBp6L3mWo/qtF9N+R3ZkPq
         RUlg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yuyufen@huawei.com designates 45.249.212.191 as permitted sender) smtp.mailfrom=yuyufen@huawei.com
Received: from huawei.com (szxga05-in.huawei.com. [45.249.212.191])
        by mx.google.com with ESMTPS id f8si229248oti.298.2019.03.02.02.43.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 02 Mar 2019 02:43:09 -0800 (PST)
Received-SPF: pass (google.com: domain of yuyufen@huawei.com designates 45.249.212.191 as permitted sender) client-ip=45.249.212.191;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yuyufen@huawei.com designates 45.249.212.191 as permitted sender) smtp.mailfrom=yuyufen@huawei.com
Received: from DGGEMS413-HUB.china.huawei.com (unknown [172.30.72.60])
	by Forcepoint Email with ESMTP id 492D549E020AE316964D;
	Sat,  2 Mar 2019 18:43:05 +0800 (CST)
Received: from huawei.com (10.90.53.225) by DGGEMS413-HUB.china.huawei.com
 (10.3.19.213) with Microsoft SMTP Server id 14.3.408.0; Sat, 2 Mar 2019
 18:43:03 +0800
From: Yufen Yu <yuyufen@huawei.com>
To: <mike.kravetz@oracle.com>, <linux-mm@kvack.org>
Subject: [PATCH] hugetlbfs: fix memory leak for resv_map
Date: Sat, 2 Mar 2019 18:47:13 +0800
Message-ID: <20190302104713.31467-1-yuyufen@huawei.com>
X-Mailer: git-send-email 2.16.2.dirty
MIME-Version: 1.0
Content-Type: text/plain
X-Originating-IP: [10.90.53.225]
X-CFilter-Loop: Reflected
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

When .mknod create a block device file in hugetlbfs, it will
allocate an inode, and kmalloc a 'struct resv_map' in resv_map_alloc().
For now, inode->i_mapping->private_data is used to point the resv_map.
However, when open the device, bd_acquire() will set i_mapping as
bd_inode->imapping, result in resv_map memory leak.

We fix the leak by adding a new entry resv_map in hugetlbfs_inode_info.
It can store resv_map pointer.

Programs to reproduce:
	mount -t hugetlbfs nodev hugetlbfs
	mknod hugetlbfs/dev b 0 0
	exec 30<> hugetlbfs/dev
	umount hugetlbfs/

Fixes: 9119a41e90 ("mm, hugetlb: unify region structure handling")
Signed-off-by: Yufen Yu <yuyufen@huawei.com>
---
 fs/hugetlbfs/inode.c    | 12 +++++++++---
 include/linux/hugetlb.h |  1 +
 mm/hugetlb.c            |  2 +-
 3 files changed, 11 insertions(+), 4 deletions(-)

diff --git a/fs/hugetlbfs/inode.c b/fs/hugetlbfs/inode.c
index a7fa037b876b..7f332443c5da 100644
--- a/fs/hugetlbfs/inode.c
+++ b/fs/hugetlbfs/inode.c
@@ -484,11 +484,15 @@ static void hugetlbfs_evict_inode(struct inode *inode)
 {
 	struct resv_map *resv_map;
 
+	struct hugetlbfs_inode_info *info = HUGETLBFS_I(inode);
+
 	remove_inode_hugepages(inode, 0, LLONG_MAX);
-	resv_map = (struct resv_map *)inode->i_mapping->private_data;
+	resv_map = info->resv_map;
 	/* root inode doesn't have the resv_map, so we should check it */
-	if (resv_map)
+	if (resv_map) {
 		resv_map_release(&resv_map->refs);
+		info->resv_map = NULL;
+	}
 	clear_inode(inode);
 }
 
@@ -757,7 +761,7 @@ static struct inode *hugetlbfs_get_inode(struct super_block *sb,
 				&hugetlbfs_i_mmap_rwsem_key);
 		inode->i_mapping->a_ops = &hugetlbfs_aops;
 		inode->i_atime = inode->i_mtime = inode->i_ctime = current_time(inode);
-		inode->i_mapping->private_data = resv_map;
+		info->resv_map = resv_map;
 		info->seals = F_SEAL_SEAL;
 		switch (mode & S_IFMT) {
 		default:
@@ -1025,6 +1029,7 @@ static struct inode *hugetlbfs_alloc_inode(struct super_block *sb)
 	 * private inode.  This simplifies hugetlbfs_destroy_inode.
 	 */
 	mpol_shared_policy_init(&p->policy, NULL);
+	p->resv_map = NULL;
 
 	return &p->vfs_inode;
 }
@@ -1039,6 +1044,7 @@ static void hugetlbfs_destroy_inode(struct inode *inode)
 {
 	hugetlbfs_inc_free_inodes(HUGETLBFS_SB(inode->i_sb));
 	mpol_free_shared_policy(&HUGETLBFS_I(inode)->policy);
+	HUGETLBFS_I(inode)->resv_map = NULL;
 	call_rcu(&inode->i_rcu, hugetlbfs_i_callback);
 }
 
diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
index 087fd5f48c91..eafcf14056bc 100644
--- a/include/linux/hugetlb.h
+++ b/include/linux/hugetlb.h
@@ -291,6 +291,7 @@ struct hugetlbfs_inode_info {
 	struct shared_policy policy;
 	struct inode vfs_inode;
 	unsigned int seals;
+	struct resv_map *resv_map;
 };
 
 static inline struct hugetlbfs_inode_info *HUGETLBFS_I(struct inode *inode)
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 8dfdffc34a99..763164b15f8f 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -739,7 +739,7 @@ void resv_map_release(struct kref *ref)
 
 static inline struct resv_map *inode_resv_map(struct inode *inode)
 {
-	return inode->i_mapping->private_data;
+	return HUGETLBFS_I(inode)->resv_map;
 }
 
 static struct resv_map *vma_resv_map(struct vm_area_struct *vma)
-- 
2.16.2.dirty

