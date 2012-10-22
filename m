Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx195.postini.com [74.125.245.195])
	by kanga.kvack.org (Postfix) with SMTP id 271AF6B0062
	for <linux-mm@kvack.org>; Mon, 22 Oct 2012 04:07:37 -0400 (EDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [RFC PATCH 0/5] vmstats for compaction, migration and autonuma
Date: Mon, 22 Oct 2012 08:59:46 +0100
Message-Id: <1350892791-2682-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>
Cc: Peter Zijlstra <peterz@infradead.org>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, LKML <linux-kernel@vger.kernel.org>

I'm travelling for a conference at the moment so these patches are not
tested but with the ongoing NUMA migration work I figured it was best to
post these sooner rather than later.

This series adds vmstat counters and tracepoints for migration, compaction
and autonuma. Using them it's possible to create a basic cost model to
estimate the overhead due to compaction or autonuma. Using the stats it
is also possible to measure if a workload is converging on autonuma or
not and potentially measure how quickly it is converging.

Ideally the same stats would be available for schednuma but I did not
review the series when it was last posted in July and had not seen a
recent posting. I only recently heard they were in the -tip tree but will
not get the chance to look at them until I've finished travelling in a
weeks time.  If schednuma had similar stats it would then be possible to
compare schednuma and autonuma in terms of how quickly a workload converges
with either approach.

 include/linux/migrate.h        |   14 +++++++++-
 include/linux/vm_event_item.h  |   12 ++++++++-
 include/trace/events/migrate.h |   52 ++++++++++++++++++++++++++++++++++++++++
 mm/autonuma.c                  |   22 +++++++++++++----
 mm/compaction.c                |   15 +++++++----
 mm/memory-failure.c            |    3 +-
 mm/memory_hotplug.c            |    3 +-
 mm/mempolicy.c                 |    6 +++-
 mm/migrate.c                   |   16 ++++++++++-
 mm/page_alloc.c                |    3 +-
 mm/vmstat.c                    |   16 ++++++++++--
 11 files changed, 139 insertions(+), 23 deletions(-)
 create mode 100644 include/trace/events/migrate.h

-- 
1.7.7

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
