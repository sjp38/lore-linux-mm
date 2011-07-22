Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 255E76B00F6
	for <linux-mm@kvack.org>; Thu, 21 Jul 2011 20:49:56 -0400 (EDT)
Received: from int-mx01.intmail.prod.int.phx2.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id p6M0ntbE021226
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-mm@kvack.org>; Thu, 21 Jul 2011 20:49:55 -0400
Received: from gelk.kernelslacker.org (ovpn-113-43.phx2.redhat.com [10.3.113.43])
	by int-mx01.intmail.prod.int.phx2.redhat.com (8.13.8/8.13.8) with ESMTP id p6M0nshY031289
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <linux-mm@kvack.org>; Thu, 21 Jul 2011 20:49:54 -0400
Received: from gelk.kernelslacker.org (gelk [127.0.0.1])
	by gelk.kernelslacker.org (8.14.5/8.14.4) with ESMTP id p6M0nsnw020754
	for <linux-mm@kvack.org>; Thu, 21 Jul 2011 20:49:54 -0400
Received: (from davej@localhost)
	by gelk.kernelslacker.org (8.14.5/8.14.5/Submit) id p6M0nruB020753
	for linux-mm@kvack.org; Thu, 21 Jul 2011 20:49:53 -0400
Date: Thu, 21 Jul 2011 20:49:53 -0400
From: Dave Jones <davej@redhat.com>
Subject: Add taint flag outputting to slub debug paths.
Message-ID: <20110722004953.GB20700@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org

When we get corruption reports, it's useful to see if the kernel
was tainted, to rule out problems we can't do anything about.

Signed-off-by: Dave Jones <davej@redhat.com>

diff --git a/mm/slub.c b/mm/slub.c
index 819f056..8eff0f4 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -433,7 +433,7 @@ static void slab_bug(struct kmem_cache *s, char *fmt, ...)
 	va_end(args);
 	printk(KERN_ERR "========================================"
 			"=====================================\n");
-	printk(KERN_ERR "BUG %s: %s\n", s->name, buf);
+	printk(KERN_ERR "BUG %s (%s): %s\n", s->name, print_tainted(), buf);
 	printk(KERN_ERR "----------------------------------------"
 			"-------------------------------------\n\n");
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
