Return-Path: <SRS0=Ztt1=P3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-21.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT,
	USER_IN_DEF_DKIM_WL autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C54BEC5AE5E
	for <linux-mm@archiver.kernel.org>; Sat, 19 Jan 2019 00:50:36 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 507C32086D
	for <linux-mm@archiver.kernel.org>; Sat, 19 Jan 2019 00:50:36 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="jyinSFuL"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 507C32086D
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9CD988E002E; Fri, 18 Jan 2019 19:50:35 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 97B878E0002; Fri, 18 Jan 2019 19:50:35 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 892B28E002E; Fri, 18 Jan 2019 19:50:35 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 450468E0002
	for <linux-mm@kvack.org>; Fri, 18 Jan 2019 19:50:35 -0500 (EST)
Received: by mail-pl1-f200.google.com with SMTP id m13so9152837pls.15
        for <linux-mm@kvack.org>; Fri, 18 Jan 2019 16:50:35 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:message-id:mime-version
         :subject:from:to:cc;
        bh=mffs7ZoNWUB7d7Vc+bx+tYMC4aNf0jf7l/hY0o8bs7c=;
        b=cXjfbvplauGbx44poQqmVX9OPqYWjpAmE4NAmTZ/XB8I6RIU2gignTLgq1R2DSBYqM
         7g7omL8Q8EqT4ZSZoIsCYjfUmLHhf9ijykxcYu8D+Qcdo+ctWNF6C/oL4D6yVPEMGiAB
         Z+HRRZ9xC9Rikfv97CDGWs3a90FnZOoMZNQT52t30zJpq7xuUdNbmLKsyZCSho4uXHuQ
         p5v5yEGo9QipvSd+rxZ68qlTONWcKDPuT3bBZcpkV709y3yF0Skw9CEE8OeObi+XiymS
         UnQgCaD5HV5PQ2tUBtH1px0IjGujSv5vLFSkRVlsiPITroisLLVkZgBW0JahlWYPvLdz
         f6AQ==
X-Gm-Message-State: AJcUukcll5mwRGj7IEEA0URyQfGN6yow/IGIIiNoHAW7QTnmF5PwRA/b
	3K1cdY2hR+wpCvmQZbim1CdmsG+jyTizNRj9K2ngx2SeWS8NQ+S4I6LODFqFuw7j6u4wstHCUsB
	J6KpnHA5XCmKhzYD9X1JjNOo9lSHqKQdJzsYp+8c5+tiHWToiq43IIQR9LgEuTrCfIhCspxvyxt
	q8jKpxRWsL/Yu9oc0H2MeIvUcUST9cdWc4uuO8UgYb2x8FORSOYcOUNyPpvdG2nKm76ZIwgPboO
	s6blcDR0Ub6jJCUhH1MBbbtwp2R495ZrGz5XMJfBQDYrKkfoF5B7eppMatVGRD+GL7YyIpxsOvH
	0aeIqf5CyQv+X21PCD/otJQoWzMh861oBn81Ghw7aQEa/MyZ5rmZTlr779+QKrYDAYXS7J2m+ab
	o
X-Received: by 2002:a62:1484:: with SMTP id 126mr21186683pfu.257.1547859034653;
        Fri, 18 Jan 2019 16:50:34 -0800 (PST)
X-Received: by 2002:a62:1484:: with SMTP id 126mr21186638pfu.257.1547859033468;
        Fri, 18 Jan 2019 16:50:33 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1547859033; cv=none;
        d=google.com; s=arc-20160816;
        b=EWTnRI5opI6OO7WviBCZMKI3rFAQ18J+da83JZZRWv5tY3F0xvUhEhT/djbzsegjtk
         hgamENZIDZ8uFlsBcbLtDtrgUl/Ub/uP+3ihw0Z+/mQEO6TVF2Ou7qADEhDhvXj+P0jY
         bKvXTukUQwMiJGQzQn+6O0OGKRNeFVkxeH+5bD8EIDlykoSWN6lWF2RaCQ/vb8BgLJ8Q
         baDH1u0OT0Ozi7Zt5LlKhbEQMIxxp9W6rEuF4AInOJluAETVJRMjT8bMrhuW0H6x4I6d
         UfPYk+LqS6IPggnkcMW2D2PfuVfPimaYnFIr05GOSsnY1u5JRKtCVh4XFviTbIcF7h8i
         icHQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:mime-version:message-id:date:dkim-signature;
        bh=mffs7ZoNWUB7d7Vc+bx+tYMC4aNf0jf7l/hY0o8bs7c=;
        b=UYaq42krOrEOfmlpEmmQnInkRnNJlaKPXYXB3FwuIrVNQWyrqFKlLOQYSxzN6YFmPB
         PrOKXW8+7ilQfd23IsAS1KTAmujItSqJjt2BIhpSZvW0uRa85YGPtXI4krPCOcSOQQdy
         divviJZg3PwgHLTipJDOGV8e4venSvNU0QEUh6zDDOItSSS/DT8+bUq/OgBF4SJyUhSd
         ocM59vNvHwpSLt1K+0h8ooK2fTovcrmJjNmsBx4hgSn7da9GYJDBZ93MU+Ig025JHDU9
         bV59tlfFisiATCfRu4v/HEjzPJc22BK6d5p5ecl+YiWg6+LfVQMYsRAC4qTPQ7n6Nw9Q
         iGyQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=jyinSFuL;
       spf=pass (google.com: domain of 3whrcxagkcdmhwpzttaqvddvat.rdbaxcjm-bbzkprz.dgv@flex--shakeelb.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3WHRCXAgKCDMhWPZTTaQVddVaT.RdbaXcjm-bbZkPRZ.dgV@flex--shakeelb.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id n15sor8773811plp.65.2019.01.18.16.50.33
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 18 Jan 2019 16:50:33 -0800 (PST)
Received-SPF: pass (google.com: domain of 3whrcxagkcdmhwpzttaqvddvat.rdbaxcjm-bbzkprz.dgv@flex--shakeelb.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=jyinSFuL;
       spf=pass (google.com: domain of 3whrcxagkcdmhwpzttaqvddvat.rdbaxcjm-bbzkprz.dgv@flex--shakeelb.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3WHRCXAgKCDMhWPZTTaQVddVaT.RdbaXcjm-bbZkPRZ.dgV@flex--shakeelb.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:message-id:mime-version:subject:from:to:cc;
        bh=mffs7ZoNWUB7d7Vc+bx+tYMC4aNf0jf7l/hY0o8bs7c=;
        b=jyinSFuLKwb+Y6S6+nFUkaUHHVGd08Fy/dre24YgZkQA/3HdqeIPFkMLiarnKhEn09
         BHx0xnsxHUqSTLqxjNyjZF7whGS2jiOcoP9UB2ubPAfOwH492cD/eZQ2Np+Lv4gleDwS
         3PHFIuBvf7MuasaFsNU9incv3ERouDNCW2QBTxPYlPAobveTSS6FxQk/VwITr3hSd6Q7
         UiOegFzk8wwHOJBd9kn4gZZio+gz1O7Nu7NX8hYAKRA/lP/Ytb6G4Zb1xtDSMalICFjE
         t5Nuwh051ig6x+NZlQ7Z6aW6JqAaWLz6yF6Qhox5OAqwUYYNxEHswuwfzGM0PLr4HklF
         GCbQ==
X-Google-Smtp-Source: ALg8bN4M/ljDwaak+PgDIMf+Aw7XX0SqMkW+JoQVAhM1JtP11tGK8U92525weKj8W/uGHgUvmfpNblGSa+kvIg==
X-Received: by 2002:a17:902:aa86:: with SMTP id d6mr7010687plr.21.1547859032905;
 Fri, 18 Jan 2019 16:50:32 -0800 (PST)
Date: Fri, 18 Jan 2019 16:50:22 -0800
Message-Id: <20190119005022.61321-1-shakeelb@google.com>
Mime-Version: 1.0
X-Mailer: git-send-email 2.20.1.321.g9e740568ce-goog
Subject: [RFC PATCH] mm, oom: fix use-after-free in oom_kill_process
From: Shakeel Butt <shakeelb@google.com>
To: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, 
	David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, 
	Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Roman Gushchin <guro@fb.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, 
	Shakeel Butt <shakeelb@google.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190119005022.gzhJK5dQjLUxbk7_A8HDXynBJIAgaPuO_A_3M87LeeY@z>

In our internal syzbot instance running on upstream kernel, we see the
following crash.

--------------------
syzbot has found the following crash on:

HEAD commit: 47bfa6d9dc8c Merge tag 'selinux-pr-20190115' of git://git.kernel.org/pub/scm/linux/kernel/g..
git tree: git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git master
...
compiler: gcc (GCC) 9.0.0 20181231 (experimental)

Unfortunately, I don't have any reproducer for this crash yet.

See http://go/syzbot for details on how to handle this bug.

kmem: usage 0kB, limit 9007199254740988kB, failcnt 0
Memory cgroup stats for /syz1: cache:28KB rss:274692KB rss_huge:190464KB shmem:64KB mapped_file:0KB dirty:0KB writeback:0KB swap:0KB inactive_anon:222780KB active_anon:4152KB inactive_file:0KB active_file:0KB unevictable:47872KB
oom-kill:constraint=CONSTRAINT_NONE,nodemask=(null),cpuset=syz1,mems_allowed=0-1,oom_memcg=/syz1,task_memcg=/syz1,task=syz-executor1,pid=15858,uid=0
Memory cgroup out of memory: Kill process 15858 (syz-executor1) score 1148 or sacrifice child
==================================================================
BUG: KASAN: use-after-free in oom_kill_process.cold+0x484/0x9d4 mm/oom_kill.c:978
Read of size 8 at addr ffff8880595f6c40 by task syz-executor1/15817

CPU: 1 PID: 15817 Comm: syz-executor1 Not tainted 5.0.0-rc2+ #29
Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS Google 01/01/2011
Call Trace:
 __dump_stack lib/dump_stack.c:77 [inline]
 dump_stack+0x1db/0x2d0 lib/dump_stack.c:113
 print_address_description.cold+0x7c/0x20d mm/kasan/report.c:187
 kasan_report.cold+0x1b/0x40 mm/kasan/report.c:317
 __asan_report_load8_noabort+0x14/0x20 mm/kasan/generic_report.c:135
 oom_kill_process.cold+0x484/0x9d4 mm/oom_kill.c:978
 out_of_memory+0x885/0x1420 mm/oom_kill.c:1133
 mem_cgroup_out_of_memory+0x160/0x210 mm/memcontrol.c:1393
 mem_cgroup_oom mm/memcontrol.c:1721 [inline]
 try_charge+0xd44/0x19b0 mm/memcontrol.c:2283
 memcg_kmem_charge_memcg+0x7c/0x130 mm/memcontrol.c:2591
 memcg_kmem_charge+0x13b/0x340 mm/memcontrol.c:2624
 __alloc_pages_nodemask+0x7b8/0xdc0 mm/page_alloc.c:4559
 __alloc_pages include/linux/gfp.h:473 [inline]
 __alloc_pages_node include/linux/gfp.h:486 [inline]
 alloc_pages_node include/linux/gfp.h:500 [inline]
 alloc_thread_stack_node kernel/fork.c:246 [inline]
 dup_task_struct kernel/fork.c:849 [inline]
 copy_process+0x847/0x8710 kernel/fork.c:1753
 _do_fork+0x1a9/0x1170 kernel/fork.c:2227
 __do_sys_clone kernel/fork.c:2334 [inline]
 __se_sys_clone kernel/fork.c:2328 [inline]
 __x64_sys_clone+0xbf/0x150 kernel/fork.c:2328
 do_syscall_64+0x1a3/0x800 arch/x86/entry/common.c:290
 entry_SYSCALL_64_after_hwframe+0x49/0xbe
RIP: 0033:0x457ec9
Code: 6d b7 fb ff c3 66 2e 0f 1f 84 00 00 00 00 00 66 90 48 89 f8 48 89 f7 48 89 d6 48 89 ca 4d 89 c2 4d 89 c8 4c 8b 4c 24 08 0f 05 <48> 3d 01 f0 ff ff 0f 83 3b b7 fb ff c3 66 2e 0f 1f 84 00 00 00 00
RSP: 002b:00007f36f091cc78 EFLAGS: 00000246 ORIG_RAX: 0000000000000038
RAX: ffffffffffffffda RBX: 0000000000000005 RCX: 0000000000457ec9
RDX: 9999999999999999 RSI: 0000000000000000 RDI: 0000000000000000
RBP: 000000000073bf00 R08: ffffffffffffffff R09: 0000000000000000
R10: 0000000000000000 R11: 0000000000000246 R12: 00007f36f091d6d4
R13: 00000000004be2a0 R14: 00000000004ce760 R15: 00000000ffffffff

Allocated by task 15809:
 save_stack+0x45/0xd0 mm/kasan/common.c:73
 set_track mm/kasan/common.c:85 [inline]
 __kasan_kmalloc mm/kasan/common.c:496 [inline]
 __kasan_kmalloc.constprop.0+0xcf/0xe0 mm/kasan/common.c:469
 kasan_kmalloc mm/kasan/common.c:504 [inline]
 kasan_slab_alloc+0xf/0x20 mm/kasan/common.c:411
 kmem_cache_alloc_node+0x144/0x710 mm/slab.c:3633
 alloc_task_struct_node kernel/fork.c:158 [inline]
 dup_task_struct kernel/fork.c:845 [inline]
 copy_process+0x405b/0x8710 kernel/fork.c:1753
 _do_fork+0x1a9/0x1170 kernel/fork.c:2227
 __do_sys_clone kernel/fork.c:2334 [inline]
 __se_sys_clone kernel/fork.c:2328 [inline]
 __x64_sys_clone+0xbf/0x150 kernel/fork.c:2328
 do_syscall_64+0x1a3/0x800 arch/x86/entry/common.c:290
 entry_SYSCALL_64_after_hwframe+0x49/0xbe

Freed by task 15817:
 save_stack+0x45/0xd0 mm/kasan/common.c:73
 set_track mm/kasan/common.c:85 [inline]
 __kasan_slab_free+0x102/0x150 mm/kasan/common.c:458
 kasan_slab_free+0xe/0x10 mm/kasan/common.c:466
 __cache_free mm/slab.c:3487 [inline]
 kmem_cache_free+0x86/0x260 mm/slab.c:3749
 free_task_struct kernel/fork.c:163 [inline]
 free_task+0x170/0x1f0 kernel/fork.c:458
 __put_task_struct+0x2e0/0x630 kernel/fork.c:731
 put_task_struct+0x4b/0x60 include/linux/sched/task.h:98
 oom_kill_process.cold+0x93a/0x9d4 mm/oom_kill.c:990
 out_of_memory+0x885/0x1420 mm/oom_kill.c:1133
 mem_cgroup_out_of_memory+0x160/0x210 mm/memcontrol.c:1393
 mem_cgroup_oom mm/memcontrol.c:1721 [inline]
 try_charge+0xd44/0x19b0 mm/memcontrol.c:2283
 memcg_kmem_charge_memcg+0x7c/0x130 mm/memcontrol.c:2591
 memcg_kmem_charge+0x13b/0x340 mm/memcontrol.c:2624
 __alloc_pages_nodemask+0x7b8/0xdc0 mm/page_alloc.c:4559
 __alloc_pages include/linux/gfp.h:473 [inline]
 __alloc_pages_node include/linux/gfp.h:486 [inline]
 alloc_pages_node include/linux/gfp.h:500 [inline]
 alloc_thread_stack_node kernel/fork.c:246 [inline]
 dup_task_struct kernel/fork.c:849 [inline]
 copy_process+0x847/0x8710 kernel/fork.c:1753
 _do_fork+0x1a9/0x1170 kernel/fork.c:2227
 __do_sys_clone kernel/fork.c:2334 [inline]
 __se_sys_clone kernel/fork.c:2328 [inline]
 __x64_sys_clone+0xbf/0x150 kernel/fork.c:2328
 do_syscall_64+0x1a3/0x800 arch/x86/entry/common.c:290
 entry_SYSCALL_64_after_hwframe+0x49/0xbe

The buggy address belongs to the object at ffff8880595f6540
 which belongs to the cache task_struct(33:syz1) of size 6080
The buggy address is located 1792 bytes inside of
 6080-byte region [ffff8880595f6540, ffff8880595f7d00)
The buggy address belongs to the page:
page:ffffea0001657d80 count:1 mapcount:0 mapping:ffff888091f65840 index:0x0 compound_mapcount: 0
flags: 0x1fffc0000010200(slab|head)
raw: 01fffc0000010200 ffffea00028b3288 ffffea0002612788 ffff888091f65840
raw: 0000000000000000 ffff8880595f6540 0000000100000001 ffff888057fe2b00
page dumped because: kasan: bad access detected
page->mem_cgroup:ffff888057fe2b00

--------------------

On looking further it seems like the process selected to be oom-killed
has exited even before reaching read_lock(&tasklist_lock) in
oom_kill_process(). More specifically the tsk->usage is 1 which is due
to get_task_struct() in oom_evaluate_task() and the put_task_struct
within for_each_thread() frees the tsk and for_each_thread() tries to
access the tsk. The easiest fix is to do get/put across the
for_each_thread() on the selected task.

Now the next question is should we continue with the oom-kill as the
previously selected task has exited? However before adding more
complexity and heuristics, let's answer why we even look at the
children of oom-kill selected task? The select_bad_process() has already
selected the worst process in the system/memcg. Due to race, the
selected process might not be the worst at the kill time but does that
matter matter? The userspace can play with oom_score_adj to prefer
children to be killed before the parent. I looked at the history but it
seems like this is there before git history.

Signed-off-by: Shakeel Butt <shakeelb@google.com>
---
 mm/oom_kill.c | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 0930b4365be7..1a007dae1e8f 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -981,6 +981,13 @@ static void oom_kill_process(struct oom_control *oc, const char *message)
 	 * still freeing memory.
 	 */
 	read_lock(&tasklist_lock);
+
+	/*
+	 * The task 'p' might have already exited before reaching here. The
+	 * put_task_struct() will free task_struct 'p' while the loop still try
+	 * to access the field of 'p', so, get an extra reference.
+	 */
+	get_task_struct(p);
 	for_each_thread(p, t) {
 		list_for_each_entry(child, &t->children, sibling) {
 			unsigned int child_points;
@@ -1000,6 +1007,7 @@ static void oom_kill_process(struct oom_control *oc, const char *message)
 			}
 		}
 	}
+	put_task_struct(p);
 	read_unlock(&tasklist_lock);
 
 	/*
-- 
2.20.1.321.g9e740568ce-goog

