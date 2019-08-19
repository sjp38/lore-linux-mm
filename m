Return-Path: <SRS0=U3FQ=WP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_SBL,URIBL_SBL_A,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4057CC3A589
	for <linux-mm@archiver.kernel.org>; Mon, 19 Aug 2019 01:18:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DDCA22146E
	for <linux-mm@archiver.kernel.org>; Mon, 19 Aug 2019 01:18:23 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="qGXy3r4r"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DDCA22146E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 781D96B000C; Sun, 18 Aug 2019 21:18:23 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 733506B000D; Sun, 18 Aug 2019 21:18:23 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 649A06B000E; Sun, 18 Aug 2019 21:18:23 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0035.hostedemail.com [216.40.44.35])
	by kanga.kvack.org (Postfix) with ESMTP id 4413A6B000C
	for <linux-mm@kvack.org>; Sun, 18 Aug 2019 21:18:23 -0400 (EDT)
Received: from smtpin08.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id EF508180AD806
	for <linux-mm@kvack.org>; Mon, 19 Aug 2019 01:18:22 +0000 (UTC)
X-FDA: 75837416844.08.glass63_491ce0e691362
X-HE-Tag: glass63_491ce0e691362
X-Filterd-Recvd-Size: 6810
Received: from mail-pg1-f193.google.com (mail-pg1-f193.google.com [209.85.215.193])
	by imf18.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon, 19 Aug 2019 01:18:22 +0000 (UTC)
Received: by mail-pg1-f193.google.com with SMTP id o13so144524pgp.12
        for <linux-mm@kvack.org>; Sun, 18 Aug 2019 18:18:22 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id;
        bh=xO5G/2aB02PfoG6yTTcPywvHCQm1y+8qt72VVk54DY8=;
        b=qGXy3r4ruIVnVfIiWUyVietKq+m7wJmSmrvfBuspwhd1GGk3OxznqDNeVRgbNFK2/L
         XKlX76WoNGdK0Dqb9OBnL9uKPW1EtOdICFxxpkLmOlfPP3T3niUNcWA7wVZ2bUa0HbXL
         tTSnyu1vtThtKfca0zjlRM4movX84E2SHNqVQOFMcKIDMcuvPQm8S8HtIabIuwZeEJSK
         U370HqH6c1Mq2RYDFo+eF4wTk4tO/hhzKXojYk29VXQvU5TBo0mBQBYx9NDDbaVwzNtz
         iW7nDw0GVrhbXVPqPRG3fMc0pFLUbz3rMMscRoN6QY8VT7ldEz2x8NWbnOEg5/FsYiqN
         krng==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id;
        bh=xO5G/2aB02PfoG6yTTcPywvHCQm1y+8qt72VVk54DY8=;
        b=K95uk7foTTQ7IBQMHgWPgQsrP7czE1EW30EnWFNO5aQjTmxEiDjnbUkYiRXZ3CsiSn
         Dw5WEaBlpV61cX6DsgU9fZocZQsUCs8bVOtiocjmB2JwuDZAwUccOfu7Wv6NlZUCjqAO
         HPHpc1BXE4HWrnoZ3TzIVIf9ZTSZ9RRQhcWtJVVtYOi/EPydo6DTIRvscHfw9QF/wDw8
         jgkyV1bySyLpPyygrYfUFrBgSMDeFp5K/hGncot3eu/maMCjUimz2ScNR+nnplQEUWr8
         fk5NFmv/oqjXrTcOqHpXh7JR9dFw/m9ta75/SM7TYPjvzt/8uXaVBFhuw/rKpVLg+2m3
         buyQ==
X-Gm-Message-State: APjAAAVjcrqsRq5Lemw8+sfdr3WcNRfjgR907j991eXh07ypHT1esDVx
	LxdCGIXsjE93jY9HvV7cebE=
X-Google-Smtp-Source: APXvYqwxn7Qx3i2UjMRpT07dIF+ieKn1x9xNEzM1WvyDCQCHpc3joyfff5ZMZnrka0YKulZ64L0s+A==
X-Received: by 2002:a65:5144:: with SMTP id g4mr17777258pgq.202.1566177501260;
        Sun, 18 Aug 2019 18:18:21 -0700 (PDT)
Received: from bogon.localdomain ([203.100.54.194])
        by smtp.gmail.com with ESMTPSA id w26sm15405696pfq.100.2019.08.18.18.18.17
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 18 Aug 2019 18:18:20 -0700 (PDT)
From: Yafang Shao <laoar.shao@gmail.com>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org,
	Yafang Shao <laoar.shao@gmail.com>,
	Roman Gushchin <guro@fb.com>,
	Randy Dunlap <rdunlap@infradead.org>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Michal Hocko <mhocko@suse.com>,
	Vladimir Davydov <vdavydov.dev@gmail.com>,
	Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>,
	Souptick Joarder <jrdr.linux@gmail.com>,
	Yafang Shao <shaoyafang@didiglobal.com>
Subject: [PATCH v2] mm, memcg: skip killing processes under memcg protection at first scan
Date: Sun, 18 Aug 2019 21:18:06 -0400
Message-Id: <1566177486-2649-1-git-send-email-laoar.shao@gmail.com>
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
Cc: Souptick Joarder <jrdr.linux@gmail.com>
Cc: Yafang Shao <shaoyafang@didiglobal.com>
---
 include/linux/memcontrol.h |  6 ++++++
 mm/memcontrol.c            | 16 ++++++++++++++++
 mm/oom_kill.c              | 23 +++++++++++++++++++++--
 3 files changed, 43 insertions(+), 2 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 44c4146..534fe92 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -337,6 +337,7 @@ static inline bool mem_cgroup_disabled(void)
 
 enum mem_cgroup_protection mem_cgroup_protected(struct mem_cgroup *root,
 						struct mem_cgroup *memcg);
+bool task_under_memcg_protection(struct task_struct *p);
 
 int mem_cgroup_try_charge(struct page *page, struct mm_struct *mm,
 			  gfp_t gfp_mask, struct mem_cgroup **memcgp,
@@ -813,6 +814,11 @@ static inline enum mem_cgroup_protection mem_cgroup_protected(
 	return MEMCG_PROT_NONE;
 }
 
+static inline bool task_under_memcg_protection(struct task_struct *p)
+{
+	return false;
+}
+
 static inline int mem_cgroup_try_charge(struct page *page, struct mm_struct *mm,
 					gfp_t gfp_mask,
 					struct mem_cgroup **memcgp,
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index cdbb7a8..8df3d88 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -6030,6 +6030,22 @@ enum mem_cgroup_protection mem_cgroup_protected(struct mem_cgroup *root,
 		return MEMCG_PROT_NONE;
 }
 
+bool task_under_memcg_protection(struct task_struct *p)
+{
+	struct mem_cgroup *memcg;
+	bool protected;
+
+	rcu_read_lock();
+	memcg = mem_cgroup_from_task(p);
+	if (memcg != root_mem_cgroup && memcg->memory.min)
+		protected = true;
+	else
+		protected = false;
+	rcu_read_unlock();
+
+	return protected;
+}
+
 /**
  * mem_cgroup_try_charge - try charging a page
  * @page: page to charge
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index eda2e2a..e9bdad3 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -367,12 +367,31 @@ static void select_bad_process(struct oom_control *oc)
 	if (is_memcg_oom(oc))
 		mem_cgroup_scan_tasks(oc->memcg, oom_evaluate_task, oc);
 	else {
+		bool memcg_check = false;
+		bool memcg_skip = false;
 		struct task_struct *p;
+		int selected = 0;
 
 		rcu_read_lock();
-		for_each_process(p)
-			if (oom_evaluate_task(p, oc))
+retry:
+		for_each_process(p) {
+			if (!memcg_check && task_under_memcg_protection(p)) {
+				memcg_skip = true;
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
+					memcg_check = true;
+					goto retry;
+				}
+			}
+		}
 		rcu_read_unlock();
 	}
 }
-- 
1.8.3.1


