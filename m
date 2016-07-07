Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f199.google.com (mail-ob0-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id E7F456B0253
	for <linux-mm@kvack.org>; Thu,  7 Jul 2016 11:58:55 -0400 (EDT)
Received: by mail-ob0-f199.google.com with SMTP id gv4so40690196obc.3
        for <linux-mm@kvack.org>; Thu, 07 Jul 2016 08:58:55 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id j7si2476438oia.289.2016.07.07.08.58.54
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 07 Jul 2016 08:58:54 -0700 (PDT)
Subject: [PATCH v2 0/6] Change OOM killer to use list of mm_struct.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Message-Id: <201607080058.BFI87504.JtFOOFQFVHSLOM@I-love.SAKURA.ne.jp>
Date: Fri, 8 Jul 2016 00:58:41 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: akpm@linux-foundation.org, oleg@redhat.com, rientjes@google.com, vdavydov@parallels.com, mst@redhat.com, mhocko@suse.com, mhocko@kernel.org

This series is an update of
http://lkml.kernel.org/r/201607031135.AAH95347.MVOHQtFJFLOOFS@I-love.SAKURA.ne.jp .

This series is based on top of linux-next-20160707 +
http://lkml.kernel.org/r/1467201562-6709-1-git-send-email-mhocko@kernel.org .

 include/linux/mm_types.h |    7 +
 include/linux/oom.h      |   14 --
 include/linux/sched.h    |    2
 kernel/exit.c            |    2
 kernel/fork.c            |    4
 mm/memcontrol.c          |   14 --
 mm/oom_kill.c            |  297 ++++++++++++++++++-----------------------------
 7 files changed, 140 insertions(+), 200 deletions(-)

[PATCH 1/6] mm,oom_reaper: Reduce find_lock_task_mm() usage.
[PATCH 2/6] mm,oom_reaper: Do not attempt to reap a task twice.
[PATCH 3/6] mm,oom: Use list of mm_struct used by OOM victims.
[PATCH 4/6] mm,oom_reaper: Make OOM reaper use list of mm_struct.
[PATCH 5/6] mm,oom: Remove OOM_SCAN_ABORT case and signal_struct->oom_victims.
[PATCH 6/6] mm,oom: Stop clearing TIF_MEMDIE on remote thread.

This series does not include patches for use_mm() users and wait_event()
in oom_killer_disable(). We can apply
http://lkml.kernel.org/r/1467365190-24640-3-git-send-email-mhocko@kernel.org
on top of this series.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
