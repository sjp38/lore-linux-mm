Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id DB5A66B0070
	for <linux-mm@kvack.org>; Thu, 28 May 2015 05:54:06 -0400 (EDT)
Received: by padbw4 with SMTP id bw4so19855423pad.0
        for <linux-mm@kvack.org>; Thu, 28 May 2015 02:54:06 -0700 (PDT)
Received: from szxga02-in.huawei.com (szxga02-in.huawei.com. [119.145.14.65])
        by mx.google.com with ESMTPS id sy7si2835109pbc.208.2015.05.28.02.54.04
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 28 May 2015 02:54:06 -0700 (PDT)
From: Wang Long <long.wanglong@huawei.com>
Subject: [PATCH] OOM: print points as unsigned int
Date: Thu, 28 May 2015 09:46:44 +0000
Message-ID: <1432806404-223203-1-git-send-email-long.wanglong@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mhocko@suse.cz, rientjes@google.com
Cc: vdavydov@parallels.com, hannes@cmpxchg.org, oleg@redhat.com, kirill.shutemov@linux.intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, wanglong@laoqinren.net, long.wanglong@huawei.com, peifeiyue@huawei.com

In oom_kill_process(), the variable 'points' is unsigned int.
Print it as such.

Signed-off-by: Wang Long <long.wanglong@huawei.com>
---
 mm/oom_kill.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 2b665da..056002c 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -528,7 +528,7 @@ void oom_kill_process(struct task_struct *p, gfp_t gfp_mask, int order,
 		dump_header(p, gfp_mask, order, memcg, nodemask);
 
 	task_lock(p);
-	pr_err("%s: Kill process %d (%s) score %d or sacrifice child\n",
+	pr_err("%s: Kill process %d (%s) score %u or sacrifice child\n",
 		message, task_pid_nr(p), p->comm, points);
 	task_unlock(p);
 
-- 
1.8.3.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
