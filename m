Received: from Relay2.suse.de (mail2.suse.de [195.135.221.8])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx2.suse.de (Postfix) with ESMTP id 961122170D
	for <linux-mm@kvack.org>; Wed, 13 Jun 2007 11:26:48 +0200 (CEST)
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Subject: [PATCH] cacheline align VM_is_OOM to prevent false sharing
Message-Id: <b24d30f03c4426237f3e.1181726790@v2.random>
Date: Wed, 13 Jun 2007 11:26:30 +0200
From: Andrea Arcangeli <andrea@suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

# HG changeset patch
# User Andrea Arcangeli <andrea@suse.de>
# Date 1181724924 -7200
# Node ID b24d30f03c4426237f3e08e28a02635d6047b7dd
# Parent  61155bad1fc923ea547852ac9fafed9f8bc7485d
cacheline align VM_is_OOM to prevent false sharing

This is better to be cacheline aligned in smp kernels just in case.

Signed-off-by: Andrea Arcangeli <andrea@suse.de>

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -28,7 +28,7 @@ int sysctl_panic_on_oom;
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
