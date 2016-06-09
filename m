Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id BE4A86B007E
	for <linux-mm@kvack.org>; Thu,  9 Jun 2016 13:06:07 -0400 (EDT)
Received: by mail-it0-f69.google.com with SMTP id h144so87208965ita.1
        for <linux-mm@kvack.org>; Thu, 09 Jun 2016 10:06:07 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id ff3si8384541pab.126.2016.06.09.10.06.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 09 Jun 2016 10:06:06 -0700 (PDT)
From: Randy Dunlap <rdunlap@infradead.org>
Subject: [PATCH] mm: fix build warnings in <linux/compaction.h>
Message-ID: <5759A1F9.2070302@infradead.org>
Date: Thu, 9 Jun 2016 10:06:01 -0700
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux MM <linux-mm@kvack.org>, "linux-next@vger.kernel.org" <linux-next@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: Stephen Rothwell <sfr@canb.auug.org.au>

From: Randy Dunlap <rdunlap@infradead.org>

Fix build warnings when struct node is not defined:

In file included from ../include/linux/balloon_compaction.h:48:0,
                 from ../mm/balloon_compaction.c:11:
../include/linux/compaction.h:237:51: warning: 'struct node' declared inside parameter list [enabled by default]
 static inline int compaction_register_node(struct node *node)
../include/linux/compaction.h:237:51: warning: its scope is only this definition or declaration, which is probably not what you want [enabled by default]
../include/linux/compaction.h:242:54: warning: 'struct node' declared inside parameter list [enabled by default]
 static inline void compaction_unregister_node(struct node *node)

Signed-off-by: Randy Dunlap <rdunlap@infradead.org>
---
 include/linux/compaction.h |    1 +
 1 file changed, 1 insertion(+)

Found in linux-next but also applies to mainline.

--- linux-next-20160609.orig/include/linux/compaction.h
+++ linux-next-20160609/include/linux/compaction.h
@@ -233,6 +233,7 @@ extern int compaction_register_node(stru
 extern void compaction_unregister_node(struct node *node);
 
 #else
+struct node;
 
 static inline int compaction_register_node(struct node *node)
 {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
