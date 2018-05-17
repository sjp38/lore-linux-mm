Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 042756B0396
	for <linux-mm@kvack.org>; Thu, 17 May 2018 03:00:40 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id w7-v6so2187009pfd.9
        for <linux-mm@kvack.org>; Thu, 17 May 2018 00:00:39 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b2-v6sor2554227plz.151.2018.05.17.00.00.38
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 17 May 2018 00:00:38 -0700 (PDT)
From: ufo19890607 <ufo19890607@gmail.com>
Subject: [PATCH] Add the memcg print oom info for system oom
Date: Thu, 17 May 2018 08:00:28 +0100
Message-Id: <1526540428-12178-1-git-send-email-ufo19890607@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mhocko@suse.com, rientjes@google.com, kirill.shutemov@linux.intel.com, aarcange@redhat.com, penguin-kernel@I-love.SAKURA.ne.jp, guro@fb.com, yang.s@alibaba-inc.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, yuzhoujian <yuzhoujian@didichuxing.com>

From: yuzhoujian <yuzhoujian@didichuxing.com>

The dump_header does not print the memcg's name when the system
oom happened. Some users want to locate the certain container
which contains the task that has been killed by the oom killer.
So I add the mem_cgroup_print_oom_info when system oom events
happened.

Signed-off-by: yuzhoujian <yuzhoujian@didichuxing.com>
---
 mm/oom_kill.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 8ba6cb88cf58..244416c9834a 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -433,6 +433,7 @@ static void dump_header(struct oom_control *oc, struct task_struct *p)
 	if (is_memcg_oom(oc))
 		mem_cgroup_print_oom_info(oc->memcg, p);
 	else {
+		mem_cgroup_print_oom_info(mem_cgroup_from_task(p), p);
 		show_mem(SHOW_MEM_FILTER_NODES, oc->nodemask);
 		if (is_dump_unreclaim_slabs())
 			dump_unreclaimable_slab();
-- 
2.14.1
