Return-Path: <SRS0=8949=Q3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 89624C43381
	for <linux-mm@archiver.kernel.org>; Wed, 20 Feb 2019 03:24:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2F0AD2146E
	for <linux-mm@archiver.kernel.org>; Wed, 20 Feb 2019 03:24:26 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=pex-com.20150623.gappssmtp.com header.i=@pex-com.20150623.gappssmtp.com header.b="zwziYVWi"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2F0AD2146E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=pex.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B630D8E0003; Tue, 19 Feb 2019 22:24:25 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AE9668E0002; Tue, 19 Feb 2019 22:24:25 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 989B18E0003; Tue, 19 Feb 2019 22:24:25 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id 3EB4E8E0002
	for <linux-mm@kvack.org>; Tue, 19 Feb 2019 22:24:25 -0500 (EST)
Received: by mail-wr1-f70.google.com with SMTP id h65so6687258wrh.16
        for <linux-mm@kvack.org>; Tue, 19 Feb 2019 19:24:25 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id;
        bh=I6TwaXrJepd3WDScQyPJsW1XPyTwmhwy7W1ausectrY=;
        b=ivuMs2Awe1gdf840aDDkIZt/S3dW2hXOe3Tn9A9RvUhXgSJB9+Xvh0Rzstj1uCNWGf
         PJGphCc/0eaLvlI2IrHmcIKOzHdQdeosA/MGughEMqf5i5iy6ciudACdIwer+uKWy3GE
         RsGAscTL6OLV8Syw8qtjBW6w7V2mfnagDGNd9O0IYRbURUMpTblDnGCqJUkzaXRHaOaX
         1dpxEkCh/Lj2FUUd+UfS3qbxTEKy1YG6/G6VWXdixpldxj4v/nQqRS70WHfrrGkJ0scu
         18Qs9z6gbAXVDerNFT2Jf56aT82p2TTl58c2j8i06bLDtRdF61J+BJlz2LkxzlZ3SNuC
         eRvQ==
X-Gm-Message-State: AHQUAuabM5KjYNyQVAbbonNA0bN00PS2S9+ozi2gmo1BQ0g5zmZP73tg
	ET8t0F0Sx3aYeTXEmcC44kZEuoYkzKSe7JKD1ANDLzAdyUgysbwgIpIy4U83YxD5tk1Ssr49juX
	8aSbH5YjPz/MGxaQnM+dNvjVb5jZeyvu2au3istUfQp+v4TVCUaUwBPk7Ldcqik6Ct2cXJGXuNX
	uqI6GwL607K0Dbf7t0CXj8MoJswfc40NpXIvxbmvV/ZZ5rAhd6f8oRYFfIiW+6XXjWuETU9X/UB
	MMkPTmO26d9Hp1Hoq8iYrfnr5u0BjYqTUvvF/3ORo9KN10eYfFc5WgaVQDYD9kCvdtER1s4aHyL
	tewFzVPvZGUBOCxikxkMDj8WsCmmRsnNdLJbiCnjRNjm2RcbOSr5ay3Blk8ropbgd5kDdGHOH7e
	JPleYHCjBvTheShFdDWLYQNYA5y4uqNAhGQv4fgR5f4JXbWvs7WgsRvgoDXN2rz7/QXZsG9F3bh
	A+t1y8khph9sG+Fs246HASD7qEJOOPVR/+HHYa3Pc7PrLWlg7i9cY2mpLPqAMzNzJW61j8SKZvx
	KSqbg0RmYlNTHKgRR9iS74CdgR4QC/s6iUXcOLkejDppj1xUvK5QMsezaNUt4vZAveBvbcbcG6g
	271u/djxWRMfsP7CvpQHmHHUxLLA5gR6GoryccsY5HEA7LmaV+4v7C1265YYxgRKAdqkrBIIuCv
	0
X-Received: by 2002:a05:6000:1142:: with SMTP id d2mr22213613wrx.43.1550633064677;
        Tue, 19 Feb 2019 19:24:24 -0800 (PST)
X-Received: by 2002:a05:6000:1142:: with SMTP id d2mr22213569wrx.43.1550633063686;
        Tue, 19 Feb 2019 19:24:23 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550633063; cv=none;
        d=google.com; s=arc-20160816;
        b=uciIUVQAABX/exJnFYxvCog+eszL598kdv8noVzhjCOES+f1E/piOggugqWmCdO8xB
         f/e0nIzuC4jT5VquVqZCXXIAs0I/dIEZ1URvZqh29N2F/ki9lLw+mwURNsMBpXoSfMMK
         mp+PwvkS5qdzo2s+T2+TRxlQqOpVpJFioGLW2oED23U5u1SV5sTjRj3xorPWXPLnJvpm
         39ufypBq5AIiOuemcuao3DbiZeGfhCMjTPQSLjH51oihd7VfT8l2NjBGr4NJ1nfbX+0n
         lIdhJfgRrh4/UNUlUtPQat3DjY0HgwkBeiZaFdhsu6PlAvE6Snf5GVt9Qrofw/4ng5YG
         ptmw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from:dkim-signature;
        bh=I6TwaXrJepd3WDScQyPJsW1XPyTwmhwy7W1ausectrY=;
        b=tZ/Pus3T2/gLm0Au/fUO2x9OAQOGp8VzFHtnMfiZNsYwrra7fY+JG+xnMxn4Ehk1bS
         C22ZnXZWthFBchmiYthfX7XpPlQWeI2sDAFTigye2QI7YxJTfPyO3K7k90BSQxs1x27b
         UxKB3WbfyBFpV8rzTWahCZrn/DNG009mxSBcxg89VYWMY5Fzn6jqbLI8bBRbqmSZX+90
         DqU2COo9EFnq1nma/ouPq0uKrScJ/OmO3AvuTPgawwPr9txMb7SMXMwoaeZ/49LNAA8A
         FJGQv1kGreCk4+2wc8Nwjn4J9R/CSUzDu45F/Rf4x42L3bXnfdHsLg88bXQlmhlVzXO2
         iyZQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@pex-com.20150623.gappssmtp.com header.s=20150623 header.b=zwziYVWi;
       spf=softfail (google.com: domain of transitioning stepan@pex.com does not designate 209.85.220.65 as permitted sender) smtp.mailfrom=stepan@pex.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=pex.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i11sor5965495wrq.49.2019.02.19.19.24.23
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 19 Feb 2019 19:24:23 -0800 (PST)
Received-SPF: softfail (google.com: domain of transitioning stepan@pex.com does not designate 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@pex-com.20150623.gappssmtp.com header.s=20150623 header.b=zwziYVWi;
       spf=softfail (google.com: domain of transitioning stepan@pex.com does not designate 209.85.220.65 as permitted sender) smtp.mailfrom=stepan@pex.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=pex.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=pex-com.20150623.gappssmtp.com; s=20150623;
        h=from:to:cc:subject:date:message-id;
        bh=I6TwaXrJepd3WDScQyPJsW1XPyTwmhwy7W1ausectrY=;
        b=zwziYVWi2zDQ1neZVMwVr06go7Jlq7k/t/QwE9L7CYafofWpecqr7JeGKZWdUjfp9d
         pm7pQZ21Cp2TEQK7ASYF9w5rmgJ67Qn6CvWQFpPRPo1llXyuCKOnZLamGzqwOffG+qfR
         kG6RdiBsBxizkkQnfXASOOv1emyhu5Yi20kYwluJVxqgMVTyUXm1KV6FesSziQeYNJv6
         rmjFsnVDbVY3jHI7xsa3xO1fxYmVGzsQe93eOC8GiS3dTEmTNXTXaUi2mdCXVFBDBNru
         OMC1IrUqk9g8c2K4pBMmEkCeGeC5jwlSnBTI/89uZgXESzoWwSHcAsFwUaRUr+j49Zr4
         YbZw==
X-Google-Smtp-Source: AHgI3IY0xVT5IhOya9MQZ+pv5oUuaiIk/Q9EtJcoZG+P3BgoaDEcUdUpw+fqaUYj5FA2n+C3DyjpkQ==
X-Received: by 2002:adf:dc4e:: with SMTP id m14mr23428694wrj.107.1550633063038;
        Tue, 19 Feb 2019 19:24:23 -0800 (PST)
Received: from localhost.localdomain ([159.253.111.17])
        by smtp.googlemail.com with ESMTPSA id 12sm7724906wme.25.2019.02.19.19.24.21
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Feb 2019 19:24:22 -0800 (PST)
From: Stepan Bujnak <stepan@pex.com>
To: linux-mm@kvack.org
Cc: corbet@lwn.net,
	mcgrof@kernel.org,
	hannes@cmpxchg.org,
	stepan@pex.com
Subject: [PATCH] mm/oom: added option 'oom_dump_task_cmdline'
Date: Wed, 20 Feb 2019 04:22:45 +0100
Message-Id: <20190220032245.2413-1-stepan@pex.com>
X-Mailer: git-send-email 2.17.1
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

When oom_dump_tasks is enabled, this option will try to display task
cmdline instead of the command name in the system-wide task dump.

This is useful in some cases e.g. on postgres server. If OOM killer is
invoked it will show a bunch of tasks called 'postgres'. With this
option enabled it will show additional information like the database
user, database name and what it is currently doing.

Other example is python. Instead of just 'python' it will also show the
script name currently being executed.

Signed-off-by: Stepan Bujnak <stepan@pex.com>
---
 Documentation/sysctl/vm.txt | 10 ++++++++++
 include/linux/oom.h         |  1 +
 kernel/sysctl.c             |  7 +++++++
 mm/oom_kill.c               | 20 ++++++++++++++++++--
 4 files changed, 36 insertions(+), 2 deletions(-)

diff --git a/Documentation/sysctl/vm.txt b/Documentation/sysctl/vm.txt
index 187ce4f599a2..74278c8c30d2 100644
--- a/Documentation/sysctl/vm.txt
+++ b/Documentation/sysctl/vm.txt
@@ -50,6 +50,7 @@ Currently, these files are in /proc/sys/vm:
 - nr_trim_pages         (only if CONFIG_MMU=n)
 - numa_zonelist_order
 - oom_dump_tasks
+- oom_dump_task_cmdline
 - oom_kill_allocating_task
 - overcommit_kbytes
 - overcommit_memory
@@ -639,6 +640,15 @@ The default value is 1 (enabled).
 
 ==============================================================
 
+oom_dump_task_cmdline
+
+When oom_dump_tasks is enabled, this option will try to display task cmdline
+instead of the command name in the system-wide task dump.
+
+The default value is 0 (disabled).
+
+==============================================================
+
 oom_kill_allocating_task
 
 This enables or disables killing the OOM-triggering task in
diff --git a/include/linux/oom.h b/include/linux/oom.h
index d07992009265..461b15b3b695 100644
--- a/include/linux/oom.h
+++ b/include/linux/oom.h
@@ -125,6 +125,7 @@ extern struct task_struct *find_lock_task_mm(struct task_struct *p);
 
 /* sysctls */
 extern int sysctl_oom_dump_tasks;
+extern int sysctl_oom_dump_task_cmdline;
 extern int sysctl_oom_kill_allocating_task;
 extern int sysctl_panic_on_oom;
 #endif /* _INCLUDE_LINUX_OOM_H */
diff --git a/kernel/sysctl.c b/kernel/sysctl.c
index ba4d9e85feb8..4edc5f8e6cf9 100644
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -1288,6 +1288,13 @@ static struct ctl_table vm_table[] = {
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec,
 	},
+	{
+		.procname	= "oom_dump_task_cmdline",
+		.data		= &sysctl_oom_dump_task_cmdline,
+		.maxlen		= sizeof(sysctl_oom_dump_task_cmdline),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec,
+	},
 	{
 		.procname	= "overcommit_ratio",
 		.data		= &sysctl_overcommit_ratio,
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 26ea8636758f..736fa0a6ab8d 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -41,6 +41,7 @@
 #include <linux/kthread.h>
 #include <linux/init.h>
 #include <linux/mmu_notifier.h>
+#include <linux/string_helpers.h>
 
 #include <asm/tlb.h>
 #include "internal.h"
@@ -52,6 +53,7 @@
 int sysctl_panic_on_oom;
 int sysctl_oom_kill_allocating_task;
 int sysctl_oom_dump_tasks = 1;
+int sysctl_oom_dump_task_cmdline;
 
 /*
  * Serializes oom killer invocations (out_of_memory()) from all contexts to
@@ -404,9 +406,18 @@ static void dump_tasks(struct mem_cgroup *memcg, const nodemask_t *nodemask)
 	pr_info("[  pid  ]   uid  tgid total_vm      rss pgtables_bytes swapents oom_score_adj name\n");
 	rcu_read_lock();
 	for_each_process(p) {
+		char *name, *cmd = NULL;
+
 		if (oom_unkillable_task(p, memcg, nodemask))
 			continue;
 
+		/*
+		 * This needs to be done before calling find_lock_task_mm()
+		 * since both grab a task lock which would result in deadlock.
+		 */
+		if (sysctl_oom_dump_task_cmdline)
+			cmd = kstrdup_quotable_cmdline(p, GFP_KERNEL);
+
 		task = find_lock_task_mm(p);
 		if (!task) {
 			/*
@@ -414,16 +425,21 @@ static void dump_tasks(struct mem_cgroup *memcg, const nodemask_t *nodemask)
 			 * detached their mm's.  There's no need to report
 			 * them; they can't be oom killed anyway.
 			 */
-			continue;
+			goto done;
 		}
 
+		name = cmd ? cmd : task->comm;
+
 		pr_info("[%7d] %5d %5d %8lu %8lu %8ld %8lu         %5hd %s\n",
 			task->pid, from_kuid(&init_user_ns, task_uid(task)),
 			task->tgid, task->mm->total_vm, get_mm_rss(task->mm),
 			mm_pgtables_bytes(task->mm),
 			get_mm_counter(task->mm, MM_SWAPENTS),
-			task->signal->oom_score_adj, task->comm);
+			task->signal->oom_score_adj, name);
 		task_unlock(task);
+
+done:
+		kfree(cmd);
 	}
 	rcu_read_unlock();
 }
-- 
2.17.1

