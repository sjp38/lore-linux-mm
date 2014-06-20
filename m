Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id 23E666B0031
	for <linux-mm@kvack.org>; Fri, 20 Jun 2014 17:10:00 -0400 (EDT)
Received: by mail-pa0-f54.google.com with SMTP id et14so3510130pad.41
        for <linux-mm@kvack.org>; Fri, 20 Jun 2014 14:09:59 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id ew3si11328692pac.229.2014.06.20.14.09.58
        for <linux-mm@kvack.org>;
        Fri, 20 Jun 2014 14:09:59 -0700 (PDT)
Date: Fri, 20 Jun 2014 14:09:57 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [mmotm:master 80/230] mm/slab.c:1308:4: warning: passing
 argument 2 of 'slab_set_debugobj_lock_classes_node' makes integer from
 pointer without a cast
Message-Id: <20140620140957.afe43a8856de2753e2d48525@linux-foundation.org>
In-Reply-To: <53a39bcf.VqwYoYRlP0B26+5N%fengguang.wu@intel.com>
References: <53a39bcf.VqwYoYRlP0B26+5N%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <fengguang.wu@intel.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Christoph Lameter <cl@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>, kbuild-all@01.org

On Fri, 20 Jun 2014 10:26:23 +0800 kbuild test robot <fengguang.wu@intel.com> wrote:

> tree:   git://git.cmpxchg.org/linux-mmotm.git master
> head:   df25ba7db0775d87018e2cd92f26b9b087093840
> commit: 21d9944b94ac764039a4bd6f0bbb7e4243cf0d30 [80/230] slab-use-get_node-and-kmem_cache_node-functions-fix-2
> config: make ARCH=sh titan_defconfig
> 
> All warnings:
> 
>    mm/slab.c: In function 'cpuup_prepare':
> >> mm/slab.c:1308:4: warning: passing argument 2 of 'slab_set_debugobj_lock_classes_node' makes integer from pointer without a cast [enabled by default]
>    mm/slab.c:593:13: note: expected 'int' but argument is of type 'struct kmem_cache_node *'
> 

grr, whack-a-mole.

--- a/mm/slab.c~slab-use-get_node-and-kmem_cache_node-functions-fix-2-fix
+++ a/mm/slab.c
@@ -590,7 +590,8 @@ static inline void on_slab_lock_classes_
 {
 }
 
-static void slab_set_debugobj_lock_classes_node(struct kmem_cache *cachep, int node)
+static void slab_set_debugobj_lock_classes_node(struct kmem_cache *cachep,
+	struct kmem_cache_node *n)
 {
 }
 
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
