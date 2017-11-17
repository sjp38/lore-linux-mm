Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id 409286B025E
	for <linux-mm@kvack.org>; Thu, 16 Nov 2017 20:49:40 -0500 (EST)
Received: by mail-io0-f197.google.com with SMTP id r70so6222206ioi.2
        for <linux-mm@kvack.org>; Thu, 16 Nov 2017 17:49:40 -0800 (PST)
Received: from szxga05-in.huawei.com (szxga05-in.huawei.com. [45.249.212.191])
        by mx.google.com with ESMTPS id m133si1624347ioe.229.2017.11.16.17.49.36
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 16 Nov 2017 17:49:38 -0800 (PST)
From: Yisheng Xie <xieyisheng1@huawei.com>
Subject: [PATCH v3 0/3] some fixes and clean up for mempolicy
Date: Fri, 17 Nov 2017 09:37:01 +0800
Message-ID: <1510882624-44342-1-git-send-email-xieyisheng1@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, vbabka@suse.cz, mhocko@suse.com, mingo@kernel.org, rientjes@google.com, n-horiguchi@ah.jp.nec.com, salls@cs.ucsb.edu, ak@linux.intel.com, cl@linux.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org, tanxiaojun@huawei.com

This patchset is triggered by Xiojun's report of ltp test fail[1],
and I have sent a patch to resolve it by check nodes_empty of new_nodes[2].

The new version is to follow Vlastimil's suggestion, which fix by checking
the new_nodes value in function get_nodes. And I just split them to small
patches for easy to review and discussion. For more detail, please look
into each patches.

Change logs of v3:
 * remove patch get_nodes's mask miscalculation
 * check whether node is empty after AND current task node, and then nodes
   which have memory.

Change logs of v2:
 * fix get_nodes's mask miscalculation
 * remove redundant check in get_nodes
 * fix the check of nodemask from user - per Vlastimil

Any comment and complain is welome.

Thanks
Yisheng Xie

[1] https://patchwork.kernel.org/patch/10012005/
[2] https://patchwork.kernel.org/patch/10013329/

Yisheng Xie (3):
  mm/mempolicy: remove redundant check in get_nodes
  mm/mempolicy: fix the check of nodemask from user
  mm/mempolicy: add nodes_empty check in SYSC_migrate_pages

 mm/mempolicy.c | 35 +++++++++++++++++++++++++++--------
 1 file changed, 27 insertions(+), 8 deletions(-)

-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
