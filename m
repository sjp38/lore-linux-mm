Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f182.google.com (mail-qk0-f182.google.com [209.85.220.182])
	by kanga.kvack.org (Postfix) with ESMTP id 81E11280281
	for <linux-mm@kvack.org>; Sat,  4 Jul 2015 11:12:05 -0400 (EDT)
Received: by qkhu186 with SMTP id u186so90149221qkh.0
        for <linux-mm@kvack.org>; Sat, 04 Jul 2015 08:12:05 -0700 (PDT)
Received: from mail-qk0-x22b.google.com (mail-qk0-x22b.google.com. [2607:f8b0:400d:c09::22b])
        by mx.google.com with ESMTPS id f207si14382874qhc.94.2015.07.04.08.12.04
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 04 Jul 2015 08:12:04 -0700 (PDT)
Received: by qkei195 with SMTP id i195so90181757qke.3
        for <linux-mm@kvack.org>; Sat, 04 Jul 2015 08:12:04 -0700 (PDT)
Date: Sat, 4 Jul 2015 11:12:00 -0400
From: Tejun Heo <tj@kernel.org>
Subject: [PATCH block/for-4.3] writeback: explain why @inode is allowed to be
 NULL for inode_congested()
Message-ID: <20150704151200.GA13251@mtj.duckdns.org>
References: <1432329245-5844-1-git-send-email-tj@kernel.org>
 <1432329245-5844-31-git-send-email-tj@kernel.org>
 <20150630152105.GP7252@quack.suse.cz>
 <20150702014634.GF26440@mtj.duckdns.org>
 <20150703121721.GJ23329@quack.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150703121721.GJ23329@quack.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: axboe@kernel.dk, linux-kernel@vger.kernel.org, hch@infradead.org, hannes@cmpxchg.org, linux-fsdevel@vger.kernel.org, vgoyal@redhat.com, lizefan@huawei.com, cgroups@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.cz, clm@fb.com, fengguang.wu@intel.com, david@fromorbit.com, gthelen@google.com, khlebnikov@yandex-team.ru

Signed-off-by: Tejun Heo <tj@kernel.org>
Suggested-by: Jan Kara <jack@suse.cz>
---
Hello,

So, something like this.  I'll resend this patch as part of a patch
series once -rc1 drops.

Thanks.

 fs/fs-writeback.c |    5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

--- a/fs/fs-writeback.c
+++ b/fs/fs-writeback.c
@@ -700,7 +700,7 @@ void wbc_account_io(struct writeback_con
 
 /**
  * inode_congested - test whether an inode is congested
- * @inode: inode to test for congestion
+ * @inode: inode to test for congestion (may be NULL)
  * @cong_bits: mask of WB_[a]sync_congested bits to test
  *
  * Tests whether @inode is congested.  @cong_bits is the mask of congestion
@@ -710,6 +710,9 @@ void wbc_account_io(struct writeback_con
  * determined by whether the cgwb (cgroup bdi_writeback) for the blkcg
  * associated with @inode is congested; otherwise, the root wb's congestion
  * state is used.
+ *
+ * @inode is allowed to be NULL as this function is often called on
+ * mapping->host which is NULL for the swapper space.
  */
 int inode_congested(struct inode *inode, int cong_bits)
 {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
