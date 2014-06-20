Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f49.google.com (mail-pb0-f49.google.com [209.85.160.49])
	by kanga.kvack.org (Postfix) with ESMTP id 3E7DB6B0035
	for <linux-mm@kvack.org>; Thu, 19 Jun 2014 22:26:58 -0400 (EDT)
Received: by mail-pb0-f49.google.com with SMTP id rr13so2531179pbb.8
        for <linux-mm@kvack.org>; Thu, 19 Jun 2014 19:26:57 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id ir1si7847358pbb.43.2014.06.19.19.26.56
        for <linux-mm@kvack.org>;
        Thu, 19 Jun 2014 19:26:57 -0700 (PDT)
Date: Fri, 20 Jun 2014 10:26:23 +0800
From: kbuild test robot <fengguang.wu@intel.com>
Subject: [mmotm:master 80/230] mm/slab.c:1308:4: warning: passing argument 2 of 'slab_set_debugobj_lock_classes_node' makes integer from pointer without a cast
Message-ID: <53a39bcf.VqwYoYRlP0B26+5N%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Christoph Lameter <cl@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>, kbuild-all@01.org

tree:   git://git.cmpxchg.org/linux-mmotm.git master
head:   df25ba7db0775d87018e2cd92f26b9b087093840
commit: 21d9944b94ac764039a4bd6f0bbb7e4243cf0d30 [80/230] slab-use-get_node-and-kmem_cache_node-functions-fix-2
config: make ARCH=sh titan_defconfig

All warnings:

   mm/slab.c: In function 'cpuup_prepare':
>> mm/slab.c:1308:4: warning: passing argument 2 of 'slab_set_debugobj_lock_classes_node' makes integer from pointer without a cast [enabled by default]
   mm/slab.c:593:13: note: expected 'int' but argument is of type 'struct kmem_cache_node *'

vim +/slab_set_debugobj_lock_classes_node +1308 mm/slab.c

  1292				 * We are serialised from CPU_DEAD or
  1293				 * CPU_UP_CANCELLED by the cpucontrol lock
  1294				 */
  1295				n->shared = shared;
  1296				shared = NULL;
  1297			}
  1298	#ifdef CONFIG_NUMA
  1299			if (!n->alien) {
  1300				n->alien = alien;
  1301				alien = NULL;
  1302			}
  1303	#endif
  1304			spin_unlock_irq(&n->list_lock);
  1305			kfree(shared);
  1306			free_alien_cache(alien);
  1307			if (cachep->flags & SLAB_DEBUG_OBJECTS)
> 1308				slab_set_debugobj_lock_classes_node(cachep, n);
  1309			else if (!OFF_SLAB(cachep) &&
  1310				 !(cachep->flags & SLAB_DESTROY_BY_RCU))
  1311				on_slab_lock_classes_node(cachep, n);
  1312		}
  1313		init_node_lock_keys(node);
  1314	
  1315		return 0;
  1316	bad:

---
0-DAY kernel build testing backend              Open Source Technology Center
http://lists.01.org/mailman/listinfo/kbuild                 Intel Corporation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
