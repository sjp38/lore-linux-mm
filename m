Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx172.postini.com [74.125.245.172])
	by kanga.kvack.org (Postfix) with SMTP id 61DFC6B0038
	for <linux-mm@kvack.org>; Sat, 15 Jun 2013 21:15:07 -0400 (EDT)
Received: from /spool/local
	by e28smtp06.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Sun, 16 Jun 2013 06:37:54 +0530
Received: from d28relay02.in.ibm.com (d28relay02.in.ibm.com [9.184.220.59])
	by d28dlp02.in.ibm.com (Postfix) with ESMTP id 0D27F394004F
	for <linux-mm@kvack.org>; Sun, 16 Jun 2013 06:45:01 +0530 (IST)
Received: from d28av05.in.ibm.com (d28av05.in.ibm.com [9.184.220.67])
	by d28relay02.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r5G1F5OP25624818
	for <linux-mm@kvack.org>; Sun, 16 Jun 2013 06:45:05 +0530
Received: from d28av05.in.ibm.com (loopback [127.0.0.1])
	by d28av05.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r5G1ExcW002791
	for <linux-mm@kvack.org>; Sun, 16 Jun 2013 11:15:00 +1000
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: [PATCH v2 3/7] mm/writeback: commit reason of WB_REASON_FORKER_THREAD mismatch name 
Date: Sun, 16 Jun 2013 09:14:46 +0800
Message-Id: <1371345290-19588-3-git-send-email-liwanp@linux.vnet.ibm.com>
In-Reply-To: <1371345290-19588-1-git-send-email-liwanp@linux.vnet.ibm.com>
References: <1371345290-19588-1-git-send-email-liwanp@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.cz>, David Rientjes <rientjes@google.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Fengguang Wu <fengguang.wu@intel.com>, Rik van Riel <riel@redhat.com>, Andrew Shewmaker <agshew@gmail.com>, Jiri Kosina <jkosina@suse.cz>, Namjae Jeon <linkinjeon@gmail.com>, Jan Kara <jack@suse.cz>, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Wanpeng Li <liwanp@linux.vnet.ibm.com>

After commit 839a8e86("writeback: replace custom worker pool implementation
with unbound workqueue"), there is no bdi forker thread any more. However,
WB_REASON_FORKER_THREAD is still used due to it is somewhat userland visible 
and we won't be exposing exactly the same information with just a different 
name. 

Signed-off-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>
---
 include/linux/writeback.h | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/include/linux/writeback.h b/include/linux/writeback.h
index 8b5cec4..cf077a7 100644
--- a/include/linux/writeback.h
+++ b/include/linux/writeback.h
@@ -47,6 +47,11 @@ enum wb_reason {
 	WB_REASON_LAPTOP_TIMER,
 	WB_REASON_FREE_MORE_MEM,
 	WB_REASON_FS_FREE_SPACE,
+/*
+ * There is no bdi forker thread any more and works are done by emergency
+ * worker, however, this is somewhat userland visible and we'll be exposing
+ * exactly the same information, so it has a mismatch name.
+ */
 	WB_REASON_FORKER_THREAD,
 
 	WB_REASON_MAX,
-- 
1.8.1.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
