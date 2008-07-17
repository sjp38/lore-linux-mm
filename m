Received: by ag-out-0708.google.com with SMTP id 22so4236995agd.8
        for <linux-mm@kvack.org>; Wed, 16 Jul 2008 17:48:13 -0700 (PDT)
From: Eduard - Gabriel Munteanu <eduard.munteanu@linux360.ro>
Subject: [RFC PATCH 0/4] kmemtrace RFC (resubmit 1)
Date: Thu, 17 Jul 2008 03:46:44 +0300
Message-Id: <cover.1216255034.git.eduard.munteanu@linux360.ro>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: penberg@cs.helsinki.fi
Cc: cl@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Hello everybody,

I hopefully fixed previous complaints. Also wrote some documentation and
fixed some missing stuff in SLAB.

Please take a look and comment.

BTW, see Documentation/vm/kmemtrace.txt for details on how to use this and
for info on design details.


	Eduard

Eduard - Gabriel Munteanu (4):
  kmemtrace: Core implementation.
  kmemtrace: SLAB hooks.
  kmemtrace: SLUB hooks.
  kmemtrace: SLOB hooks.

 Documentation/kernel-parameters.txt |    6 +
 Documentation/vm/kmemtrace.txt      |   96 ++++++++++++++++
 MAINTAINERS                         |    6 +
 include/linux/kmemtrace.h           |  110 ++++++++++++++++++
 include/linux/slab_def.h            |   56 ++++++++-
 include/linux/slub_def.h            |    9 ++-
 init/main.c                         |    2 +
 lib/Kconfig.debug                   |    4 +
 mm/Makefile                         |    2 +-
 mm/kmemtrace.c                      |  208 +++++++++++++++++++++++++++++++++++
 mm/slab.c                           |   61 +++++++++-
 mm/slob.c                           |   37 +++++-
 mm/slub.c                           |   47 +++++++-
 13 files changed, 617 insertions(+), 27 deletions(-)
 create mode 100644 Documentation/vm/kmemtrace.txt
 create mode 100644 include/linux/kmemtrace.h
 create mode 100644 mm/kmemtrace.c

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
