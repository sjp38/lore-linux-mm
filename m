Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 39CFF6B0012
	for <linux-mm@kvack.org>; Fri,  6 May 2011 14:28:06 -0400 (EDT)
Received: by qyk2 with SMTP id 2so5714977qyk.14
        for <linux-mm@kvack.org>; Fri, 06 May 2011 11:28:04 -0700 (PDT)
MIME-Version: 1.0
Date: Fri, 6 May 2011 21:28:04 +0300
Message-ID: <BANLkTi=Jdxu7am8-jhJbT0t-uhNmW4zWhw@mail.gmail.com>
Subject: [PATCH] slub: slub_def.h: needs additional check for "index"
From: Maxin John <maxin.john@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

In slub_def.h file, the kmalloc_index() may return -1 for some special cases.
If that negative return value gets assigned to "index", it might lead to issues
later as the variable "index" is used as index to array "kmalloc_caches" in :

return kmalloc_caches[index];

Please let me know your comments.

Signed-off-by: Maxin B. John <maxin.john@gmail.com>
---
diff --git a/include/linux/slub_def.h b/include/linux/slub_def.h
index 45ca123..3db4b33 100644
--- a/include/linux/slub_def.h
+++ b/include/linux/slub_def.h
@@ -211,7 +211,7 @@ static __always_inline struct kmem_cache
*kmalloc_slab(size_t size)
 {
        int index = kmalloc_index(size);

-       if (index == 0)
+       if (index <= 0)
                return NULL;

        return kmalloc_caches[index];

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
