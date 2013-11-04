Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f179.google.com (mail-pd0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id 4DA296B0035
	for <linux-mm@kvack.org>; Sun,  3 Nov 2013 22:31:32 -0500 (EST)
Received: by mail-pd0-f179.google.com with SMTP id y10so6128501pdj.24
        for <linux-mm@kvack.org>; Sun, 03 Nov 2013 19:31:31 -0800 (PST)
Received: from psmtp.com ([74.125.245.139])
        by mx.google.com with SMTP id ai2si9657530pad.262.2013.11.03.19.31.30
        for <linux-mm@kvack.org>;
        Sun, 03 Nov 2013 19:31:31 -0800 (PST)
Received: by mail-pa0-f43.google.com with SMTP id hz1so6391734pad.2
        for <linux-mm@kvack.org>; Sun, 03 Nov 2013 19:31:29 -0800 (PST)
From: Zheng Liu <gnehzuil.liu@gmail.com>
Subject: [PATCH] mm: improve the description for dirty_background_ratio/dirty_ratio sysctl
Date: Mon,  4 Nov 2013 11:33:42 +0800
Message-Id: <1383536022-29555-1-git-send-email-wenqing.lz@taobao.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-doc@vger.kernel.org
Cc: Rob Landley <rob@landley.net>, Andrew Morton <akpm@linux-foundation.org>, Zheng Liu <wenqing.lz@taobao.com>

From: Zheng Liu <wenqing.lz@taobao.com>

Now dirty_backgraound_ratio/dirty_ratio contains a percentage of total avaiable
memory, which contains free pages and reclaimable pages.  The number of these
pages is not equal to the number of total system memory.  But they are described
as a percentage of total system memory in Documentation/sysctl/vm.txt.  So we
need to fix them to avoid misunderstanding.

Cc: Rob Landley <rob@landley.net>
Cc: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Zheng Liu <wenqing.lz@taobao.com>
---
 Documentation/sysctl/vm.txt |   15 ++++++++++-----
 1 file changed, 10 insertions(+), 5 deletions(-)

diff --git a/Documentation/sysctl/vm.txt b/Documentation/sysctl/vm.txt
index 79a797e..1fbd4eb 100644
--- a/Documentation/sysctl/vm.txt
+++ b/Documentation/sysctl/vm.txt
@@ -119,8 +119,11 @@ other appears as 0 when read.
 
 dirty_background_ratio
 
-Contains, as a percentage of total system memory, the number of pages at which
-the background kernel flusher threads will start writing out dirty data.
+Contains, as a percentage of total available memory that contains free pages
+and reclaimable pages, the number of pages at which the background kernel
+flusher threads will start writing out dirty data.
+
+The total avaiable memory is not equal to total system memory.
 
 ==============================================================
 
@@ -151,9 +154,11 @@ interval will be written out next time a flusher thread wakes up.
 
 dirty_ratio
 
-Contains, as a percentage of total system memory, the number of pages at which
-a process which is generating disk writes will itself start writing out dirty
-data.
+Contains, as a percentage of total available memory that contains free pages
+and reclaimable pages, the number of pages at which a process which is
+generating disk writes will itself start writing out dirty data.
+
+The total avaiable memory is not equal to total system memory.
 
 ==============================================================
 
-- 
1.7.9.7

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
