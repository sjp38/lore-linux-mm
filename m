Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f182.google.com (mail-wi0-f182.google.com [209.85.212.182])
	by kanga.kvack.org (Postfix) with ESMTP id 3EF5D6B010B
	for <linux-mm@kvack.org>; Wed, 20 May 2015 08:50:50 -0400 (EDT)
Received: by wichy4 with SMTP id hy4so58847958wic.1
        for <linux-mm@kvack.org>; Wed, 20 May 2015 05:50:49 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ml5si3609012wic.74.2015.05.20.05.50.48
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 20 May 2015 05:50:48 -0700 (PDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 0/2] Reduce overhead of memcg when unused
Date: Wed, 20 May 2015 13:50:43 +0100
Message-Id: <1432126245-10908-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: Tejun Heo <tj@kernel.org>, Linux-CGroups <cgroups@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

These are two patches to reduce the overhead of memcg, particularly when
it's not used. The first is a simple reordering of when a barrier is applied
which memcg happens to get burned by.  I doubt it is controversial at all.

The second optionally disables memcg by default. This should have
been the default from the start and it matches what Debian already does
today. The difficulty is that existing installations may break if the new
kernel parameter is not applied so distributions need to be careful with
upgrades. The difference it makes is marginal and only visible in profiles,
not headline performance. It'd be understandable if memcg maintainers
rejected it but I'll leave it up to them.

 Documentation/kernel-parameters.txt |  4 ++++
 init/Kconfig                        | 15 +++++++++++++++
 kernel/cgroup.c                     | 20 ++++++++++++++++----
 mm/memcontrol.c                     |  3 +++
 mm/memory.c                         | 10 ++++++----
 5 files changed, 44 insertions(+), 8 deletions(-)

-- 
2.3.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
