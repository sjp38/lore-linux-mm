Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id 86B836B0003
	for <linux-mm@kvack.org>; Sat, 23 Jun 2018 10:13:12 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id d6-v6so5263735plo.15
        for <linux-mm@kvack.org>; Sat, 23 Jun 2018 07:13:12 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id u29-v6sor2910437pfa.125.2018.06.23.07.13.11
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 23 Jun 2018 07:13:11 -0700 (PDT)
From: ufo19890607@gmail.com
Subject: [PATCH v10 1/2] Move enum oom_constraint in oom.h
Date: Sat, 23 Jun 2018 22:12:50 +0800
Message-Id: <1529763171-29240-1-git-send-email-ufo19890607@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mhocko@suse.com, rientjes@google.com, kirill.shutemov@linux.intel.com, aarcange@redhat.com, penguin-kernel@i-love.sakura.ne.jp, guro@fb.com, yang.s@alibaba-inc.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, yuzhoujian@didichuxing.com

From: yuzhoujian <yuzhoujian@didichuxing.com>

This patch will make some preparation for the follow-up patch: Refactor
part of the oom report in dump_header. It puts enum oom_constraint in
oom.h.

Signed-off-by: yuzhoujian <yuzhoujian@didichuxing.com>
---
 include/linux/memcontrol.h | 1 +
 include/linux/oom.h        | 7 +++++++
 mm/oom_kill.c              | 7 -------
 3 files changed, 8 insertions(+), 7 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 6c6fb116e925..513b74b3115b 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -28,6 +28,7 @@
 #include <linux/eventfd.h>
 #include <linux/mm.h>
 #include <linux/vmstat.h>
+#include <linux/oom.h>
 #include <linux/writeback.h>
 #include <linux/page-flags.h>
 
diff --git a/include/linux/oom.h b/include/linux/oom.h
index 6adac113e96d..40cc561f8557 100644
--- a/include/linux/oom.h
+++ b/include/linux/oom.h
@@ -15,6 +15,13 @@ struct notifier_block;
 struct mem_cgroup;
 struct task_struct;
 
+enum oom_constraint {
+	CONSTRAINT_NONE,
+	CONSTRAINT_CPUSET,
+	CONSTRAINT_MEMORY_POLICY,
+	CONSTRAINT_MEMCG,
+};
+
 /*
  * Details of the page allocation that triggered the oom killer that are used to
  * determine what should be killed.
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 84081e77bc51..1045c5bc7c37 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -237,13 +237,6 @@ unsigned long oom_badness(struct task_struct *p, struct mem_cgroup *memcg,
 	return points > 0 ? points : 1;
 }
 
-enum oom_constraint {
-	CONSTRAINT_NONE,
-	CONSTRAINT_CPUSET,
-	CONSTRAINT_MEMORY_POLICY,
-	CONSTRAINT_MEMCG,
-};
-
 /*
  * Determine the type of allocation constraint.
  */
-- 
2.14.1
