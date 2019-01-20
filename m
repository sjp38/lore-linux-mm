Return-Path: <SRS0=a6Xk=P4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT,USER_IN_DEF_DKIM_WL
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7EBACC282C2
	for <linux-mm@archiver.kernel.org>; Sun, 20 Jan 2019 21:51:10 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1EDBB20880
	for <linux-mm@archiver.kernel.org>; Sun, 20 Jan 2019 21:51:09 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="Po6GX4wf"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1EDBB20880
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7867B8E0003; Sun, 20 Jan 2019 16:51:09 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 70F1A8E0001; Sun, 20 Jan 2019 16:51:09 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5B0038E0003; Sun, 20 Jan 2019 16:51:09 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 132BC8E0001
	for <linux-mm@kvack.org>; Sun, 20 Jan 2019 16:51:09 -0500 (EST)
Received: by mail-pl1-f198.google.com with SMTP id 12so11792574plb.18
        for <linux-mm@kvack.org>; Sun, 20 Jan 2019 13:51:09 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:message-id:mime-version
         :subject:from:to:cc;
        bh=dGeQKrvoHP1mulhRks0X12a//E5VjB8pLY/mCP1JLI4=;
        b=i7ssNsTANt/bfX1M7jghzWnfx7oBVaQtVBGi0DXfe4i9SZpuCwqpLMsGRPzvaPYfXa
         PCbCvAw2J3OAdEGOoFBMdEk1ccF38yafBmIBmTWEWio56ZlTsmSkYqLgf0aL6SZLlu8o
         vtN/ezvNtbBwkgKWQgPSrgZNvM8+Uyami6z1UA2GV6OwFYoVBWRaODt/vxI6atg/Skro
         wpd2fwA3AeDre8aYzzl8jQXR9qqHkP929a+dIuT5wDsBNs7KrlSbYKTuMylA0s7K9t7M
         3OmV3ACaCfN/MYl3FIrVs4rVQDHcot9mkLhxapMbPkdSHzLyftY26Di+z6WF+OpyQ+Kz
         PdIQ==
X-Gm-Message-State: AJcUukdf12wjekz34WXFGhuETdF9+Z0caPreKXKKn8+Do6BAfRlXf0dF
	svi524mfFeHARL+pwucc+xhqwYGwZz7KoIDxK86Q4Cucwbvg6ssVWW3IpiiOZ4/nYErzPgedwfC
	Vf+JbLqIAr+SqY34K+j0mjAX9vDfXnOzrhaaejiNOyE5Xo/VSE0rkcLSx9bSHyO3iCm0aWYi2fH
	lT365F6NJEFRUWjGNflPW1FGxomP0hMi1w+33oMI5Vx6d4G9tfNoEuFqVrd9opTw7Hw9FmzizTO
	dCltMJ7QKRDeRmLQqZ0Gvu2ZF9UBR3SoI/FpJHVdFiKiJCuyHEmIn4wrW1TYB3hgIfVIEAoApHO
	In5hVZ1wsNqKx0Ya2zLGq3DXzu0179CixLe/KnDR8Z/fUHLtQcLqaCP/ikz4Ui3D+kuzBLW0L9o
	l
X-Received: by 2002:a17:902:bf03:: with SMTP id bi3mr27590986plb.83.1548021068602;
        Sun, 20 Jan 2019 13:51:08 -0800 (PST)
X-Received: by 2002:a17:902:bf03:: with SMTP id bi3mr27590962plb.83.1548021067771;
        Sun, 20 Jan 2019 13:51:07 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548021067; cv=none;
        d=google.com; s=arc-20160816;
        b=TMqqa5Q+HoIzZk+34yq0PqcWkY7DKdooXeVbd6JoTyTFjNeWBTQ4JxmXPcoeD4CWho
         JPxFtm+7r7VqG2puP26cbqNKXrw0SbFB9fZ1fiN0P8TB1K4lLlrang3GiUWOnVeSkNNx
         SlKRNDQVVGqVpXx8l+i2IcV5DboxNUgTCpvv2VtzspKXiCG8QCY1SDV/Bwol1C98DPIk
         vKu/vpNA6LOXypy/Rn5LIAYo/0PgG3pzyvDNuDO7tE1RFc20jGzAdAqUmzTn88un/QCI
         CRQWyridBA1/B0TSYYGCuVqeMeqPFq4IdIyQVpP4OL0EQRviGzYBKoKcuzEWvTH1tsfh
         r/mw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:mime-version:message-id:date:dkim-signature;
        bh=dGeQKrvoHP1mulhRks0X12a//E5VjB8pLY/mCP1JLI4=;
        b=FePalzhTzTR2frTrSFn79Y1Hsu3SXFnyzXE4MwJyIlhQulrYqDXFyX9oyD4tDXJ5Sh
         iKfX8RUXT9gPAdhAmOgIM41peyV0UsOGSdYkQm6KiUumdbKRVnSUuid6ZaxRWNLV2Ppp
         K3Jb0FI6+ypd4blPb5jvD/HTJRXr3XyAesgbJQox9R+hnILEAJnBz9qxUQgh1kW4v+bL
         4gs2qo+v+h3U3dv+13QcEagC4dWcOS7+VgplXigUv5y8KbZOlqVPOsiukX7QSTW1msbo
         8aIAwDBuhNCWk4Qz4dAcCcHOd6Cl3Wd+N5viRnZDCEGzvjw6aW51ZEo7dXkZpG8wGPwP
         m9mA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=Po6GX4wf;
       spf=pass (google.com: domain of 3s-1exagkcciqf8iccj9emmejc.amkjglsv-kkit8ai.mpe@flex--shakeelb.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3S-1EXAgKCCIQF8ICCJ9EMMEJC.AMKJGLSV-KKIT8AI.MPE@flex--shakeelb.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id r134sor17250465pgr.30.2019.01.20.13.51.07
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 20 Jan 2019 13:51:07 -0800 (PST)
Received-SPF: pass (google.com: domain of 3s-1exagkcciqf8iccj9emmejc.amkjglsv-kkit8ai.mpe@flex--shakeelb.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=Po6GX4wf;
       spf=pass (google.com: domain of 3s-1exagkcciqf8iccj9emmejc.amkjglsv-kkit8ai.mpe@flex--shakeelb.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3S-1EXAgKCCIQF8ICCJ9EMMEJC.AMKJGLSV-KKIT8AI.MPE@flex--shakeelb.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:message-id:mime-version:subject:from:to:cc;
        bh=dGeQKrvoHP1mulhRks0X12a//E5VjB8pLY/mCP1JLI4=;
        b=Po6GX4wfAFK03gqLwVzvI8GHpeT139HHpp0P/CVUXBT+j/KH8k7+rCidut/34U/PTK
         UJtQQX5xRhhXlZMJub9c62Kv+i3VEngRcuhOtTOWF70yQ4I+kUpQB3I5suRskWM9B9iN
         6g1dgCayj8EeA+w2uyg8fKi5ZENHsxupyIJKT6L4bOScnfPtU0Cn30w39MhpOgQm/fsQ
         Qhe5DwWJdTV0IeHzk3TpUD1HU35wG/TkF7Bc/yolqromjC1/WWdnbbF6dIyrpStHGWtA
         fuVzv+sL+osGVikgrkMvrUopj2HgAmdUVLaidlJHoJWmiu9K1JJwenlXvz6JFDQYfKs8
         /CAg==
X-Google-Smtp-Source: ALg8bN6T2O3E8tAVrCDbIcRTFRXdkMq4qK9xmdx74lJif9rd7s6qpdyYpbRgra1byBueWBfWsWQN5U6X0GI0ow==
X-Received: by 2002:a63:8c07:: with SMTP id m7mr11849200pgd.136.1548021067221;
 Sun, 20 Jan 2019 13:51:07 -0800 (PST)
Date: Sun, 20 Jan 2019 13:50:59 -0800
Message-Id: <20190120215059.183552-1-shakeelb@google.com>
Mime-Version: 1.0
X-Mailer: git-send-email 2.20.1.321.g9e740568ce-goog
Subject: [PATCH] mm, oom: remove 'prefer children over parent' heuristic
From: Shakeel Butt <shakeelb@google.com>
To: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, 
	David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, 
	Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Roman Gushchin <guro@fb.com>, 
	Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, 
	Shakeel Butt <shakeelb@google.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190120215059.P9DzXkOIpA8oXxitSkCOGZdRzePmlU5zMUfCWjCO8h8@z>

From the start of the git history of Linux, the kernel after selecting
the worst process to be oom-killed, prefer to kill its child (if the
child does not share mm with the parent). Later it was changed to prefer
to kill a child who is worst. If the parent is still the worst then the
parent will be killed.

This heuristic assumes that the children did less work than their parent
and by killing one of them, the work lost will be less. However this is
very workload dependent. If there is a workload which can benefit from
this heuristic, can use oom_score_adj to prefer children to be killed
before the parent.

The select_bad_process() has already selected the worst process in the
system/memcg. There is no need to recheck the badness of its children
and hoping to find a worse candidate. That's a lot of unneeded racy
work. So, let's remove this whole heuristic.

Signed-off-by: Shakeel Butt <shakeelb@google.com>
---
 mm/oom_kill.c | 49 ++++---------------------------------------------
 1 file changed, 4 insertions(+), 45 deletions(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 1a007dae1e8f..6cee185dc147 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -944,12 +944,7 @@ static int oom_kill_memcg_member(struct task_struct *task, void *unused)
 static void oom_kill_process(struct oom_control *oc, const char *message)
 {
 	struct task_struct *p = oc->chosen;
-	unsigned int points = oc->chosen_points;
-	struct task_struct *victim = p;
-	struct task_struct *child;
-	struct task_struct *t;
 	struct mem_cgroup *oom_group;
-	unsigned int victim_points = 0;
 	static DEFINE_RATELIMIT_STATE(oom_rs, DEFAULT_RATELIMIT_INTERVAL,
 					      DEFAULT_RATELIMIT_BURST);
 
@@ -971,53 +966,17 @@ static void oom_kill_process(struct oom_control *oc, const char *message)
 	if (__ratelimit(&oom_rs))
 		dump_header(oc, p);
 
-	pr_err("%s: Kill process %d (%s) score %u or sacrifice child\n",
-		message, task_pid_nr(p), p->comm, points);
-
-	/*
-	 * If any of p's children has a different mm and is eligible for kill,
-	 * the one with the highest oom_badness() score is sacrificed for its
-	 * parent.  This attempts to lose the minimal amount of work done while
-	 * still freeing memory.
-	 */
-	read_lock(&tasklist_lock);
-
-	/*
-	 * The task 'p' might have already exited before reaching here. The
-	 * put_task_struct() will free task_struct 'p' while the loop still try
-	 * to access the field of 'p', so, get an extra reference.
-	 */
-	get_task_struct(p);
-	for_each_thread(p, t) {
-		list_for_each_entry(child, &t->children, sibling) {
-			unsigned int child_points;
-
-			if (process_shares_mm(child, p->mm))
-				continue;
-			/*
-			 * oom_badness() returns 0 if the thread is unkillable
-			 */
-			child_points = oom_badness(child,
-				oc->memcg, oc->nodemask, oc->totalpages);
-			if (child_points > victim_points) {
-				put_task_struct(victim);
-				victim = child;
-				victim_points = child_points;
-				get_task_struct(victim);
-			}
-		}
-	}
-	put_task_struct(p);
-	read_unlock(&tasklist_lock);
+	pr_err("%s: Kill process %d (%s) score %lu or sacrifice child\n",
+		message, task_pid_nr(p), p->comm, oc->chosen_points);
 
 	/*
 	 * Do we need to kill the entire memory cgroup?
 	 * Or even one of the ancestor memory cgroups?
 	 * Check this out before killing the victim task.
 	 */
-	oom_group = mem_cgroup_get_oom_group(victim, oc->memcg);
+	oom_group = mem_cgroup_get_oom_group(p, oc->memcg);
 
-	__oom_kill_process(victim);
+	__oom_kill_process(p);
 
 	/*
 	 * If necessary, kill all tasks in the selected memory cgroup.
-- 
2.20.1.321.g9e740568ce-goog

