Received: by ti-out-0910.google.com with SMTP id j3so992596tid.8
        for <linux-mm@kvack.org>; Tue, 22 Jul 2008 11:33:14 -0700 (PDT)
From: Eduard - Gabriel Munteanu <eduard.munteanu@linux360.ro>
Subject: [RFC PATCH 0/4] kmemtrace RFC (resend 2)
Date: Tue, 22 Jul 2008 21:31:29 +0300
Message-Id: <1216751493-13785-1-git-send-email-eduard.munteanu@linux360.ro>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: penberg@cs.helsinki.fi
Cc: cl@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, rdunlap@xenotime.net, mpm@selenic.co
List-ID: <linux-mm.kvack.org>

Hi everyone,

I hopefully fixed all your previous objections. I have also set up a git tree
for anyone who'd like to try kmemtrace (gitweb URL):

http://repo.or.cz/w/linux-2.6/kmemtrace.git

Comment on the patchset and please try running kmemtrace if possible. Check
the docs for information on how to get the userspace tool and set it up.

Important: the kmemtrace-user repo went stable and I'll not alter the revision
history anymore. BTW, don't be scared if you see many errors being reported by
kmemtrace-report, this is a known issue (I could use some advice on this if
you know what's going on).

Changes since last submission:
1. fixed allocator tracing
2. wrote more documentation
3. reworked the ABI and documented it in Documentation/ABI; we don't include
kernel headers in userspace anymore
4. added support for disabling kmemtrace at boot-time
5. added provisions for disabling kmemtrace at runtime
6. changed slab allocators to use __always_inline instead of plain inline,
so that we're sure the return address is valid
7. removed some useless cast, as pointed out by Pekka Enberg

Since the changes were quite extensive, I chose not to preserve any tags such
as "Reviewed-by".

I'm waiting for your input on this.


	Thanks,
	Eduard

P.S.: Pekka, I followed your advice on adding a field containing the struct
size (managed to make room for it without adding to the current struct size).
This allows us to do crazy stuff in the future, like exporting the whole
stack trace on every allocation. Not sure how useful this is right now, but
let's keep the ABI extensible.


Eduard - Gabriel Munteanu (4):
  kmemtrace: Core implementation.
  kmemtrace: SLAB hooks.
  kmemtrace: SLUB hooks.
  kmemtrace: SLOB hooks.

 Documentation/ABI/testing/debugfs-kmemtrace |   58 +++++++
 Documentation/kernel-parameters.txt         |   10 +
 Documentation/vm/kmemtrace.txt              |  126 ++++++++++++++
 MAINTAINERS                                 |    6 +
 include/linux/kmemtrace.h                   |  110 ++++++++++++
 include/linux/slab_def.h                    |   68 +++++++-
 include/linux/slob_def.h                    |    9 +-
 include/linux/slub_def.h                    |   53 ++++++-
 init/main.c                                 |    2 +
 lib/Kconfig.debug                           |   28 +++
 mm/Makefile                                 |    2 +-
 mm/kmemtrace.c                              |  244 +++++++++++++++++++++++++++
 mm/slab.c                                   |   71 +++++++-
 mm/slob.c                                   |   37 ++++-
 mm/slub.c                                   |   66 +++++++-
 15 files changed, 854 insertions(+), 36 deletions(-)
 create mode 100644 Documentation/ABI/testing/debugfs-kmemtrace
 create mode 100644 Documentation/vm/kmemtrace.txt
 create mode 100644 include/linux/kmemtrace.h
 create mode 100644 mm/kmemtrace.c

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
