Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id A3D086B0074
	for <linux-mm@kvack.org>; Fri, 25 Nov 2011 07:20:35 -0500 (EST)
Received: by wwf22 with SMTP id 22so2225008wwf.2
        for <linux-mm@kvack.org>; Fri, 25 Nov 2011 04:20:31 -0800 (PST)
MIME-Version: 1.0
Date: Fri, 25 Nov 2011 20:20:31 +0800
Message-ID: <CAJd=RBChfVC4hUKvO5ks0+NxahTgibdivLotw3VpAa7_-r8_+g@mail.gmail.com>
Subject: [PATCH] mm: migration: pair unlock_page and lock_page when migrating
 huge pages
From: Hillf Danton <dhillf@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

Skip unlocking page if fail to lock, then lock and unlock are paired.

Signed-off-by: Hillf Danton <dhillf@gmail.com>
---

--- a/mm/migrate.c	Fri Nov 25 20:11:14 2011
+++ b/mm/migrate.c	Fri Nov 25 20:21:26 2011
@@ -869,9 +869,9 @@ static int unmap_and_move_huge_page(new_

 	if (anon_vma)
 		put_anon_vma(anon_vma);
-out:
 	unlock_page(hpage);

+out:
 	if (rc != -EAGAIN) {
 		list_del(&hpage->lru);
 		put_page(hpage);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
