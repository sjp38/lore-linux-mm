Received: by ti-out-0910.google.com with SMTP id j3so861329tid.8
        for <linux-mm@kvack.org>; Tue, 05 Aug 2008 22:43:31 -0700 (PDT)
From: MinChan Kim <minchan.kim@gmail.com>
Subject: [PATCH][migration] Trivial cleanup
Date: Wed, 6 Aug 2008 14:42:54 +0900
References: <20080805135559.GQ26461@parisc-linux.org> <20080805092209.830f5d0a.akpm@linux-foundation.org>
In-Reply-To: <20080805092209.830f5d0a.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200808061442.55159.minchan.kim@gmail.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux-foundation.org>
Cc: linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

This is a trivial cleanup.
Anyone doesn't use it any more.  

Signed-off-by: MinChan Kim <minchan.kim@gmail.com>
---
 mm/mempolicy.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index 97020c0..36f4257 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -808,7 +808,6 @@ static int migrate_to_node(struct mm_struct *mm, int 
source, int dest,
 int do_migrate_pages(struct mm_struct *mm,
 	const nodemask_t *from_nodes, const nodemask_t *to_nodes, int flags)
 {
-	LIST_HEAD(pagelist);
 	int busy = 0;
 	int err = 0;
 	nodemask_t tmp;
-- 
1.5.4.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
