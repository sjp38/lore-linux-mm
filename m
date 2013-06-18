Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx157.postini.com [74.125.245.157])
	by kanga.kvack.org (Postfix) with SMTP id 539566B0032
	for <linux-mm@kvack.org>; Tue, 18 Jun 2013 07:34:03 -0400 (EDT)
Received: from /spool/local
	by e23smtp07.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Tue, 18 Jun 2013 21:22:43 +1000
Received: from d23relay05.au.ibm.com (d23relay05.au.ibm.com [9.190.235.152])
	by d23dlp01.au.ibm.com (Postfix) with ESMTP id 9526B2CE8051
	for <linux-mm@kvack.org>; Tue, 18 Jun 2013 21:33:57 +1000 (EST)
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay05.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r5IBJ6tA6357290
	for <linux-mm@kvack.org>; Tue, 18 Jun 2013 21:19:07 +1000
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r5IBXtPO014194
	for <linux-mm@kvack.org>; Tue, 18 Jun 2013 21:33:56 +1000
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: [PATCH v3 1/6] mm/writeback: remove wb_reason_name
Date: Tue, 18 Jun 2013 19:33:37 +0800
Message-Id: <1371555222-22678-1-git-send-email-liwanp@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.cz>, David Rientjes <rientjes@google.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Fengguang Wu <fengguang.wu@intel.com>, Rik van Riel <riel@redhat.com>, Andrew Shewmaker <agshew@gmail.com>, Jiri Kosina <jkosina@suse.cz>, Namjae Jeon <linkinjeon@gmail.com>, Jan Kara <jack@suse.cz>, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Wanpeng Li <liwanp@linux.vnet.ibm.com>

wb_reason_name is not used any more, this patch remove it.

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
