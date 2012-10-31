Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx137.postini.com [74.125.245.137])
	by kanga.kvack.org (Postfix) with SMTP id 128C66B0062
	for <linux-mm@kvack.org>; Wed, 31 Oct 2012 05:24:44 -0400 (EDT)
Date: Wed, 31 Oct 2012 17:25:04 +0800
From: kbuild test robot <fengguang.wu@intel.com>
Subject: [glommer-memcg:slab-common/kmalloc 3/16] mm/slab_common.c:210:6:
 warning: format '%td' expects argument of type 'ptrdiff_t', but argument 3
 has type 'size_t'
Message-ID: <5090ee70.0VqxCVMJOPKPP7+v%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: linux-mm@kvack.org, Glauber Costa <glommer@parallels.com>

tree:   git://git.kernel.org/pub/scm/linux/kernel/git/glommer/memcg.git slab-common/kmalloc
head:   b59d450914258587897b8b602068a840e26df19b
commit: b665ac5d4350e39e5ab017a3c9023323a35ba908 [3/16] CK2 [02/15] create common functions for boot slab creation
config: make ARCH=s390 allnoconfig

All warnings:

mm/slab_common.c: In function 'create_boot_cache':
mm/slab_common.c:210:6: warning: format '%td' expects argument of type 'ptrdiff_t', but argument 3 has type 'size_t' [-Wformat]

vim +210 mm/slab_common.c

97d06609 Christoph Lameter 2012-07-06  194  }
b665ac5d Christoph Lameter 2012-10-19  195  
b665ac5d Christoph Lameter 2012-10-19  196  #ifndef CONFIG_SLOB
b665ac5d Christoph Lameter 2012-10-19  197  /* Create a cache during boot when no slab services are available yet */
b665ac5d Christoph Lameter 2012-10-19  198  void __init create_boot_cache(struct kmem_cache *s, const char *name, size_t size,
b665ac5d Christoph Lameter 2012-10-19  199  		unsigned long flags)
b665ac5d Christoph Lameter 2012-10-19  200  {
b665ac5d Christoph Lameter 2012-10-19  201  	int err;
b665ac5d Christoph Lameter 2012-10-19  202  
b665ac5d Christoph Lameter 2012-10-19  203  	s->name = name;
b665ac5d Christoph Lameter 2012-10-19  204  	s->size = s->object_size = size;
b665ac5d Christoph Lameter 2012-10-19  205  	s->align = ARCH_KMALLOC_MINALIGN;
b665ac5d Christoph Lameter 2012-10-19  206  	err = __kmem_cache_create(s, flags);
b665ac5d Christoph Lameter 2012-10-19  207  
b665ac5d Christoph Lameter 2012-10-19  208  	if (err)
b665ac5d Christoph Lameter 2012-10-19  209  		panic("Creation of kmalloc slab %s size=%td failed. Reason %d\n",
b665ac5d Christoph Lameter 2012-10-19 @210  					name, size, err);
b665ac5d Christoph Lameter 2012-10-19  211  
b665ac5d Christoph Lameter 2012-10-19  212  	list_add(&s->list, &slab_caches);
b665ac5d Christoph Lameter 2012-10-19  213  	s->refcount = -1;	/* Exempt from merging for now */
b665ac5d Christoph Lameter 2012-10-19  214  }
b665ac5d Christoph Lameter 2012-10-19  215  
b665ac5d Christoph Lameter 2012-10-19  216  struct kmem_cache *__init create_kmalloc_cache(const char *name, size_t size,
b665ac5d Christoph Lameter 2012-10-19  217  				unsigned long flags)
b665ac5d Christoph Lameter 2012-10-19  218  {

---
0-DAY kernel build testing backend         Open Source Technology Center
Fengguang Wu, Yuanhan Liu                              Intel Corporation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
