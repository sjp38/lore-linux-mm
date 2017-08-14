Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id 38F496B02F3
	for <linux-mm@kvack.org>; Mon, 14 Aug 2017 03:02:13 -0400 (EDT)
Received: by mail-io0-f200.google.com with SMTP id b136so99673948ioe.9
        for <linux-mm@kvack.org>; Mon, 14 Aug 2017 00:02:13 -0700 (PDT)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id w23si3715086pgc.814.2017.08.14.00.02.11
        for <linux-mm@kvack.org>;
        Mon, 14 Aug 2017 00:02:12 -0700 (PDT)
From: Byungchul Park <byungchul.park@lge.com>
Subject: [PATCH 0/2] Fix a bug in crossrelease
Date: Mon, 14 Aug 2017 16:00:50 +0900
Message-Id: <1502694052-16085-1-git-send-email-byungchul.park@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: peterz@infradead.org, mingo@kernel.org
Cc: tglx@linutronix.de, walken@google.com, boqun.feng@gmail.com, kirill@shutemov.name, linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, willy@infradead.org, npiggin@gmail.com, kernel-team@lge.com

Thanks to Boqun, we found out a bug with regard to the rollback and
overwrite-detection. I like Boqun's or Peterz's suggestions more, but
please consider this fix-up first if we need time to decide which one
to choose.

https://lkml.org/lkml/2017/8/11/383

Byungchul Park (2):
  lockdep: Add a comment about crossrelease_hist_end() in
    lockdep_sys_exit()
  lockdep: Fix the rollback and overwrite detection in crossrelease

 kernel/locking/lockdep.c | 12 ++++++++----
 1 file changed, 8 insertions(+), 4 deletions(-)

-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
