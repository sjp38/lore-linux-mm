Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 13B826B0010
	for <linux-mm@kvack.org>; Mon, 30 Jul 2018 14:01:41 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id q11-v6so11510955oih.15
        for <linux-mm@kvack.org>; Mon, 30 Jul 2018 11:01:41 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id 126-v6si7619072oih.306.2018.07.30.11.01.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 30 Jul 2018 11:01:39 -0700 (PDT)
From: Roman Gushchin <guro@fb.com>
Subject: [PATCH 0/3] introduce memory.oom.group
Date: Mon, 30 Jul 2018 11:00:57 -0700
Message-ID: <20180730180100.25079-1-guro@fb.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, David Rientjes <rientjes@google.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Tejun Heo <tj@kernel.org>, kernel-team@fb.com, linux-kernel@vger.kernel.org, Roman Gushchin <guro@fb.com>

This is a tiny implementation of cgroup-aware OOM killer,
which adds an ability to kill a cgroup as a single unit
and so guarantee the integrity of the workload.

Although it has only a limited functionality in comparison
to what now resides in the mm tree (it doesn't change
the victim task selection algorithm, doesn't look
at memory stas on cgroup level, etc), it's also much
simpler and more straightforward. So, hopefully, we can
avoid having long debates here, as we had with the full
implementation.

As it doesn't prevent any futher development,
and implements an useful and complete feature,
it looks as a sane way forward.

This patchset is against Linus's tree to avoid conflicts
with the cgroup-aware OOM killer patchset in the mm tree.

Two first patches are already in the mm tree.
The first one ("mm: introduce mem_cgroup_put() helper")
is totally fine, and the second's commit message has to be
changed to reflect that it's not a part of old patchset
anymore.

Roman Gushchin (3):
  mm: introduce mem_cgroup_put() helper
  mm, oom: refactor oom_kill_process()
  mm, oom: introduce memory.oom.group

 Documentation/admin-guide/cgroup-v2.rst |  16 ++++
 include/linux/memcontrol.h              |  22 +++++
 mm/memcontrol.c                         |  84 ++++++++++++++++++
 mm/oom_kill.c                           | 152 ++++++++++++++++++++------------
 4 files changed, 216 insertions(+), 58 deletions(-)

-- 
2.14.4
