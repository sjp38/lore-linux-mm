Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 7D8086B03A8
	for <linux-mm@kvack.org>; Fri, 21 Apr 2017 10:05:16 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id n4so21861781qte.18
        for <linux-mm@kvack.org>; Fri, 21 Apr 2017 07:05:16 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id r6si9621952qkb.41.2017.04.21.07.05.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 21 Apr 2017 07:05:15 -0700 (PDT)
From: Waiman Long <longman@redhat.com>
Subject: [RFC PATCH 13/14] sched: Make cpu/cpuacct threaded controllers
Date: Fri, 21 Apr 2017 10:04:11 -0400
Message-Id: <1492783452-12267-14-git-send-email-longman@redhat.com>
In-Reply-To: <1492783452-12267-1-git-send-email-longman@redhat.com>
References: <1492783452-12267-1-git-send-email-longman@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>, Li Zefan <lizefan@huawei.com>, Johannes Weiner <hannes@cmpxchg.org>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>
Cc: cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, kernel-team@fb.com, pjt@google.com, luto@amacapital.net, efault@gmx.de, Waiman Long <longman@redhat.com>

Make cpu and cpuacct cgroup controllers usable within a threaded cgroup.

Signed-off-by: Waiman Long <longman@redhat.com>
---
 kernel/sched/core.c    | 1 +
 kernel/sched/cpuacct.c | 1 +
 2 files changed, 2 insertions(+)

diff --git a/kernel/sched/core.c b/kernel/sched/core.c
index 78dfcaa..9d8beda 100644
--- a/kernel/sched/core.c
+++ b/kernel/sched/core.c
@@ -7432,6 +7432,7 @@ struct cgroup_subsys cpu_cgrp_subsys = {
 	.legacy_cftypes	= cpu_legacy_files,
 	.dfl_cftypes	= cpu_files,
 	.early_init	= true,
+	.threaded	= true,
 #ifdef CONFIG_CGROUP_CPUACCT
 	/*
 	 * cpuacct is enabled together with cpu on the unified hierarchy
diff --git a/kernel/sched/cpuacct.c b/kernel/sched/cpuacct.c
index fc1cf13..853d18a 100644
--- a/kernel/sched/cpuacct.c
+++ b/kernel/sched/cpuacct.c
@@ -414,4 +414,5 @@ struct cgroup_subsys cpuacct_cgrp_subsys = {
 	.css_free	= cpuacct_css_free,
 	.legacy_cftypes	= files,
 	.early_init	= true,
+	.threaded	= true,
 };
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
