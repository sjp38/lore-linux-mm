Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx157.postini.com [74.125.245.157])
	by kanga.kvack.org (Postfix) with SMTP id C82756B0009
	for <linux-mm@kvack.org>; Tue, 22 Jan 2013 12:12:40 -0500 (EST)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 0/6] Follow up work on NUMA Balancing
Date: Tue, 22 Jan 2013 17:12:36 +0000
Message-Id: <1358874762-19717-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrea Arcangeli <aarcange@redhat.com>, Ingo Molnar <mingo@kernel.org>, Simon Jeons <simon.jeons@gmail.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

The following series is a few follow-up patches left over from NUMA
balancing. The three three patches are tiny fixes. Patches 4 and 5 fold
page->_last_nid into page->flags and is entirely based on work from Peter
Zijlstra. The final patch is a cleanup by Hugh Dickins that he had marked
as a prototype but on examination and testing I could not find any problems
with it (famous last words).

 include/linux/mm.h                |   73 ++++++++++++---------------
 include/linux/mm_types.h          |    9 ++--
 include/linux/mmzone.h            |   22 +--------
 include/linux/page-flags-layout.h |   88 +++++++++++++++++++++++++++++++++
 include/linux/vmstat.h            |    2 +-
 mm/huge_memory.c                  |   28 ++++-------
 mm/memory.c                       |    4 ++
 mm/migrate.c                      |   99 +++++++++++++++++--------------------
 8 files changed, 186 insertions(+), 139 deletions(-)
 create mode 100644 include/linux/page-flags-layout.h

-- 
1.7.9.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
