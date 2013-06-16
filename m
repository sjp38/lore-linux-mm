Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx166.postini.com [74.125.245.166])
	by kanga.kvack.org (Postfix) with SMTP id 031D86B003A
	for <linux-mm@kvack.org>; Sat, 15 Jun 2013 21:15:09 -0400 (EDT)
Received: from /spool/local
	by e28smtp02.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Sun, 16 Jun 2013 06:37:33 +0530
Received: from d28relay04.in.ibm.com (d28relay04.in.ibm.com [9.184.220.61])
	by d28dlp03.in.ibm.com (Postfix) with ESMTP id 1D4391258043
	for <linux-mm@kvack.org>; Sun, 16 Jun 2013 06:44:00 +0530 (IST)
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay04.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r5G1Exf322544558
	for <linux-mm@kvack.org>; Sun, 16 Jun 2013 06:44:59 +0530
Received: from d28av01.in.ibm.com (loopback [127.0.0.1])
	by d28av01.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r5G1F3NX010213
	for <linux-mm@kvack.org>; Sun, 16 Jun 2013 01:15:04 GMT
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: [PATCH v2 5/7] mm/page_alloc: fix doc for numa_zonelist_order
Date: Sun, 16 Jun 2013 09:14:48 +0800
Message-Id: <1371345290-19588-5-git-send-email-liwanp@linux.vnet.ibm.com>
In-Reply-To: <1371345290-19588-1-git-send-email-liwanp@linux.vnet.ibm.com>
References: <1371345290-19588-1-git-send-email-liwanp@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.cz>, David Rientjes <rientjes@google.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Fengguang Wu <fengguang.wu@intel.com>, Rik van Riel <riel@redhat.com>, Andrew Shewmaker <agshew@gmail.com>, Jiri Kosina <jkosina@suse.cz>, Namjae Jeon <linkinjeon@gmail.com>, Jan Kara <jack@suse.cz>, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Wanpeng Li <liwanp@linux.vnet.ibm.com>

The default zonelist order selecter will select "node" order if any node's
DMA zone comprises greater than 70% of its local memory instead of 60%,
according to default_zonelist_order::low_kmem_size > total * 70/100.

Signed-off-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>
---
 Documentation/sysctl/vm.txt | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/Documentation/sysctl/vm.txt b/Documentation/sysctl/vm.txt
index a5717c3..15d341a 100644
--- a/Documentation/sysctl/vm.txt
+++ b/Documentation/sysctl/vm.txt
@@ -531,7 +531,7 @@ Specify "[Dd]efault" to request automatic configuration.  Autoconfiguration
 will select "node" order in following case.
 (1) if the DMA zone does not exist or
 (2) if the DMA zone comprises greater than 50% of the available memory or
-(3) if any node's DMA zone comprises greater than 60% of its local memory and
+(3) if any node's DMA zone comprises greater than 70% of its local memory and
     the amount of local memory is big enough.
 
 Otherwise, "zone" order will be selected. Default order is recommended unless
-- 
1.8.1.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
