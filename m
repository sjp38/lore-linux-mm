From: Christoph Lameter <clameter@sgi.com>
Subject: [patch 08/23] SLUB: Replace ctor field with ops field in /sys/slab/:0000008 /sys/slab/:0000016 /sys/slab/:0000024 /sys/slab/:0000032 /sys/slab/:0000040 /sys/slab/:0000048 /sys/slab/:0000056 /sys/slab/:0000064 /sys/slab/:0000072 /sys/slab/:0000080 /sys/slab/:0000088 /sys/slab/:0000096 /sys/slab/:0000104 /sys/slab/:0000128 /sys/slab/:0000144 /sys/slab/:0000184 /sys/slab/:0000192 /sys/slab/:0000216 /sys/slab/:0000256 /sys/slab/:0000344 /sys/slab/:0000384 /sys/slab/:0000448 /sys/slab/:0000512 /sys/slab/:0000768 /sys/slab/:0000968 /sys/slab/:0001024 /sys/slab/:0001152 /sys/slab/:0001312 /sys/slab/:0001536 /sys/slab/:0002048 /sys/slab/:0003072 /sys/slab/:0004096 /sys/slab/:a-0000016 /sys/slab/:a-0000024 /sys/slab/:a-0000056 /sys/slab/:a-0000080 /sys/slab/:a-0000128 /sys/slab/Acpi-Namesp
 ace /sys/slab/Acpi-Operand /sys/slab/Acpi-Parse /sys/slab/Acpi-ParseExt /sys/slab/Acpi-State /sys/
Date: Tue, 06 Nov 2007 17:11:38 -0800
Message-ID: <20071107011228.355540572@sgi.com>
References: <20071107011130.382244340@sgi.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1757425AbXKGBPQ@vger.kernel.org>
Content-Disposition: inline; filename=0005-slab_defrag_ops_field.patch
Sender: linux-kernel-owner@vger.kernel.org
To: akpm@linux-foundatin.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Mel Gorman <mel@skynet.ie>
List-Id: linux-mm.kvack.org

Create an ops field in /sys/slab/*/ops to contain all the operations defined
on a slab. This will be used to display the additional operations that will
be defined soon.

Reviewed-by: Rik van Riel <riel@redhat.com>
Signed-off-by: Christoph Lameter <clameter@sgi.com>
---
 mm/slub.c |   16 +++++++++-------
 1 file changed, 9 insertions(+), 7 deletions(-)

Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c	2007-11-06 12:37:44.000000000 -0800
+++ linux-2.6/mm/slub.c	2007-11-06 12:37:47.000000000 -0800
@@ -3789,16 +3789,18 @@ static ssize_t order_show(struct kmem_ca
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
@@ -4049,7 +4051,7 @@ static struct attribute * slab_attrs[] =
 	&slabs_attr.attr,
 	&partial_attr.attr,
 	&cpu_slabs_attr.attr,
-	&ctor_attr.attr,
+	&ops_attr.attr,
 	&aliases_attr.attr,
 	&align_attr.attr,
 	&sanity_checks_attr.attr,

-- 
