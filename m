Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id 43EE66B0269
	for <linux-mm@kvack.org>; Thu, 22 Sep 2016 13:03:29 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id m186so228410724ioa.0
        for <linux-mm@kvack.org>; Thu, 22 Sep 2016 10:03:29 -0700 (PDT)
Received: from p3plsmtps2ded04.prod.phx3.secureserver.net (p3plsmtps2ded04.prod.phx3.secureserver.net. [208.109.80.198])
        by mx.google.com with ESMTPS id r202si3142720itb.73.2016.09.22.10.03.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 22 Sep 2016 10:03:28 -0700 (PDT)
From: Matthew Wilcox <mawilcox@linuxonhyperv.com>
Subject: [PATCH 0/2] Fix radix_tree_lookup_slot()
Date: Thu, 22 Sep 2016 11:53:33 -0700
Message-Id: <1474570415-14938-1-git-send-email-mawilcox@linuxonhyperv.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Konstantin Khlebnikov <koct9i@gmail.com>, Ross Zwisler <ross.zwisler@linux.intel.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Matthew Wilcox <mawilcox@microsoft.com>

From: Matthew Wilcox <mawilcox@microsoft.com>

Hi Linus,

Please apply for 4.8.  The same bug is also present in 4.7, but is
probably latent.

Matthew Wilcox (2):
  radix tree test suite: Test radix_tree_replace_slot() for multiorder
    entries
  radix-tree: Fix optimisation problem

 lib/radix-tree.c                      |  3 ++-
 tools/testing/radix-tree/Makefile     |  2 +-
 tools/testing/radix-tree/multiorder.c | 16 ++++++++++++----
 3 files changed, 15 insertions(+), 6 deletions(-)

-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
