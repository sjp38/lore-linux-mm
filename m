Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id 109766B0038
	for <linux-mm@kvack.org>; Mon, 14 Apr 2014 19:57:30 -0400 (EDT)
Received: by mail-pa0-f42.google.com with SMTP id fb1so8947016pad.1
        for <linux-mm@kvack.org>; Mon, 14 Apr 2014 16:57:30 -0700 (PDT)
Received: from g2t2353.austin.hp.com (g2t2353.austin.hp.com. [15.217.128.52])
        by mx.google.com with ESMTPS id yb4si5455807pab.431.2014.04.14.16.57.29
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 14 Apr 2014 16:57:29 -0700 (PDT)
From: Davidlohr Bueso <davidlohr@hp.com>
Subject: [PATCH 1/3] mm: fix CONFIG_DEBUG_VM_RB description
Date: Mon, 14 Apr 2014 16:57:19 -0700
Message-Id: <1397519841-24847-2-git-send-email-davidlohr@hp.com>
In-Reply-To: <1397519841-24847-1-git-send-email-davidlohr@hp.com>
References: <1397519841-24847-1-git-send-email-davidlohr@hp.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, davidlohr@hp.com, aswin@hp.com

This appears to be a copy/paste error. Update the description
to reflect extra rbtree debug and checks for the config option
instead of duplicating CONFIG_DEBUG_VM.

Signed-off-by: Davidlohr Bueso <davidlohr@hp.com>
---
 lib/Kconfig.debug | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/lib/Kconfig.debug b/lib/Kconfig.debug
index 140b66a..819ac51 100644
--- a/lib/Kconfig.debug
+++ b/lib/Kconfig.debug
@@ -505,8 +505,7 @@ config DEBUG_VM_RB
 	bool "Debug VM red-black trees"
 	depends on DEBUG_VM
 	help
-	  Enable this to turn on more extended checks in the virtual-memory
-	  system that may impact performance.
+	  Enable VM red-black tree debugging information and extra validations.
 
 	  If unsure, say N.
 
-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
