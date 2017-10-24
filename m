Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 1B7D26B0033
	for <linux-mm@kvack.org>; Tue, 24 Oct 2017 05:38:19 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id d28so18194079pfe.1
        for <linux-mm@kvack.org>; Tue, 24 Oct 2017 02:38:19 -0700 (PDT)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id 85si6759273pfo.365.2017.10.24.02.38.15
        for <linux-mm@kvack.org>;
        Tue, 24 Oct 2017 02:38:17 -0700 (PDT)
From: Byungchul Park <byungchul.park@lge.com>
Subject: [PATCH v3 0/8] cross-release: enhence performance and fix false positives
Date: Tue, 24 Oct 2017 18:38:01 +0900
Message-Id: <1508837889-16932-1-git-send-email-byungchul.park@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: peterz@infradead.org, mingo@kernel.org, axboe@kernel.dk
Cc: tglx@linutronix.de, linux-kernel@vger.kernel.org, linux-mm@kvack.org, tj@kernel.org, johannes.berg@intel.com, oleg@redhat.com, amir73il@gmail.com, david@fromorbit.com, darrick.wong@oracle.com, linux-xfs@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-block@vger.kernel.org, hch@infradead.org, idryomov@gmail.com, kernel-team@lge.com

Changes from v2
- Combine 2 serises, fixing false positives and enhance performance
- Add Christoph Hellwig's patch simplifying submit_bio_wait() code
- Add 2 more 'init with lockdep map' macros for completionm
- Rename init_completion_with_map() to init_completion_map()

Changes from v1
- Fix kconfig description as Ingo suggested
- Fix commit message writing out CONFIG_ variable
- Introduce a new kernel parameter, crossrelease_fullstack
- Replace the number with the output of *perf*
- Separate a patch removing white space

Byungchul Park (7):
  lockdep: Introduce CROSSRELEASE_STACK_TRACE and make it not unwind as
    default
  lockdep: Remove BROKEN flag of LOCKDEP_CROSSRELEASE
  lockdep: Add a kernel parameter, crossrelease_fullstack
  completion: Add support for initializing completion with lockdep_map
  lockdep: Remove unnecessary acquisitions wrt workqueue flush
  genhd.h: Remove trailing white space
  block: Assign a lock_class per gendisk used for wait_for_completion()

Christoph Hellwig (1):
  block: use DECLARE_COMPLETION_ONSTACK in submit_bio_wait

 Documentation/admin-guide/kernel-parameters.txt |  3 +++
 block/bio.c                                     | 19 +++++-------------
 block/genhd.c                                   | 13 +++++--------
 include/linux/completion.h                      | 14 +++++++++++++
 include/linux/genhd.h                           | 26 +++++++++++++++++++++----
 include/linux/lockdep.h                         |  4 ++++
 include/linux/workqueue.h                       |  4 ++--
 kernel/locking/lockdep.c                        | 23 ++++++++++++++++++++--
 kernel/workqueue.c                              | 19 +++---------------
 lib/Kconfig.debug                               | 20 +++++++++++++++++--
 10 files changed, 97 insertions(+), 48 deletions(-)

-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
