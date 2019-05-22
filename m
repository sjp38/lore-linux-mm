Return-Path: <SRS0=Hl4p=TW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CE48BC18E7D
	for <linux-mm@archiver.kernel.org>; Wed, 22 May 2019 10:46:43 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8135820856
	for <linux-mm@archiver.kernel.org>; Wed, 22 May 2019 10:46:43 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8135820856
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=I-love.SAKURA.ne.jp
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1AC126B0003; Wed, 22 May 2019 06:46:43 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 15E8B6B0006; Wed, 22 May 2019 06:46:43 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 026B96B0007; Wed, 22 May 2019 06:46:42 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id B99E56B0003
	for <linux-mm@kvack.org>; Wed, 22 May 2019 06:46:42 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id t1so1512413pfa.10
        for <linux-mm@kvack.org>; Wed, 22 May 2019 03:46:42 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=mXB+S4M+P8XzrJ6i/1ecfgvGIikSNdfbe764del+NnQ=;
        b=tZCToKx6EiSfUu5BKPUyWUJnGvoDGfUSpaB97dl707ueY5sgxtbai7Zl+l+PchBrvO
         NGMf1srO7QeBrRB3SiU70NxR/vyWzoawsSn4zFcKS/rqnBOyTxFk2u6rKeC9wDG7Akxx
         JdveJ46pU59WMYtshfCbulJHkw9U4ol3uG7peIhggrU2uI5AZ6PTax6GOiCUteyufKl/
         JzFzLSZb9bc1cDaTauy3aJxALWM9MmWg11+8tWjEtQ/GIMVQurpjUrT7vSVGcuFEB/4n
         vtE1DEGoSzyIGNzeZL1JuTOzdLHATrB9AlRLiXD7WiCKTwJcSEK2fZEvszJksKE0Af6x
         TpOA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) smtp.mailfrom=penguin-kernel@i-love.sakura.ne.jp
X-Gm-Message-State: APjAAAUj/SGySYdA6fcc0hF4ZOM8ZxomVZtQag3V3mZSOUesGxaH6vvy
	DXZnWtdiMCe8SBcfDXqBfbzFbac+jfW4gy7FExHjO1++2FM36FI1aEWiSC5U4+RH7v8TbKTTipd
	+SQAy+i/kG8GW762EC/L7dy4Ct4QADT+cm0f8ORzZ+sQQVpeQwT91S+qvBbHBqN3lFg==
X-Received: by 2002:a62:470e:: with SMTP id u14mr95710946pfa.31.1558522002292;
        Wed, 22 May 2019 03:46:42 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxBuwPRKhvaTTehlb1dddJloHfAjwoGSSjXkuvNuO8ML7/mTbxDEwLiT2/MTY9WE9dWn5sZ
X-Received: by 2002:a62:470e:: with SMTP id u14mr95710788pfa.31.1558522000821;
        Wed, 22 May 2019 03:46:40 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558522000; cv=none;
        d=google.com; s=arc-20160816;
        b=uxo2zNxM+ufMe6zx4TIOAi1pS/k/N0r6DMFXIOyduej0CoKTg23NU9heDQyqZ2SGMx
         TyOjdCi1a3912hofjcAK8elm36kFzdeuOmFm+0c4NJwQxXuj7l2+QYv2JFRZutu6kxsv
         shl9sK3ITkWUXxWzvAvPRsTVlPyURG1NSooWqbnFeezTt7nnco1ICfz63fvejGcp+ZJt
         g43D4aUrC4yZ5JpGXkRqwS88kiG9L8dfM6svkGtOpybuXQUZH6enMt/MCyRjWr4d+4jP
         5iwSVIDFlNo7K2dPPtnoDha/iPY2vbuNIW0eWhJG3IHBkljhYexxWelS/4NANXAjuaEL
         P5sQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=mXB+S4M+P8XzrJ6i/1ecfgvGIikSNdfbe764del+NnQ=;
        b=WYVQ5DXF5NTiqJ38AFzGZoZjWmB1fu1vo0DGYO3MoGEb513NwvtBpRqytZCJkS+144
         sMYffYsNtAeLhG59SdGhO8oVvUmWTzXg5COpf2Bzum5gqiHQWHaC5ufMG8w72mJb1VUF
         EEbrIrVI0FPh5tNAB+rMjbtP8IWbCBbvuLNV7OrPMmQ7mfwQ/UJH+Xj1vslt6wQvSJ2Q
         V6wTYKjdWoALv4ymA5wSwyizdg0hhcOVq1e1XFTxkb0Rhb6wfUON8Dk06aBN1I047paz
         qcCedjAuHgmUbvx1TesTFiYaOGZcflOZn7uevpVE4B0NFE6fUMN552uffw97iLYXp03r
         w/jQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) smtp.mailfrom=penguin-kernel@i-love.sakura.ne.jp
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id b9si26242926plk.333.2019.05.22.03.46.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 May 2019 03:46:40 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) client-ip=202.181.97.72;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) smtp.mailfrom=penguin-kernel@i-love.sakura.ne.jp
Received: from fsav404.sakura.ne.jp (fsav404.sakura.ne.jp [133.242.250.103])
	by www262.sakura.ne.jp (8.15.2/8.15.2) with ESMTP id x4MA8Jl9039254;
	Wed, 22 May 2019 19:08:19 +0900 (JST)
	(envelope-from penguin-kernel@I-love.SAKURA.ne.jp)
Received: from www262.sakura.ne.jp (202.181.97.72)
 by fsav404.sakura.ne.jp (F-Secure/fsigk_smtp/530/fsav404.sakura.ne.jp);
 Wed, 22 May 2019 19:08:19 +0900 (JST)
X-Virus-Status: clean(F-Secure/fsigk_smtp/530/fsav404.sakura.ne.jp)
Received: from ccsecurity.localdomain (softbank126012062002.bbtec.net [126.12.62.2])
	(authenticated bits=0)
	by www262.sakura.ne.jp (8.15.2/8.15.2) with ESMTPSA id x4MA8Fdn039015
	(version=TLSv1.2 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=NO);
	Wed, 22 May 2019 19:08:19 +0900 (JST)
	(envelope-from penguin-kernel@I-love.SAKURA.ne.jp)
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Michal Hocko <mhocko@suse.com>,
        Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>,
        Dmitry Vyukov <dvyukov@google.com>, Petr Mladek <pmladek@suse.com>,
        Sergey Senozhatsky <sergey.senozhatsky@gmail.com>,
        Steven Rostedt <rostedt@goodmis.org>
Subject: [PATCH 2/4] mm, oom: Avoid potential RCU stall at dump_tasks().
Date: Wed, 22 May 2019 19:08:04 +0900
Message-Id: <1558519686-16057-2-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1558519686-16057-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
References: <1558519686-16057-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

dump_tasks() calls printk() on each userspace process under RCU which
might result in RCU stall warning. I proposed introducing timeout for
dump_tasks() operation, but Michal Hocko expects that dump_tasks() is
either print all or suppress all [1]. Therefore, this patch changes to
cache all candidates at oom_evaluate_task() and then print the cached
candidates at dump_tasks().

With this patch, dump_tasks() no longer need to call printk() under RCU.
Also, dump_tasks() no longer need to check oom_unkillable_task() by
traversing all userspace processes, for select_bad_process() already
traversed all possible candidates. Also, the OOM killer no longer need to
call put_task_struct() from atomic context, and we can simplify refcount
handling for __oom_kill_process().

This patch has a user-visible side effect that oom_kill_allocating_task
path implies oom_dump_tasks == 0, for oom_evaluate_task() is not called
via select_bad_process(). But since the purpose of enabling
oom_kill_allocating_task is to kill as quick as possible (i.e. tolerate
killing more than needed) whereas the purpose of dump_tasks() which might
take minutes is to understand how the OOM killer selected an OOM victim,
not printing candidates should be acceptable when the administrator asked
the OOM killer to kill current thread.

[1] https://lore.kernel.org/linux-mm/20180906115320.GS14951@dhcp22.suse.cz/

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: Dmitry Vyukov <dvyukov@google.com>
Cc: Petr Mladek <pmladek@suse.com>
Cc: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Cc: Steven Rostedt <rostedt@goodmis.org>
---
 include/linux/sched.h |  1 +
 mm/oom_kill.c         | 44 +++++++++++++++++++-------------------------
 2 files changed, 20 insertions(+), 25 deletions(-)

diff --git a/include/linux/sched.h b/include/linux/sched.h
index 1183741..f1736bf 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -1180,6 +1180,7 @@ struct task_struct {
 #ifdef CONFIG_MMU
 	struct task_struct		*oom_reaper_list;
 #endif
+	struct list_head                oom_candidate_list;
 #ifdef CONFIG_VMAP_STACK
 	struct vm_struct		*stack_vm_area;
 #endif
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 7534046..00b594c 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -63,6 +63,7 @@
  * and mark_oom_victim
  */
 DEFINE_MUTEX(oom_lock);
+static LIST_HEAD(oom_candidate_list);
 
 #ifdef CONFIG_NUMA
 /**
@@ -333,6 +334,9 @@ static int oom_evaluate_task(struct task_struct *task, void *arg)
 		goto abort;
 	}
 
+	get_task_struct(task);
+	list_add_tail(&task->oom_candidate_list, &oom_candidate_list);
+
 	/*
 	 * If task is allocating a lot of memory and has been marked to be
 	 * killed first if it triggers an oom, then select it.
@@ -350,16 +354,11 @@ static int oom_evaluate_task(struct task_struct *task, void *arg)
 	if (points == oc->chosen_points && thread_group_leader(oc->chosen))
 		goto next;
 select:
-	if (oc->chosen)
-		put_task_struct(oc->chosen);
-	get_task_struct(task);
 	oc->chosen = task;
 	oc->chosen_points = points;
 next:
 	return 0;
 abort:
-	if (oc->chosen)
-		put_task_struct(oc->chosen);
 	oc->chosen = (void *)-1UL;
 	return 1;
 }
@@ -401,11 +400,8 @@ static void dump_tasks(struct mem_cgroup *memcg, const nodemask_t *nodemask)
 
 	pr_info("Tasks state (memory values in pages):\n");
 	pr_info("[  pid  ]   uid  tgid total_vm      rss pgtables_bytes swapents oom_score_adj name\n");
-	rcu_read_lock();
-	for_each_process(p) {
-		if (oom_unkillable_task(p, memcg, nodemask))
-			continue;
-
+	list_for_each_entry(p, &oom_candidate_list, oom_candidate_list) {
+		cond_resched();
 		task = find_lock_task_mm(p);
 		if (!task) {
 			/*
@@ -424,7 +420,6 @@ static void dump_tasks(struct mem_cgroup *memcg, const nodemask_t *nodemask)
 			task->signal->oom_score_adj, task->comm);
 		task_unlock(task);
 	}
-	rcu_read_unlock();
 }
 
 static void dump_oom_summary(struct oom_control *oc, struct task_struct *victim)
@@ -455,7 +450,7 @@ static void dump_header(struct oom_control *oc, struct task_struct *p)
 		if (is_dump_unreclaim_slabs())
 			dump_unreclaimable_slab();
 	}
-	if (sysctl_oom_dump_tasks)
+	if (sysctl_oom_dump_tasks && !list_empty(&oom_candidate_list))
 		dump_tasks(oc->memcg, oc->nodemask);
 	if (p)
 		dump_oom_summary(oc, p);
@@ -849,17 +844,11 @@ static void __oom_kill_process(struct task_struct *victim, const char *message)
 	struct mm_struct *mm;
 	bool can_oom_reap = true;
 
-	p = find_lock_task_mm(victim);
-	if (!p) {
-		put_task_struct(victim);
-		return;
-	} else if (victim != p) {
-		get_task_struct(p);
-		put_task_struct(victim);
-		victim = p;
-	}
-
 	/* Get a reference to safely compare mm after task_unlock(victim) */
+	victim = find_lock_task_mm(victim);
+	if (!victim)
+		return;
+	get_task_struct(victim);
 	mm = victim->mm;
 	mmgrab(mm);
 
@@ -931,7 +920,6 @@ static int oom_kill_memcg_member(struct task_struct *task, void *message)
 {
 	if (task->signal->oom_score_adj != OOM_SCORE_ADJ_MIN &&
 	    !is_global_init(task)) {
-		get_task_struct(task);
 		__oom_kill_process(task, message);
 	}
 	return 0;
@@ -954,7 +942,6 @@ static void oom_kill_process(struct oom_control *oc, const char *message)
 		mark_oom_victim(victim);
 		wake_oom_reaper(victim);
 		task_unlock(victim);
-		put_task_struct(victim);
 		return;
 	}
 	task_unlock(victim);
@@ -1077,7 +1064,6 @@ bool out_of_memory(struct oom_control *oc)
 	if (!is_memcg_oom(oc) && sysctl_oom_kill_allocating_task &&
 	    current->mm && !oom_unkillable_task(current, NULL, oc->nodemask) &&
 	    current->signal->oom_score_adj != OOM_SCORE_ADJ_MIN) {
-		get_task_struct(current);
 		oc->chosen = current;
 		oom_kill_process(oc, "Out of memory (oom_kill_allocating_task)");
 		return true;
@@ -1099,6 +1085,14 @@ bool out_of_memory(struct oom_control *oc)
 	if (oc->chosen && oc->chosen != (void *)-1UL)
 		oom_kill_process(oc, !is_memcg_oom(oc) ? "Out of memory" :
 				 "Memory cgroup out of memory");
+	while (!list_empty(&oom_candidate_list)) {
+		struct task_struct *p = list_first_entry(&oom_candidate_list,
+							 struct task_struct,
+							 oom_candidate_list);
+
+		list_del(&p->oom_candidate_list);
+		put_task_struct(p);
+	}
 	return !!oc->chosen;
 }
 
-- 
1.8.3.1

