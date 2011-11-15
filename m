Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 0AA1D6B006C
	for <linux-mm@kvack.org>; Tue, 15 Nov 2011 18:04:03 -0500 (EST)
Received: by ywe9 with SMTP id 9so548601ywe.2
        for <linux-mm@kvack.org>; Tue, 15 Nov 2011 15:04:01 -0800 (PST)
Message-Id: <201111152304.pAFN40e9015135@wpaz5.hot.corp.google.com>
Subject: [patch 2/2] slub: add taint flag outputting to debug paths
From: akpm@linux-foundation.org
Date: Tue, 15 Nov 2011 15:04:00 -0800
MIME-Version: 1.0
Content-Type: text/plain; charset=ASCII
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: penberg@cs.helsinki.fi
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, davej@redhat.com

From: Dave Jones <davej@redhat.com>
Subject: slub: add taint flag outputting to debug paths

When we get corruption reports, it's useful to see if the kernel was
tainted, to rule out problems we can't do anything about.

Signed-off-by: Dave Jones <davej@redhat.com>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 mm/slub.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff -puN mm/slub.c~slub-add-taint-flag-outputting-to-debug-paths mm/slub.c
--- a/mm/slub.c~slub-add-taint-flag-outputting-to-debug-paths
+++ a/mm/slub.c
@@ -570,7 +570,7 @@ static void slab_bug(struct kmem_cache *
 	va_end(args);
 	printk(KERN_ERR "========================================"
 			"=====================================\n");
-	printk(KERN_ERR "BUG %s: %s\n", s->name, buf);
+	printk(KERN_ERR "BUG %s (%s): %s\n", s->name, print_tainted(), buf);
 	printk(KERN_ERR "----------------------------------------"
 			"-------------------------------------\n\n");
 }
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
