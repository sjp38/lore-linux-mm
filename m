Return-Path: <SRS0=7Cer=U3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-17.4 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT,
	USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9F6A8C4321A
	for <linux-mm@archiver.kernel.org>; Fri, 28 Jun 2019 15:25:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 48DF42064A
	for <linux-mm@archiver.kernel.org>; Fri, 28 Jun 2019 15:25:06 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="cKMaTa6F"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 48DF42064A
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C4E1B8E0005; Fri, 28 Jun 2019 11:25:05 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BFDDB8E0002; Fri, 28 Jun 2019 11:25:05 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AC5DD8E0005; Fri, 28 Jun 2019 11:25:05 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 735748E0002
	for <linux-mm@kvack.org>; Fri, 28 Jun 2019 11:25:05 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id 65so3683523plf.16
        for <linux-mm@kvack.org>; Fri, 28 Jun 2019 08:25:05 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:in-reply-to:message-id
         :mime-version:references:subject:from:to:cc;
        bh=SF83LfmJfuCG+/hVMdmXg0ktbCrQc452ZBvHL1Q4HoU=;
        b=RfJ7Q3EUbeNCnvbmXjfSNkr7a216tX9qfXe4uEqQWsxnrGN9Pzvqu6i3iHekpGSSLl
         4iMQMZQG8ZXFnXF3rt/G0i7BYIZE9kJ+jLxBfvvHu+kJK+6ol8Ivf5D/IVRctX/zUAL8
         8R+PAmH6RN8Xs3PNgqsOVyIaXK0AzEA8KY+7Z8FHIU+rAMv7UKC1YtM5SahFPTm4i7u4
         qfuy4keuyhbzVI2JLtx7+z08F8c0NlHjmNJ+LwnHfYxCtwPYLJ6CBLglBdAe3Wr5Uqut
         j3OjwI5c9SDd+zOuqAkRJoiScnB1bSkJ+rhJAI39Ci6rbt6cbVIAhvQ+fZ6Y3FKLQ6dP
         sqMw==
X-Gm-Message-State: APjAAAUr1ekwUDJkKoAegGp/p/F3a83m+EkgljsP7p3woxOTvvZw6mPC
	X7NIqC0EJh00stTZrE+3itULC89ewX/vQhDR+cKRwgZvcdLGyicyaUYEbUB/sIZtd2pHU/25pi/
	pgc+kL8ZPZWimnC0QIVm+FarJWxOwqpDCw1R/iQ/iGkFZHSiGX645BU1VmFjDK/98Iw==
X-Received: by 2002:a17:902:8bc1:: with SMTP id r1mr12342989plo.42.1561735505068;
        Fri, 28 Jun 2019 08:25:05 -0700 (PDT)
X-Received: by 2002:a17:902:8bc1:: with SMTP id r1mr12342922plo.42.1561735504332;
        Fri, 28 Jun 2019 08:25:04 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561735504; cv=none;
        d=google.com; s=arc-20160816;
        b=QVQDOwHfsEniwCkk5pjFr7mDmLx9R15S5PatDt4p6eBSaQZb4kxdtrmeUH2fcX7RcF
         VK0xYx8DOSQrqtk57R/8ThS0XjCMhbTCWR32ybqvTj7ImCbgal4yBnsLXoOVxb3EloJa
         VtCeXs8PEFWTpfjSjMOiqWUM5QoqN47EBwn+aBYDqv2EpmMTCFkuRnrR3J1HXSnjqHRa
         EMtTo8as8P2ldFYWPSxO20kqIJsuUnBlno9x6xAYXEtz5CZipMbOp+7tKifATe5NOOPN
         tFp83l24M6V3UTBHLDGtlzjRI64zpNn/t41Li27XIljnrn4m19xETjBWsHUFRxlXWEbV
         e+xQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:references:mime-version:message-id:in-reply-to
         :date:dkim-signature;
        bh=SF83LfmJfuCG+/hVMdmXg0ktbCrQc452ZBvHL1Q4HoU=;
        b=mRmdxinxxR2LyqGm2JpIMPtKHZ4vHlsmsbkPQrXp7i971JtYMl9J8YjBKuV7dfE+kr
         NEx8Dh3+3LJKyQT+rMaGhK8S1BtrPB/A1Lz6Ca9GyuQFFVrqasLhPorQ+YOJQPM1FOQ2
         yQKDWlIQjlRF7+h1+kgCEV4GTSrc8cE2U2s9fnZ969oB8QsN004bgFefb0VCUv6h37Ki
         yAg1cRFE1/tz6bT1Fi5AUM+GOm13BsNcW69GSSl+ChkowpGUjUSRRNmdOkA81F3/HMMI
         dw4eceX2Cjk80B9aBmUN822EvqngpORhTLP8qw+XHxxtawev+ruSYt8g1+48u5uUwnuz
         gBJg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=cKMaTa6F;
       spf=pass (google.com: domain of 3tzewxqgkcpgxmfpjjqglttlqj.htrqnsz2-rrp0fhp.twl@flex--shakeelb.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3TzEWXQgKCPgxmfpjjqglttlqj.htrqnsz2-rrp0fhp.twl@flex--shakeelb.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id r3sor1029819pgj.74.2019.06.28.08.25.04
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 28 Jun 2019 08:25:04 -0700 (PDT)
Received-SPF: pass (google.com: domain of 3tzewxqgkcpgxmfpjjqglttlqj.htrqnsz2-rrp0fhp.twl@flex--shakeelb.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=cKMaTa6F;
       spf=pass (google.com: domain of 3tzewxqgkcpgxmfpjjqglttlqj.htrqnsz2-rrp0fhp.twl@flex--shakeelb.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3TzEWXQgKCPgxmfpjjqglttlqj.htrqnsz2-rrp0fhp.twl@flex--shakeelb.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:in-reply-to:message-id:mime-version:references:subject:from:to
         :cc;
        bh=SF83LfmJfuCG+/hVMdmXg0ktbCrQc452ZBvHL1Q4HoU=;
        b=cKMaTa6FyKq9p1/jTTOlIGliwsN1WZFXEqkbfv1kAhDxqggJRSsT5IuOMrtlJmkQoG
         ybj/LHFkG3bDggkE6H/W0roOsKHxQMKe2U4G4yXaZ83TdCvTAmJfpxvnIrvtAW58cWub
         92BdmVdgqHbH8XbNnztYJXiQCoZFL71dW9vOCUf7hmBvriybZHBRUHs5+rOeWzmG6kNR
         YRzo8llnaHlW4gKfgr1wGff4hyPw8P+NPCOcOhkhuVHnKPIlMd5xmgFzrIkPCCbvK1yW
         1Xwjx0v7hxE+6ZRnyUG9Dda8Rjf6bCV8Ix4073MZ7DfOmOSWMNN5s4jh4vp80yTUIsmj
         Bgdw==
X-Google-Smtp-Source: APXvYqzBE6kCNMUP+NzxA6JkiXzQluu8P7gxuTbCoe9j2uvcyvnTmKTB1Rj+MyL14Al+uuvcisZQ8tIUq5Ghyg==
X-Received: by 2002:a63:4c15:: with SMTP id z21mr9448936pga.87.1561735503555;
 Fri, 28 Jun 2019 08:25:03 -0700 (PDT)
Date: Fri, 28 Jun 2019 08:24:20 -0700
In-Reply-To: <20190628152421.198994-1-shakeelb@google.com>
Message-Id: <20190628152421.198994-2-shakeelb@google.com>
Mime-Version: 1.0
References: <20190628152421.198994-1-shakeelb@google.com>
X-Mailer: git-send-email 2.22.0.410.gd8fdbe21b5-goog
Subject: [PATCH v4 2/3] mm, oom: remove redundant task_in_mem_cgroup() check
From: Shakeel Butt <shakeelb@google.com>
To: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.com>, 
	Andrew Morton <akpm@linux-foundation.org>, Roman Gushchin <guro@fb.com>, 
	David Rientjes <rientjes@google.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, 
	Shakeel Butt <shakeelb@google.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, 
	KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Nick Piggin <npiggin@gmail.com>, 
	Paul Jackson <pj@sgi.com>, Vladimir Davydov <vdavydov.dev@gmail.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

oom_unkillable_task() can be called from three different contexts i.e.
global OOM, memcg OOM and oom_score procfs interface.  At the moment
oom_unkillable_task() does a task_in_mem_cgroup() check on the given
process.  Since there is no reason to perform task_in_mem_cgroup() check
for global OOM and oom_score procfs interface, those contexts provide NULL
memcg and skips the task_in_mem_cgroup() check.  However for memcg OOM
context, the oom_unkillable_task() is always called from
mem_cgroup_scan_tasks() and thus task_in_mem_cgroup() check becomes
redundant and effectively dead code. So, just remove the
task_in_mem_cgroup() check altogether.

Signed-off-by: Shakeel Butt <shakeelb@google.com>
Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Acked-by: Michal Hocko <mhocko@suse.com>
Acked-by: Roman Gushchin <guro@fb.com>
Cc: David Rientjes <rientjes@google.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Nick Piggin <npiggin@gmail.com>
Cc: Paul Jackson <pj@sgi.com>
Cc: Vladimir Davydov <vdavydov.dev@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
---
Changelog since v3:
- Update commit message.

Changelog since v2:
- Further divided the patch into two patches.
- Incorporated the task_in_mem_cgroup() from Tetsuo.

Changelog since v1:
- Divide the patch into two patches.

 fs/proc/base.c             |  2 +-
 include/linux/memcontrol.h |  7 -------
 include/linux/oom.h        |  2 +-
 mm/memcontrol.c            | 26 --------------------------
 mm/oom_kill.c              | 19 +++++++------------
 5 files changed, 9 insertions(+), 47 deletions(-)

diff --git a/fs/proc/base.c b/fs/proc/base.c
index b8d5d100ed4a..5eacce5e924a 100644
--- a/fs/proc/base.c
+++ b/fs/proc/base.c
@@ -532,7 +532,7 @@ static int proc_oom_score(struct seq_file *m, struct pid_namespace *ns,
 	unsigned long totalpages = totalram_pages() + total_swap_pages;
 	unsigned long points = 0;
 
-	points = oom_badness(task, NULL, NULL, totalpages) *
+	points = oom_badness(task, NULL, totalpages) *
 					1000 / totalpages;
 	seq_printf(m, "%lu\n", points);
 
diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 9abf31bbe53a..2cbce1fe7780 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -407,7 +407,6 @@ static inline struct lruvec *mem_cgroup_lruvec(struct pglist_data *pgdat,
 
 struct lruvec *mem_cgroup_page_lruvec(struct page *, struct pglist_data *);
 
-bool task_in_mem_cgroup(struct task_struct *task, struct mem_cgroup *memcg);
 struct mem_cgroup *mem_cgroup_from_task(struct task_struct *p);
 
 struct mem_cgroup *get_mem_cgroup_from_mm(struct mm_struct *mm);
@@ -896,12 +895,6 @@ static inline bool mm_match_cgroup(struct mm_struct *mm,
 	return true;
 }
 
-static inline bool task_in_mem_cgroup(struct task_struct *task,
-				      const struct mem_cgroup *memcg)
-{
-	return true;
-}
-
 static inline struct mem_cgroup *get_mem_cgroup_from_mm(struct mm_struct *mm)
 {
 	return NULL;
diff --git a/include/linux/oom.h b/include/linux/oom.h
index d07992009265..b75104690311 100644
--- a/include/linux/oom.h
+++ b/include/linux/oom.h
@@ -108,7 +108,7 @@ static inline vm_fault_t check_stable_address_space(struct mm_struct *mm)
 bool __oom_reap_task_mm(struct mm_struct *mm);
 
 extern unsigned long oom_badness(struct task_struct *p,
-		struct mem_cgroup *memcg, const nodemask_t *nodemask,
+		const nodemask_t *nodemask,
 		unsigned long totalpages);
 
 extern bool out_of_memory(struct oom_control *oc);
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 7532ddcf31b2..b3f67a6b6527 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1259,32 +1259,6 @@ void mem_cgroup_update_lru_size(struct lruvec *lruvec, enum lru_list lru,
 		*lru_size += nr_pages;
 }
 
-bool task_in_mem_cgroup(struct task_struct *task, struct mem_cgroup *memcg)
-{
-	struct mem_cgroup *task_memcg;
-	struct task_struct *p;
-	bool ret;
-
-	p = find_lock_task_mm(task);
-	if (p) {
-		task_memcg = get_mem_cgroup_from_mm(p->mm);
-		task_unlock(p);
-	} else {
-		/*
-		 * All threads may have already detached their mm's, but the oom
-		 * killer still needs to detect if they have already been oom
-		 * killed to prevent needlessly killing additional tasks.
-		 */
-		rcu_read_lock();
-		task_memcg = mem_cgroup_from_task(task);
-		css_get(&task_memcg->css);
-		rcu_read_unlock();
-	}
-	ret = mem_cgroup_is_descendant(task_memcg, memcg);
-	css_put(&task_memcg->css);
-	return ret;
-}
-
 /**
  * mem_cgroup_margin - calculate chargeable space of a memory cgroup
  * @memcg: the memory cgroup
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index a940d2aa92d6..eff879acc886 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -153,17 +153,13 @@ static inline bool is_memcg_oom(struct oom_control *oc)
 
 /* return true if the task is not adequate as candidate victim task. */
 static bool oom_unkillable_task(struct task_struct *p,
-		struct mem_cgroup *memcg, const nodemask_t *nodemask)
+				const nodemask_t *nodemask)
 {
 	if (is_global_init(p))
 		return true;
 	if (p->flags & PF_KTHREAD)
 		return true;
 
-	/* When mem_cgroup_out_of_memory() and p is not member of the group */
-	if (memcg && !task_in_mem_cgroup(p, memcg))
-		return true;
-
 	/* p may not have freeable memory in nodemask */
 	if (!has_intersects_mems_allowed(p, nodemask))
 		return true;
@@ -194,20 +190,19 @@ static bool is_dump_unreclaim_slabs(void)
  * oom_badness - heuristic function to determine which candidate task to kill
  * @p: task struct of which task we should calculate
  * @totalpages: total present RAM allowed for page allocation
- * @memcg: task's memory controller, if constrained
  * @nodemask: nodemask passed to page allocator for mempolicy ooms
  *
  * The heuristic for determining which task to kill is made to be as simple and
  * predictable as possible.  The goal is to return the highest value for the
  * task consuming the most memory to avoid subsequent oom failures.
  */
-unsigned long oom_badness(struct task_struct *p, struct mem_cgroup *memcg,
+unsigned long oom_badness(struct task_struct *p,
 			  const nodemask_t *nodemask, unsigned long totalpages)
 {
 	long points;
 	long adj;
 
-	if (oom_unkillable_task(p, memcg, nodemask))
+	if (oom_unkillable_task(p, nodemask))
 		return 0;
 
 	p = find_lock_task_mm(p);
@@ -318,7 +313,7 @@ static int oom_evaluate_task(struct task_struct *task, void *arg)
 	struct oom_control *oc = arg;
 	unsigned long points;
 
-	if (oom_unkillable_task(task, NULL, oc->nodemask))
+	if (oom_unkillable_task(task, oc->nodemask))
 		goto next;
 
 	/*
@@ -342,7 +337,7 @@ static int oom_evaluate_task(struct task_struct *task, void *arg)
 		goto select;
 	}
 
-	points = oom_badness(task, NULL, oc->nodemask, oc->totalpages);
+	points = oom_badness(task, oc->nodemask, oc->totalpages);
 	if (!points || points < oc->chosen_points)
 		goto next;
 
@@ -385,7 +380,7 @@ static int dump_task(struct task_struct *p, void *arg)
 	struct oom_control *oc = arg;
 	struct task_struct *task;
 
-	if (oom_unkillable_task(p, NULL, oc->nodemask))
+	if (oom_unkillable_task(p, oc->nodemask))
 		return 0;
 
 	task = find_lock_task_mm(p);
@@ -1083,7 +1078,7 @@ bool out_of_memory(struct oom_control *oc)
 	check_panic_on_oom(oc);
 
 	if (!is_memcg_oom(oc) && sysctl_oom_kill_allocating_task &&
-	    current->mm && !oom_unkillable_task(current, NULL, oc->nodemask) &&
+	    current->mm && !oom_unkillable_task(current, oc->nodemask) &&
 	    current->signal->oom_score_adj != OOM_SCORE_ADJ_MIN) {
 		get_task_struct(current);
 		oc->chosen = current;
-- 
2.22.0.410.gd8fdbe21b5-goog

