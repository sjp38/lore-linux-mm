Return-Path: <SRS0=Hl4p=TW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 44D1CC18E7D
	for <linux-mm@archiver.kernel.org>; Wed, 22 May 2019 10:08:43 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0659520868
	for <linux-mm@archiver.kernel.org>; Wed, 22 May 2019 10:08:42 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0659520868
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=I-love.SAKURA.ne.jp
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8CDB96B0010; Wed, 22 May 2019 06:08:42 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 87F6A6B0266; Wed, 22 May 2019 06:08:42 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 76EB36B0269; Wed, 22 May 2019 06:08:42 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f70.google.com (mail-ot1-f70.google.com [209.85.210.70])
	by kanga.kvack.org (Postfix) with ESMTP id 4D6496B0010
	for <linux-mm@kvack.org>; Wed, 22 May 2019 06:08:42 -0400 (EDT)
Received: by mail-ot1-f70.google.com with SMTP id e88so951630ote.14
        for <linux-mm@kvack.org>; Wed, 22 May 2019 03:08:42 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=rs4UdQDICU/o5iwjI5TTWqhrv+pRH7CNKbCoDL5CNSw=;
        b=ONR0UKKMK7csi5WsX2I/eDJrE9/B3i76QJ+Q1KZpYbdg4MxmRFAOL7gxO1HvhPnnP9
         zQEUjmODixv3zrLy5da0CaWUPqR1U5b9J3Y9ht0dkFed3Vhq2PQ/yvzPP9rwyBnl56xE
         QIEC1XFSiOWo36j1DfG/BkL1BLcJbMpf6cfGXKMSx5B4mT5SgXd9TgjDAo4Dzwbt5IXm
         nMLPjTBuMjIIbSSFczibZ36xK29moVTwelLEHOhJ9WV1X3tJWUuZLJvwi3IT1GdFXuOb
         irB3xlHwq9lMdT5rkpSl4AAbbxfrohkSMA+fmldhnQ92FTeRfbhDzJxA9weqv6YbtFg+
         0Pww==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) smtp.mailfrom=penguin-kernel@i-love.sakura.ne.jp
X-Gm-Message-State: APjAAAXVBBNgA2yUMcMyiYjBlPTwpDYpbr8j5t/qHbtTwoAx1QIi3kVY
	0e9m2UkMetBcx39e2goBv9ifMRFCKkaS8UgH7DE5iJ3fVjI8dTdwm7sigSmWY9HP+Jz8BGA2qLf
	wP+RbezvOIyXcf3EOx5+Rm9XZfnXhBXQqnG1V08JMa40ExbwB48BfhLgEzABsKFIw9A==
X-Received: by 2002:aca:b1d4:: with SMTP id a203mr6624877oif.67.1558519721946;
        Wed, 22 May 2019 03:08:41 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwI/RfoLfW9uIdw2qETKAO3znX88XG1zZSIrdnkUp6qC+TjG6QWyvSCpRL6GgQ8SQtjWDfB
X-Received: by 2002:aca:b1d4:: with SMTP id a203mr6624815oif.67.1558519720676;
        Wed, 22 May 2019 03:08:40 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558519720; cv=none;
        d=google.com; s=arc-20160816;
        b=vLkl0SVTuiLbX03Qsa8k3Zx7OkmX2FgQyGRobhovBfEcSJLuSAvHvzss7Ay3LnFIBs
         tCGfwccZPhMihmWdw9ggdEjZKoiCTBbkaS2qLkJaETq11a9Jbfr7MPZpV4w7DHBjt/Ea
         rAGzpZR8n/znSxWkKDESFTHBYqGjpRy6W2jMxozd7mkzxKJcS9TmD3PUtIB3CMwZjvCF
         /hriUvVJTaOLGe3NmWn8i2dUhURQBFkwNxTx/oJtha0vGIGoQPk6qu1JigyC0VOJJMGO
         p7xR6bp0JwfZ16HVrAp5G6gWh7kuQGlYigWL1HfuetRCazIynrXchurbUe4fav70RFlC
         RZ6w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=rs4UdQDICU/o5iwjI5TTWqhrv+pRH7CNKbCoDL5CNSw=;
        b=h31XnzFb4N5LY2CWzHbgmcmjuwd1z70XsRO6NLbhxpeoe64hvpdShcb9n2TKi0tAF9
         Cqs3g8Iw49wKilzU0yqUqHUrK4z2vP/S1VjmyzBVh8uCTARE3kyoi6CbR9XxP7EjsRUb
         s26AH3EonBEtz844BF80ikoyBZVx7S51SWB2XXJD4aSebmNsmfwFGjgnBj0HJm02IB+d
         TBeJug+aeZJvKzd1cwfsHO22+LfHSzZ4sPbIdqHHTM9pkqcvcBFfLjw1SVjh0hwQB1kx
         PXykb78czGbDO6+OimMjrt+CGdZ17EAPzvEl1qeD6bwkVrEZn+2f+YS4lRAm1II2Kcj2
         QuMA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) smtp.mailfrom=penguin-kernel@i-love.sakura.ne.jp
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id l9si13003218otf.273.2019.05.22.03.08.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 May 2019 03:08:40 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) client-ip=202.181.97.72;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) smtp.mailfrom=penguin-kernel@i-love.sakura.ne.jp
Received: from fsav404.sakura.ne.jp (fsav404.sakura.ne.jp [133.242.250.103])
	by www262.sakura.ne.jp (8.15.2/8.15.2) with ESMTP id x4MA8JdW039257;
	Wed, 22 May 2019 19:08:19 +0900 (JST)
	(envelope-from penguin-kernel@I-love.SAKURA.ne.jp)
Received: from www262.sakura.ne.jp (202.181.97.72)
 by fsav404.sakura.ne.jp (F-Secure/fsigk_smtp/530/fsav404.sakura.ne.jp);
 Wed, 22 May 2019 19:08:19 +0900 (JST)
X-Virus-Status: clean(F-Secure/fsigk_smtp/530/fsav404.sakura.ne.jp)
Received: from ccsecurity.localdomain (softbank126012062002.bbtec.net [126.12.62.2])
	(authenticated bits=0)
	by www262.sakura.ne.jp (8.15.2/8.15.2) with ESMTPSA id x4MA8Fdo039015
	(version=TLSv1.2 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=NO);
	Wed, 22 May 2019 19:08:19 +0900 (JST)
	(envelope-from penguin-kernel@I-love.SAKURA.ne.jp)
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Michal Hocko <mhocko@suse.com>,
        Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: [PATCH 3/4] mm, oom: Wait for OOM victims even if oom_kill_allocating_task case.
Date: Wed, 22 May 2019 19:08:05 +0900
Message-Id: <1558519686-16057-3-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1558519686-16057-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
References: <1558519686-16057-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

"mm, oom: Avoid potential RCU stall at dump_tasks()." changed to imply
oom_dump_tasks == 0 if oom_kill_allocating_task != 0. But since we can
expect the OOM reaper to reclaim memory quickly, and majority of latency
is not for_each_process() from select_bad_process() but printk() from
dump_header(), waiting for in-flight OOM victims until the OOM reaper
completes should generate preferable results (i.e. minimal number of
OOM victims).

As side effects of this patch, oom_kill_allocating_task != 0 no longer
implies oom_dump_tasks == 0, complicated conditions for whether to enter
oom_kill_allocating_task path are simplified, and a theoretical bug that
the OOM killer forever retries oom_kill_allocating_task path even after
the OOM reaper set MMF_OOM_SKIP is fixed.

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
---
 mm/oom_kill.c | 44 +++++++++++++++++++++++---------------------
 1 file changed, 23 insertions(+), 21 deletions(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 00b594c..64e582e 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -367,19 +367,29 @@ static int oom_evaluate_task(struct task_struct *task, void *arg)
  * Simple selection loop. We choose the process with the highest number of
  * 'points'. In case scan was aborted, oc->chosen is set to -1.
  */
-static void select_bad_process(struct oom_control *oc)
+static const char *select_bad_process(struct oom_control *oc)
 {
-	if (is_memcg_oom(oc))
-		mem_cgroup_scan_tasks(oc->memcg, oom_evaluate_task, oc);
-	else {
-		struct task_struct *p;
+	struct task_struct *p;
 
-		rcu_read_lock();
-		for_each_process(p)
-			if (oom_evaluate_task(p, oc))
-				break;
-		rcu_read_unlock();
+	if (is_memcg_oom(oc)) {
+		mem_cgroup_scan_tasks(oc->memcg, oom_evaluate_task, oc);
+		return "Memory cgroup out of memory";
 	}
+	rcu_read_lock();
+	for_each_process(p)
+		if (oom_evaluate_task(p, oc))
+			break;
+	rcu_read_unlock();
+	if (sysctl_oom_kill_allocating_task && oc->chosen != (void *)-1UL) {
+		list_for_each_entry(p, &oom_candidate_list,
+				    oom_candidate_list) {
+			if (!same_thread_group(p, current))
+				continue;
+			oc->chosen = current;
+			return "Out of memory (oom_kill_allocating_task)";
+		}
+	}
+	return "Out of memory";
 }
 
 /**
@@ -1021,6 +1031,7 @@ bool out_of_memory(struct oom_control *oc)
 {
 	unsigned long freed = 0;
 	enum oom_constraint constraint = CONSTRAINT_NONE;
+	const char *message;
 
 	if (oom_killer_disabled)
 		return false;
@@ -1061,15 +1072,7 @@ bool out_of_memory(struct oom_control *oc)
 		oc->nodemask = NULL;
 	check_panic_on_oom(oc, constraint);
 
-	if (!is_memcg_oom(oc) && sysctl_oom_kill_allocating_task &&
-	    current->mm && !oom_unkillable_task(current, NULL, oc->nodemask) &&
-	    current->signal->oom_score_adj != OOM_SCORE_ADJ_MIN) {
-		oc->chosen = current;
-		oom_kill_process(oc, "Out of memory (oom_kill_allocating_task)");
-		return true;
-	}
-
-	select_bad_process(oc);
+	message = select_bad_process(oc);
 	/* Found nothing?!?! */
 	if (!oc->chosen) {
 		dump_header(oc, NULL);
@@ -1083,8 +1086,7 @@ bool out_of_memory(struct oom_control *oc)
 			panic("System is deadlocked on memory\n");
 	}
 	if (oc->chosen && oc->chosen != (void *)-1UL)
-		oom_kill_process(oc, !is_memcg_oom(oc) ? "Out of memory" :
-				 "Memory cgroup out of memory");
+		oom_kill_process(oc, message);
 	while (!list_empty(&oom_candidate_list)) {
 		struct task_struct *p = list_first_entry(&oom_candidate_list,
 							 struct task_struct,
-- 
1.8.3.1

