Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx148.postini.com [74.125.245.148])
	by kanga.kvack.org (Postfix) with SMTP id 8887A6B003D
	for <linux-mm@kvack.org>; Mon, 26 Aug 2013 04:46:41 -0400 (EDT)
Received: from /spool/local
	by e23smtp02.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Mon, 26 Aug 2013 18:35:17 +1000
Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [9.190.235.21])
	by d23dlp02.au.ibm.com (Postfix) with ESMTP id 36E582BB0053
	for <linux-mm@kvack.org>; Mon, 26 Aug 2013 18:46:36 +1000 (EST)
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r7Q8kOo447644768
	for <linux-mm@kvack.org>; Mon, 26 Aug 2013 18:46:25 +1000
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r7Q8kYBZ030959
	for <linux-mm@kvack.org>; Mon, 26 Aug 2013 18:46:35 +1000
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: [PATCH v4 9/10] mm/hwpoison: change permission of corrupt-pfn/unpoison-pfn to 0400 
Date: Mon, 26 Aug 2013 16:46:13 +0800
Message-Id: <1377506774-5377-9-git-send-email-liwanp@linux.vnet.ibm.com>
In-Reply-To: <1377506774-5377-1-git-send-email-liwanp@linux.vnet.ibm.com>
References: <1377506774-5377-1-git-send-email-liwanp@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andi Kleen <andi@firstfloor.org>, Fengguang Wu <fengguang.wu@intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Tony Luck <tony.luck@intel.com>, gong.chen@linux.intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Wanpeng Li <liwanp@linux.vnet.ibm.com>

Hwpoison inject doesn't implement read method for corrupt-pfn/unpoison-pfn
attributes:

# cat /sys/kernel/debug/hwpoison/corrupt-pfn 
cat: /sys/kernel/debug/hwpoison/corrupt-pfn: Permission denied
# cat /sys/kernel/debug/hwpoison/unpoison-pfn 
cat: /sys/kernel/debug/hwpoison/unpoison-pfn: Permission denied

This patch change the permission of corrupt-pfn/unpoison-pfn to 0400.

Signed-off-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>
---
 mm/hwpoison-inject.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/hwpoison-inject.c b/mm/hwpoison-inject.c
index 3a61efc..8b77bfd 100644
--- a/mm/hwpoison-inject.c
+++ b/mm/hwpoison-inject.c
@@ -88,12 +88,12 @@ static int pfn_inject_init(void)
 	 * hardware status change, hence do not require hardware support.
 	 * They are mainly for testing hwpoison in software level.
 	 */
-	dentry = debugfs_create_file("corrupt-pfn", 0600, hwpoison_dir,
+	dentry = debugfs_create_file("corrupt-pfn", 0400, hwpoison_dir,
 					  NULL, &hwpoison_fops);
 	if (!dentry)
 		goto fail;
 
-	dentry = debugfs_create_file("unpoison-pfn", 0600, hwpoison_dir,
+	dentry = debugfs_create_file("unpoison-pfn", 0400, hwpoison_dir,
 				     NULL, &unpoison_fops);
 	if (!dentry)
 		goto fail;
-- 
1.8.1.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
