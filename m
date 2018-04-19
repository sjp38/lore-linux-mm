Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id EBC1A6B0005
	for <linux-mm@kvack.org>; Thu, 19 Apr 2018 03:17:23 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id a6so2315041pfn.3
        for <linux-mm@kvack.org>; Thu, 19 Apr 2018 00:17:23 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id z6-v6sor1112878pln.101.2018.04.19.00.17.22
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 19 Apr 2018 00:17:22 -0700 (PDT)
From: ufo19890607 <ufo19890607@gmail.com>
Subject: Some questions about cgroup aware OOM killer.
Date: Thu, 19 Apr 2018 08:17:04 +0100
Message-Id: <1524122224-26670-1-git-send-email-ufo19890607@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: guro@fb.com, mhocko@suse.com, vdavydov.dev@gmail.com, penguin-kernel@i-love.sakura.ne.jp, rientjes@google.com, akpm@linux-foundation.org, tj@kernel.org
Cc: kernel-team@fb.com, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, yuzhoujian <yuzhoujian@didichuxing.com>

From: yuzhoujian <yuzhoujian@didichuxing.com>

Hi Roman
I've read your patchset about cgroup aware OOM killer, and try
to merge your patchset to the upstream kernel(v4.17-rc1). But
I found some functions which in your patch([PATCH v13 3/7] 
mm, oom: cgroup-aware OOM killer) does not exist in the upstream
kernel. Which version of the kernel do you patch on? And, do you
have the latest patchset?

The faults in PATCH v13 3/7:
1. mm/oom_kill.o: In function `out_of_memory':
   /linux/mm/oom_kill.c:1125: undefined reference to `alloc_pages_before_oomkill'
2. mm/oom_kill.c: In function a??out_of_memorya??:
   mm/oom_kill.c:1125:5: error: a??struct oom_controla?? has no member named a??pagea??
   oc->page = alloc_pages_before_oomkill(oc);
     ^

Best wishes
