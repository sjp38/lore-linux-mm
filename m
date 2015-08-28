Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f175.google.com (mail-yk0-f175.google.com [209.85.160.175])
	by kanga.kvack.org (Postfix) with ESMTP id AF03F6B0254
	for <linux-mm@kvack.org>; Fri, 28 Aug 2015 11:25:37 -0400 (EDT)
Received: by ykek5 with SMTP id k5so4796845yke.3
        for <linux-mm@kvack.org>; Fri, 28 Aug 2015 08:25:37 -0700 (PDT)
Received: from mail-yk0-x22c.google.com (mail-yk0-x22c.google.com. [2607:f8b0:4002:c07::22c])
        by mx.google.com with ESMTPS id x75si105971ywd.152.2015.08.28.08.25.34
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 28 Aug 2015 08:25:36 -0700 (PDT)
Received: by ykek5 with SMTP id k5so4795139yke.3
        for <linux-mm@kvack.org>; Fri, 28 Aug 2015 08:25:34 -0700 (PDT)
From: Tejun Heo <tj@kernel.org>
Subject: [PATCHSET] memcg: improve high limit behavior and always enable kmemcg on dfl hier
Date: Fri, 28 Aug 2015 11:25:26 -0400
Message-Id: <1440775530-18630-1-git-send-email-tj@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: hannes@cmpxchg.org, mhocko@kernel.org
Cc: cgroups@vger.kernel.org, linux-mm@kvack.org, vdavydov@parallels.com, kernel-team@fb.com

Hello,

This patchset contains the following four patches.

 0001-memcg-fix-over-high-reclaim-amount.patch
 0002-memcg-flatten-task_struct-memcg_oom.patch
 0003-memcg-punt-high-overage-reclaim-to-return-to-userlan.patch
 0004-memcg-always-enable-kmemcg-on-the-default-hierarchy.patch

0001-0002 are simple fix and prep patches.  0003 makes memcg alwyas
punt direct reclaim of high limit overages to return-to-user path.
0004 always enables kmemcg on the default hierarchy.

This patchset is on top of next/akpm 1f3bd508da15
("drivers/w1/w1_int.c: call put_device if device_register fails") and
also available in the following git branch.

 git://git.kernel.org/pub/scm/linux/kernel/git/tj/cgroup.git review-memcg-dfl

diffstat follows.  Thanks.

 include/linux/memcontrol.h |   16 +++++---
 include/linux/sched.h      |   14 +++----
 include/linux/tracehook.h  |    3 +
 mm/memcontrol.c            |   88 +++++++++++++++++++++++++++++++++++----------
 4 files changed, 91 insertions(+), 30 deletions(-)

--
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
