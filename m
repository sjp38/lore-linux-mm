Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx174.postini.com [74.125.245.174])
	by kanga.kvack.org (Postfix) with SMTP id 81A976B004D
	for <linux-mm@kvack.org>; Fri, 16 Nov 2012 02:01:54 -0500 (EST)
Received: by mail-bk0-f41.google.com with SMTP id jg9so1179094bkc.14
        for <linux-mm@kvack.org>; Thu, 15 Nov 2012 23:01:52 -0800 (PST)
Message-ID: <50A5E4D6.60301@gmail.com>
Date: Fri, 16 Nov 2012 08:01:42 +0100
From: Michael Kerrisk <mtk.manpages@gmail.com>
MIME-Version: 1.0
Subject: [PATCH] Correct description of SwapFree in Documentation/filesystems/proc.txt
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, lkml <linux-kernel@vger.kernel.org>, linux-doc@vger.kernel.org, Rob Landley <rob@landley.net>, Jim Paris <jim@jtan.com>, "Michael Kerrisk (gmail)" <mtk.manpages@gmail.com>

After migrating most of the information in 
Documentation/filesystems/proc.txt to the proc(5) man page,
Jim Paris pointed out to me that the description of SwapFree
in the man page seemed wrong. I think Jim is right,
but am given pause by fact that that text has been in 
Documentation/filesystems/proc.txt since at least 2.6.0.
Anyway, I believe that the patch below fixes things.

Signed-off-by: Michael Kerrisk <mtk.manpages@gmail.com>


diff --git a/Documentation/filesystems/proc.txt b/Documentation/filesystems/proc.txt
index a1793d6..cf4260f 100644
--- a/Documentation/filesystems/proc.txt
+++ b/Documentation/filesystems/proc.txt
@@ -778,8 +778,7 @@ AnonHugePages:   49152 kB
               other things, it is where everything from the Slab is
               allocated.  Bad things happen when you're out of lowmem.
    SwapTotal: total amount of swap space available
-    SwapFree: Memory which has been evicted from RAM, and is temporarily
-              on the disk
+    SwapFree: Amount of swap space that is currently unused.
        Dirty: Memory which is waiting to get written back to the disk
    Writeback: Memory which is actively being written back to the disk
    AnonPages: Non-file backed pages mapped into userspace page tables

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
