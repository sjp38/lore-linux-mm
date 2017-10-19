Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id C87BA6B0033
	for <linux-mm@kvack.org>; Thu, 19 Oct 2017 03:03:30 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id y5so1572652pgq.15
        for <linux-mm@kvack.org>; Thu, 19 Oct 2017 00:03:30 -0700 (PDT)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id 98si785193plt.495.2017.10.19.00.03.28
        for <linux-mm@kvack.org>;
        Thu, 19 Oct 2017 00:03:29 -0700 (PDT)
From: Byungchul Park <byungchul.park@lge.com>
Subject: [PATCH v2 0/4] Fix false positives by cross-release feature
Date: Thu, 19 Oct 2017 16:03:23 +0900
Message-Id: <1508396607-25362-1-git-send-email-byungchul.park@lge.com>
In-Reply-To: <1508392531-11284-1-git-send-email-byungchul.park@lge.com>
References: <1508392531-11284-1-git-send-email-byungchul.park@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: peterz@infradead.org, mingo@kernel.org
Cc: tglx@linutronix.de, linux-kernel@vger.kernel.org, linux-mm@kvack.org, tj@kernel.org, johannes.berg@intel.com, oleg@redhat.com, amir73il@gmail.com, david@fromorbit.com, darrick.wong@oracle.com, linux-xfs@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-block@vger.kernel.org, hch@infradead.org, idryomov@gmail.com, kernel-team@lge.com

I attached this patchset into another thread for patches fixing a
performance regression by cross-release, so that the cross-release can
be re-enabled easily as the last, after fixing false positives as well.

Changes from v1
- Separate a patch removing white space

Byungchul Park (4):
  completion: Add support for initializing completion with lockdep_map
  lockdep: Remove unnecessary acquisitions wrt workqueue flush
  genhd.h: Remove trailing white space
  lockdep: Assign a lock_class per gendisk used for
    wait_for_completion()

 block/bio.c                |  2 +-
 block/genhd.c              | 13 +++++--------
 include/linux/completion.h |  8 ++++++++
 include/linux/genhd.h      | 26 ++++++++++++++++++++++----
 include/linux/workqueue.h  |  4 ++--
 kernel/workqueue.c         | 20 ++++----------------
 6 files changed, 42 insertions(+), 31 deletions(-)

-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
