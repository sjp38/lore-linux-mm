Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it1-f197.google.com (mail-it1-f197.google.com [209.85.166.197])
	by kanga.kvack.org (Postfix) with ESMTP id A37C58E0001
	for <linux-mm@kvack.org>; Wed, 19 Dec 2018 02:24:01 -0500 (EST)
Received: by mail-it1-f197.google.com with SMTP id j202so7694267itj.1
        for <linux-mm@kvack.org>; Tue, 18 Dec 2018 23:24:01 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id d14si2350899ita.139.2018.12.18.23.23.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 18 Dec 2018 23:24:00 -0800 (PST)
Message-Id: <201812190723.wBJ7NdkN032628@www262.sakura.ne.jp>
Subject: Re: [PATCH v15 2/2] Add oom victim's memcg to the oom context information
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
MIME-Version: 1.0
Date: Wed, 19 Dec 2018 16:23:39 +0900
References: <20181122133954.GI18011@dhcp22.suse.cz> <CAHCio2gdCX3p-7=N0cA22cWTaUmUXRq8WbiMAA2sM2wLVX4GjQ@mail.gmail.com>
In-Reply-To: <CAHCio2gdCX3p-7=N0cA22cWTaUmUXRq8WbiMAA2sM2wLVX4GjQ@mail.gmail.com>
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?UTF-8?B?56a56Iif6ZSu?= <ufo19890607@gmail.com>, akpm@linux-foundation.org
Cc: mhocko@kernel.org, rientjes@google.com, kirill.shutemov@linux.intel.com, aarcange@redhat.com, guro@fb.com, yang.s@alibaba-inc.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Wind Yu <yuzhoujian@didichuxing.com>

Andrew, will you fold below diff into "mm, oom: add oom victim's memcg to the oom context information" ?

>From add1e8daddbfc5186417dbc58e9e11e7614868f8 Mon Sep 17 00:00:00 2001
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Date: Wed, 19 Dec 2018 16:09:31 +0900
Subject: [PATCH] mm, oom: Use pr_cont() in mem_cgroup_print_oom_context().

One line summary of the OOM killer context is not one line due to
not using KERN_CONT.

[   23.346650] oom-kill:constraint=CONSTRAINT_NONE,nodemask=(null),cpuset=/,mems_allowed=0
[   23.346691] ,global_oom,task_memcg=/,task=firewalld,pid=5096,uid=0

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
---
 mm/memcontrol.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index b860dd4f7..4afd597 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1306,10 +1306,10 @@ void mem_cgroup_print_oom_context(struct mem_cgroup *memcg, struct task_struct *
 	rcu_read_lock();
 
 	if (memcg) {
-		pr_info(",oom_memcg=");
+		pr_cont(",oom_memcg=");
 		pr_cont_cgroup_path(memcg->css.cgroup);
 	} else
-		pr_info(",global_oom");
+		pr_cont(",global_oom");
 	if (p) {
 		pr_cont(",task_memcg=");
 		pr_cont_cgroup_path(task_cgroup(p, memory_cgrp_id));
-- 
1.8.3.1
