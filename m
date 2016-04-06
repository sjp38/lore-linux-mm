Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f170.google.com (mail-pf0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id 245016B007E
	for <linux-mm@kvack.org>; Wed,  6 Apr 2016 17:27:46 -0400 (EDT)
Received: by mail-pf0-f170.google.com with SMTP id e128so41153093pfe.3
        for <linux-mm@kvack.org>; Wed, 06 Apr 2016 14:27:46 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id os10si6867848pab.228.2016.04.06.14.21.55
        for <linux-mm@kvack.org>;
        Wed, 06 Apr 2016 14:21:55 -0700 (PDT)
From: Matthew Wilcox <willy@linux.intel.com>
Subject: [PATCH 30/30] radix-tree: Add copyright statements
Date: Wed,  6 Apr 2016 17:21:39 -0400
Message-Id: <1459977699-2349-31-git-send-email-willy@linux.intel.com>
In-Reply-To: <1459977699-2349-1-git-send-email-willy@linux.intel.com>
References: <1459977699-2349-1-git-send-email-willy@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>
Cc: Matthew Wilcox <willy@linux.intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Konstantin Khlebnikov <koct9i@gmail.com>, Kirill Shutemov <kirill.shutemov@linux.intel.com>, Jan Kara <jack@suse.com>, Neil Brown <neilb@suse.de>

The multiorder support is a sufficiently large feature to be worth adding
copyrigt lines for.

Signed-off-by: Matthew Wilcox <willy@linux.intel.com>
Reviewed-by: Ross Zwisler <ross.zwisler@linux.intel.com>
---
 lib/radix-tree.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/lib/radix-tree.c b/lib/radix-tree.c
index 0402c4f1a344..edaf4771feb0 100644
--- a/lib/radix-tree.c
+++ b/lib/radix-tree.c
@@ -4,6 +4,8 @@
  * Copyright (C) 2005 SGI, Christoph Lameter
  * Copyright (C) 2006 Nick Piggin
  * Copyright (C) 2012 Konstantin Khlebnikov
+ * Copyright (C) 2016 Intel, Matthew Wilcox
+ * Copyright (C) 2016 Intel, Ross Zwisler
  *
  * This program is free software; you can redistribute it and/or
  * modify it under the terms of the GNU General Public License as
-- 
2.8.0.rc3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
