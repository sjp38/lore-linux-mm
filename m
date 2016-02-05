Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id 2F4F54403D8
	for <linux-mm@kvack.org>; Thu,  4 Feb 2016 22:41:00 -0500 (EST)
Received: by mail-pa0-f45.google.com with SMTP id uo6so27114111pac.1
        for <linux-mm@kvack.org>; Thu, 04 Feb 2016 19:41:00 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id fm8si20896396pad.29.2016.02.04.19.40.59
        for <linux-mm@kvack.org>;
        Thu, 04 Feb 2016 19:40:59 -0800 (PST)
From: Matthew Wilcox <matthew.r.wilcox@intel.com>
Subject: [PATCH 0/2] Radix tree retry bug fix & test case
Date: Thu,  4 Feb 2016 22:40:46 -0500
Message-Id: <1454643648-10002-1-git-send-email-matthew.r.wilcox@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <koct9i@gmail.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Matthew Wilcox <matthew.r.wilcox@intel.com>, Hugh Dickins <hughd@google.com>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

Konstantin pointed out my braino when using radix_tree_iter_retry(),
and then pointed out a second braino.  I think we can fix both brainos
with one simple test (the advantage of having your braino pointed out
to you is that you know what you were expecting to happen, so you can
sometimes propose simlpy making happen what you expected to happen.
Konstantin doesn't have access to my though tprocesses.)

Kontantin wrote a really great test ... and then didn't add it to the
test suite.  That made me sad, so I added it.

Andrew, can you drop radix-tree-fix-oops-after-radix_tree_iter_retry.patch
from your tree and add these two patches instead?  If you prefer
Konstantin's fix to this one, I'll send you another patch to fix the
second problem Konstantin pointed out.

I was a bit unsure about the proper attribution here.  The essentials
of the test-suite change from Konstantin are unchanged, but he didn't
have his own sign-off on it.  So I made him 'From' and only added my
own sign-off.

Konstantin Khlebnikov (1):
  radix-tree tests: Add regression3 test

Matthew Wilcox (1):
  radix-tree: fix oops after radix_tree_iter_retry

 include/linux/radix-tree.h              |  3 ++
 tools/testing/radix-tree/Makefile       |  2 +-
 tools/testing/radix-tree/linux/kernel.h |  1 +
 tools/testing/radix-tree/main.c         |  1 +
 tools/testing/radix-tree/regression.h   |  1 +
 tools/testing/radix-tree/regression3.c  | 86 +++++++++++++++++++++++++++++++++
 6 files changed, 93 insertions(+), 1 deletion(-)
 create mode 100644 tools/testing/radix-tree/regression3.c

-- 
2.7.0.rc3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
