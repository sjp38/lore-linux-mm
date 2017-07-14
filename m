Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id 88E6044093E
	for <linux-mm@kvack.org>; Fri, 14 Jul 2017 18:16:11 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id f1so28704418ioj.11
        for <linux-mm@kvack.org>; Fri, 14 Jul 2017 15:16:11 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id y3si13755555ioe.11.2017.07.14.15.16.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 14 Jul 2017 15:16:10 -0700 (PDT)
From: daniel.m.jordan@oracle.com
Subject: [RFC PATCH v1 3/6] ktask: add /proc/sys/debug/ktask_max_threads
Date: Fri, 14 Jul 2017 15:16:10 -0700
Message-Id: <1500070573-3948-4-git-send-email-daniel.m.jordan@oracle.com>
In-Reply-To: <1500070573-3948-1-git-send-email-daniel.m.jordan@oracle.com>
References: <1500070573-3948-1-git-send-email-daniel.m.jordan@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org

Adds a proc file to control the maximum number of ktask threads in use
for any one job.  Its primary use is to aid in debugging.

Signed-off-by: Daniel Jordan <daniel.m.jordan@oracle.com>
---
 kernel/sysctl.c |   10 ++++++++++
 1 files changed, 10 insertions(+), 0 deletions(-)

diff --git a/kernel/sysctl.c b/kernel/sysctl.c
index 4dfba1a..7fe142b 100644
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -67,6 +67,7 @@
 #include <linux/kexec.h>
 #include <linux/bpf.h>
 #include <linux/mount.h>
+#include <linux/ktask_internal.h>
 
 #include <linux/uaccess.h>
 #include <asm/processor.h>
@@ -1850,6 +1851,15 @@ static int sysrq_sysctl_handler(struct ctl_table *table, int write,
 		.extra2		= &one,
 	},
 #endif
+#if defined(CONFIG_KTASK)
+	{
+		.procname	= "ktask_max_threads",
+		.data		= &ktask_max_threads,
+		.maxlen		= sizeof(ktask_max_threads),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec,
+	},
+#endif
 	{ }
 };
 
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
