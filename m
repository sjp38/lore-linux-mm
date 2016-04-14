Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id C8F436B007E
	for <linux-mm@kvack.org>; Thu, 14 Apr 2016 10:17:32 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id c20so131015364pfc.2
        for <linux-mm@kvack.org>; Thu, 14 Apr 2016 07:17:32 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTP id fe1si11001656pac.200.2016.04.14.07.17.30
        for <linux-mm@kvack.org>;
        Thu, 14 Apr 2016 07:17:30 -0700 (PDT)
From: Matthew Wilcox <willy@linux.intel.com>
Subject: [PATCH v2 06/29] radix tree test suite: rebuild when headers change
Date: Thu, 14 Apr 2016 10:16:27 -0400
Message-Id: <1460643410-30196-7-git-send-email-willy@linux.intel.com>
In-Reply-To: <1460643410-30196-1-git-send-email-willy@linux.intel.com>
References: <1460643410-30196-1-git-send-email-willy@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Konstantin Khlebnikov <koct9i@gmail.com>, Kirill Shutemov <kirill.shutemov@linux.intel.com>, Jan Kara <jack@suse.com>, Neil Brown <neilb@suse.de>, Matthew Wilcox <willy@linux.intel.com>

From: Ross Zwisler <ross.zwisler@linux.intel.com>

When we make changes to radix-tree.h in the regular kernel source
(include/linux/radix-tree.h), we really want our test code to be rebuilt.

We also include a few other headers from tools/include and probably want
to rebuild if these have been changed.

Update the makefile so that all of our objects will be rebuilt when any
of the headers we depend on are changed.

Signed-off-by: Ross Zwisler <ross.zwisler@linux.intel.com>
Signed-off-by: Matthew Wilcox <willy@linux.intel.com>
---
 tools/testing/radix-tree/Makefile | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/tools/testing/radix-tree/Makefile b/tools/testing/radix-tree/Makefile
index 604212d..43febba 100644
--- a/tools/testing/radix-tree/Makefile
+++ b/tools/testing/radix-tree/Makefile
@@ -13,7 +13,7 @@ main:	$(OFILES)
 clean:
 	$(RM) -f $(TARGETS) *.o radix-tree.c
 
-$(OFILES): *.h */*.h
+$(OFILES): *.h */*.h ../../../include/linux/radix-tree.h ../../include/linux/*.h
 
 radix-tree.c: ../../../lib/radix-tree.c
 	sed -e 's/^static //' -e 's/__always_inline //' -e 's/inline //' < $< > $@
-- 
2.8.0.rc3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
