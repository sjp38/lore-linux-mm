Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f179.google.com (mail-ob0-f179.google.com [209.85.214.179])
	by kanga.kvack.org (Postfix) with ESMTP id B02716B0038
	for <linux-mm@kvack.org>; Wed,  2 Dec 2015 04:33:27 -0500 (EST)
Received: by obcse5 with SMTP id se5so24449850obc.3
        for <linux-mm@kvack.org>; Wed, 02 Dec 2015 01:33:27 -0800 (PST)
Received: from mail-ob0-x22f.google.com (mail-ob0-x22f.google.com. [2607:f8b0:4003:c01::22f])
        by mx.google.com with ESMTPS id k17si2012006oib.66.2015.12.02.01.33.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 02 Dec 2015 01:33:27 -0800 (PST)
Received: by obbbj7 with SMTP id bj7so28075064obb.1
        for <linux-mm@kvack.org>; Wed, 02 Dec 2015 01:33:27 -0800 (PST)
Date: Wed, 2 Dec 2015 01:33:03 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH] mm: fix kerneldoc on mem_cgroup_replace_page
In-Reply-To: <alpine.LSU.2.11.1510182152560.2481@eggly.anvils>
Message-ID: <alpine.LSU.2.11.1512020130410.32078@eggly.anvils>
References: <alpine.LSU.2.11.1510182132470.2481@eggly.anvils> <alpine.LSU.2.11.1510182152560.2481@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Hugh Dickins <hughd@google.com>, Christoph Lameter <cl@linux.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Greg Thelen <gthelen@google.com>, linux-mm@kvack.org

Whoops, I missed removing the kerneldoc comment of the lrucare arg
removed from mem_cgroup_replace_page; but it's a good comment, keep it.

Signed-off-by: Hugh Dickins <hughd@google.com>
---

 mm/memcontrol.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- 4.4-rc3/mm/memcontrol.c	2015-11-15 21:06:56.505752425 -0800
+++ linux/mm/memcontrol.c	2015-11-30 17:40:42.510193391 -0800
@@ -5511,11 +5511,11 @@ void mem_cgroup_uncharge_list(struct lis
  * mem_cgroup_replace_page - migrate a charge to another page
  * @oldpage: currently charged page
  * @newpage: page to transfer the charge to
- * @lrucare: either or both pages might be on the LRU already
  *
  * Migrate the charge from @oldpage to @newpage.
  *
  * Both pages must be locked, @newpage->mapping must be set up.
+ * Either or both pages might be on the LRU already.
  */
 void mem_cgroup_replace_page(struct page *oldpage, struct page *newpage)
 {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
