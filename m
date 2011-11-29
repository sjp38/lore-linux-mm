Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 43A3D6B004D
	for <linux-mm@kvack.org>; Wed, 30 Nov 2011 03:17:09 -0500 (EST)
Subject: [PATCH] mm: Use kcalloc instead of kzalloc to allocate array
From: Thomas Meyer <thomas@m3y3r.de>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Date: Tue, 29 Nov 2011 22:08:00 +0100
Message-ID: <1322600880.1534.349.camel@localhost.localdomain>
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org

The advantage of kcalloc is, that will prevent integer overflows which could
result from the multiplication of number of elements and size and it is also
a bit nicer to read.

The semantic patch that makes this change is available
in https://lkml.org/lkml/2011/11/25/107

Signed-off-by: Thomas Meyer <thomas@m3y3r.de>
---

diff -u -p a/mm/vmalloc.c b/mm/vmalloc.c
--- a/mm/vmalloc.c 2011-11-28 19:36:48.210120310 +0100
+++ b/mm/vmalloc.c 2011-11-28 20:06:49.925235983 +0100
@@ -2348,8 +2348,8 @@ struct vm_struct **pcpu_get_vm_areas(con
 		return NULL;
 	}
 
-	vms = kzalloc(sizeof(vms[0]) * nr_vms, GFP_KERNEL);
-	vas = kzalloc(sizeof(vas[0]) * nr_vms, GFP_KERNEL);
+	vms = kcalloc(nr_vms, sizeof(vms[0]), GFP_KERNEL);
+	vas = kcalloc(nr_vms, sizeof(vas[0]), GFP_KERNEL);
 	if (!vas || !vms)
 		goto err_free;
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
