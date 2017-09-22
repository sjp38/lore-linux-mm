Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 1CA486B0038
	for <linux-mm@kvack.org>; Fri, 22 Sep 2017 17:55:37 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id p87so3762360pfj.4
        for <linux-mm@kvack.org>; Fri, 22 Sep 2017 14:55:37 -0700 (PDT)
Received: from out0-242.mail.aliyun.com (out0-242.mail.aliyun.com. [140.205.0.242])
        by mx.google.com with ESMTPS id d3si130569plo.365.2017.09.22.14.55.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 Sep 2017 14:55:35 -0700 (PDT)
From: "Yang Shi" <yang.s@alibaba-inc.com>
Subject: [PATCH] mm: madvise: add description for MADV_WIPEONFORK and MADV_KEEPONFORK
Date: Sat, 23 Sep 2017 05:55:28 +0800
Message-Id: <1506117328-88228-1-git-send-email-yang.s@alibaba-inc.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: riel@redhat.com
Cc: Yang Shi <yang.s@alibaba-inc.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

mm/madvise.c has the brief description about all MADV_ flags, added the
description for the newly added MADV_WIPEONFORK and MADV_KEEPONFORK.

Although man page has the similar information, but it'd better to keep the
consistency with other flags.

Signed-off-by: Yang Shi <yang.s@alibaba-inc.com>
---
 mm/madvise.c | 7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff --git a/mm/madvise.c b/mm/madvise.c
index 21261ff..c6bf572 100644
--- a/mm/madvise.c
+++ b/mm/madvise.c
@@ -749,6 +749,9 @@ static int madvise_inject_error(int behavior,
  *  MADV_DONTFORK - omit this area from child's address space when forking:
  *		typically, to avoid COWing pages pinned by get_user_pages().
  *  MADV_DOFORK - cancel MADV_DONTFORK: no longer omit this area when forking.
+ *  MADV_WIPEONFORK - present the child process with zero-filled memory in this
+ *              range after a fork.
+ *  MADV_KEEPONFORK - undo the effect of MADV_WIPEONFORK
  *  MADV_HWPOISON - trigger memory error handler as if the given memory range
  *		were corrupted by unrecoverable hardware memory failure.
  *  MADV_SOFT_OFFLINE - try to soft-offline the given range of memory.
@@ -769,7 +772,9 @@ static int madvise_inject_error(int behavior,
  *  zero    - success
  *  -EINVAL - start + len < 0, start is not page-aligned,
  *		"behavior" is not a valid value, or application
- *		is attempting to release locked or shared pages.
+ *		is attempting to release locked or shared pages,
+ *		or the specified address range includes file, Huge TLB,
+ *		MAP_SHARED or VMPFNMAP range.
  *  -ENOMEM - addresses in the specified range are not currently
  *		mapped, or are outside the AS of the process.
  *  -EIO    - an I/O error occurred while paging in data.
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
