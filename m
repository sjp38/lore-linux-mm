Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx166.postini.com [74.125.245.166])
	by kanga.kvack.org (Postfix) with SMTP id 1556A6B0037
	for <linux-mm@kvack.org>; Thu, 20 Jun 2013 20:57:29 -0400 (EDT)
Received: from /spool/local
	by e28smtp02.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Fri, 21 Jun 2013 06:19:41 +0530
Received: from d28relay03.in.ibm.com (d28relay03.in.ibm.com [9.184.220.60])
	by d28dlp03.in.ibm.com (Postfix) with ESMTP id 6E7AC125804E
	for <linux-mm@kvack.org>; Fri, 21 Jun 2013 06:26:23 +0530 (IST)
Received: from d28av02.in.ibm.com (d28av02.in.ibm.com [9.184.220.64])
	by d28relay03.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r5L0vW3V32178340
	for <linux-mm@kvack.org>; Fri, 21 Jun 2013 06:27:32 +0530
Received: from d28av02.in.ibm.com (loopback [127.0.0.1])
	by d28av02.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r5L0vMpZ021206
	for <linux-mm@kvack.org>; Fri, 21 Jun 2013 10:57:23 +1000
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: [PATCH v6 3/6] mm/writeback: commit reason of WB_REASON_FORKER_THREAD mismatch name
Date: Fri, 21 Jun 2013 08:57:10 +0800
Message-Id: <1371776233-9364-3-git-send-email-liwanp@linux.vnet.ibm.com>
In-Reply-To: <1371776233-9364-1-git-send-email-liwanp@linux.vnet.ibm.com>
References: <1371776233-9364-1-git-send-email-liwanp@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.cz>, David Rientjes <rientjes@google.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Fengguang Wu <fengguang.wu@intel.com>, Rik van Riel <riel@redhat.com>, Andrew Shewmaker <agshew@gmail.com>, Jiri Kosina <jkosina@suse.cz>, Namjae Jeon <linkinjeon@gmail.com>, Jan Kara <jack@suse.cz>, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Wanpeng Li <liwanp@linux.vnet.ibm.com>

Changelog:
  v4 -> v5:
   * indent the comment

After commit 839a8e86("writeback: replace custom worker pool implementation
with unbound workqueue"), there is no bdi forker thread any more. However,
WB_REASON_FORKER_THREAD is still used due to it is TPs userland visible
and we won't be exposing exactly the same information with just a different
name.

Reviewed-by: Tejun Heo <tj@kernel.org>
Signed-off-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>
---
 include/linux/writeback.h |    6 ++++++
 1 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/include/linux/writeback.h b/include/linux/writeback.h
index 8b5cec4..703a48a 100644
--- a/include/linux/writeback.h
+++ b/include/linux/writeback.h
@@ -47,6 +47,12 @@ enum wb_reason {
 	WB_REASON_LAPTOP_TIMER,
 	WB_REASON_FREE_MORE_MEM,
 	WB_REASON_FS_FREE_SPACE,
+	/*
+	 * There is no bdi forker thread any more and works are done
+	 * by emergency worker, however, this is TPs userland visible 
+	 * and we'll be exposing exactly the same information,
+	 * so it has a mismatch name.
+	 */
 	WB_REASON_FORKER_THREAD,
 
 	WB_REASON_MAX,
-- 
1.7.5.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
