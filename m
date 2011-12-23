Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx137.postini.com [74.125.245.137])
	by kanga.kvack.org (Postfix) with SMTP id 95F196B004D
	for <linux-mm@kvack.org>; Fri, 23 Dec 2011 08:41:10 -0500 (EST)
Received: by wibhq12 with SMTP id hq12so4351349wib.14
        for <linux-mm@kvack.org>; Fri, 23 Dec 2011 05:41:09 -0800 (PST)
MIME-Version: 1.0
Date: Fri, 23 Dec 2011 21:41:08 +0800
Message-ID: <CAJd=RBCXTp0GrMGw+MBDdj0K15+L5v+O2t6EcDghFk34aNwt1g@mail.gmail.com>
Subject: [PATCH] mm: hugetlb: add might_sleep() for gigantic page
From: Hillf Danton <dhillf@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

From: Hillf Danton <dhillf@gmail.com>
Subject: [PATCH] mm: hugetlb: add might_sleep() for gigantic page

Like the case of huge page, might_sleep() is added for gigantic page, then
both are treated in same way.

Cc: Michal Hocko <mhocko@suse.cz>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Hillf Danton <dhillf@gmail.com>
---

--- a/mm/hugetlb.c	Tue Dec 20 21:26:30 2011
+++ b/mm/hugetlb.c	Fri Dec 23 21:19:18 2011
@@ -401,6 +401,7 @@ static void copy_gigantic_page(struct pa
 	struct page *dst_base = dst;
 	struct page *src_base = src;

+	might_sleep();
 	for (i = 0; i < pages_per_huge_page(h); ) {
 		cond_resched();
 		copy_highpage(dst, src);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
