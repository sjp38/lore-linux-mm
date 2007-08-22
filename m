Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Subject: [PATCH 19 of 24] cacheline align VM_is_OOM to prevent false sharing
Message-Id: <be2fc447cec06990a2a3.1187786946@v2.random>
In-Reply-To: <patchbomb.1187786927@v2.random>
Date: Wed, 22 Aug 2007 14:49:06 +0200
From: Andrea Arcangeli <andrea@suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: David Rientjes <rientjes@google.com>
List-ID: <linux-mm.kvack.org>

# HG changeset patch
# User Andrea Arcangeli <andrea@suse.de>
# Date 1187778125 -7200
# Node ID be2fc447cec06990a2a31658b166f0c909777260
# Parent  040cab5c8aafe1efcb6fc21d1f268c11202dac02
cacheline align VM_is_OOM to prevent false sharing

This is better to be cacheline aligned in smp kernels just in case.

Signed-off-by: Andrea Arcangeli <andrea@suse.de>

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -29,7 +29,7 @@ int sysctl_panic_on_oom;
 int sysctl_panic_on_oom;
 /* #define DEBUG */
 
-unsigned long VM_is_OOM;
+unsigned long VM_is_OOM __cacheline_aligned_in_smp;
 static unsigned long last_tif_memdie_jiffies;
 
 /**

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
