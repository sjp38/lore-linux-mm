Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx194.postini.com [74.125.245.194])
	by kanga.kvack.org (Postfix) with SMTP id 9C6776B004A
	for <linux-mm@kvack.org>; Thu, 12 Apr 2012 16:44:30 -0400 (EDT)
From: H Hartley Sweeten <hartleys@visionengravers.com>
Subject: [PATCH] mm: page-writeback.c: local functions should not be exposed globally
Date: Thu, 12 Apr 2012 13:44:20 -0700
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-ID: <201204121344.20613.hartleys@visionengravers.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux Kernel <linux-kernel@vger.kernel.org>
Cc: linux-mm@kvack.org

The function global_dirtyable_memory is only referenced in this file and
should be marked static to prevent it from being exposed globally.

This quiets the sparse warning:

warning: symbol 'global_dirtyable_memory' was not declared. Should it be static?

Signed-off-by: H Hartley Sweeten <hsweeten@visionengravers.com>

---

diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index 26adea8..9dec97f 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -204,7 +204,7 @@ static unsigned long highmem_dirtyable_memory(unsigned long total)
  * Returns the global number of pages potentially available for dirty
  * page cache.  This is the base value for the global dirty limits.
  */
-unsigned long global_dirtyable_memory(void)
+static unsigned long global_dirtyable_memory(void)
 {
 	unsigned long x;
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
