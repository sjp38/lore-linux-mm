Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 0F51D6B0033
	for <linux-mm@kvack.org>; Mon,  4 Dec 2017 00:16:48 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id m16so10561782pgn.22
        for <linux-mm@kvack.org>; Sun, 03 Dec 2017 21:16:48 -0800 (PST)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id 59si6098438plp.809.2017.12.03.21.16.46
        for <linux-mm@kvack.org>;
        Sun, 03 Dec 2017 21:16:46 -0800 (PST)
From: Byungchul Park <byungchul.park@lge.com>
Subject: [PATCH v2 0/4] lockdep/crossrelease: Apply crossrelease to page locks
Date: Mon,  4 Dec 2017 14:16:19 +0900
Message-Id: <1512364583-26070-1-git-send-email-byungchul.park@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: peterz@infradead.org, mingo@kernel.org, akpm@linux-foundation.org
Cc: tglx@linutronix.de, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-block@vger.kernel.org, kernel-team@lge.com, jack@suse.cz, jlayton@redhat.com, viro@zeniv.linux.org.uk, hannes@cmpxchg.org, npiggin@gmail.com, rgoldwyn@suse.com, vbabka@suse.cz, mhocko@suse.com, pombredanne@nexb.com, vinmenon@codeaurora.org, gregkh@linuxfoundation.org

For now, wait_for_completion() / complete() works with lockdep, add
lock_page() / unlock_page() and its family to lockdep support.

Changes from v1
 - Move lockdep_map_cross outside of page_ext to make it flexible
 - Prevent allocating lockdep_map per page by default
 - Add a boot parameter allowing the allocation for debugging

Byungchul Park (4):
  lockdep: Apply crossrelease to PG_locked locks
  lockdep: Apply lock_acquire(release) on __Set(__Clear)PageLocked
  lockdep: Move data of CONFIG_LOCKDEP_PAGELOCK from page to page_ext
  lockdep: Add a boot parameter enabling to track page locks using
    lockdep and disable it by default

 Documentation/admin-guide/kernel-parameters.txt |   7 ++
 include/linux/mm_types.h                        |   4 +
 include/linux/page-flags.h                      |  43 +++++++-
 include/linux/pagemap.h                         | 125 ++++++++++++++++++++++--
 lib/Kconfig.debug                               |  11 +++
 mm/filemap.c                                    | 114 ++++++++++++++++++++-
 mm/page_ext.c                                   |   4 +
 7 files changed, 299 insertions(+), 9 deletions(-)

-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
