Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 204916B006E
	for <linux-mm@kvack.org>; Wed,  9 Nov 2011 00:18:17 -0500 (EST)
Received: by iaae16 with SMTP id e16so1977531iaa.14
        for <linux-mm@kvack.org>; Tue, 08 Nov 2011 21:18:14 -0800 (PST)
Date: Tue, 8 Nov 2011 21:18:10 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH mm] mm: memcg: remove unused node/section info from pc->flags
 fix
In-Reply-To: <1320787408-22866-11-git-send-email-jweiner@redhat.com>
Message-ID: <alpine.LSU.2.00.1111082108160.1250@sister.anvils>
References: <1320787408-22866-1-git-send-email-jweiner@redhat.com> <1320787408-22866-11-git-send-email-jweiner@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <jweiner@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, "Kirill A. Shutemov" <kirill@shutemov.name>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <bsingharora@gmail.com>, Ying Han <yinghan@google.com>, Greg Thelen <gthelen@google.com>, Michel Lespinasse <walken@google.com>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Christoph Hellwig <hch@infradead.org>, Stephen Rothwell <sfr@canb.auug.org.au>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Fix non-CONFIG_SPARSEMEM build, which failed with
mm/page_cgroup.c: In function `alloc_node_page_cgroup':
mm/page_cgroup.c:44: error: `start_pfn' undeclared (first use in this function)

Signed-off-by: Hugh Dickins <hughd@google.com>
---
For folding into mm-memcg-remove-unused-node-section-info-from-pc-flags.patch

 mm/page_cgroup.c |    2 --
 1 file changed, 2 deletions(-)

Hannes: heartfelt thanks to you for this great work - Hugh

--- 3.2-rc1-jw/mm/page_cgroup.c	2011-11-08 20:25:24.678395000 -0800
+++ linux/mm/page_cgroup.c	2011-11-08 20:42:05.687358464 -0800
@@ -41,9 +41,7 @@ static int __init alloc_node_page_cgroup
 	unsigned long table_size;
 	unsigned long nr_pages;
 
-	start_pfn = NODE_DATA(nid)->node_start_pfn;
 	nr_pages = NODE_DATA(nid)->node_spanned_pages;
-
 	if (!nr_pages)
 		return 0;
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
