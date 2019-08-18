Return-Path: <SRS0=q2Op=WO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6247DC3A589
	for <linux-mm@archiver.kernel.org>; Sun, 18 Aug 2019 04:25:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CA08F21019
	for <linux-mm@archiver.kernel.org>; Sun, 18 Aug 2019 04:25:16 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="c1SBcXHu"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CA08F21019
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 33E876B0008; Sun, 18 Aug 2019 00:25:15 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2EE9D6B000A; Sun, 18 Aug 2019 00:25:15 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1DE566B000C; Sun, 18 Aug 2019 00:25:15 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0237.hostedemail.com [216.40.44.237])
	by kanga.kvack.org (Postfix) with ESMTP id F05786B0008
	for <linux-mm@kvack.org>; Sun, 18 Aug 2019 00:25:14 -0400 (EDT)
Received: from smtpin23.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id 78D60181AC9AE
	for <linux-mm@kvack.org>; Sun, 18 Aug 2019 04:25:14 +0000 (UTC)
X-FDA: 75834258948.23.jeans19_2db39ec6fb92b
X-HE-Tag: jeans19_2db39ec6fb92b
X-Filterd-Recvd-Size: 6566
Received: from mail-pl1-f195.google.com (mail-pl1-f195.google.com [209.85.214.195])
	by imf38.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Sun, 18 Aug 2019 04:25:13 +0000 (UTC)
Received: by mail-pl1-f195.google.com with SMTP id c2so4172284plz.13
        for <linux-mm@kvack.org>; Sat, 17 Aug 2019 21:25:13 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id;
        bh=EzysOLi+WQidHzaJ0C2T4u12xqhRWUhemelKYN/QOG8=;
        b=c1SBcXHu5yNHl3LAuxBAyzFSbcKuktVedMBcSIBsHWFgF2t1I/rCexGhg03SXNPhNX
         iVVDIPuIrYaRKNt4bqvrfcsT2VEPNCGc8Ro4YixVxH9jPxKHkdo5DYMzKOtImiOmF1/O
         PtDAGQjswXSY5Q1cwYH95Ss+G+bceGb0lwNtb+6ammaK9ajIxzecz0MujNNZEmIcMdiZ
         e/7GCZkx1u1V5fSyVy0RUuEyy0dYW45qsbl8AoqiHMtlGMIKuFu+WcpWZVd7SeLeaDmX
         Hd4vrwDMFZvRM0wpumeym5+kc9nTkunHrlECxzEouaGx0xmYfnPxko60NJbIUyUwCuhN
         dJvQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id;
        bh=EzysOLi+WQidHzaJ0C2T4u12xqhRWUhemelKYN/QOG8=;
        b=jgjT+vE4Qllk/ZlI1oNA4qQtqcn1uCFmdwYWm5rMOttug4650teHVhgI2IgwfilJrx
         DIz2Em7OWxcgCb3hLHj6F3DM28dk3OKIx43uUwGSIP1mAj60HK6iDrQMW8tB1g+8u7T5
         GZCUjw0kmnnhu4W1NQ47yfNrhevtC4z+iaSGigrh8CQldRhRTW3VT1HdffP98df7pnPf
         7acSQWlF06BFa2N5xcxyKaAhj8T+5/iBo76fOgY6l96BTG/kcuWSXKzRJ38g1S1En3AV
         6ObgT/GGsNgEk4r6XPZmBQnmvrMb5BLS1gxK4N2YLOymna+3E2e1J58KgoL26MXYBa8A
         Dzqw==
X-Gm-Message-State: APjAAAXYhmtzMERxo9MKShpvRCWrFrM3X/amxKCaD4hwY+veyZsbkPD/
	qWhXbkHNQnq2mwWzuWI7QB4=
X-Google-Smtp-Source: APXvYqyLlhbKApRO1uDvWDBM9dlXYVQstlFsFZI+7EyEYw85hst4fRwMdvYBKzxBSevFJUKVPt9m2g==
X-Received: by 2002:a17:902:9f8e:: with SMTP id g14mr16762196plq.67.1566102312946;
        Sat, 17 Aug 2019 21:25:12 -0700 (PDT)
Received: from bogon.localdomain ([203.100.54.194])
        by smtp.gmail.com with ESMTPSA id b136sm13490230pfb.73.2019.08.17.21.25.09
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 17 Aug 2019 21:25:12 -0700 (PDT)
From: Yafang Shao <laoar.shao@gmail.com>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org,
	Yafang Shao <laoar.shao@gmail.com>,
	Roman Gushchin <guro@fb.com>,
	Randy Dunlap <rdunlap@infradead.org>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Michal Hocko <mhocko@suse.com>,
	Vladimir Davydov <vdavydov.dev@gmail.com>,
	Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: [PATCH] mm, memcg: skip killing processes under memcg protection at first scan
Date: Sun, 18 Aug 2019 00:24:54 -0400
Message-Id: <1566102294-14803-1-git-send-email-laoar.shao@gmail.com>
X-Mailer: git-send-email 1.8.3.1
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

In the current memory.min design, the system is going to do OOM instead
of reclaiming the reclaimable pages protected by memory.min if the
system is lack of free memory. While under this condition, the OOM
killer may kill the processes in the memcg protected by memory.min.
This behavior is very weird.
In order to make it more reasonable, I make some changes in the OOM
killer. In this patch, the OOM killer will do two-round scan. It will
skip the processes under memcg protection at the first scan, and if it
can't kill any processes it will rescan all the processes.

Regarding the overhead this change may takes, I don't think it will be a
problem because this only happens under system  memory pressure and
the OOM killer can't find any proper victims which are not under memcg
protection.

Signed-off-by: Yafang Shao <laoar.shao@gmail.com>
Cc: Roman Gushchin <guro@fb.com>
Cc: Randy Dunlap <rdunlap@infradead.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Vladimir Davydov <vdavydov.dev@gmail.com>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
---
 include/linux/memcontrol.h |  6 ++++++
 mm/memcontrol.c            | 16 ++++++++++++++++
 mm/oom_kill.c              | 23 +++++++++++++++++++++--
 3 files changed, 43 insertions(+), 2 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 44c4146..58bd86b 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -337,6 +337,7 @@ static inline bool mem_cgroup_disabled(void)
 
 enum mem_cgroup_protection mem_cgroup_protected(struct mem_cgroup *root,
 						struct mem_cgroup *memcg);
+int task_under_memcg_protection(struct task_struct *p);
 
 int mem_cgroup_try_charge(struct page *page, struct mm_struct *mm,
 			  gfp_t gfp_mask, struct mem_cgroup **memcgp,
@@ -813,6 +814,11 @@ static inline enum mem_cgroup_protection mem_cgroup_protected(
 	return MEMCG_PROT_NONE;
 }
 
+int task_under_memcg_protection(struct task_struct *p)
+{
+	return 0;
+}
+
 static inline int mem_cgroup_try_charge(struct page *page, struct mm_struct *mm,
 					gfp_t gfp_mask,
 					struct mem_cgroup **memcgp,
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index cdbb7a8..c4d8e53 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -6030,6 +6030,22 @@ enum mem_cgroup_protection mem_cgroup_protected(struct mem_cgroup *root,
 		return MEMCG_PROT_NONE;
 }
 
+int task_under_memcg_protection(struct task_struct *p)
+{
+	struct mem_cgroup *memcg;
+	int protected;
+
+	rcu_read_lock();
+	memcg = mem_cgroup_from_task(p);
+	if (memcg != root_mem_cgroup && memcg->memory.min)
+		protected = 1;
+	else
+		protected = 0;
+	rcu_read_unlock();
+
+	return protected;
+}
+
 /**
  * mem_cgroup_try_charge - try charging a page
  * @page: page to charge
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index eda2e2a..259dd2c 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -368,11 +368,30 @@ static void select_bad_process(struct oom_control *oc)
 		mem_cgroup_scan_tasks(oc->memcg, oom_evaluate_task, oc);
 	else {
 		struct task_struct *p;
+		int memcg_check = 0;
+		int memcg_skip = 0;
+		int selected = 0;
 
 		rcu_read_lock();
-		for_each_process(p)
-			if (oom_evaluate_task(p, oc))
+retry:
+		for_each_process(p) {
+			if (!memcg_check && task_under_memcg_protection(p)) {
+				memcg_skip = 1;
+				continue;
+			}
+			selected = oom_evaluate_task(p, oc);
+			if (selected)
 				break;
+		}
+
+		if (!selected) {
+			if (memcg_skip) {
+				if (!oc->chosen || oc->chosen == (void *)-1UL) {
+					memcg_check = 1;
+					goto retry;
+				}
+			}
+		}
 		rcu_read_unlock();
 	}
 }
-- 
1.8.3.1


