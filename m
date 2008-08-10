Received: by qb-out-1314.google.com with SMTP id e11so2064336qbc.4
        for <linux-mm@kvack.org>; Sun, 10 Aug 2008 10:17:13 -0700 (PDT)
From: Eduard - Gabriel Munteanu <eduard.munteanu@linux360.ro>
Subject: [PATCH 0/5] kmemtrace
Date: Sun, 10 Aug 2008 20:14:02 +0300
Message-Id: <1218388447-5578-1-git-send-email-eduard.munteanu@linux360.ro>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: penberg@cs.helsinki.fi
Cc: mathieu.desnoyers@polymtl.ca, cl@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, rdunlap@xenotime.net, mpm@selenic.com, rostedt@goodmis.org, tglx@linutronix.de
List-ID: <linux-mm.kvack.org>

Hi everybody,

As usual, the kmemtrace userspace repo is located at
git://repo.or.cz/kmemtrace-user.git

It's not updated now, but I will rebase it. So re-clone it, don't just
git-rebase it. The changes were too extensive and I'd like to keep the
revision history clean.

Changes in kmemtrace:
- new ABI, supports variable sized packets and it's much shorter (it has
specific fields for allocations)
- we'll use splice() in userspace
- replaced timestamps with sequence numbers, since timestamps don't have a good
enough resolution (though they could be added as an additional feature)
- used relay_reserve() as Mathieu Desnoyers suggested
- moved additional docs into a different commit and documented the replacement
of inline with __always_inline in those commits

Please have a look and let me know what you think.

Eduard - Gabriel Munteanu (5):
  kmemtrace: Core implementation.
  kmemtrace: Additional documentation.
  kmemtrace: SLAB hooks.
  kmemtrace: SLUB hooks.
  kmemtrace: SLOB hooks.

 Documentation/ABI/testing/debugfs-kmemtrace |   71 ++++++
 Documentation/kernel-parameters.txt         |   10 +
 Documentation/vm/kmemtrace.txt              |  126 ++++++++++
 MAINTAINERS                                 |    6 +
 include/linux/kmemtrace.h                   |   85 +++++++
 include/linux/slab_def.h                    |   68 +++++-
 include/linux/slob_def.h                    |    9 +-
 include/linux/slub_def.h                    |   53 ++++-
 init/main.c                                 |    2 +
 lib/Kconfig.debug                           |   28 +++
 mm/Makefile                                 |    2 +-
 mm/kmemtrace.c                              |  335 +++++++++++++++++++++++++++
 mm/slab.c                                   |   71 +++++-
 mm/slob.c                                   |   37 +++-
 mm/slub.c                                   |   66 +++++-
 15 files changed, 933 insertions(+), 36 deletions(-)
 create mode 100644 Documentation/ABI/testing/debugfs-kmemtrace
 create mode 100644 Documentation/vm/kmemtrace.txt
 create mode 100644 include/linux/kmemtrace.h
 create mode 100644 mm/kmemtrace.c

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
