Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 6F7566B01C5
	for <linux-mm@kvack.org>; Fri, 26 Mar 2010 22:28:06 -0400 (EDT)
From: Joe Perches <joe@perches.com>
Subject: [PATCH 9/9] mm: Fix continuation lines
Date: Fri, 26 Mar 2010 19:27:58 -0700
Message-Id: <c53e66323c5898fe17221c0813779862189abce3.1269655209.git.joe@perches.com>
In-Reply-To: <cover.1269655208.git.joe@perches.com>
References: <cover.1269655208.git.joe@perches.com>
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org
Cc: Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Matt Mackall <mpm@selenic.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Signed-off-by: Joe Perches <joe@perches.com>
---
 mm/slab.c |    9 +++++----
 1 files changed, 5 insertions(+), 4 deletions(-)

diff --git a/mm/slab.c b/mm/slab.c
index a9f325b..ceb4e3a 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -4227,10 +4227,11 @@ static int s_show(struct seq_file *m, void *p)
 		unsigned long node_frees = cachep->node_frees;
 		unsigned long overflows = cachep->node_overflow;
 
-		seq_printf(m, " : globalstat %7lu %6lu %5lu %4lu \
-				%4lu %4lu %4lu %4lu %4lu", allocs, high, grown,
-				reaped, errors, max_freeable, node_allocs,
-				node_frees, overflows);
+		seq_printf(m, " : globalstat %7lu %6lu %5lu %4lu "
+			   "%4lu %4lu %4lu %4lu %4lu",
+			   allocs, high, grown,
+			   reaped, errors, max_freeable, node_allocs,
+			   node_frees, overflows);
 	}
 	/* cpu stats */
 	{
-- 
1.7.0.14.g7e948

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
