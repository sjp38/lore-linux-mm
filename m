Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f179.google.com (mail-wi0-f179.google.com [209.85.212.179])
	by kanga.kvack.org (Postfix) with ESMTP id F14286B0032
	for <linux-mm@kvack.org>; Wed, 10 Jun 2015 01:46:07 -0400 (EDT)
Received: by wiwd19 with SMTP id d19so36700104wiw.0
        for <linux-mm@kvack.org>; Tue, 09 Jun 2015 22:46:07 -0700 (PDT)
Received: from mail2-relais-roc.national.inria.fr (mail2-relais-roc.national.inria.fr. [192.134.164.83])
        by mx.google.com with ESMTPS id e17si7490934wic.4.2015.06.09.22.46.05
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 09 Jun 2015 22:46:06 -0700 (PDT)
Date: Wed, 10 Jun 2015 07:46:03 +0200 (CEST)
From: Julia Lawall <julia.lawall@lip6.fr>
Subject: Re: [RFC][PATCH 0/5] do not dereference NULL pools in pools' destroy()
 functions
In-Reply-To: <1433894769.2730.87.camel@perches.com>
Message-ID: <alpine.DEB.2.02.1506100743200.2087@localhost6.localdomain6>
References: <1433851493-23685-1-git-send-email-sergey.senozhatsky@gmail.com>  <20150609142523.b717dba6033ee08de997c8be@linux-foundation.org> <1433894769.2730.87.camel@perches.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joe Perches <joe@perches.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Julia Lawall <julia.lawall@lip6.fr>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Minchan Kim <minchan@kernel.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Michal Hocko <mhocko@suse.cz>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, sergey.senozhatsky.work@gmail.com

> > Well I like it, even though it's going to cause a zillion little cleanup
> > patches.

Actually only at most 87.  There are some functions that look quite a bit 
nicer with the change, like:

 void jffs2_destroy_slab_caches(void)
 {
-       if(full_dnode_slab)
-               kmem_cache_destroy(full_dnode_slab);
-       if(raw_dirent_slab)
-               kmem_cache_destroy(raw_dirent_slab);
-       if(raw_inode_slab)
-               kmem_cache_destroy(raw_inode_slab);
-       if(tmp_dnode_info_slab)
-               kmem_cache_destroy(tmp_dnode_info_slab);
-       if(raw_node_ref_slab)
-               kmem_cache_destroy(raw_node_ref_slab);
-       if(node_frag_slab)
-               kmem_cache_destroy(node_frag_slab);
-       if(inode_cache_slab)
-               kmem_cache_destroy(inode_cache_slab);
+       kmem_cache_destroy(full_dnode_slab);
+       kmem_cache_destroy(raw_dirent_slab);
+       kmem_cache_destroy(raw_inode_slab);
+       kmem_cache_destroy(tmp_dnode_info_slab);
+       kmem_cache_destroy(raw_node_ref_slab);
+       kmem_cache_destroy(node_frag_slab);
+       kmem_cache_destroy(inode_cache_slab);
 #ifdef CONFIG_JFFS2_FS_XATTR
-       if (xattr_datum_cache)
-               kmem_cache_destroy(xattr_datum_cache);
-       if (xattr_ref_cache)
-               kmem_cache_destroy(xattr_ref_cache);
+       kmem_cache_destroy(xattr_datum_cache);
+       kmem_cache_destroy(xattr_ref_cache);
 #endif
 }

I can try to check and submit the patches.

julia

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
