Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx115.postini.com [74.125.245.115])
	by kanga.kvack.org (Postfix) with SMTP id B2BF76B0037
	for <linux-mm@kvack.org>; Tue, 18 Jun 2013 07:34:07 -0400 (EDT)
Received: from /spool/local
	by e23smtp09.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Wed, 19 Jun 2013 08:30:33 +1000
Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [9.190.235.21])
	by d23dlp01.au.ibm.com (Postfix) with ESMTP id 173D52CE8044
	for <linux-mm@kvack.org>; Tue, 18 Jun 2013 21:34:03 +1000 (EST)
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r5IBXsYb6750474
	for <linux-mm@kvack.org>; Tue, 18 Jun 2013 21:33:54 +1000
Received: from d23av03.au.ibm.com (loopback [127.0.0.1])
	by d23av03.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r5IBY2Ts002493
	for <linux-mm@kvack.org>; Tue, 18 Jun 2013 21:34:02 +1000
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: [PATCH v3 3/6] mm/writeback: commit reason of WB_REASON_FORKER_THREAD mismatch name
Date: Tue, 18 Jun 2013 19:33:39 +0800
Message-Id: <1371555222-22678-3-git-send-email-liwanp@linux.vnet.ibm.com>
In-Reply-To: <1371555222-22678-1-git-send-email-liwanp@linux.vnet.ibm.com>
References: <1371555222-22678-1-git-send-email-liwanp@linux.vnet.ibm.com>
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
 include/linux/writeback.h |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/include/linux/writeback.h b/include/linux/writeback.h
index 8b5cec4..ac73a9d 100644
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
1.7.5.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
