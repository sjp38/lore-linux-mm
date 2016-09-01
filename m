Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f197.google.com (mail-ua0-f197.google.com [209.85.217.197])
	by kanga.kvack.org (Postfix) with ESMTP id E63096B025E
	for <linux-mm@kvack.org>; Thu,  1 Sep 2016 02:56:31 -0400 (EDT)
Received: by mail-ua0-f197.google.com with SMTP id j4so157464300uaj.2
        for <linux-mm@kvack.org>; Wed, 31 Aug 2016 23:56:31 -0700 (PDT)
Received: from szxga03-in.huawei.com (szxga03-in.huawei.com. [119.145.14.66])
        by mx.google.com with ESMTPS id o78si4075324pfi.291.2016.08.31.23.56.25
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 31 Aug 2016 23:56:27 -0700 (PDT)
From: Zhen Lei <thunder.leizhen@huawei.com>
Subject: [PATCH v8 07/16] of_numa: Use pr_fmt()
Date: Thu, 1 Sep 2016 14:54:58 +0800
Message-ID: <1472712907-12700-8-git-send-email-thunder.leizhen@huawei.com>
In-Reply-To: <1472712907-12700-1-git-send-email-thunder.leizhen@huawei.com>
References: <1472712907-12700-1-git-send-email-thunder.leizhen@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, linux-arm-kernel <linux-arm-kernel@lists.infradead.org>, linux-kernel <linux-kernel@vger.kernel.org>, Rob Herring <robh+dt@kernel.org>, Frank
 Rowand <frowand.list@gmail.com>, devicetree <devicetree@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>
Cc: Zefan Li <lizefan@huawei.com>, Xinwei Hu <huxinwei@huawei.com>, Tianhong
 Ding <dingtianhong@huawei.com>, Hanjun Guo <guohanjun@huawei.com>, Zhen Lei <thunder.leizhen@huawei.com>

From: Kefeng Wang <wangkefeng.wang@huawei.com>

Use pr_fmt to prefix kernel output.

Signed-off-by: Kefeng Wang <wangkefeng.wang@huawei.com>
Acked-by: Rob Herring <robh@kernel.org>
---
 drivers/of/of_numa.c | 21 +++++++++++----------
 1 file changed, 11 insertions(+), 10 deletions(-)

diff --git a/drivers/of/of_numa.c b/drivers/of/of_numa.c
index 0d7459b..f63d4b0d 100644
--- a/drivers/of/of_numa.c
+++ b/drivers/of/of_numa.c
@@ -16,6 +16,8 @@
  * along with this program.  If not, see <http://www.gnu.org/licenses/>.
  */

+#define pr_fmt(fmt) "OF: NUMA: " fmt
+
 #include <linux/of.h>
 #include <linux/of_address.h>
 #include <linux/nodemask.h>
@@ -49,10 +51,9 @@ static void __init of_numa_parse_cpu_nodes(void)
 		if (r)
 			continue;

-		pr_debug("NUMA: CPU on %u\n", nid);
+		pr_debug("CPU on %u\n", nid);
 		if (nid >= MAX_NUMNODES)
-			pr_warn("NUMA: Node id %u exceeds maximum value\n",
-				nid);
+			pr_warn("Node id %u exceeds maximum value\n", nid);
 		else
 			node_set(nid, numa_nodes_parsed);
 	}
@@ -76,7 +77,7 @@ static int __init of_numa_parse_memory_nodes(void)
 			continue;

 		if (nid >= MAX_NUMNODES) {
-			pr_warn("NUMA: Node id %u exceeds maximum value\n", nid);
+			pr_warn("Node id %u exceeds maximum value\n", nid);
 			r = -EINVAL;
 		}

@@ -85,7 +86,7 @@ static int __init of_numa_parse_memory_nodes(void)

 		if (!i || r) {
 			of_node_put(np);
-			pr_err("NUMA: bad property in memory node\n");
+			pr_err("bad property in memory node\n");
 			return r ? : -EINVAL;
 		}
 	}
@@ -99,17 +100,17 @@ static int __init of_numa_parse_distance_map_v1(struct device_node *map)
 	int entry_count;
 	int i;

-	pr_info("NUMA: parsing numa-distance-map-v1\n");
+	pr_info("parsing numa-distance-map-v1\n");

 	matrix = of_get_property(map, "distance-matrix", NULL);
 	if (!matrix) {
-		pr_err("NUMA: No distance-matrix property in distance-map\n");
+		pr_err("No distance-matrix property in distance-map\n");
 		return -EINVAL;
 	}

 	entry_count = of_property_count_u32_elems(map, "distance-matrix");
 	if (entry_count <= 0) {
-		pr_err("NUMA: Invalid distance-matrix\n");
+		pr_err("Invalid distance-matrix\n");
 		return -EINVAL;
 	}

@@ -124,7 +125,7 @@ static int __init of_numa_parse_distance_map_v1(struct device_node *map)
 		matrix++;

 		numa_set_distance(nodea, nodeb, distance);
-		pr_debug("NUMA:  distance[node%d -> node%d] = %d\n",
+		pr_debug("distance[node%d -> node%d] = %d\n",
 			 nodea, nodeb, distance);

 		/* Set default distance of node B->A same as A->B */
@@ -171,7 +172,7 @@ int of_node_to_nid(struct device_node *device)
 		np = of_get_next_parent(np);
 	}
 	if (np && r)
-		pr_warn("NUMA: Invalid \"numa-node-id\" property in node %s\n",
+		pr_warn("Invalid \"numa-node-id\" property in node %s\n",
 			np->name);
 	of_node_put(np);

--
2.5.0


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
