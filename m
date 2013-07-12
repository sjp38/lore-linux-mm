Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx159.postini.com [74.125.245.159])
	by kanga.kvack.org (Postfix) with SMTP id E19586B0032
	for <linux-mm@kvack.org>; Thu, 11 Jul 2013 20:24:48 -0400 (EDT)
Message-ID: <51DF4C94.3060103@asianux.com>
Date: Fri, 12 Jul 2013 08:23:48 +0800
From: Chen Gang <gang.chen@asianux.com>
MIME-Version: 1.0
Subject: [PATCH v2] mm/slub.c: remove 'per_cpu' which is useless variable
References: <51DA734B.4060608@asianux.com> <51DE549F.9070505@kernel.org> <51DE55C9.1060908@asianux.com> <0000013fce9f5b32-7d62f3c5-bb35-4dd9-ab19-d72bae4b5bdc-000000@email.amazonses.com> <51DEF935.4040804@kernel.org> <0000013fcf608df8-457e2029-51f9-4e49-9992-bf399a97d953-000000@email.amazonses.com> <51DF4540.8060700@asianux.com>
In-Reply-To: <51DF4540.8060700@asianux.com>
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>, mpm@selenic.com, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>

Remove 'per_cpu', since it is useless now after the patch: "205ab99
slub: Update statistics handling for variable order slabs". And the
partial list is handled in the same way as the per cpu slab.

Signed-off-by: Chen Gang <gang.chen@asianux.com>
---
 mm/slub.c |    6 +-----
 1 files changed, 1 insertions(+), 5 deletions(-)

diff --git a/mm/slub.c b/mm/slub.c
index 2b02d66..c94a03f 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -4271,12 +4271,10 @@ static ssize_t show_slab_objects(struct kmem_cache *s,
 	int node;
 	int x;
 	unsigned long *nodes;
-	unsigned long *per_cpu;
 
-	nodes = kzalloc(2 * sizeof(unsigned long) * nr_node_ids, GFP_KERNEL);
+	nodes = kzalloc(sizeof(unsigned long) * nr_node_ids, GFP_KERNEL);
 	if (!nodes)
 		return -ENOMEM;
-	per_cpu = nodes + nr_node_ids;
 
 	if (flags & SO_CPU) {
 		int cpu;
@@ -4307,8 +4305,6 @@ static ssize_t show_slab_objects(struct kmem_cache *s,
 				total += x;
 				nodes[node] += x;
 			}
-
-			per_cpu[node]++;
 		}
 	}
 
-- 
1.7.7.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
