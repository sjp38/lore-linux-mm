Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 52FF16B0033
	for <linux-mm@kvack.org>; Fri,  8 Dec 2017 03:24:34 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id a13so7467027pgt.0
        for <linux-mm@kvack.org>; Fri, 08 Dec 2017 00:24:34 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r59sor3047700plb.9.2017.12.08.00.24.32
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 08 Dec 2017 00:24:32 -0800 (PST)
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: [PATCH] sched/autogroup: move sched.h include
Date: Fri,  8 Dec 2017 17:24:22 +0900
Message-Id: <20171208082422.5021-1-sergey.senozhatsky@gmail.com>
In-Reply-To: <20171208025616.16267-2-sergey.senozhatsky@gmail.com>
References: <20171208025616.16267-2-sergey.senozhatsky@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>, Martin Schwidefsky <schwidefsky@de.ibm.com>
Cc: Steven Rostedt <rostedt@goodmis.org>, Petr Mladek <pmladek@suse.com>, LKML <linux-kernel@vger.kernel.org>, linux-pm@vger.kernel.org, linux-pci@vger.kernel.org, linux-mm@kvack.org, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

Move local "sched.h" include to the bottom. sched.h defines
several macros that are getting redefined in ARCH-specific
code, for instance, finish_arch_post_lock_switch() and
prepare_arch_switch(), so we need ARCH-specific definitions
to come in first.

Suggested-by: Martin Schwidefsky <schwidefsky@de.ibm.com>
Signed-off-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
---
 kernel/sched/autogroup.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/kernel/sched/autogroup.c b/kernel/sched/autogroup.c
index 0786227a3f48..bb4b9fe026a1 100644
--- a/kernel/sched/autogroup.c
+++ b/kernel/sched/autogroup.c
@@ -1,12 +1,12 @@
 // SPDX-License-Identifier: GPL-2.0
-#include "sched.h"
-
 #include <linux/proc_fs.h>
 #include <linux/seq_file.h>
 #include <linux/utsname.h>
 #include <linux/security.h>
 #include <linux/export.h>
 
+#include "sched.h"
+
 unsigned int __read_mostly sysctl_sched_autogroup_enabled = 1;
 static struct autogroup autogroup_default;
 static atomic_t autogroup_seq_nr;
-- 
2.15.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
