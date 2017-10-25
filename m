Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 5C2E96B0033
	for <linux-mm@kvack.org>; Wed, 25 Oct 2017 01:11:26 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id j3so16187135pga.5
        for <linux-mm@kvack.org>; Tue, 24 Oct 2017 22:11:26 -0700 (PDT)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id f126si1387094pfg.263.2017.10.24.22.11.23
        for <linux-mm@kvack.org>;
        Tue, 24 Oct 2017 22:11:24 -0700 (PDT)
From: Byungchul Park <byungchul.park@lge.com>
Subject: [PATCH v4 0/7] cross-release: Enhence performance and fix false positives
Date: Wed, 25 Oct 2017 14:11:05 +0900
Message-Id: <1508908272-15757-1-git-send-email-byungchul.park@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: peterz@infradead.org, mingo@kernel.org, axboe@kernel.dk
Cc: johan@kernel.org, tglx@linutronix.de, linux-kernel@vger.kernel.org, linux-mm@kvack.org, tj@kernel.org, johannes.berg@intel.com, oleg@redhat.com, amir73il@gmail.com, david@fromorbit.com, darrick.wong@oracle.com, linux-xfs@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-block@vger.kernel.org, hch@infradead.org, idryomov@gmail.com, kernel-team@lge.com

There are two things I didn't apply as Ingo suggested, since I didn't
understand his intention exactly:

   1. Adding 'Analyzed-by' tag at the 2nd patch
   2. Using a inline function instead #define at the 7th patch

Let me know if the above should still be applied.

Changes from v3
- Exclude a patch removing white space
- Enhance commit messages as Ingo suggested
- Re-design patches adding a boot param and a Kconfig allowing unwind
- Simplify a patch assigning lock classes to genhds as Ingo suggested
- Add proper tags in commit messages e.g. reported-by and analyzed-by

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

Byungchul Park (6):
  locking/lockdep: Add a boot parameter allowing unwind in cross-release
    and disable it by default
  locking/lockdep: Remove the BROKEN flag from
    CONFIG_LOCKDEP_CROSSRELEASE and CONFIG_LOCKDEP_COMPLETIONS
  locking/lockdep: Introduce
    CONFIG_BOOTPARAM_LOCKDEP_CROSSRELEASE_FULLSTACK
  completion: Add support for initializing completion with lockdep_map
  workqueue: Remove unnecessary acquisitions wrt workqueue flush
  block: Assign a lock_class per gendisk used for wait_for_completion()

Christoph Hellwig (1):
  block: use DECLARE_COMPLETION_ONSTACK in submit_bio_wait

 Documentation/admin-guide/kernel-parameters.txt |  3 +++
 block/bio.c                                     | 19 +++++--------------
 block/genhd.c                                   | 10 ++--------
 include/linux/completion.h                      | 14 ++++++++++++++
 include/linux/genhd.h                           | 24 ++++++++++++++++++++++--
 include/linux/workqueue.h                       |  4 ++--
 kernel/locking/lockdep.c                        | 23 +++++++++++++++++++++--
 kernel/workqueue.c                              | 19 +++----------------
 lib/Kconfig.debug                               | 19 +++++++++++++++++--
 9 files changed, 89 insertions(+), 46 deletions(-)

-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
