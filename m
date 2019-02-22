Return-Path: <SRS0=SgWF=Q5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7CB0DC43381
	for <linux-mm@archiver.kernel.org>; Fri, 22 Feb 2019 04:37:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 24F7B2086A
	for <linux-mm@archiver.kernel.org>; Fri, 22 Feb 2019 04:37:39 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 24F7B2086A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lge.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 994778E00E7; Thu, 21 Feb 2019 23:37:39 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 943B88E00D4; Thu, 21 Feb 2019 23:37:39 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 859DD8E00E7; Thu, 21 Feb 2019 23:37:39 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 438EF8E00D4
	for <linux-mm@kvack.org>; Thu, 21 Feb 2019 23:37:39 -0500 (EST)
Received: by mail-pl1-f198.google.com with SMTP id j13so767172pll.15
        for <linux-mm@kvack.org>; Thu, 21 Feb 2019 20:37:39 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id;
        bh=sMzbtLXxmUkTmnmDuOn/8WkbA9/hakMSs7eQaMVhfII=;
        b=te6SVW7VnZzgBQc+yOuBAOcd+95gzQwyO4sErZ3I1Lg2Yl1tS6tSwFGGXd3H0Bt5Hw
         CX6Ve5GWXBepW088kmLeAjhBm3/cyzL0gNgs7xPBOtm8ZDAcLtlyXoY75mmDKkos4YX/
         2fgxI7ys33SKrvQ5UzZGJ+eR7WMqmN2WTV3gFjsD0d4bxrkG9/YMRuvpaa+vBRKThvv6
         /ImLj2yBQQJT2v438d2A7b6A5TeDGuuzASI6fYTAlYpoKBDawAP3e/M7twhM+xD6EwEe
         hlqJd9NEBBe5v/IK+aTLbnUE0DCIVmpJYVvl/CAkB6RcF6vyIcPlmYbUDAnCXuHUxv9V
         ubiA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of junil0814.lee@lge.com designates 156.147.23.52 as permitted sender) smtp.mailfrom=junil0814.lee@lge.com
X-Gm-Message-State: AHQUAuYMuFt5dFLy7PgwnyaB3uIiZ5IQT5DcLvaHUlUYmQQ6g0db+Fud
	FHvk7ZoziTo3c72G85xM3CyPN6M6SNHstfGXt/KBx/PmWwD1BAE0WlHuiVzgfpalAeZSfukumI/
	fY1tDTodZJnDYlfAz0EkTCRYpCPiMD+62Jdb6Ogeg8OPgCuQdA/1xxLNbgwj19lBMNQ==
X-Received: by 2002:a63:43c1:: with SMTP id q184mr2101401pga.110.1550810258849;
        Thu, 21 Feb 2019 20:37:38 -0800 (PST)
X-Google-Smtp-Source: AHgI3IaQz6guoEpz56L7/8iEIYYVVuzf0rGyyrGPLddzIq5GEJKrCh0ihGVNBC2NJqt4N6pbE1qA
X-Received: by 2002:a63:43c1:: with SMTP id q184mr2101346pga.110.1550810257881;
        Thu, 21 Feb 2019 20:37:37 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550810257; cv=none;
        d=google.com; s=arc-20160816;
        b=miNzHLkchRoXOiNzPyyWcNv2vv5NSXFNH5arQVxBxs5SMIkfReBzSC6uWQbu5ziE7n
         s3bWoPC82Nu9s3CtOVm+MdF5X76SRaUGmitaYCmvKzb2MzW2jm1T51IuB0rJ8I7lHyEJ
         +otfnik6zKxrL9dhMekIb18nooQ68+wVtAXpMOEYKy+8SMlbQJc7cVPX+PejJuprJZk4
         3LKRl5MZPUm6jjgnXQnqr19Zc7rsSGzJUhEj42+CJSM7b9PnGinBuWfVP58ahRIo29RI
         eBDIU/TjeMq+U72rn5qm4UzzBToJYd1FJ81oZVK1pQyXpo8X53XL/paD6eMxKudb31U1
         8IyQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from;
        bh=sMzbtLXxmUkTmnmDuOn/8WkbA9/hakMSs7eQaMVhfII=;
        b=KdpZJTCS0Y6DlKYAcFwBB3rFrTQ8a8S+cy7xGNbQY5/9ZvQzM1j1oVTcyC7C0GNpqx
         HuRUgsk7mw9ukDwgtAJH7AB3UQz/n7i/d4nZ97qugTzevbGOaAsPwKM/eCA9hC7v4QcP
         wxf3550axO5UTDAXKdbhXX8XnSIYfnP/261GIZaCySXKhl7CFBcTCSe/A7y0+4BNA665
         VfSSA4zu5P4BdIE5QoFfJM2Bz9E4PJ8PY4TCk3XeJJEWY/t67T6/+oBWduwD5+j6u7ej
         ZAOjzD0kyKfekvDFpBeXII9DjClRu1XN7pTO2aIWgb7OC0jHy76GWRLpC2F3SJ1/FFTn
         UiYQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of junil0814.lee@lge.com designates 156.147.23.52 as permitted sender) smtp.mailfrom=junil0814.lee@lge.com
Received: from lgeamrelo11.lge.com (lgeamrelo12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id q15si416875pgg.570.2019.02.21.20.37.37
        for <linux-mm@kvack.org>;
        Thu, 21 Feb 2019 20:37:37 -0800 (PST)
Received-SPF: pass (google.com: domain of junil0814.lee@lge.com designates 156.147.23.52 as permitted sender) client-ip=156.147.23.52;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of junil0814.lee@lge.com designates 156.147.23.52 as permitted sender) smtp.mailfrom=junil0814.lee@lge.com
Received: from unknown (HELO lgeamrelo02.lge.com) (156.147.1.126)
	by 156.147.23.52 with ESMTP; 22 Feb 2019 13:37:36 +0900
X-Original-SENDERIP: 156.147.1.126
X-Original-MAILFROM: junil0814.lee@lge.com
Received: from unknown (HELO localhost.localdomain) (10.168.178.220)
	by 156.147.1.126 with ESMTP; 22 Feb 2019 13:37:35 +0900
X-Original-SENDERIP: 10.168.178.220
X-Original-MAILFROM: junil0814.lee@lge.com
From: Junil Lee <junil0814.lee@lge.com>
To: linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Cc: akpm@linux-foundation.org,
	willy@infradead.org,
	mhocko@suse.com,
	pasha.tatashin@oracle.com,
	kirill.shutemov@linux.intel.com,
	jrdr.linux@gmail.com,
	dan.j.williams@intel.com,
	alexander.h.duyck@linux.intel.com,
	andreyknvl@google.com,
	arunks@codeaurora.org,
	keith.busch@intel.com,
	guro@fb.com,
	hannes@cmpxchg.org,
	rientjes@google.com,
	penguin-kernel@I-love.SAKURA.ne.jp,
	shakeelb@google.com,
	yuzhoujian@didichuxing.com,
	Junil Lee <junil0814.lee@lge.com>
Subject: [PATCH] mm, oom: OOM killer use rss size without shmem
Date: Fri, 22 Feb 2019 13:37:33 +0900
Message-Id: <1550810253-152925-1-git-send-email-junil0814.lee@lge.com>
X-Mailer: git-send-email 2.6.2
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The oom killer use get_mm_rss() function to estimate how free memory
will be reclaimed when the oom killer select victim task.

However, the returned rss size by get_mm_rss() function was changed from
"mm, shmem: add internal shmem resident memory accounting" commit.
This commit makes the get_mm_rss() return size including SHMEM pages.

The oom killer can't get free memory from SHMEM pages directly after
kill victim process, it leads to mis-calculate victim points.

Therefore, make new API as get_mm_rss_wo_shmem() which returns the rss
value excluding SHMEM_PAGES.

Signed-off-by: Junil Lee <junil0814.lee@lge.com>
---
 include/linux/mm.h | 6 ++++++
 mm/oom_kill.c      | 4 ++--
 2 files changed, 8 insertions(+), 2 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 2d483db..bca3acc 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1701,6 +1701,12 @@ static inline int mm_counter(struct page *page)
 	return mm_counter_file(page);
 }
 
+static inline unsigned long get_mm_rss_wo_shmem(struct mm_struct *mm)
+{
+	return get_mm_counter(mm, MM_FILEPAGES) +
+		get_mm_counter(mm, MM_ANONPAGES);
+}
+
 static inline unsigned long get_mm_rss(struct mm_struct *mm)
 {
 	return get_mm_counter(mm, MM_FILEPAGES) +
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 3a24848..e569737 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -230,7 +230,7 @@ unsigned long oom_badness(struct task_struct *p, struct mem_cgroup *memcg,
 	 * The baseline for the badness score is the proportion of RAM that each
 	 * task's rss, pagetable and swap space use.
 	 */
-	points = get_mm_rss(p->mm) + get_mm_counter(p->mm, MM_SWAPENTS) +
+	points = get_mm_rss_wo_shmem(p->mm) + get_mm_counter(p->mm, MM_SWAPENTS) +
 		mm_pgtables_bytes(p->mm) / PAGE_SIZE;
 	task_unlock(p);
 
@@ -419,7 +419,7 @@ static void dump_tasks(struct mem_cgroup *memcg, const nodemask_t *nodemask)
 
 		pr_info("[%7d] %5d %5d %8lu %8lu %8ld %8lu         %5hd %s\n",
 			task->pid, from_kuid(&init_user_ns, task_uid(task)),
-			task->tgid, task->mm->total_vm, get_mm_rss(task->mm),
+			task->tgid, task->mm->total_vm, get_mm_rss_wo_shmem(task->mm),
 			mm_pgtables_bytes(task->mm),
 			get_mm_counter(task->mm, MM_SWAPENTS),
 			task->signal->oom_score_adj, task->comm);
-- 
2.6.2

