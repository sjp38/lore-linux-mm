Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 1FEFF6B0038
	for <linux-mm@kvack.org>; Sat,  1 Apr 2017 23:53:12 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id s29so25610062pfg.21
        for <linux-mm@kvack.org>; Sat, 01 Apr 2017 20:53:12 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id o1si9935706pgn.247.2017.04.01.20.53.10
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sat, 01 Apr 2017 20:53:11 -0700 (PDT)
Subject: oom: Bogus "sysrq: OOM request ignored because killer is disabled" message
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Message-Id: <201704021252.GIF21549.QFFOFOMVJtHSLO@I-love.SAKURA.ne.jp>
Date: Sun, 2 Apr 2017 12:52:55 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: vdavydov@virtuozzo.com, hannes@cmpxchg.org, mhocko@kernel.org, rientjes@google.com
Cc: linux-mm@kvack.org

I noticed that SysRq-f prints

  "sysrq: OOM request ignored because killer is disabled"

when no process was selected (rather than when oom killer was disabled).
This message was not printed until Linux 4.8 because commit 7c5f64f84483bd13
("mm: oom: deduplicate victim selection code for memcg and global oom") changed
 from "return true;" to "return !!oc->chosen;" when is_sysrq_oom(oc) is true.

Is this what we meant?

[  713.805315] sysrq: SysRq : Manual OOM execution
[  713.808920] Out of memory: Kill process 4468 ((agetty)) score 0 or sacrifice child
[  713.814913] Killed process 4468 ((agetty)) total-vm:43704kB, anon-rss:1760kB, file-rss:0kB, shmem-rss:0kB
[  714.004805] sysrq: SysRq : Manual OOM execution
[  714.005936] Out of memory: Kill process 4469 (systemd-cgroups) score 0 or sacrifice child
[  714.008117] Killed process 4469 (systemd-cgroups) total-vm:10704kB, anon-rss:120kB, file-rss:0kB, shmem-rss:0kB
[  714.189310] sysrq: SysRq : Manual OOM execution
[  714.193425] sysrq: OOM request ignored because killer is disabled
[  714.381313] sysrq: SysRq : Manual OOM execution
[  714.385158] sysrq: OOM request ignored because killer is disabled
[  714.573320] sysrq: SysRq : Manual OOM execution
[  714.576988] sysrq: OOM request ignored because killer is disabled

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
