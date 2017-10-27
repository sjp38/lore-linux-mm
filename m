Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 50E8D6B0069
	for <linux-mm@kvack.org>; Fri, 27 Oct 2017 06:23:20 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id f85so4609291pfe.7
        for <linux-mm@kvack.org>; Fri, 27 Oct 2017 03:23:20 -0700 (PDT)
Received: from szxga05-in.huawei.com (szxga05-in.huawei.com. [45.249.212.191])
        by mx.google.com with ESMTPS id m10si4703334pgt.327.2017.10.27.03.23.18
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 27 Oct 2017 03:23:19 -0700 (PDT)
From: Yisheng Xie <xieyisheng1@huawei.com>
Subject: [PATCH RFC v2 0/4] some fixes and clean up for mempolicy
Date: Fri, 27 Oct 2017 18:14:21 +0800
Message-ID: <1509099265-30868-1-git-send-email-xieyisheng1@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, vbabka@suse.cz, mhocko@suse.com, mingo@kernel.org, rientjes@google.com, n-horiguchi@ah.jp.nec.com, salls@cs.ucsb.edu
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, tanxiaojun@huawei.com, linux-api@vger.kernel.org

This patchset is triggered by Xiojun's report of ltp test fail[1],
and I have sent a patch to resolve it by check nodes_empty of new_nodes[2].

The new version is to follow Vlastimil's suggestion, which fix by checking
the new_nodes value in function get_nodes. And I just split them to small
patches for easy to review and discussion. For more detail, please look
into each patches.

Change logs of v2:
 * fix get_nodes's mask miscalculation
 * remove redundant check in get_nodes
 * fix the check of nodemask from user - per Vlastimil

Any comment and complain is welome.

Thanks
Yisheng Xie

[1] https://patchwork.kernel.org/patch/10012005/
[2] https://patchwork.kernel.org/patch/10013329/

Yisheng Xie (4):
  mm/mempolicy: Fix get_nodes() mask miscalculation
  mm/mempolicy: remove redundant check in get_nodes
  mm/mempolicy: fix the check of nodemask from user
  mm/mempolicy: add nodes_empty check in SYSC_migrate_pages

 mm/mempolicy.c | 31 +++++++++++++++++++++++++------
 1 file changed, 25 insertions(+), 6 deletions(-)

-- 
1.7.12.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
