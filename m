Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f174.google.com (mail-wi0-f174.google.com [209.85.212.174])
	by kanga.kvack.org (Postfix) with ESMTP id 4D61C6B0039
	for <linux-mm@kvack.org>; Thu,  5 Jun 2014 10:00:54 -0400 (EDT)
Received: by mail-wi0-f174.google.com with SMTP id r20so10592071wiv.13
        for <linux-mm@kvack.org>; Thu, 05 Jun 2014 07:00:53 -0700 (PDT)
Received: from mail.sigma-star.at (mail.sigma-star.at. [95.130.255.111])
        by mx.google.com with ESMTP id a10si270571wiz.51.2014.06.05.07.00.52
        for <linux-mm@kvack.org>;
        Thu, 05 Jun 2014 07:00:52 -0700 (PDT)
From: Richard Weinberger <richard@nod.at>
Subject: oom: Be less verbose
Date: Thu,  5 Jun 2014 16:00:40 +0200
Message-Id: <1401976841-3899-1-git-send-email-richard@nod.at>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: hannes@cmpxchg.org
Cc: mhocko@suse.cz, bsingharora@gmail.com, kamezawa.hiroyu@jp.fujitsu.com, akpm@linux-foundation.org, vdavydov@parallels.com, tj@kernel.org, handai.szj@taobao.com, rientjes@google.com, oleg@redhat.com, rusty@rustcorp.com.au, kirill.shutemov@linux.intel.com, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, linux-mm@kvack.org

Processes within Linux containers very often hit their memory limits.
This has the side effect that the kernel log gets spammed all day with
useless OOM messages.
If a userspace program listens to the memory cgroup event fd to
get notified upon OOM we can avoid this spamming and be less verbose.

With this patch applied the OOM killer will only print much details
if nobody listens to the affected memory cgroup event fd.
I can also think of a new sysctl like "vm.oom_verbose=1" to guarantee the old
behavior even if we have listeners.

What do you think?

Thanks,
//richard

[RFC][PATCH] oom: Be less verbose if the oom_control event fd has listeners
--
 include/linux/memcontrol.h |    6 ++++++
 mm/memcontrol.c            |   20 ++++++++++++++++++++
 mm/oom_kill.c              |    2 +-
 3 files changed, 27 insertions(+), 1 deletion(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
