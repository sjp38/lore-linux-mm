Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 5A6AE6B0027
	for <linux-mm@kvack.org>; Tue, 10 May 2011 09:13:41 -0400 (EDT)
Received: by pvc12 with SMTP id 12so3910299pvc.14
        for <linux-mm@kvack.org>; Tue, 10 May 2011 06:13:39 -0700 (PDT)
Subject: [PATCH v2]mm/migrate.c: clean up comment
From: "Figo.zhang" <figo1802@gmail.com>
Date: Tue, 10 May 2011 21:13:08 +0800
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Message-ID: <1305033196.6993.1.camel@figo-desktop>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: lkml <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

clean up comment. prepare cgroup return 0 or -ENOMEN, others return -EAGAIN.
avoid conflict meanings.

Signed-off-by: Figo.zhang <figo1802@gmail.com>
---

 mm/migrate.c |    6 +++++-
 1 files changed, 5 insertions(+), 1 deletions(-)

diff --git a/mm/migrate.c b/mm/migrate.c
index 34132f8..5f137cd 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -624,6 +624,11 @@ static int move_to_new_page(struct page *newpage, struct page *page,
 /*
  * Obtain the lock on page, remove all ptes and migrate the page
  * to the newly allocated page in newpage.
+ * Return values:
+ * 0       - success
+ * -ENOMEM - error code
+ * -EBUSY  - error code
+ * -EAGAIN - try again
  */
 static int unmap_and_move(new_page_t get_new_page, unsigned long private,
 			struct page *page, int force, bool offlining, bool sync)
@@ -647,7 +652,6 @@ static int unmap_and_move(new_page_t get_new_page, unsigned long private,
 		if (unlikely(split_huge_page(page)))
 			goto move_newpage;
 
-	/* prepare cgroup just returns 0 or -ENOMEM */
 	rc = -EAGAIN;
 
 	if (!trylock_page(page)) {


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
