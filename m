Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f45.google.com (mail-ee0-f45.google.com [74.125.83.45])
	by kanga.kvack.org (Postfix) with ESMTP id 509FF6B0031
	for <linux-mm@kvack.org>; Tue,  3 Dec 2013 03:52:04 -0500 (EST)
Received: by mail-ee0-f45.google.com with SMTP id d49so1268108eek.18
        for <linux-mm@kvack.org>; Tue, 03 Dec 2013 00:52:03 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTP id e2si2217379eeg.198.2013.12.03.00.52.03
        for <linux-mm@kvack.org>;
        Tue, 03 Dec 2013 00:52:03 -0800 (PST)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 00/14] NUMA balancing segmentation faults candidate fix on large machines
Date: Tue,  3 Dec 2013 08:51:47 +0000
Message-Id: <1386060721-3794-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alex Thorlton <athorlton@sgi.com>
Cc: Rik van Riel <riel@redhat.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

Alex Thorlton reported segementation faults when NUMA balancing is enabled
on large machines. There is no obvious explanation from the console what the
problem is so this series is based on code review.

The series is against 3.12. In the event it addresses the problem the
patches will need to be forward-ported and retested. The series is not
against the latest mainline as changes to PTE scan rates may mask the bug.

 arch/x86/mm/gup.c       |  13 ++++
 include/linux/hugetlb.h |  10 ++--
 include/linux/migrate.h |  27 ++++++++-
 kernel/sched/fair.c     |  16 ++++-
 mm/huge_memory.c        |  58 ++++++++++++++----
 mm/hugetlb.c            |  51 ++++++----------
 mm/memory.c             |  93 ++---------------------------
 mm/mempolicy.c          |   2 +
 mm/migrate.c            | 155 ++++++++++++++++++++++++++++++++++++++++++++----
 mm/mprotect.c           |  50 ++++------------
 mm/pgtable-generic.c    |   3 +
 mm/swap.c               | 143 +++++++++++++++++++++++++-------------------
 12 files changed, 371 insertions(+), 250 deletions(-)

-- 
1.8.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
