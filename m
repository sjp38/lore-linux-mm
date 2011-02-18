Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 423738D0039
	for <linux-mm@kvack.org>; Thu, 17 Feb 2011 21:08:58 -0500 (EST)
Received: from kpbe17.cbf.corp.google.com (kpbe17.cbf.corp.google.com [172.25.105.81])
	by smtp-out.google.com with ESMTP id p1I28nV1007366
	for <linux-mm@kvack.org>; Thu, 17 Feb 2011 18:08:49 -0800
Received: from iwn3 (iwn3.prod.google.com [10.241.68.67])
	by kpbe17.cbf.corp.google.com with ESMTP id p1I28llK005971
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 17 Feb 2011 18:08:48 -0800
Received: by iwn3 with SMTP id 3so3412841iwn.26
        for <linux-mm@kvack.org>; Thu, 17 Feb 2011 18:08:47 -0800 (PST)
From: Michel Lespinasse <walken@google.com>
Subject: [PATCH] mm: remove unused TestSetPageLocked() interface
Date: Thu, 17 Feb 2011 18:08:32 -0800
Message-Id: <1297994912-27555-1-git-send-email-walken@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: Linux-kernel <linux-kernel@google.com>

TestSetPageLocked() isn't being used anywhere. Also, using it would
likely be an error, since the proper interface trylock_page() provides
stronger ordering guarantees.

Signed-off-by: Michel Lespinasse <walken@google.com>
---
 include/linux/page-flags.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/include/linux/page-flags.h b/include/linux/page-flags.h
index 0db8037..811183d 100644
--- a/include/linux/page-flags.h
+++ b/include/linux/page-flags.h
@@ -196,7 +196,7 @@ static inline int __TestClearPage##uname(struct page *page) { return 0; }
 
 struct page;	/* forward declaration */
 
-TESTPAGEFLAG(Locked, locked) TESTSETFLAG(Locked, locked)
+TESTPAGEFLAG(Locked, locked)
 PAGEFLAG(Error, error) TESTCLEARFLAG(Error, error)
 PAGEFLAG(Referenced, referenced) TESTCLEARFLAG(Referenced, referenced)
 PAGEFLAG(Dirty, dirty) TESTSCFLAG(Dirty, dirty) __CLEARPAGEFLAG(Dirty, dirty)
-- 
1.7.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
