Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id 5C7B46B0005
	for <linux-mm@kvack.org>; Sat,  2 Jun 2018 07:07:04 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id y17-v6so3849201lfj.19
        for <linux-mm@kvack.org>; Sat, 02 Jun 2018 04:07:04 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e7-v6sor731260lfi.66.2018.06.02.04.07.02
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 02 Jun 2018 04:07:02 -0700 (PDT)
MIME-Version: 1.0
From: =?UTF-8?B?56a56Iif6ZSu?= <ufo19890607@gmail.com>
Date: Sat, 2 Jun 2018 19:06:44 +0800
Message-ID: <CAHCio2hrYo6f35cT69+xa5BwUXpwYXXm76GppUBB2WTrKonaFQ@mail.gmail.com>
Subject: [PATCH v7 1/2] Add an array of const char and enum oom_constraint in memcontrol.h
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mhocko@suse.com, rientjes@google.com, kirill.shutemov@linux.intel.com, aarcange@redhat.com, penguin-kernel@i-love.sakura.ne.jp, guro@fb.com, yang.s@alibaba-inc.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Wind Yu <yuzhoujian@didichuxing.com>

From: yuzhoujian <yuzhoujian@didichuxing.com>

This patch will make some preparation for the follow-up patch: Refactor
part of the oom report in dump_header. It puts enum oom_constraint in
memcontrol.h and adds an array of const char for each constraint.

Signed-off-by: yuzhoujian <yuzhoujian@didichuxing.com>
---
 include/linux/memcontrol.h | 14 ++++++++++++++
 mm/oom_kill.c              |  7 -------
 2 files changed, 14 insertions(+), 7 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index d99b71bc2c66..57311b6c4d67 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -62,6 +62,20 @@ struct mem_cgroup_reclaim_cookie {
  unsigned int generation;
 };

+enum oom_constraint {
+ CONSTRAINT_NONE,
+ CONSTRAINT_CPUSET,
+ CONSTRAINT_MEMORY_POLICY,
+ CONSTRAINT_MEMCG,
+};
+
+static const char * const oom_constraint_text[] = {
+ [CONSTRAINT_NONE] = "CONSTRAINT_NONE",
+ [CONSTRAINT_CPUSET] = "CONSTRAINT_CPUSET",
+ [CONSTRAINT_MEMORY_POLICY] = "CONSTRAINT_MEMORY_POLICY",
+ [CONSTRAINT_MEMCG] = "CONSTRAINT_MEMCG",
+};
+
 #ifdef CONFIG_MEMCG

 #define MEM_CGROUP_ID_SHIFT 16
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 8ba6cb88cf58..c806cd656af6 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -237,13 +237,6 @@ unsigned long oom_badness(struct task_struct *p,
struct mem_cgroup *memcg,
  return points > 0 ? points : 1;
 }

-enum oom_constraint {
- CONSTRAINT_NONE,
- CONSTRAINT_CPUSET,
- CONSTRAINT_MEMORY_POLICY,
- CONSTRAINT_MEMCG,
-};
-
 /*
  * Determine the type of allocation constraint.
  */
-- 
2.14.1
