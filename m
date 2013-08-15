Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx168.postini.com [74.125.245.168])
	by kanga.kvack.org (Postfix) with SMTP id 9C9C16B0033
	for <linux-mm@kvack.org>; Wed, 14 Aug 2013 20:32:02 -0400 (EDT)
Received: from /spool/local
	by e28smtp02.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Thu, 15 Aug 2013 05:52:07 +0530
Received: from d28relay05.in.ibm.com (d28relay05.in.ibm.com [9.184.220.62])
	by d28dlp02.in.ibm.com (Postfix) with ESMTP id 477363940062
	for <linux-mm@kvack.org>; Thu, 15 Aug 2013 06:01:46 +0530 (IST)
Received: from d28av03.in.ibm.com (d28av03.in.ibm.com [9.184.220.65])
	by d28relay05.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r7F0VpKu31391800
	for <linux-mm@kvack.org>; Thu, 15 Aug 2013 06:01:52 +0530
Received: from d28av03.in.ibm.com (localhost [127.0.0.1])
	by d28av03.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id r7F0VrKP025211
	for <linux-mm@kvack.org>; Thu, 15 Aug 2013 06:01:54 +0530
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: [PATCH 3/4] mm/writeback: make writeback_inodes_wb static
Date: Thu, 15 Aug 2013 08:31:42 +0800
Message-Id: <1376526703-2081-3-git-send-email-liwanp@linux.vnet.ibm.com>
In-Reply-To: <1376526703-2081-1-git-send-email-liwanp@linux.vnet.ibm.com>
References: <1376526703-2081-1-git-send-email-liwanp@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Dave Hansen <dave.hansen@linux.intel.com>, Fengguang Wu <fengguang.wu@intel.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, David Rientjes <rientjes@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Jiri Kosina <jkosina@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Wanpeng Li <liwanp@linux.vnet.ibm.com>

It's not used globally and could be static.

Signed-off-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>
---
 fs/fs-writeback.c         | 2 +-
 include/linux/writeback.h | 2 --
 2 files changed, 1 insertion(+), 3 deletions(-)

diff --git a/fs/fs-writeback.c b/fs/fs-writeback.c
index 68851ff..a75951c 100644
--- a/fs/fs-writeback.c
+++ b/fs/fs-writeback.c
@@ -723,7 +723,7 @@ static long __writeback_inodes_wb(struct bdi_writeback *wb,
 	return wrote;
 }
 
-long writeback_inodes_wb(struct bdi_writeback *wb, long nr_pages,
+static long writeback_inodes_wb(struct bdi_writeback *wb, long nr_pages,
 				enum wb_reason reason)
 {
 	struct wb_writeback_work work = {
diff --git a/include/linux/writeback.h b/include/linux/writeback.h
index 4e198ca..021b8a3 100644
--- a/include/linux/writeback.h
+++ b/include/linux/writeback.h
@@ -98,8 +98,6 @@ int try_to_writeback_inodes_sb(struct super_block *, enum wb_reason reason);
 int try_to_writeback_inodes_sb_nr(struct super_block *, unsigned long nr,
 				  enum wb_reason reason);
 void sync_inodes_sb(struct super_block *);
-long writeback_inodes_wb(struct bdi_writeback *wb, long nr_pages,
-				enum wb_reason reason);
 void wakeup_flusher_threads(long nr_pages, enum wb_reason reason);
 void inode_wait_for_writeback(struct inode *inode);
 
-- 
1.8.1.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
