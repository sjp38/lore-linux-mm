Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx138.postini.com [74.125.245.138])
	by kanga.kvack.org (Postfix) with SMTP id 05E7B6B0009
	for <linux-mm@kvack.org>; Fri, 18 Jan 2013 16:24:31 -0500 (EST)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: [PATCH V2 0/5] staging: zcache: move new zcache code base from ramster
Date: Fri, 18 Jan 2013 13:24:22 -0800
Message-Id: <1358544267-9104-1-git-send-email-dan.magenheimer@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: devel@linuxdriverproject.org, linux-kernel@vger.kernel.org, gregkh@linuxfoundation.org, linux-mm@kvack.org, ngupta@vflare.org, konrad.wilk@oracle.com, sjenning@linux.vnet.ibm.com, minchan@kernel.org, dan.magenheimer@oracle.com

[V2: no code changes, patchset now generated via git format-patch -M]

Hi Greg --

With "old zcache" now removed, we can now move "new zcache" from its
temporary home (in drivers/staging/ramster) to reclaim sole possession
of the name "zcache".

(Note that [PATCH 2/5] is just a git mv.)

This patchset should apply cleanly to staging-next.

Thanks,
Dan

Signed-off-by: Dan Magenheimer <dan.magenheimer@oracle.com>

---
Diffstat:

 drivers/staging/Kconfig                            |    4 +-
 drivers/staging/Makefile                           |    2 +-
 drivers/staging/ramster/Kconfig                    |   31 -
 drivers/staging/ramster/Makefile                   |    6 -
 drivers/staging/ramster/ramster.h                  |   59 -
 drivers/staging/ramster/ramster/heartbeat.c        |  462 ----
 drivers/staging/ramster/ramster/heartbeat.h        |   87 -
 drivers/staging/ramster/ramster/masklog.c          |  155 --
 drivers/staging/ramster/ramster/masklog.h          |  220 --
 drivers/staging/ramster/ramster/nodemanager.c      |  995 ---------
 drivers/staging/ramster/ramster/nodemanager.h      |   88 -
 drivers/staging/ramster/ramster/r2net.c            |  414 ----
 drivers/staging/ramster/ramster/ramster.c          |  985 ---------
 drivers/staging/ramster/ramster/ramster.h          |  161 --
 .../staging/ramster/ramster/ramster_nodemanager.h  |   39 -
 drivers/staging/ramster/ramster/tcp.c              | 2253 --------------------
 drivers/staging/ramster/ramster/tcp.h              |  159 --
 drivers/staging/ramster/ramster/tcp_internal.h     |  248 ---
 drivers/staging/ramster/tmem.c                     |  894 --------
 drivers/staging/ramster/tmem.h                     |  259 ---
 drivers/staging/ramster/zbud.c                     | 1060 ---------
 drivers/staging/ramster/zbud.h                     |   33 -
 drivers/staging/ramster/zcache-main.c              | 1820 ----------------
 drivers/staging/ramster/zcache.h                   |   53 -
 drivers/staging/zcache/Kconfig                     |   26 +
 drivers/staging/zcache/Makefile                    |    6 +
 drivers/staging/zcache/ramster.h                   |   59 +
 drivers/staging/zcache/ramster/heartbeat.c         |  462 ++++
 drivers/staging/zcache/ramster/heartbeat.h         |   87 +
 drivers/staging/zcache/ramster/masklog.c           |  155 ++
 drivers/staging/zcache/ramster/masklog.h           |  220 ++
 drivers/staging/zcache/ramster/nodemanager.c       |  995 +++++++++
 drivers/staging/zcache/ramster/nodemanager.h       |   88 +
 drivers/staging/zcache/ramster/r2net.c             |  414 ++++
 drivers/staging/zcache/ramster/ramster.c           |  985 +++++++++
 drivers/staging/zcache/ramster/ramster.h           |  161 ++
 .../staging/zcache/ramster/ramster_nodemanager.h   |   39 +
 drivers/staging/zcache/ramster/tcp.c               | 2253 ++++++++++++++++++++
 drivers/staging/zcache/ramster/tcp.h               |  159 ++
 drivers/staging/zcache/ramster/tcp_internal.h      |  248 +++
 drivers/staging/zcache/tmem.c                      |  894 ++++++++
 drivers/staging/zcache/tmem.h                      |  259 +++
 drivers/staging/zcache/zbud.c                      | 1060 +++++++++
 drivers/staging/zcache/zbud.h                      |   33 +
 drivers/staging/zcache/zcache-main.c               | 1820 ++++++++++++++++
 drivers/staging/zcache/zcache.h                    |   53 +
 46 files changed, 10479 insertions(+), 10484 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
