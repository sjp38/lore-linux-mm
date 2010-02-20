Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 1CDE86B0047
	for <linux-mm@kvack.org>; Sat, 20 Feb 2010 09:12:09 -0500 (EST)
Received: by yxe6 with SMTP id 6so2306305yxe.11
        for <linux-mm@kvack.org>; Sat, 20 Feb 2010 06:12:50 -0800 (PST)
Date: Sat, 20 Feb 2010 22:12:41 +0800
From: Dave Young <hidave.darkstar@gmail.com>
Subject: [PATCH 06/18] sysctl extern cleanup - mm
Message-ID: <20100220141241.GE3195@darkstar>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@elte.hu>, Andi Kleen <ak@linux.intel.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Peter Zijlstra <a.p.zijlstra@chello.nl>, James Morris <jmorris@namei.org>, "Eric W. Biederman" <ebiederm@xmission.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Extern declarations in sysctl.c should be move to their own head file,
and then include them in relavant .c files.

Move min_free_kbytes extern declaration to linux/mm.h

Signed-off-by: Dave Young <hidave.darkstar@gmail.com>
---
 include/linux/mm.h |    1 +
 kernel/sysctl.c    |    1 -
 2 files changed, 1 insertion(+), 1 deletion(-)

--- linux-2.6.32.orig/include/linux/mm.h	2010-02-20 14:02:25.281592573 +0800
+++ linux-2.6.32/include/linux/mm.h	2010-02-20 14:14:21.374855298 +0800
@@ -31,6 +31,7 @@ extern int page_cluster;
 
 #ifdef CONFIG_SYSCTL
 extern int sysctl_legacy_va_layout;
+extern int min_free_kbytes;
 #else
 #define sysctl_legacy_va_layout 0
 #endif
--- linux-2.6.32.orig/kernel/sysctl.c	2010-02-20 14:13:08.415694935 +0800
+++ linux-2.6.32/kernel/sysctl.c	2010-02-20 14:13:28.511525875 +0800
@@ -72,7 +72,6 @@
 #if defined(CONFIG_SYSCTL)
 
 /* External variables not in a header file. */
-extern int min_free_kbytes;
 extern int compat_log;
 extern int latencytop_enabled;
 extern int sysctl_nr_open_min, sysctl_nr_open_max;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
