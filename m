Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id C9AF9280254
	for <linux-mm@kvack.org>; Wed, 15 Nov 2017 22:14:35 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id d15so14416665pfl.0
        for <linux-mm@kvack.org>; Wed, 15 Nov 2017 19:14:35 -0800 (PST)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id z186si104026pgb.356.2017.11.15.19.14.34
        for <linux-mm@kvack.org>;
        Wed, 15 Nov 2017 19:14:34 -0800 (PST)
From: Byungchul Park <byungchul.park@lge.com>
Subject: [PATCH 0/3] lockdep/crossrelease: Apply crossrelease to page locks
Date: Thu, 16 Nov 2017 12:14:24 +0900
Message-Id: <1510802067-18609-1-git-send-email-byungchul.park@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: peterz@infradead.org, mingo@kernel.org, akpm@linux-foundation.org
Cc: tglx@linutronix.de, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-block@vger.kernel.org, kernel-team@lge.com, jack@suse.cz, jlayton@redhat.com, viro@zeniv.linux.org.uk, hannes@cmpxchg.org, npiggin@gmail.com, rgoldwyn@suse.com, vbabka@suse.cz, mhocko@suse.com, pombredanne@nexb.com, vinmenon@codeaurora.org, gregkh@linuxfoundation.org

For now, wait_for_completion() / complete() works with lockdep.

Add lock_page() / unlock_page() and its family to lockdep support.

Byungchul Park (3):
  lockdep: Apply crossrelease to PG_locked locks
  lockdep: Apply lock_acquire(release) on __Set(__Clear)PageLocked
  lockdep: Move data of CONFIG_LOCKDEP_PAGELOCK from page to page_ext

 include/linux/mm_types.h   |   4 ++
 include/linux/page-flags.h |  43 +++++++++++++++-
 include/linux/page_ext.h   |   4 ++
 include/linux/pagemap.h    | 121 ++++++++++++++++++++++++++++++++++++++++++---
 lib/Kconfig.debug          |   8 +++
 mm/filemap.c               |  73 ++++++++++++++++++++++++++-
 mm/page_ext.c              |   4 ++
 7 files changed, 248 insertions(+), 9 deletions(-)

-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
