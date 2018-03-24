Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f200.google.com (mail-yw0-f200.google.com [209.85.161.200])
	by kanga.kvack.org (Postfix) with ESMTP id 5F29A6B000C
	for <linux-mm@kvack.org>; Sat, 24 Mar 2018 12:51:39 -0400 (EDT)
Received: by mail-yw0-f200.google.com with SMTP id y64so6639574ywd.13
        for <linux-mm@kvack.org>; Sat, 24 Mar 2018 09:51:39 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a124sor4260301ywg.195.2018.03.24.09.51.38
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 24 Mar 2018 09:51:38 -0700 (PDT)
From: Tejun Heo <tj@kernel.org>
Subject: [PATCHSET] mm, memcontrol: Implement memory.swap.events
Date: Sat, 24 Mar 2018 09:51:25 -0700
Message-Id: <20180324165127.701194-1-tj@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: hannes@cmpxchg.org, mhocko@kernel.org, vdavydov.dev@gmail.com
Cc: guro@fb.com, riel@surriel.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, kernel-team@fb.com, cgroups@vger.kernel.org, linux-mm@kvack.org

Hello,

This patchset implements memory.swap.events which contains max and
fail events so that userland can monitor and respond to swap running
out.  It contains the following two patches.

 0001-mm-memcontrol-Move-swap-charge-handling-into-get_swa.patch
 0002-mm-memcontrol-Implement-memory.swap.events.patch

This patchset is on top of the "cgroup/for-4.17: Make cgroup_rstat
available to controllers" patchset[1] and "mm, memcontrol: Make
cgroup_rstat available to controllers" patchset[2] and also available
in the following git branch.

 git://git.kernel.org/pub/scm/linux/kernel/git/tj/cgroup.git review-memcg-swap.events

diffstat follows.

 Documentation/cgroup-v2.txt |   16 ++++++++++++++++
 include/linux/memcontrol.h  |    5 +++++
 mm/memcontrol.c             |   25 +++++++++++++++++++++++++
 mm/shmem.c                  |    4 ----
 mm/swap_slots.c             |   10 +++++++---
 mm/swap_state.c             |    3 ---
 6 files changed, 53 insertions(+), 10 deletions(-)

Thanks.

--
tejun

[1] http://lkml.kernel.org/r/20180323231313.1254142-1-tj@kernel.org
[2] http://lkml.kernel.org/r/20180324160901.512135-1-tj@kernel.org
