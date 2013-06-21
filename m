Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx196.postini.com [74.125.245.196])
	by kanga.kvack.org (Postfix) with SMTP id F32F06B0039
	for <linux-mm@kvack.org>; Thu, 20 Jun 2013 20:57:31 -0400 (EDT)
Received: from /spool/local
	by e28smtp01.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Fri, 21 Jun 2013 06:20:41 +0530
Received: from d28relay03.in.ibm.com (d28relay03.in.ibm.com [9.184.220.60])
	by d28dlp02.in.ibm.com (Postfix) with ESMTP id C3A623940053
	for <linux-mm@kvack.org>; Fri, 21 Jun 2013 06:27:26 +0530 (IST)
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay03.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r5L0vZH732178350
	for <linux-mm@kvack.org>; Fri, 21 Jun 2013 06:27:35 +0530
Received: from d28av01.in.ibm.com (loopback [127.0.0.1])
	by d28av01.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r5L0vPbv010704
	for <linux-mm@kvack.org>; Fri, 21 Jun 2013 00:57:25 GMT
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: [PATCH v6 5/6] mm/thp: fix doc for transparent huge zero page
Date: Fri, 21 Jun 2013 08:57:12 +0800
Message-Id: <1371776233-9364-5-git-send-email-liwanp@linux.vnet.ibm.com>
In-Reply-To: <1371776233-9364-1-git-send-email-liwanp@linux.vnet.ibm.com>
References: <1371776233-9364-1-git-send-email-liwanp@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.cz>, David Rientjes <rientjes@google.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Fengguang Wu <fengguang.wu@intel.com>, Rik van Riel <riel@redhat.com>, Andrew Shewmaker <agshew@gmail.com>, Jiri Kosina <jkosina@suse.cz>, Namjae Jeon <linkinjeon@gmail.com>, Jan Kara <jack@suse.cz>, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Wanpeng Li <liwanp@linux.vnet.ibm.com>

Transparent huge zero page is used during the page fault instead of
in khugepaged.

# ls /sys/kernel/mm/transparent_hugepage/
defrag  enabled  khugepaged  use_zero_page
# ls /sys/kernel/mm/transparent_hugepage/khugepaged/
alloc_sleep_millisecs  defrag  full_scans  max_ptes_none  pages_collapsed  pages_to_scan  scan_sleep_millisecs

This patch corrects the documentation just like the codes done.

Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Signed-off-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>
---
 Documentation/vm/transhuge.txt |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/Documentation/vm/transhuge.txt b/Documentation/vm/transhuge.txt
index 8785fb8..4a63953 100644
--- a/Documentation/vm/transhuge.txt
+++ b/Documentation/vm/transhuge.txt
@@ -120,8 +120,8 @@ By default kernel tries to use huge zero page on read page fault.
 It's possible to disable huge zero page by writing 0 or enable it
 back by writing 1:
 
-echo 0 >/sys/kernel/mm/transparent_hugepage/khugepaged/use_zero_page
-echo 1 >/sys/kernel/mm/transparent_hugepage/khugepaged/use_zero_page
+echo 0 >/sys/kernel/mm/transparent_hugepage/use_zero_page
+echo 1 >/sys/kernel/mm/transparent_hugepage/use_zero_page
 
 khugepaged will be automatically started when
 transparent_hugepage/enabled is set to "always" or "madvise, and it'll
-- 
1.7.5.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
