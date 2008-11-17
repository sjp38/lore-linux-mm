Received: from d28relay04.in.ibm.com (d28relay04.in.ibm.com [9.184.220.61])
	by e28smtp01.in.ibm.com (8.13.1/8.13.1) with ESMTP id mAH4eTCL000971
	for <linux-mm@kvack.org>; Mon, 17 Nov 2008 10:10:29 +0530
Received: from d28av02.in.ibm.com (d28av02.in.ibm.com [9.184.220.64])
	by d28relay04.in.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id mAH4eTjw1241168
	for <linux-mm@kvack.org>; Mon, 17 Nov 2008 10:10:29 +0530
Received: from d28av02.in.ibm.com (loopback [127.0.0.1])
	by d28av02.in.ibm.com (8.13.1/8.13.3) with ESMTP id mAH4e43b021040
	for <linux-mm@kvack.org>; Mon, 17 Nov 2008 10:10:05 +0530
Date: Mon, 17 Nov 2008 10:10:08 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Fix typo in swap cgroup message
Message-ID: <20081117044008.GA25269@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Hugh Dickins <hugh@veritas.com>, Li Zefan <lizf@cn.fujitsu.com>, Pavel Emelyanov <xemul@openvz.org>
List-ID: <linux-mm.kvack.org>

There is a typo in the spelling of buffers (buffres) and the message is
not very clear either. Fix the message and typo (hopefully not introducing
any new ones ;) )

Cc: Hugh Dickins <hugh@veritas.com>
Cc: Li Zefan <lizf@cn.fujitsu.com>
Cc: Pavel Emelyanov <xemul@openvz.org>
Signed-off-by: Balbir Singh <balbir@linux.vnet.ibm.com>
---

 mm/page_cgroup.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff -puN mm/page_cgroup.c~fix-typo-swap-cgroup mm/page_cgroup.c
--- linux-2.6.28-rc4/mm/page_cgroup.c~fix-typo-swap-cgroup	2008-11-16 20:03:28.000000000 +0530
+++ linux-2.6.28-rc4-balbir/mm/page_cgroup.c	2008-11-17 09:59:43.000000000 +0530
@@ -423,7 +423,8 @@ int swap_cgroup_swapon(int type, unsigne
 	mutex_unlock(&swap_cgroup_mutex);
 
 	printk(KERN_INFO
-		"swap_cgroup: uses %ld bytes vmalloc and %ld bytes buffres\n",
+		"swap_cgroup: uses %ld bytes of vmalloc for pointer array space"
+		" and %ld bytes to hold mem_cgroup pointers on swap\n",
 		array_size, length * PAGE_SIZE);
 	printk(KERN_INFO
 	"swap_cgroup can be disabled by noswapaccount boot option.\n");
_

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
