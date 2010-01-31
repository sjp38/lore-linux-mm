Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 6C3546B007B
	for <linux-mm@kvack.org>; Sun, 31 Jan 2010 15:02:25 -0500 (EST)
From: Joe Perches <joe@perches.com>
Subject: [PATCH 09/10] mm/slab.c: Fix continuation line formats
Date: Sun, 31 Jan 2010 12:02:11 -0800
Message-Id: <9d64ab1e1d69c750d53a398e09fe5da2437668c5.1264967500.git.joe@perches.com>
In-Reply-To: <cover.1264967493.git.joe@perches.com>
References: <cover.1264967493.git.joe@perches.com>
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org
Cc: Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Matt Mackall <mpm@selenic.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

String constants that are continued on subsequent lines with \
are not good.

The characters between seq_printf elements are tabs.
That was probably not intentional, but isn't being changed.
It's behind an #ifdef, so it could probably become a single space.

Signed-off-by: Joe Perches <joe@perches.com>
---
 mm/slab.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/slab.c b/mm/slab.c
index 7451bda..9964619 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -4228,8 +4228,8 @@ static int s_show(struct seq_file *m, void *p)
 		unsigned long node_frees = cachep->node_frees;
 		unsigned long overflows = cachep->node_overflow;
 
-		seq_printf(m, " : globalstat %7lu %6lu %5lu %4lu \
-				%4lu %4lu %4lu %4lu %4lu", allocs, high, grown,
+		seq_printf(m, " : globalstat %7lu %6lu %5lu %4lu 				%4lu %4lu %4lu %4lu %4lu",
+				allocs, high, grown,
 				reaped, errors, max_freeable, node_allocs,
 				node_frees, overflows);
 	}
-- 
1.6.6.rc0.57.gad7a

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
