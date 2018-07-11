Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id 561586B0276
	for <linux-mm@kvack.org>; Wed, 11 Jul 2018 08:01:29 -0400 (EDT)
Received: by mail-wr1-f69.google.com with SMTP id z13-v6so3188211wrq.3
        for <linux-mm@kvack.org>; Wed, 11 Jul 2018 05:01:29 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id w198-v6sor476053wmw.56.2018.07.11.05.01.28
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 11 Jul 2018 05:01:28 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH] mm, oom: document oom_lock
Date: Wed, 11 Jul 2018 14:01:21 +0200
Message-Id: <20180711120121.25635-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: David Rientjes <rientjes@google.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

From: Michal Hocko <mhocko@suse.com>

Add a short documentation about what is the oom_lock scope.

Requested-by: David Rientjes <rientjes@google.com>
Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 mm/oom_kill.c | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index ed9d473c571e..32e6f7becb40 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -53,6 +53,14 @@ int sysctl_panic_on_oom;
 int sysctl_oom_kill_allocating_task;
 int sysctl_oom_dump_tasks = 1;
 
+/*
+ * Serializes oom killer invocations (out_of_memory()) from all contexts to
+ * prevent from over eager oom killing (e.g. when the oom killer is invoked
+ * from different domains).
+ *
+ * oom_killer_disable() relies on this lock to stabilize oom_killer_disabled
+ * and mark_oom_victim
+ */
 DEFINE_MUTEX(oom_lock);
 
 #ifdef CONFIG_NUMA
-- 
2.18.0
