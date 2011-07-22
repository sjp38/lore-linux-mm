Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 980C76B00F2
	for <linux-mm@kvack.org>; Thu, 21 Jul 2011 20:47:29 -0400 (EDT)
Received: from int-mx10.intmail.prod.int.phx2.redhat.com (int-mx10.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id p6M0lS7l020572
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-mm@kvack.org>; Thu, 21 Jul 2011 20:47:28 -0400
Received: from gelk.kernelslacker.org (ovpn-113-43.phx2.redhat.com [10.3.113.43])
	by int-mx10.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id p6M0lRZ2026549
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <linux-mm@kvack.org>; Thu, 21 Jul 2011 20:47:27 -0400
Received: from gelk.kernelslacker.org (gelk [127.0.0.1])
	by gelk.kernelslacker.org (8.14.5/8.14.4) with ESMTP id p6M0lQ1P020467
	for <linux-mm@kvack.org>; Thu, 21 Jul 2011 20:47:26 -0400
Received: (from davej@localhost)
	by gelk.kernelslacker.org (8.14.5/8.14.5/Submit) id p6M0lQD6020466
	for linux-mm@kvack.org; Thu, 21 Jul 2011 20:47:26 -0400
Date: Thu, 21 Jul 2011 20:47:26 -0400
From: Dave Jones <davej@redhat.com>
Subject: output a list of loaded modules when we hit bad_page()
Message-ID: <20110722004726.GC19615@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org

When we get a bad_page bug report, it's useful to see what
modules the user had loaded.

Signed-off-by: Dave Jones <davej@redhat.com>

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 4e8985a..70d0853 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -318,6 +318,7 @@ static void bad_page(struct page *page)
 		current->comm, page_to_pfn(page));
 	dump_page(page);
 
+	print_modules();
 	dump_stack();
 out:
 	/* Leave bad fields for debug, except PageBuddy could make trouble */


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
