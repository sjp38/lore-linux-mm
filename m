From: Christoph Lameter <clameter@sgi.com>
Subject: [RFC 05/26] SLUB: Replace ctor field with ops field in /sys/slab/:0000008 /sys/slab/:0000016 /sys/slab/:0000024 /sys/slab/:0000032 /sys/slab/:0000040 /sys/slab/:0000048 /sys/slab/:0000056 /sys/slab/:0000064 /sys/slab/:0000072 /sys/slab/:0000080 /sys/slab/:0000088 /sys/slab/:0000096 /sys/slab/:0000104 /sys/slab/:0000128 /sys/slab/:0000144 /sys/slab/:0000184 /sys/slab/:0000192 /sys/slab/:0000216 /sys/slab/:0000256 /sys/slab/:0000344 /sys/slab/:0000384 /sys/slab/:0000448 /sys/slab/:0000512 /sys/slab/:0000768 /sys/slab/:0000920 /sys/slab/:0001024 /sys/slab/:0001152 /sys/slab/:0001344 /sys/slab/:0001536 /sys/slab/:0002048 /sys/slab/:0003072 /sys/slab/:0004096 /sys/slab/:a-0000056 /sys/slab/:a-0000080 /sys/slab/:a-0000128 /sys/slab/Acpi-Namespace /sys/slab/Acpi-Operand /sys/slab/Acpi-Pa
 rse /sys/slab/Acpi-ParseExt /sys/slab/Acpi-State /sys/slab/RAW /sys/slab/TCP /sys/slab/UDP /sys/sl
Date: Fri, 31 Aug 2007 18:41:12 -0700
Message-ID: <20070901014220.452715954@sgi.com>
References: <20070901014107.719506437@sgi.com>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
Content-Disposition: inline; filename=0005-slab_defrag_ops_field.patch
Sender: linux-fsdevel-owner@vger.kernel.org
To: Andy Whitcroft <apw@shadowen.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Christoph Hellwig <hch@lst.de>, Mel Gorman <mel@skynet.ie>, David Chinner <dgc@sgi.com>
List-Id: linux-mm.kvack.org

Create an ops field in /sys/slab/*/ops to contain all the operations defined
on a slab. This will be used to display the additional operations that we
will define soon.

Signed-off-by: Christoph Lameter <clameter@sgi.com>
---
 mm/slub.c |   16 +++++++++-------
 1 files changed, 9 insertions(+), 7 deletions(-)

diff --git a/mm/slub.c b/mm/slub.c
index f95a760..fc2f1e3 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -3501,16 +3501,18 @@ static ssize_t order_show(struct kmem_cache *s, char *buf)
 }
 SLAB_ATTR_RO(order);
 
-static ssize_t ctor_show(struct kmem_cache *s, char *buf)
+static ssize_t ops_show(struct kmem_cache *s, char *buf)
 {
-	if (s->ctor) {
-		int n = sprint_symbol(buf, (unsigned long)s->ctor);
+	int x = 0;
 
-		return n + sprintf(buf + n, "\n");
+	if (s->ctor) {
+		x += sprintf(buf + x, "ctor : ");
+		x += sprint_symbol(buf + x, (unsigned long)s->ops->ctor);
+		x += sprintf(buf + x, "\n");
 	}
-	return 0;
+	return x;
 }
-SLAB_ATTR_RO(ctor);
+SLAB_ATTR_RO(ops);
 
 static ssize_t aliases_show(struct kmem_cache *s, char *buf)
 {
@@ -3761,7 +3763,7 @@ static struct attribute * slab_attrs[] = {
 	&slabs_attr.attr,
 	&partial_attr.attr,
 	&cpu_slabs_attr.attr,
-	&ctor_attr.attr,
+	&ops_attr.attr,
 	&aliases_attr.attr,
 	&align_attr.attr,
 	&sanity_checks_attr.attr,
-- 
1.5.2.4

-- 
