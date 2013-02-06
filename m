Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx177.postini.com [74.125.245.177])
	by kanga.kvack.org (Postfix) with SMTP id 09AB76B0005
	for <linux-mm@kvack.org>; Wed,  6 Feb 2013 13:15:10 -0500 (EST)
Received: by mail-da0-f47.google.com with SMTP id s35so768453dak.20
        for <linux-mm@kvack.org>; Wed, 06 Feb 2013 10:15:10 -0800 (PST)
Date: Wed, 6 Feb 2013 10:15:07 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: [patch] mm: break circular include from linux/mmzone.h fix fix fix
 fix
In-Reply-To: <1360037707-13935-1-git-send-email-lig.fnst@cn.fujitsu.com>
Message-ID: <alpine.DEB.2.02.1302061013160.26828@chino.kir.corp.google.com>
References: <1360037707-13935-1-git-send-email-lig.fnst@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="531381512-853465630-1360174509=:26828"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: liguang <lig.fnst@cn.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--531381512-853465630-1360174509=:26828
Content-Type: TEXT/PLAIN; charset=UTF-8
Content-Transfer-Encoding: 8BIT

kernel/jump_label.c: In function a??jump_label_module_notifya??:
kernel/jump_label.c:393:2: error: implicit declaration of function a??notifier_from_errnoa?? [-Werror=implicit-function-declaration]
kernel/jump_label.c: At top level:
kernel/jump_label.c:396:8: error: variable a??jump_label_module_nba?? has initializer but incomplete type
kernel/jump_label.c:397:2: error: unknown field a??notifier_calla?? specified in initializer
kernel/jump_label.c:397:2: warning: excess elements in struct initializer [enabled by default]
kernel/jump_label.c:397:2: warning: (near initialization for a??jump_label_module_nba??) [enabled by default]
kernel/jump_label.c:398:2: error: unknown field a??prioritya?? specified in initializer
kernel/jump_label.c:398:2: warning: excess elements in struct initializer [enabled by default]
kernel/jump_label.c:398:2: warning: (near initialization for a??jump_label_module_nba??) [enabled by default]

Signed-off-by: David Rientjes <rientjes@google.com>
---
 kernel/jump_label.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/kernel/jump_label.c b/kernel/jump_label.c
index 60f48fa..012219d 100644
--- a/kernel/jump_label.c
+++ b/kernel/jump_label.c
@@ -13,6 +13,7 @@
 #include <linux/sort.h>
 #include <linux/err.h>
 #include <linux/static_key.h>
+#include <linux/notifier.h>
 
 #ifdef HAVE_JUMP_LABEL
 
--531381512-853465630-1360174509=:26828--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
