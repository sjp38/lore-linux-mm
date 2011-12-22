Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx176.postini.com [74.125.245.176])
	by kanga.kvack.org (Postfix) with SMTP id 3BEFD6B004D
	for <linux-mm@kvack.org>; Wed, 21 Dec 2011 22:16:05 -0500 (EST)
Received: by iacb35 with SMTP id b35so14341643iac.14
        for <linux-mm@kvack.org>; Wed, 21 Dec 2011 19:16:04 -0800 (PST)
Message-ID: <4EF2A0ED.8080308@gmail.com>
Date: Thu, 22 Dec 2011 11:15:57 +0800
From: "nai.xia" <nai.xia@gmail.com>
MIME-Version: 1.0
Subject: [PATCH] radix_tree: delete orphaned macro radix_tree_indirect_to_ptr
References: <alpine.LSU.2.00.1112182234310.1503@eggly.anvils> <20111221050740.GD23662@dastard> <alpine.LSU.2.00.1112202218490.4026@eggly.anvils> <20111221221527.GE23662@dastard> <alpine.LSU.2.00.1112211555430.25868@eggly.anvils>
In-Reply-To: <alpine.LSU.2.00.1112211555430.25868@eggly.anvils>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Dave Chinner <david@fromorbit.com>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Seems nobody has been using the macro radix_tree_indirect_to_ptr()
since long time ago. Delete it.

Signed-off-by: Nai Xia <nai.xia@gmail.com>
---
  include/linux/radix-tree.h |    3 ---
  1 files changed, 0 insertions(+), 3 deletions(-)

--- a/include/linux/radix-tree.h
+++ b/include/linux/radix-tree.h
@@ -49,9 +49,6 @@
  #define RADIX_TREE_EXCEPTIONAL_ENTRY	2
  #define RADIX_TREE_EXCEPTIONAL_SHIFT	2

-#define radix_tree_indirect_to_ptr(ptr) \
-	radix_tree_indirect_to_ptr((void __force *)(ptr))
-
  static inline int radix_tree_is_indirect_ptr(void *ptr)
  {
  	return (int)((unsigned long)ptr & RADIX_TREE_INDIRECT_PTR);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
