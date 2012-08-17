Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx153.postini.com [74.125.245.153])
	by kanga.kvack.org (Postfix) with SMTP id 6D2F76B0069
	for <linux-mm@kvack.org>; Fri, 17 Aug 2012 18:02:37 -0400 (EDT)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: [PATCH V2 0/3] staging: zcache+ramster: move to new code base and re-merge
Date: Fri, 17 Aug 2012 15:02:29 -0700
Message-Id: <1345240952-28302-1-git-send-email-dan.magenheimer@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: devel@linuxdriverproject.org, linux-kernel@vger.kernel.org, gregkh@linuxfoundation.org, linux-mm@kvack.org, ngupta@vflare.org, konrad.wilk@oracle.com, sjenning@linux.vnet.ibm.com, minchan@kernel.org, dan.magenheimer@oracle.com

[V2 fixes patch submission errors; no code changes]

This patchset moves both the original "demo" zcache (in staging since 2.6.29)
and ramster (in staging since 3.4) to a new stable code base which re-merges
duplicate code and resolves various serious design flaws needed to allow
progress in promoting zcache (and ramster) out of staging.

An overview of the zcache rewrite is in the git commit of the new zcache patch.

A significant item of debate in the new codebase is the removal of zsmalloc.
This removal may be temporary if zsmalloc is enhanced with necessary
features to meet the needs of the new zcache codebase.  Justification
for the change can be found at http://lkml.org/lkml/2012/8/15/292

While this new codebase is far from perfect (and thus remains in staging),
the foundation is now cleaner, more stable, more maintainable, and much
better commented.

Signed-off-by: Dan Magenheimer <dan.magenheimer@oracle.com>

---
Diffstat:

 drivers/staging/Kconfig                            |    6 +-
 drivers/staging/Makefile                           |    3 +-
 drivers/staging/ramster/Kconfig                    |   13 -
 drivers/staging/ramster/Makefile                   |    1 -
 drivers/staging/ramster/TODO                       |   13 -
 drivers/staging/ramster/cluster/Makefile           |    3 -
 drivers/staging/ramster/cluster/heartbeat.c        |  464 ---
 drivers/staging/ramster/cluster/heartbeat.h        |   87 -
 drivers/staging/ramster/cluster/masklog.c          |  155 -
 drivers/staging/ramster/cluster/masklog.h          |  220 --
 drivers/staging/ramster/cluster/nodemanager.c      |  992 ------
 drivers/staging/ramster/cluster/nodemanager.h      |   88 -
 .../staging/ramster/cluster/ramster_nodemanager.h  |   39 -
 drivers/staging/ramster/cluster/tcp.c              | 2256 -------------
 drivers/staging/ramster/cluster/tcp.h              |  159 -
 drivers/staging/ramster/cluster/tcp_internal.h     |  248 --
 drivers/staging/ramster/r2net.c                    |  401 ---
 drivers/staging/ramster/ramster.h                  |  118 -
 drivers/staging/ramster/tmem.c                     |  851 -----
 drivers/staging/ramster/tmem.h                     |  244 --
 drivers/staging/ramster/xvmalloc.c                 |  509 ---
 drivers/staging/ramster/xvmalloc.h                 |   30 -
 drivers/staging/ramster/xvmalloc_int.h             |   95 -
 drivers/staging/ramster/zcache-main.c              | 3320 --------------------
 drivers/staging/ramster/zcache.h                   |   22 -
 drivers/staging/zcache/Kconfig                     |   23 +-
 drivers/staging/zcache/Makefile                    |    5 +-
 drivers/staging/zcache/ramster.h                   |   59 +
 drivers/staging/zcache/ramster/heartbeat.c         |  462 +++
 drivers/staging/zcache/ramster/heartbeat.h         |   87 +
 drivers/staging/zcache/ramster/masklog.c           |  155 +
 drivers/staging/zcache/ramster/masklog.h           |  220 ++
 drivers/staging/zcache/ramster/nodemanager.c       |  995 ++++++
 drivers/staging/zcache/ramster/nodemanager.h       |   88 +
 drivers/staging/zcache/ramster/r2net.c             |  414 +++
 drivers/staging/zcache/ramster/ramster.c           |  985 ++++++
 drivers/staging/zcache/ramster/ramster.h           |  161 +
 .../staging/zcache/ramster/ramster_nodemanager.h   |   39 +
 drivers/staging/zcache/ramster/tcp.c               | 2253 +++++++++++++
 drivers/staging/zcache/ramster/tcp.h               |  159 +
 drivers/staging/zcache/ramster/tcp_internal.h      |  248 ++
 drivers/staging/zcache/tmem.c                      |  376 ++-
 drivers/staging/zcache/tmem.h                      |   83 +-
 drivers/staging/zcache/zbud.c                      | 1060 +++++++
 drivers/staging/zcache/zbud.h                      |   33 +
 drivers/staging/zcache/zcache-main.c               | 2322 ++++++--------
 drivers/staging/zcache/zcache.h                    |   53 +
 47 files changed, 8842 insertions(+), 11775 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
