Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 01CCE6B0011
	for <linux-mm@kvack.org>; Fri,  6 May 2011 12:03:41 -0400 (EDT)
Received: by pxi9 with SMTP id 9so2468894pxi.14
        for <linux-mm@kvack.org>; Fri, 06 May 2011 09:03:39 -0700 (PDT)
Subject: [PATCH]mm/migrate.c: clean up comment
From: "Figo.zhang" <figo1802@gmail.com>
Date: Sat, 07 May 2011 00:03:11 +0800
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Message-ID: <1304697799.2450.9.camel@figo-desktop>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: lkml <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: Andrew Morton <akpm@osdl.org>


clean up comment. prepare cgroup return 0 or -ENOMEN, others return -EAGAIN.
avoid conflict meanings.

Signed-off-by: Figo.zhang <figo1802@gmail.com>
---
mm/migrate.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/mm/migrate.c b/mm/migrate.c
index 34132f8..d65b351 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -647,7 +647,6 @@ static int unmap_and_move(new_page_t get_new_page, unsigned long private,
 		if (unlikely(split_huge_page(page)))
 			goto move_newpage;
 
-	/* prepare cgroup just returns 0 or -ENOMEM */
 	rc = -EAGAIN;
 
 	if (!trylock_page(page)) {
@@ -687,7 +686,7 @@ static int unmap_and_move(new_page_t get_new_page, unsigned long private,
 		goto unlock;
 	}
 
-	/* charge against new page */
+	/* charge against new page, return 0 or -ENOMEM */
 	charge = mem_cgroup_prepare_migration(page, newpage, &mem, GFP_KERNEL);
 	if (charge == -ENOMEM) {
 		rc = -ENOMEM;


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
