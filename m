Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx191.postini.com [74.125.245.191])
	by kanga.kvack.org (Postfix) with SMTP id 95F826B0033
	for <linux-mm@kvack.org>; Thu, 20 Jun 2013 21:24:28 -0400 (EDT)
Received: from /spool/local
	by e28smtp04.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Fri, 21 Jun 2013 06:48:19 +0530
Received: from d28relay01.in.ibm.com (d28relay01.in.ibm.com [9.184.220.58])
	by d28dlp03.in.ibm.com (Postfix) with ESMTP id C27831258052
	for <linux-mm@kvack.org>; Fri, 21 Jun 2013 06:53:22 +0530 (IST)
Received: from d28av02.in.ibm.com (d28av02.in.ibm.com [9.184.220.64])
	by d28relay01.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r5L1OW4s15663316
	for <linux-mm@kvack.org>; Fri, 21 Jun 2013 06:54:32 +0530
Received: from d28av02.in.ibm.com (loopback [127.0.0.1])
	by d28av02.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r5L1OMks031790
	for <linux-mm@kvack.org>; Fri, 21 Jun 2013 11:24:23 +1000
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: [PATCH v7 1/6] mm/writeback: remove wb_reason_name
Date: Fri, 21 Jun 2013 09:24:14 +0800
Message-Id: <1371777859-13459-1-git-send-email-liwanp@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.cz>, David Rientjes <rientjes@google.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Fengguang Wu <fengguang.wu@intel.com>, Rik van Riel <riel@redhat.com>, Andrew Shewmaker <agshew@gmail.com>, Jiri Kosina <jkosina@suse.cz>, Namjae Jeon <linkinjeon@gmail.com>, Jan Kara <jack@suse.cz>, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Wanpeng Li <liwanp@linux.vnet.ibm.com>

wb_reason_name is not used any more, this patch remove it.

Reviewed-by: Tejun Heo <tj@kernel.org>
Reviewed-by: Fengguang Wu <fengguang.wu@intel.com>
Signed-off-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>
---
 include/linux/writeback.h |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/include/linux/writeback.h b/include/linux/writeback.h
index e27468e..8b5cec4 100644
--- a/include/linux/writeback.h
+++ b/include/linux/writeback.h
@@ -51,7 +51,6 @@ enum wb_reason {
 
 	WB_REASON_MAX,
 };
-extern const char *wb_reason_name[];
 
 /*
  * A control structure which tells the writeback code what to do.  These are
-- 
1.7.5.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
