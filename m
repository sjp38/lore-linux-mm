Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f179.google.com (mail-pd0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id AA3F36B0035
	for <linux-mm@kvack.org>; Thu, 26 Jun 2014 02:20:10 -0400 (EDT)
Received: by mail-pd0-f179.google.com with SMTP id w10so2637330pde.10
        for <linux-mm@kvack.org>; Wed, 25 Jun 2014 23:20:10 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id sr7si8332215pab.202.2014.06.25.23.20.09
        for <linux-mm@kvack.org>;
        Wed, 25 Jun 2014 23:20:09 -0700 (PDT)
Date: Thu, 26 Jun 2014 14:19:21 +0800
From: kbuild test robot <fengguang.wu@intel.com>
Subject: [mmotm:master 144/319] mm/zsmalloc.c:253:6: sparse: symbol
 'zs_zpool_destroy' was not declared. Should it be static?
Message-ID: <53abbb69.1g8q3OIP0CYmy0aT%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: multipart/mixed;
 boundary="=_53abbb69.ISLzRu2j7j0odBVO4TJ0YqZcNEJb9RCWrV+801ZuKZBOGfPa"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Streetman <ddstreet@ieee.org>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, kbuild-all@01.org

This is a multi-part message in MIME format.

--=_53abbb69.ISLzRu2j7j0odBVO4TJ0YqZcNEJb9RCWrV+801ZuKZBOGfPa
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

tree:   git://git.cmpxchg.org/linux-mmotm.git master
head:   9477ec75947f2cf0fc47e8ab781a5e9171099be2
commit: b03c0167d85a990598c69922fa6a290cba5b5ec8 [144/319] mm/zpool: update zswap to use zpool
reproduce: make C=1 CF=-D__CHECK_ENDIAN__


sparse warnings: (new ones prefixed by >>)

>> mm/zsmalloc.c:253:6: sparse: symbol 'zs_zpool_destroy' was not declared. Should it be static?
>> mm/zsmalloc.c:258:5: sparse: symbol 'zs_zpool_malloc' was not declared. Should it be static?
>> mm/zsmalloc.c:263:6: sparse: symbol 'zs_zpool_free' was not declared. Should it be static?
>> mm/zsmalloc.c:268:5: sparse: symbol 'zs_zpool_shrink' was not declared. Should it be static?
>> mm/zsmalloc.c:274:6: sparse: symbol 'zs_zpool_map' was not declared. Should it be static?
>> mm/zsmalloc.c:294:6: sparse: symbol 'zs_zpool_unmap' was not declared. Should it be static?
>> mm/zsmalloc.c:299:5: sparse: symbol 'zs_zpool_total_size' was not declared. Should it be static?

Please consider folding the attached diff :-)

---
0-DAY kernel build testing backend              Open Source Technology Center
http://lists.01.org/mailman/listinfo/kbuild                 Intel Corporation

--=_53abbb69.ISLzRu2j7j0odBVO4TJ0YqZcNEJb9RCWrV+801ZuKZBOGfPa
Content-Type: text/x-diff;
 charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="make-it-static-b03c0167d85a990598c69922fa6a290cba5b5ec8.diff"

From: Fengguang Wu <fengguang.wu@intel.com>
Subject: [PATCH mmotm] mm/zpool: zs_zpool_destroy() can be static
TO: Dan Streetman <ddstreet@ieee.org>
CC: Johannes Weiner <hannes@cmpxchg.org>
CC: linux-mm@kvack.org 
CC: linux-kernel@vger.kernel.org 

CC: Dan Streetman <ddstreet@ieee.org>
CC: Johannes Weiner <hannes@cmpxchg.org>
Signed-off-by: Fengguang Wu <fengguang.wu@intel.com>
---
 zsmalloc.c |   14 +++++++-------
 1 file changed, 7 insertions(+), 7 deletions(-)

diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
index feba644..20dc632 100644
--- a/mm/zsmalloc.c
+++ b/mm/zsmalloc.c
@@ -250,28 +250,28 @@ static void *zs_zpool_create(gfp_t gfp, struct zpool_ops *zpool_ops)
 	return zs_create_pool(gfp);
 }
 
-void zs_zpool_destroy(void *pool)
+static void zs_zpool_destroy(void *pool)
 {
 	zs_destroy_pool(pool);
 }
 
-int zs_zpool_malloc(void *pool, size_t size, unsigned long *handle)
+static int zs_zpool_malloc(void *pool, size_t size, unsigned long *handle)
 {
 	*handle = zs_malloc(pool, size);
 	return *handle ? 0 : -1;
 }
-void zs_zpool_free(void *pool, unsigned long handle)
+static void zs_zpool_free(void *pool, unsigned long handle)
 {
 	zs_free(pool, handle);
 }
 
-int zs_zpool_shrink(void *pool, unsigned int pages,
+static int zs_zpool_shrink(void *pool, unsigned int pages,
 			unsigned int *reclaimed)
 {
 	return -EINVAL;
 }
 
-void *zs_zpool_map(void *pool, unsigned long handle,
+static void *zs_zpool_map(void *pool, unsigned long handle,
 			enum zpool_mapmode mm)
 {
 	enum zs_mapmode zs_mm;
@@ -291,12 +291,12 @@ void *zs_zpool_map(void *pool, unsigned long handle,
 
 	return zs_map_object(pool, handle, zs_mm);
 }
-void zs_zpool_unmap(void *pool, unsigned long handle)
+static void zs_zpool_unmap(void *pool, unsigned long handle)
 {
 	zs_unmap_object(pool, handle);
 }
 
-u64 zs_zpool_total_size(void *pool)
+static u64 zs_zpool_total_size(void *pool)
 {
 	return zs_get_total_size_bytes(pool);
 }

--=_53abbb69.ISLzRu2j7j0odBVO4TJ0YqZcNEJb9RCWrV+801ZuKZBOGfPa--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
