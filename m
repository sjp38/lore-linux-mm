Return-Path: <SRS0=92PK=RL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT,
	USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C23A6C43381
	for <linux-mm@archiver.kernel.org>; Fri,  8 Mar 2019 18:43:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7517620857
	for <linux-mm@archiver.kernel.org>; Fri,  8 Mar 2019 18:43:24 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="Fq0xrXkG"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7517620857
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1C6168E0004; Fri,  8 Mar 2019 13:43:24 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 17A658E0002; Fri,  8 Mar 2019 13:43:24 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 03D028E0004; Fri,  8 Mar 2019 13:43:23 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f71.google.com (mail-io1-f71.google.com [209.85.166.71])
	by kanga.kvack.org (Postfix) with ESMTP id CC0AC8E0002
	for <linux-mm@kvack.org>; Fri,  8 Mar 2019 13:43:23 -0500 (EST)
Received: by mail-io1-f71.google.com with SMTP id r21so16315648ioa.13
        for <linux-mm@kvack.org>; Fri, 08 Mar 2019 10:43:23 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:in-reply-to:message-id
         :mime-version:references:subject:from:to:cc;
        bh=KOFnefpWm/MGJVRwB1q3IBuYjFO05z5JkA9pY57L9o8=;
        b=WjyYOxwzorRI4vuTBBC3Udq7m7jX1Nwr4DMcDYhCFgEzai/k8b05uMzvi6j7a1w8TF
         wwca0BRTMtbdnTctfBWRbrPLo1JjIKJeJMP8/8hob6eLxYisWLtCh2I4+irHoZhK0/md
         e+ImtWASSEvP7b48OamUXHMTU3nHsvoZSEt7KYCjvJVG6AY0in+/zmnrXhvaUQrfNTFj
         6wA5Zfda9dSJn+PYQHG+YKFK1KZkBC4viDCUASoV/S4oMOOY8/GhwQ+UseTH8ha2tWtN
         TeByO4EbR2ICIZXqBsXL7/+cQKH4Fn7uoTlCAr0tTrUbHeNRKpdDJ/99QdcvPaJy9NNq
         tfRg==
X-Gm-Message-State: APjAAAWQ1Y0StftjOyarPMo0Sd7YzfZSu6fFzrMBBa6krhwMJoPCt3Ri
	sN+oYNAK3w6ng9NAnNYd9fVlbvC8IUz1W07UumI1dFGmMJnwXrdCZUqFS8u+D5u9S3IeXfHcTnC
	INv76BcHndeGM9qWMU4twTuHIYmDa18LwUhD5tW35toZ8YXV3+mBCCX+Fc0r1/E90TIAGOB/045
	dBcbKN3d0hc8G2ezYbEFWR7FATf9Baa0AV152xGRxtDx413mKKKSG7+5oF25JGOrghCnT9JYle8
	VL2WbzsP97DuKwFQ45rYOLNwin4jenf6CT2mDlwNj+fsAX98xCOZLuCJSWkpJ9yPgXcVYiFsCOE
	fXFShu4JYJphOzEVY7a8APxkoPtzHl/J4Ba7GB+PMPTH3iWQGYytYwflZV52egY4R/0mlIE4js2
	/
X-Received: by 2002:a5d:91d3:: with SMTP id k19mr6047785ior.258.1552070603568;
        Fri, 08 Mar 2019 10:43:23 -0800 (PST)
X-Received: by 2002:a5d:91d3:: with SMTP id k19mr6047742ior.258.1552070602220;
        Fri, 08 Mar 2019 10:43:22 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1552070602; cv=none;
        d=google.com; s=arc-20160816;
        b=l8eUWRY4NjIXzi6cr+syV7ufQlCBXFf/rSusOVyUsrRXjpWVFuNNRsep0CzXH4fskp
         zjqh4hSxbo8k0D38AjjpZQ2dtei+TkqYypTC9pDvFPnoIPSTVnDOJSks/DEj1+8XaPSL
         dt6Wj8QiWCgA3vwz1gVdJKfAGLjstKJ5KGCtmmbULqLqQ9IS5vX7JV0snFDTNRL34jka
         5/rthnWupCHvgTQFxyqAFgF+nyxvynZZKJz48mKfmag7g51g1TsCbVuxq4bm878Per1m
         7lIQy+B5TtJoxNRnArLqKP2OZ/0mwle6Zz69lPenX0b+zsO9RC+LucLgGEXlM33GSszD
         sTug==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:references:mime-version:message-id:in-reply-to
         :date:dkim-signature;
        bh=KOFnefpWm/MGJVRwB1q3IBuYjFO05z5JkA9pY57L9o8=;
        b=g6pAIQYEXhP2TPdK2RBdqFemetTOdLf0mOvFDlPuXj3UKXqd/HyQSQjUEXPAn/dR1v
         VFiZXbMD8MYqrZBU0TjqECSd2nE7Ps4z5SwtsF1JwgXXfhpVIz63+wgxGxmFC1+t/Jwx
         ge+TcK3SpfRznum3iSU+Dc+gKGbmONlB12OhpH55yxY1zs31EqKqVY3t7CLrqNteX3J4
         MW4+u1lHcVTZ9Tjadw9JcQhUN3twuhD2Hhu4lZK/XeCECBU8qRTWA+/6oz0bOvNyZ/xN
         W9/lu/lgMj1pVgy6qIOlkWDXo2YXEaf5moy1lOBGaw7UDnAqyBB7zeBZcENhNuBkLIQa
         0v/A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=Fq0xrXkG;
       spf=pass (google.com: domain of 3ybecxaykcc4ceboxlqyyqvo.mywvsxeh-wwufkmu.ybq@flex--surenb.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3ybeCXAYKCC4cebOXLQYYQVO.MYWVSXeh-WWUfKMU.YbQ@flex--surenb.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id j24sor15105875itl.10.2019.03.08.10.43.22
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 08 Mar 2019 10:43:22 -0800 (PST)
Received-SPF: pass (google.com: domain of 3ybecxaykcc4ceboxlqyyqvo.mywvsxeh-wwufkmu.ybq@flex--surenb.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=Fq0xrXkG;
       spf=pass (google.com: domain of 3ybecxaykcc4ceboxlqyyqvo.mywvsxeh-wwufkmu.ybq@flex--surenb.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3ybeCXAYKCC4cebOXLQYYQVO.MYWVSXeh-WWUfKMU.YbQ@flex--surenb.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:in-reply-to:message-id:mime-version:references:subject:from:to
         :cc;
        bh=KOFnefpWm/MGJVRwB1q3IBuYjFO05z5JkA9pY57L9o8=;
        b=Fq0xrXkGnIBrB8IPGplA3ONIgs9/AtsDhXfa957pzUu8VveDvKt9hXCBFa4g03sXKf
         RfWWaxlEQ4HMi5vxnjFLw0BKcyO38p2v6BTsg3bUqecPc73aVEV+OsaDwDNDaCJH+wWy
         INLmlffLQotYNi+/k8wdjfNeG3pHvI1zRa3+65vy9XYgbxHRqsdmJIZ65avsqwaIYnCV
         +NEYwgx7MeOOuLV0XrUYK5/r0T2bYFqkh10ng3mN4+EvqUVSn8H/Zq8rxGvGY4cJDq1t
         SRBPt0IdkWFekzJX7pCy5JUaQRUXNXYgt9SSXeiLuvF1MmrTFVn6uK34PQ+Nv20lBiQ3
         aQIA==
X-Google-Smtp-Source: APXvYqzVQIDO3zH6/Mcc0ykLp0T9S36f2LzzA98NkiJ7Xxv2hG0pOuBW+mRWBRsSFt8RyW5EjF/qZ8iyxt4=
X-Received: by 2002:a24:8088:: with SMTP id g130mr13087838itd.28.1552070601978;
 Fri, 08 Mar 2019 10:43:21 -0800 (PST)
Date: Fri,  8 Mar 2019 10:43:05 -0800
In-Reply-To: <20190308184311.144521-1-surenb@google.com>
Message-Id: <20190308184311.144521-2-surenb@google.com>
Mime-Version: 1.0
References: <20190308184311.144521-1-surenb@google.com>
X-Mailer: git-send-email 2.21.0.360.g471c308f928-goog
Subject: [PATCH v5 1/7] psi: introduce state_mask to represent stalled psi states
From: Suren Baghdasaryan <surenb@google.com>
To: gregkh@linuxfoundation.org
Cc: tj@kernel.org, lizefan@huawei.com, hannes@cmpxchg.org, axboe@kernel.dk, 
	dennis@kernel.org, dennisszhou@gmail.com, mingo@redhat.com, 
	peterz@infradead.org, akpm@linux-foundation.org, corbet@lwn.net, 
	cgroups@vger.kernel.org, linux-mm@kvack.org, linux-doc@vger.kernel.org, 
	linux-kernel@vger.kernel.org, kernel-team@android.com, 
	Suren Baghdasaryan <surenb@google.com>, Stephen Rothwell <sfr@canb.auug.org.au>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The psi monitoring patches will need to determine the same states as
record_times().  To avoid calculating them twice, maintain a state mask
that can be consulted cheaply.  Do this in a separate patch to keep the
churn in the main feature patch at a minimum.

This adds 4-byte state_mask member into psi_group_cpu struct which results
in its first cacheline-aligned part becoming 52 bytes long.  Add explicit
values to enumeration element counters that affect psi_group_cpu struct
size.

Link: http://lkml.kernel.org/r/20190124211518.244221-4-surenb@google.com
Signed-off-by: Suren Baghdasaryan <surenb@google.com>
Acked-by: Johannes Weiner <hannes@cmpxchg.org>
Cc: Dennis Zhou <dennis@kernel.org>
Cc: Ingo Molnar <mingo@redhat.com>
Cc: Jens Axboe <axboe@kernel.dk>
Cc: Li Zefan <lizefan@huawei.com>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Tejun Heo <tj@kernel.org>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Stephen Rothwell <sfr@canb.auug.org.au>
---
 include/linux/psi_types.h |  9 ++++++---
 kernel/sched/psi.c        | 29 +++++++++++++++++++----------
 2 files changed, 25 insertions(+), 13 deletions(-)

diff --git a/include/linux/psi_types.h b/include/linux/psi_types.h
index 2cf422db5d18..762c6bb16f3c 100644
--- a/include/linux/psi_types.h
+++ b/include/linux/psi_types.h
@@ -11,7 +11,7 @@ enum psi_task_count {
 	NR_IOWAIT,
 	NR_MEMSTALL,
 	NR_RUNNING,
-	NR_PSI_TASK_COUNTS,
+	NR_PSI_TASK_COUNTS = 3,
 };
 
 /* Task state bitmasks */
@@ -24,7 +24,7 @@ enum psi_res {
 	PSI_IO,
 	PSI_MEM,
 	PSI_CPU,
-	NR_PSI_RESOURCES,
+	NR_PSI_RESOURCES = 3,
 };
 
 /*
@@ -41,7 +41,7 @@ enum psi_states {
 	PSI_CPU_SOME,
 	/* Only per-CPU, to weigh the CPU in the global average: */
 	PSI_NONIDLE,
-	NR_PSI_STATES,
+	NR_PSI_STATES = 6,
 };
 
 struct psi_group_cpu {
@@ -53,6 +53,9 @@ struct psi_group_cpu {
 	/* States of the tasks belonging to this group */
 	unsigned int tasks[NR_PSI_TASK_COUNTS];
 
+	/* Aggregate pressure state derived from the tasks */
+	u32 state_mask;
+
 	/* Period time sampling buckets for each state of interest (ns) */
 	u32 times[NR_PSI_STATES];
 
diff --git a/kernel/sched/psi.c b/kernel/sched/psi.c
index 0e97ca9306ef..22c1505ad290 100644
--- a/kernel/sched/psi.c
+++ b/kernel/sched/psi.c
@@ -213,17 +213,17 @@ static bool test_state(unsigned int *tasks, enum psi_states state)
 static void get_recent_times(struct psi_group *group, int cpu, u32 *times)
 {
 	struct psi_group_cpu *groupc = per_cpu_ptr(group->pcpu, cpu);
-	unsigned int tasks[NR_PSI_TASK_COUNTS];
 	u64 now, state_start;
+	enum psi_states s;
 	unsigned int seq;
-	int s;
+	u32 state_mask;
 
 	/* Snapshot a coherent view of the CPU state */
 	do {
 		seq = read_seqcount_begin(&groupc->seq);
 		now = cpu_clock(cpu);
 		memcpy(times, groupc->times, sizeof(groupc->times));
-		memcpy(tasks, groupc->tasks, sizeof(groupc->tasks));
+		state_mask = groupc->state_mask;
 		state_start = groupc->state_start;
 	} while (read_seqcount_retry(&groupc->seq, seq));
 
@@ -239,7 +239,7 @@ static void get_recent_times(struct psi_group *group, int cpu, u32 *times)
 		 * (u32) and our reported pressure close to what's
 		 * actually happening.
 		 */
-		if (test_state(tasks, s))
+		if (state_mask & (1 << s))
 			times[s] += now - state_start;
 
 		delta = times[s] - groupc->times_prev[s];
@@ -407,15 +407,15 @@ static void record_times(struct psi_group_cpu *groupc, int cpu,
 	delta = now - groupc->state_start;
 	groupc->state_start = now;
 
-	if (test_state(groupc->tasks, PSI_IO_SOME)) {
+	if (groupc->state_mask & (1 << PSI_IO_SOME)) {
 		groupc->times[PSI_IO_SOME] += delta;
-		if (test_state(groupc->tasks, PSI_IO_FULL))
+		if (groupc->state_mask & (1 << PSI_IO_FULL))
 			groupc->times[PSI_IO_FULL] += delta;
 	}
 
-	if (test_state(groupc->tasks, PSI_MEM_SOME)) {
+	if (groupc->state_mask & (1 << PSI_MEM_SOME)) {
 		groupc->times[PSI_MEM_SOME] += delta;
-		if (test_state(groupc->tasks, PSI_MEM_FULL))
+		if (groupc->state_mask & (1 << PSI_MEM_FULL))
 			groupc->times[PSI_MEM_FULL] += delta;
 		else if (memstall_tick) {
 			u32 sample;
@@ -436,10 +436,10 @@ static void record_times(struct psi_group_cpu *groupc, int cpu,
 		}
 	}
 
-	if (test_state(groupc->tasks, PSI_CPU_SOME))
+	if (groupc->state_mask & (1 << PSI_CPU_SOME))
 		groupc->times[PSI_CPU_SOME] += delta;
 
-	if (test_state(groupc->tasks, PSI_NONIDLE))
+	if (groupc->state_mask & (1 << PSI_NONIDLE))
 		groupc->times[PSI_NONIDLE] += delta;
 }
 
@@ -448,6 +448,8 @@ static void psi_group_change(struct psi_group *group, int cpu,
 {
 	struct psi_group_cpu *groupc;
 	unsigned int t, m;
+	enum psi_states s;
+	u32 state_mask = 0;
 
 	groupc = per_cpu_ptr(group->pcpu, cpu);
 
@@ -480,6 +482,13 @@ static void psi_group_change(struct psi_group *group, int cpu,
 		if (set & (1 << t))
 			groupc->tasks[t]++;
 
+	/* Calculate state mask representing active states */
+	for (s = 0; s < NR_PSI_STATES; s++) {
+		if (test_state(groupc->tasks, s))
+			state_mask |= (1 << s);
+	}
+	groupc->state_mask = state_mask;
+
 	write_seqcount_end(&groupc->seq);
 }
 
-- 
2.21.0.360.g471c308f928-goog

