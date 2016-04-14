Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id BAB016B0263
	for <linux-mm@kvack.org>; Thu, 14 Apr 2016 10:17:47 -0400 (EDT)
Received: by mail-pa0-f70.google.com with SMTP id dx6so49832025pad.0
        for <linux-mm@kvack.org>; Thu, 14 Apr 2016 07:17:47 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTP id g3si9140591pap.29.2016.04.14.07.17.32
        for <linux-mm@kvack.org>;
        Thu, 14 Apr 2016 07:17:32 -0700 (PDT)
From: Matthew Wilcox <willy@linux.intel.com>
Subject: [PATCH v2 29/29] radix-tree: Add copyright statements
Date: Thu, 14 Apr 2016 10:16:50 -0400
Message-Id: <1460643410-30196-30-git-send-email-willy@linux.intel.com>
In-Reply-To: <1460643410-30196-1-git-send-email-willy@linux.intel.com>
References: <1460643410-30196-1-git-send-email-willy@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>
Cc: Matthew Wilcox <willy@linux.intel.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Konstantin Khlebnikov <koct9i@gmail.com>, Kirill Shutemov <kirill.shutemov@linux.intel.com>, Jan Kara <jack@suse.com>, Neil Brown <neilb@suse.de>, Ross Zwisler <ross.zwisler@linux.intel.com>

The multiorder support is a sufficiently large feature to be worth adding
copyrigt lines for.

Signed-off-by: Matthew Wilcox <willy@linux.intel.com>
Reviewed-by: Ross Zwisler <ross.zwisler@linux.intel.com>
---
 lib/radix-tree.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/lib/radix-tree.c b/lib/radix-tree.c
index 9fe5b83..cd7dc59 100644
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
