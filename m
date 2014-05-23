Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f41.google.com (mail-pb0-f41.google.com [209.85.160.41])
	by kanga.kvack.org (Postfix) with ESMTP id 438AC6B0035
	for <linux-mm@kvack.org>; Fri, 23 May 2014 17:16:00 -0400 (EDT)
Received: by mail-pb0-f41.google.com with SMTP id uo5so4664419pbc.14
        for <linux-mm@kvack.org>; Fri, 23 May 2014 14:15:59 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id qd5si5442210pbb.211.2014.05.23.14.15.59
        for <linux-mm@kvack.org>;
        Fri, 23 May 2014 14:15:59 -0700 (PDT)
From: Andi Kleen <andi@firstfloor.org>
Subject: [PATCH] Pass on hwpoison maintainership to Naoya Noriguchi
Date: Fri, 23 May 2014 14:15:39 -0700
Message-Id: <1400879739-12614-1-git-send-email-andi@firstfloor.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: torvalds@linux-foundation.org
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andi Kleen <ak@linux.intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

From: Andi Kleen <ak@linux.intel.com>

Noriguchi-san has done most of the work on hwpoison in the last years
and he also does most of the reviewing. So I'm passing on the hwpoison
maintainership to him.

Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Signed-off-by: Andi Kleen <ak@linux.intel.com>
---
 MAINTAINERS | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/MAINTAINERS b/MAINTAINERS
index c596b74..e84d510 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -4017,9 +4017,8 @@ S:	Odd Fixes
 F:	drivers/media/usb/hdpvr/
 
 HWPOISON MEMORY FAILURE HANDLING
-M:	Andi Kleen <andi@firstfloor.org>
+M:	Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
 L:	linux-mm@kvack.org
-T:	git git://git.kernel.org/pub/scm/linux/kernel/git/ak/linux-mce-2.6.git hwpoison
 S:	Maintained
 F:	mm/memory-failure.c
 F:	mm/hwpoison-inject.c
-- 
1.9.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
