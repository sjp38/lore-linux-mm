Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f171.google.com (mail-qk0-f171.google.com [209.85.220.171])
	by kanga.kvack.org (Postfix) with ESMTP id BB270829CE
	for <linux-mm@kvack.org>; Fri, 22 May 2015 17:15:58 -0400 (EDT)
Received: by qkx62 with SMTP id 62so22162440qkx.3
        for <linux-mm@kvack.org>; Fri, 22 May 2015 14:15:58 -0700 (PDT)
Received: from mail-qg0-x22c.google.com (mail-qg0-x22c.google.com. [2607:f8b0:400d:c04::22c])
        by mx.google.com with ESMTPS id l5si3691134qkh.99.2015.05.22.14.15.57
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 May 2015 14:15:58 -0700 (PDT)
Received: by qgez61 with SMTP id z61so16267873qge.1
        for <linux-mm@kvack.org>; Fri, 22 May 2015 14:15:57 -0700 (PDT)
From: Tejun Heo <tj@kernel.org>
Subject: [PATCH 51/51] ext2: enable cgroup writeback support
Date: Fri, 22 May 2015 17:14:05 -0400
Message-Id: <1432329245-5844-52-git-send-email-tj@kernel.org>
In-Reply-To: <1432329245-5844-1-git-send-email-tj@kernel.org>
References: <1432329245-5844-1-git-send-email-tj@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: axboe@kernel.dk
Cc: linux-kernel@vger.kernel.org, jack@suse.cz, hch@infradead.org, hannes@cmpxchg.org, linux-fsdevel@vger.kernel.org, vgoyal@redhat.com, lizefan@huawei.com, cgroups@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.cz, clm@fb.com, fengguang.wu@intel.com, david@fromorbit.com, gthelen@google.com, khlebnikov@yandex-team.ru, Tejun Heo <tj@kernel.org>, linux-ext4@vger.kernel.org

Writeback now supports cgroup writeback and the generic writeback,
buffer, libfs, and mpage helpers that ext2 uses are all updated to
work with cgroup writeback.

This patch enables cgroup writeback for ext2 by adding
FS_CGROUP_WRITEBACK to its ->fs_flags.

Signed-off-by: Tejun Heo <tj@kernel.org>
Cc: Jens Axboe <axboe@kernel.dk>
Cc: Jan Kara <jack@suse.cz>
Cc: linux-ext4@vger.kernel.org
---
 fs/ext2/super.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/ext2/super.c b/fs/ext2/super.c
index d0e746e..549219d 100644
--- a/fs/ext2/super.c
+++ b/fs/ext2/super.c
@@ -1543,7 +1543,7 @@ static struct file_system_type ext2_fs_type = {
 	.name		= "ext2",
 	.mount		= ext2_mount,
 	.kill_sb	= kill_block_super,
-	.fs_flags	= FS_REQUIRES_DEV,
+	.fs_flags	= FS_REQUIRES_DEV | FS_CGROUP_WRITEBACK,
 };
 MODULE_ALIAS_FS("ext2");
 
-- 
2.4.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
