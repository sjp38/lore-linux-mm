Return-Path: <SRS0=7Cer=U3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-17.4 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT,USER_IN_DEF_DKIM_WL autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DFFA6C5B579
	for <linux-mm@archiver.kernel.org>; Fri, 28 Jun 2019 15:24:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 836B2208E3
	for <linux-mm@archiver.kernel.org>; Fri, 28 Jun 2019 15:24:52 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="BtPgXcHa"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 836B2208E3
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DAE658E0003; Fri, 28 Jun 2019 11:24:51 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D5D9D8E0002; Fri, 28 Jun 2019 11:24:51 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C4CE18E0003; Fri, 28 Jun 2019 11:24:51 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 8C8BF8E0002
	for <linux-mm@kvack.org>; Fri, 28 Jun 2019 11:24:51 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id y7so4097203pfy.9
        for <linux-mm@kvack.org>; Fri, 28 Jun 2019 08:24:51 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:message-id:mime-version
         :subject:from:to:cc;
        bh=ZsiRx6xvzXROMUfoU65xDsRvBFu/S3BDc/iiU2HXWv4=;
        b=mWswfTI1CKAOeOAHgvM+PicG+oGXZIiHgYhYb1fUQVjly4I/6E+7T4Mkv1XrpivgQf
         53FilWh2PQ3DmAry8oGW5Zzpo7rCTF/NlmB5YJ9EXXi1V4/IQ5Q5FZ26BWhAhKbH9P51
         3/gBI0pg0EOxPVFw2Mz4ZbVcg4VI3jfYwq9xyeIi+ZRVSDBeUxpo7HXLPp/wwDQpX5vl
         shB99lXoGmK+STezCTqKXAefc3VANiBSHJIfIw74rBAIQ912QMD3n9LlQ3iwC2pYvLof
         3m0GuffWRUiWCOUrSfcFVHo8FIJ52rzxKjs7Zb57yjx+xGTh8OrQ4pDYctH081/Uz9PG
         zmAQ==
X-Gm-Message-State: APjAAAWDjiSikM1Y/3F9JOBIM2tJFx6akccJ54C4WzKg70T7c4x5WCQA
	R4PCTwB8W3c9Zjw7thD9j/NiqPbdhBdJfSWvxilr2oqGYoqlOyWIRzI/yF67s9qYhPyD1kN8Lso
	r8qGd1xaTrPyc70Gl2Lq1YZau9cXXQPEhbYRra9IRKod75Dn2U5cIaXESHOIz/8wXhw==
X-Received: by 2002:a17:902:f64:: with SMTP id 91mr11963637ply.247.1561735491022;
        Fri, 28 Jun 2019 08:24:51 -0700 (PDT)
X-Received: by 2002:a17:902:f64:: with SMTP id 91mr11963566ply.247.1561735490152;
        Fri, 28 Jun 2019 08:24:50 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561735490; cv=none;
        d=google.com; s=arc-20160816;
        b=HBn60Ne8Wbjy54Ve4Y/5zDGub95L7sl0vPG5qBnQyFQ5fMUpwcFoMeMApX0ULgKxWa
         oabs5sxL0RvSX9m4XPILyl3nzkT8ZUX1j2lM/jXwjlv8TYf+GKj/vP+JdcTXkE3eSCMb
         EiuBZKD1ixJPhjGWLq9jAO475aYLYxR2BbQStef7/zX3jOxmRT3OF1wofUunZ1NQNd84
         AiNxr1cgLD2Q4enbTE8zMd7Dh5bwcdkGozuMzYb0hU+NgKDwbQDkBB89piShG96Jk/pC
         +64cQ9N2K5l5LJj3B23GwCTb2Zo3mQq1vaO4BZ6+IvmtmxcPxaQXkkPtm4b6zSqUB73v
         pMCw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:mime-version:message-id:date:dkim-signature;
        bh=ZsiRx6xvzXROMUfoU65xDsRvBFu/S3BDc/iiU2HXWv4=;
        b=NY8N5AYbhDEFEcO/oWECC+Puy8bibqmfZyzfOnhvvXnNi4mz9x7SVa7Efmdi02Jj2k
         cnxW46/CfACFJ3caFOxPCpwm9lWlz+5nL+s6KayeAhsP1hVZipYFV4hy7zBV/HY94JtO
         0kbtA20pGt3IAiUx0Ap1hsj3MGhiaXW339fPe2H1NVGNoCNGFGqya3/ga0+lmn6BzoY9
         v7vDqg2mmbcVD/Cn5MUAa9YitJCMGw3YMw/2C1JyWVWxnO9H2KxyKmJhIezjt24OgaQg
         CRCausa22jf7eJpCxMMaMuCZ0hX49O4USu2hgEgr+Cjv1d57rymOx5bEwoD9QLCoy4jE
         uL2Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=BtPgXcHa;
       spf=pass (google.com: domain of 3qtewxqgkcooetmwqqxnsaasxq.oayxuzgj-yywhmow.ads@flex--shakeelb.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3QTEWXQgKCOoeTMWQQXNSaaSXQ.OaYXUZgj-YYWhMOW.adS@flex--shakeelb.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id v185sor1047704pgv.10.2019.06.28.08.24.50
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 28 Jun 2019 08:24:50 -0700 (PDT)
Received-SPF: pass (google.com: domain of 3qtewxqgkcooetmwqqxnsaasxq.oayxuzgj-yywhmow.ads@flex--shakeelb.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=BtPgXcHa;
       spf=pass (google.com: domain of 3qtewxqgkcooetmwqqxnsaasxq.oayxuzgj-yywhmow.ads@flex--shakeelb.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3QTEWXQgKCOoeTMWQQXNSaaSXQ.OaYXUZgj-YYWhMOW.adS@flex--shakeelb.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:message-id:mime-version:subject:from:to:cc;
        bh=ZsiRx6xvzXROMUfoU65xDsRvBFu/S3BDc/iiU2HXWv4=;
        b=BtPgXcHakceSysUUvvTmVSqsGhdHXi1kTosXaG1TL6r/NdCk16Kn1UZudJwQ8FryNT
         MqMKLaTqfEshncO9iNRq3T2l4bFQs9lSi8YCG2CnMALJaJycGYuXhHwviqJu5AP4riC8
         i3YxItLgROyPMkeYXhbQ+04IIo3s28z1I4gbaqa10tstGRhTEsE7azL2mH+zTyglgFCp
         TB0VyCvjbF3Vt92IjWzM5k50QSqsGJtJ7QBekyVLXcBao3UchX5g5/oua87eS/1oWJUt
         brlC1HXwtP1z0swdd16RFVvCEJ2o2gDNUQpf/2Rc7F1tgTQ+cEGt2lKpSg+CStlr7gF1
         zxUg==
X-Google-Smtp-Source: APXvYqzEojWmbhFHT2oTqcaA/Uz0vqGKl0ZGIuOIBoO2lEvVjVcxnQ2cWLOCM1OrJQdFMc9IHU4lEf3YCZuZ6w==
X-Received: by 2002:a63:f953:: with SMTP id q19mr9792545pgk.367.1561735489272;
 Fri, 28 Jun 2019 08:24:49 -0700 (PDT)
Date: Fri, 28 Jun 2019 08:24:19 -0700
Message-Id: <20190628152421.198994-1-shakeelb@google.com>
Mime-Version: 1.0
X-Mailer: git-send-email 2.22.0.410.gd8fdbe21b5-goog
Subject: [PATCH v4 1/3] mm, oom: refactor dump_tasks for memcg OOMs
From: Shakeel Butt <shakeelb@google.com>
To: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.com>, 
	Andrew Morton <akpm@linux-foundation.org>, Roman Gushchin <guro@fb.com>, 
	David Rientjes <rientjes@google.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, 
	Shakeel Butt <shakeelb@google.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, 
	Vladimir Davydov <vdavydov.dev@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, 
	Paul Jackson <pj@sgi.com>, Nick Piggin <npiggin@gmail.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

dump_tasks() traverses all the existing processes even for the memcg OOM
context which is not only unnecessary but also wasteful.  This imposes a
long RCU critical section even from a contained context which can be quite
disruptive.

Change dump_tasks() to be aligned with select_bad_process and use
mem_cgroup_scan_tasks to selectively traverse only processes of the target
memcg hierarchy during memcg OOM.

Signed-off-by: Shakeel Butt <shakeelb@google.com>
Acked-by: Michal Hocko <mhocko@suse.com>
Acked-by: Roman Gushchin <guro@fb.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: Vladimir Davydov <vdavydov.dev@gmail.com>
Cc: David Rientjes <rientjes@google.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Paul Jackson <pj@sgi.com>
Cc: Nick Piggin <npiggin@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
---
Changelog since v3:
- None

Changelog since v2:
- Updated the commit message.

Changelog since v1:
- Divide the patch into two patches.

 mm/oom_kill.c | 68 ++++++++++++++++++++++++++++++---------------------
 1 file changed, 40 insertions(+), 28 deletions(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 085abc91024d..a940d2aa92d6 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -380,10 +380,38 @@ static void select_bad_process(struct oom_control *oc)
 	}
 }
 
+static int dump_task(struct task_struct *p, void *arg)
+{
+	struct oom_control *oc = arg;
+	struct task_struct *task;
+
+	if (oom_unkillable_task(p, NULL, oc->nodemask))
+		return 0;
+
+	task = find_lock_task_mm(p);
+	if (!task) {
+		/*
+		 * This is a kthread or all of p's threads have already
+		 * detached their mm's.  There's no need to report
+		 * them; they can't be oom killed anyway.
+		 */
+		return 0;
+	}
+
+	pr_info("[%7d] %5d %5d %8lu %8lu %8ld %8lu         %5hd %s\n",
+		task->pid, from_kuid(&init_user_ns, task_uid(task)),
+		task->tgid, task->mm->total_vm, get_mm_rss(task->mm),
+		mm_pgtables_bytes(task->mm),
+		get_mm_counter(task->mm, MM_SWAPENTS),
+		task->signal->oom_score_adj, task->comm);
+	task_unlock(task);
+
+	return 0;
+}
+
 /**
  * dump_tasks - dump current memory state of all system tasks
- * @memcg: current's memory controller, if constrained
- * @nodemask: nodemask passed to page allocator for mempolicy ooms
+ * @oc: pointer to struct oom_control
  *
  * Dumps the current memory state of all eligible tasks.  Tasks not in the same
  * memcg, not in the same cpuset, or bound to a disjoint set of mempolicy nodes
@@ -391,37 +419,21 @@ static void select_bad_process(struct oom_control *oc)
  * State information includes task's pid, uid, tgid, vm size, rss,
  * pgtables_bytes, swapents, oom_score_adj value, and name.
  */
-static void dump_tasks(struct mem_cgroup *memcg, const nodemask_t *nodemask)
+static void dump_tasks(struct oom_control *oc)
 {
-	struct task_struct *p;
-	struct task_struct *task;
-
 	pr_info("Tasks state (memory values in pages):\n");
 	pr_info("[  pid  ]   uid  tgid total_vm      rss pgtables_bytes swapents oom_score_adj name\n");
-	rcu_read_lock();
-	for_each_process(p) {
-		if (oom_unkillable_task(p, memcg, nodemask))
-			continue;
 
-		task = find_lock_task_mm(p);
-		if (!task) {
-			/*
-			 * This is a kthread or all of p's threads have already
-			 * detached their mm's.  There's no need to report
-			 * them; they can't be oom killed anyway.
-			 */
-			continue;
-		}
+	if (is_memcg_oom(oc))
+		mem_cgroup_scan_tasks(oc->memcg, dump_task, oc);
+	else {
+		struct task_struct *p;
 
-		pr_info("[%7d] %5d %5d %8lu %8lu %8ld %8lu         %5hd %s\n",
-			task->pid, from_kuid(&init_user_ns, task_uid(task)),
-			task->tgid, task->mm->total_vm, get_mm_rss(task->mm),
-			mm_pgtables_bytes(task->mm),
-			get_mm_counter(task->mm, MM_SWAPENTS),
-			task->signal->oom_score_adj, task->comm);
-		task_unlock(task);
+		rcu_read_lock();
+		for_each_process(p)
+			dump_task(p, oc);
+		rcu_read_unlock();
 	}
-	rcu_read_unlock();
 }
 
 static void dump_oom_summary(struct oom_control *oc, struct task_struct *victim)
@@ -453,7 +465,7 @@ static void dump_header(struct oom_control *oc, struct task_struct *p)
 			dump_unreclaimable_slab();
 	}
 	if (sysctl_oom_dump_tasks)
-		dump_tasks(oc->memcg, oc->nodemask);
+		dump_tasks(oc);
 	if (p)
 		dump_oom_summary(oc, p);
 }
-- 
2.22.0.410.gd8fdbe21b5-goog

