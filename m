Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na6sys010bmx008.postini.com [74.125.246.108])
	by kanga.kvack.org (Postfix) with SMTP id 421A16B0033
	for <linux-mm@kvack.org>; Thu, 20 Jun 2013 20:29:05 -0400 (EDT)
Received: from /spool/local
	by e28smtp01.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Fri, 21 Jun 2013 05:52:14 +0530
Received: from d28relay05.in.ibm.com (d28relay05.in.ibm.com [9.184.220.62])
	by d28dlp03.in.ibm.com (Postfix) with ESMTP id 2B64C125804E
	for <linux-mm@kvack.org>; Fri, 21 Jun 2013 05:57:59 +0530 (IST)
Received: from d28av04.in.ibm.com (d28av04.in.ibm.com [9.184.220.66])
	by d28relay05.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r5L0StTR27656394
	for <linux-mm@kvack.org>; Fri, 21 Jun 2013 05:58:55 +0530
Received: from d28av04.in.ibm.com (loopback [127.0.0.1])
	by d28av04.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r5L0SwIt031062
	for <linux-mm@kvack.org>; Fri, 21 Jun 2013 10:28:59 +1000
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: [PATCH v5 1/6] mm/writeback: remove wb_reason_name
Date: Fri, 21 Jun 2013 08:28:49 +0800
Message-Id: <1371774534-4139-1-git-send-email-liwanp@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.cz>, David Rientjes <rientjes@google.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Fengguang Wu <fengguang.wu@intel.com>, Rik van Riel <riel@redhat.com>, Andrew Shewmaker <agshew@gmail.com>, Jiri Kosina <jkosina@suse.cz>, Namjae Jeon <linkinjeon@gmail.com>, Jan Kara <jack@suse.cz>, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Wanpeng Li <liwanp@linux.vnet.ibm.com>

wb_reason_name is not used any more, this patch remove it.

Reviewed-by: Tejun Heo <tj@kernel.org>
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
