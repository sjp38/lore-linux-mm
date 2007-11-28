Received: from [99.236.101.138] (helo=crashcourse.ca)
	by astoria.ccjclearline.com with esmtpsa (TLSv1:AES256-SHA:256)
	(Exim 4.68)
	(envelope-from <rpjday@crashcourse.ca>)
	id 1IxJpv-0003sz-Jt
	for linux-mm@kvack.org; Wed, 28 Nov 2007 05:08:07 -0500
Date: Wed, 28 Nov 2007 05:06:09 -0500 (EST)
From: "Robert P. J. Day" <rpjday@crashcourse.ca>
Subject: [PATCH] MM: Standardize inclusion of linux header file to use
 "<>".
Message-ID: <alpine.LFD.0.9999.0711280503480.4130@localhost.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Signed-off-by: Robert P. J. Day <rpjday@crashcourse.ca>

---

  outside of the UML code, there are very few instances of including
linux header files that use quotes instead of angle brackets, and it
would be nice to make all of that standard.


diff --git a/mm/slab.c b/mm/slab.c
index c31cd36..12b1bf3 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -333,7 +333,7 @@ static __always_inline int index_of(const size_t size)
 		return i; \
 	else \
 		i++;
-#include "linux/kmalloc_sizes.h"
+#include <linux/kmalloc_sizes.h>
 #undef CACHE
 		__bad_size();
 	} else
========================================================================
Robert P. J. Day
Linux Consulting, Training and Annoying Kernel Pedantry
Waterloo, Ontario, CANADA

http://crashcourse.ca
========================================================================

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
