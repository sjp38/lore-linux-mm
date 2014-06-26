Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f181.google.com (mail-pd0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id 129186B0035
	for <linux-mm@kvack.org>; Thu, 26 Jun 2014 05:22:35 -0400 (EDT)
Received: by mail-pd0-f181.google.com with SMTP id v10so2811029pde.12
        for <linux-mm@kvack.org>; Thu, 26 Jun 2014 02:22:34 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id hn2si8909739pbc.256.2014.06.26.02.22.33
        for <linux-mm@kvack.org>;
        Thu, 26 Jun 2014 02:22:34 -0700 (PDT)
Date: Thu, 26 Jun 2014 17:22:18 +0800
From: kbuild test robot <fengguang.wu@intel.com>
Subject: [next:master 138/302] mm/zbud.c:137:6: sparse: symbol
 'zbud_zpool_destroy' was not declared. Should it be static?
Message-ID: <53abe64a.qgmlsuCh+7811kqd%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: multipart/mixed;
 boundary="=_53abe64a.rwd+HxDAPUGpWZ2YVzNSYy9YJ3Kem4MDBxscL9Z3mrtk+Vaz"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Streetman <ddstreet@ieee.org>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, kbuild-all@01.org

This is a multi-part message in MIME format.

--=_53abe64a.rwd+HxDAPUGpWZ2YVzNSYy9YJ3Kem4MDBxscL9Z3mrtk+Vaz
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

tree:   git://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git master
head:   070b95becb3dee794bc6e313ec391b598e8664f9
commit: a5eaa8ab0f9c42b8b4c457c15c09b8f9b092ecef [138/302] mm/zpool: update zswap to use zpool
reproduce: make C=1 CF=-D__CHECK_ENDIAN__


sparse warnings: (new ones prefixed by >>)

>> mm/zbud.c:137:6: sparse: symbol 'zbud_zpool_destroy' was not declared. Should it be static?
>> mm/zbud.c:142:5: sparse: symbol 'zbud_zpool_malloc' was not declared. Should it be static?
>> mm/zbud.c:146:6: sparse: symbol 'zbud_zpool_free' was not declared. Should it be static?
>> mm/zbud.c:151:5: sparse: symbol 'zbud_zpool_shrink' was not declared. Should it be static?
>> mm/zbud.c:170:6: sparse: symbol 'zbud_zpool_map' was not declared. Should it be static?
>> mm/zbud.c:175:6: sparse: symbol 'zbud_zpool_unmap' was not declared. Should it be static?
>> mm/zbud.c:180:5: sparse: symbol 'zbud_zpool_total_size' was not declared. Should it be static?

Please consider folding the attached diff :-)

---
0-DAY kernel build testing backend              Open Source Technology Center
http://lists.01.org/mailman/listinfo/kbuild                 Intel Corporation

--=_53abe64a.rwd+HxDAPUGpWZ2YVzNSYy9YJ3Kem4MDBxscL9Z3mrtk+Vaz
Content-Type: text/x-diff;
 charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="make-it-static-a5eaa8ab0f9c42b8b4c457c15c09b8f9b092ecef.diff"

From: Fengguang Wu <fengguang.wu@intel.com>
Subject: [PATCH next] mm/zpool: zbud_zpool_destroy() can be static
TO: Dan Streetman <ddstreet@ieee.org>
CC: linux-mm@kvack.org 
CC: linux-kernel@vger.kernel.org 

CC: Dan Streetman <ddstreet@ieee.org>
Signed-off-by: Fengguang Wu <fengguang.wu@intel.com>
---
 zbud.c |   14 +++++++-------
 1 file changed, 7 insertions(+), 7 deletions(-)

diff --git a/mm/zbud.c b/mm/zbud.c
index 645379e..1695c28 100644
--- a/mm/zbud.c
+++ b/mm/zbud.c
@@ -134,21 +134,21 @@ static void *zbud_zpool_create(gfp_t gfp, struct zpool_ops *zpool_ops)
 	return zbud_create_pool(gfp, &zbud_zpool_ops);
 }
 
-void zbud_zpool_destroy(void *pool)
+static void zbud_zpool_destroy(void *pool)
 {
 	zbud_destroy_pool(pool);
 }
 
-int zbud_zpool_malloc(void *pool, size_t size, unsigned long *handle)
+static int zbud_zpool_malloc(void *pool, size_t size, unsigned long *handle)
 {
 	return zbud_alloc(pool, size, handle);
 }
-void zbud_zpool_free(void *pool, unsigned long handle)
+static void zbud_zpool_free(void *pool, unsigned long handle)
 {
 	zbud_free(pool, handle);
 }
 
-int zbud_zpool_shrink(void *pool, unsigned int pages,
+static int zbud_zpool_shrink(void *pool, unsigned int pages,
 			unsigned int *reclaimed)
 {
 	unsigned int total = 0;
@@ -167,17 +167,17 @@ int zbud_zpool_shrink(void *pool, unsigned int pages,
 	return ret;
 }
 
-void *zbud_zpool_map(void *pool, unsigned long handle,
+static void *zbud_zpool_map(void *pool, unsigned long handle,
 			enum zpool_mapmode mm)
 {
 	return zbud_map(pool, handle);
 }
-void zbud_zpool_unmap(void *pool, unsigned long handle)
+static void zbud_zpool_unmap(void *pool, unsigned long handle)
 {
 	zbud_unmap(pool, handle);
 }
 
-u64 zbud_zpool_total_size(void *pool)
+static u64 zbud_zpool_total_size(void *pool)
 {
 	return zbud_get_pool_size(pool) * PAGE_SIZE;
 }

--=_53abe64a.rwd+HxDAPUGpWZ2YVzNSYy9YJ3Kem4MDBxscL9Z3mrtk+Vaz--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
