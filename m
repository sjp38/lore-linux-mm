Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx197.postini.com [74.125.245.197])
	by kanga.kvack.org (Postfix) with SMTP id 3AF0A6B0087
	for <linux-mm@kvack.org>; Mon, 13 Aug 2012 07:17:45 -0400 (EDT)
Received: from /spool/local
	by e23smtp06.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <xiaoguangrong@linux.vnet.ibm.com>;
	Mon, 13 Aug 2012 21:17:09 +1000
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay05.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q7DB8x6F20447264
	for <linux-mm@kvack.org>; Mon, 13 Aug 2012 21:08:59 +1000
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q7DBHdPi004871
	for <linux-mm@kvack.org>; Mon, 13 Aug 2012 21:17:39 +1000
Message-ID: <5028E251.1070007@linux.vnet.ibm.com>
Date: Mon, 13 Aug 2012 19:17:37 +0800
From: Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: [PATCH 12/12] thp: remove unnecessary set_recommended_min_free_kbytes
References: <5028E12C.70101@linux.vnet.ibm.com>
In-Reply-To: <5028E12C.70101@linux.vnet.ibm.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, David Rientjes <rientjes@google.com>, LKML <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>

Since it is called in start_khugepaged

Signed-off-by: Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>
---
 mm/huge_memory.c |    5 -----
 1 files changed, 0 insertions(+), 5 deletions(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 6becf6c..6533956 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -225,9 +225,6 @@ static ssize_t enabled_store(struct kobject *kobj,
 			ret = err;
 	}

-	if (ret > 0 && khugepaged_enabled())
-		set_recommended_min_free_kbytes();
-
 	return ret;
 }
 static struct kobj_attribute enabled_attr =
@@ -562,8 +559,6 @@ static int __init hugepage_init(void)

 	start_khugepaged();

-	set_recommended_min_free_kbytes();
-
 	return 0;
 out:
 	hugepage_exit_sysfs(hugepage_kobj);
-- 
1.7.7.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
