Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id E0BDF6B0003
	for <linux-mm@kvack.org>; Sun,  1 Jul 2018 12:09:54 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id b2-v6so10611388oib.14
        for <linux-mm@kvack.org>; Sun, 01 Jul 2018 09:09:54 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id w5-v6si5011049oth.377.2018.07.01.09.09.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 01 Jul 2018 09:09:53 -0700 (PDT)
From: Rodrigo Freire <rfreire@redhat.com>
Subject: [PATCH] mm: be more informative in OOM task list
Date: Sun,  1 Jul 2018 13:09:40 -0300
Message-Id: <7de14c6cac4a486c04149f37948e3a76028f3fa5.1530461087.git.rfreire@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org

The default page memory unit of OOM task dump events might not be
intuitive for the non-initiated when debugging OOM events. Add
a small printk prior to the task dump informing that the memory
units are actually memory _pages_.

Signed-off-by: Rodrigo Freire <rfreire@redhat.com>
---
 mm/oom_kill.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 84081e7..b4d9557 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -392,6 +392,7 @@ static void dump_tasks(struct mem_cgroup *memcg, const nodemask_t *nodemask)
 	struct task_struct *p;
 	struct task_struct *task;
 
+	pr_info("Tasks state (memory values in pages):\n");
 	pr_info("[ pid ]   uid  tgid total_vm      rss pgtables_bytes swapents oom_score_adj name\n");
 	rcu_read_lock();
 	for_each_process(p) {
-- 
1.8.3.1
