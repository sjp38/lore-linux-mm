Date: Sun, 5 Oct 2008 03:28:34 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: [PATCH next 3/3] slub defrag: slabinfo help trivia
In-Reply-To: <Pine.LNX.4.64.0810050319001.22004@blonde.site>
Message-ID: <Pine.LNX.4.64.0810050327110.22004@blonde.site>
References: <Pine.LNX.4.64.0810050319001.22004@blonde.site>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Fix typo on --display-defrag line of slabinfo's help message;
fix misaligning tabs to spaces on two other lines of that message.

Signed-off-by: Hugh Dickins <hugh@veritas.com>
---

 Documentation/vm/slabinfo.c |    6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

--- 2.6.27-rc7-mmotm/Documentation/vm/slabinfo.c	2008-09-26 13:18:44.000000000 +0100
+++ linux/Documentation/vm/slabinfo.c	2008-10-04 19:47:40.000000000 +0100
@@ -117,14 +117,14 @@ void usage(void)
 		"-e|--empty             Show empty slabs\n"
 		"-f|--first-alias       Show first alias\n"
 		"-F|--defrag            Show defragmentable caches\n"
-		"-G:--display-defrag    Display defrag counters\n"
+		"-G|--display-defrag    Display defrag counters\n"
 		"-h|--help              Show usage information\n"
 		"-i|--inverted          Inverted list\n"
 		"-l|--slabs             Show slabs\n"
 		"-n|--numa              Show NUMA information\n"
-		"-o|--ops		Show kmem_cache_ops\n"
+		"-o|--ops               Show kmem_cache_ops\n"
 		"-s|--shrink            Shrink slabs\n"
-		"-r|--report		Detailed report on single slabs\n"
+		"-r|--report            Detailed report on single slabs\n"
 		"-S|--Size              Sort by size\n"
 		"-t|--tracking          Show alloc/free information\n"
 		"-T|--Totals            Show summary information\n"

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
