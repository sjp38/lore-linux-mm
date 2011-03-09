Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 975778D0039
	for <linux-mm@kvack.org>; Wed,  9 Mar 2011 01:34:47 -0500 (EST)
Received: by iwl42 with SMTP id 42so289063iwl.14
        for <linux-mm@kvack.org>; Tue, 08 Mar 2011 22:34:46 -0800 (PST)
From: Namhyung Kim <namhyung@gmail.com>
Subject: [PATCH] vmalloc: remove confusing comment on vwrite()
Date: Wed,  9 Mar 2011 15:34:36 +0900
Message-Id: <1299652476-5185-1-git-send-email-namhyung@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

KM_USER1 is never used for vwrite() path so the caller
doesn't need to guarantee it is not used. Only the caller
should guarantee is KM_USER0 and it is commented already.

Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Signed-off-by: Namhyung Kim <namhyung@gmail.com>
---
 mm/vmalloc.c |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index f9b166732e70..2828b6122bd4 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -1951,8 +1951,6 @@ finished:
  *	should know vmalloc() area is valid and can use memcpy().
  *	This is for routines which have to access vmalloc area without
  *	any informaion, as /dev/kmem.
- *
- *	The caller should guarantee KM_USER1 is not used.
  */
 
 long vwrite(char *buf, char *addr, unsigned long count)
-- 
1.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
