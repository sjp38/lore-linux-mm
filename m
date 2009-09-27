Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id C594C6B0055
	for <linux-mm@kvack.org>; Sat, 26 Sep 2009 23:15:35 -0400 (EDT)
Received: by pzk38 with SMTP id 38so1677485pzk.11
        for <linux-mm@kvack.org>; Sat, 26 Sep 2009 20:15:39 -0700 (PDT)
From: Huang Weiyi <weiyi.huang@gmail.com>
Subject: [PATCH 4/5] /proc/kcore: remove duplicated #include
Date: Sun, 27 Sep 2009 11:15:33 +0800
Message-Id: <1254021333-2844-1-git-send-email-weiyi.huang@gmail.com>
Sender: owner-linux-mm@kvack.org
To: kamezawa.hiroyu@jp.fujitsu.com
Cc: linux-mm@kvack.org, Huang Weiyi <weiyi.huang@gmail.com>
List-ID: <linux-mm.kvack.org>

Remove duplicated #include('s) in
  fs/proc/kcore.c

Signed-off-by: Huang Weiyi <weiyi.huang@gmail.com>
---
 fs/proc/kcore.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/fs/proc/kcore.c b/fs/proc/kcore.c
index 5601337..a44a789 100644
--- a/fs/proc/kcore.c
+++ b/fs/proc/kcore.c
@@ -23,7 +23,6 @@
 #include <asm/io.h>
 #include <linux/list.h>
 #include <linux/ioport.h>
-#include <linux/mm.h>
 #include <linux/memory.h>
 #include <asm/sections.h>
 
-- 
1.6.1.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
