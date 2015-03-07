Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f41.google.com (mail-wg0-f41.google.com [74.125.82.41])
	by kanga.kvack.org (Postfix) with ESMTP id 2388C6B006C
	for <linux-mm@kvack.org>; Sat,  7 Mar 2015 10:20:58 -0500 (EST)
Received: by wggy19 with SMTP id y19so1875129wgg.9
        for <linux-mm@kvack.org>; Sat, 07 Mar 2015 07:20:57 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ca7si26849146wib.49.2015.03.07.07.20.55
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sat, 07 Mar 2015 07:20:56 -0800 (PST)
From: Mel Gorman <mgorman@suse.de>
Subject: [RFC PATCH 0/4] Automatic NUMA balancing and PROT_NONE handling followup v2r8
Date: Sat,  7 Mar 2015 15:20:47 +0000
Message-Id: <1425741651-29152-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, xfs@oss.sgi.com, linuxppc-dev@lists.ozlabs.org, Mel Gorman <mgorman@suse.de>

Dave Chinner reported a problem due to excessive NUMA balancing activity
and bisected it. The first patch in this series corrects a major problem
that is unlikely to affect Dave but is still serious. Patch 2 is a minor
cleanup that was spotted while looking at scan rate control. Patch 3 is
minor and unlikely to make a difference but is still an inconsistentcy
between base and THP handling. Patch 4 is the important one, it slows
PTE scan updates if migrations are failing or throttled. Details of the
performance impact on local tests is included in the patch.

 include/linux/migrate.h |  5 -----
 include/linux/sched.h   |  9 +++++----
 kernel/sched/fair.c     |  8 ++++++--
 mm/huge_memory.c        |  8 +++++---
 mm/memory.c             |  3 ++-
 mm/migrate.c            | 20 --------------------
 6 files changed, 18 insertions(+), 35 deletions(-)

-- 
2.1.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
