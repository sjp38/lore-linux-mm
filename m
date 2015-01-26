Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f44.google.com (mail-qa0-f44.google.com [209.85.216.44])
	by kanga.kvack.org (Postfix) with ESMTP id E15BF6B0071
	for <linux-mm@kvack.org>; Mon, 26 Jan 2015 03:56:48 -0500 (EST)
Received: by mail-qa0-f44.google.com with SMTP id w8so5858712qac.3
        for <linux-mm@kvack.org>; Mon, 26 Jan 2015 00:56:48 -0800 (PST)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id y6si12173682qcg.14.2015.01.26.00.56.47
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Jan 2015 00:56:47 -0800 (PST)
Date: Mon, 26 Jan 2015 11:56:38 +0300
From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [mmotm:master 200/417] mm/slab_common.c:166 update_memcg_params()
 warn: variable dereferenced before check 'old' (see line 162)
Message-ID: <20150126085638.GA6507@mwanda>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild@01.org, Vladimir Davydov <vdavydov@parallels.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>, Dan Carpenter <dan.carpenter@oracle.com>

tree:   git://git.cmpxchg.org/linux-mmotm.git master
head:   c64429bcc60a702f19f5cfdb5c39277863278a8c
commit: 5d06629c100b942a51f02b4d886c116ba3afb32a [200/417] slab: embed memcg_cache_params to kmem_cache

mm/slab_common.c:166 update_memcg_params() warn: variable dereferenced before check 'old' (see line 162)

git remote add mmotm git://git.cmpxchg.org/linux-mmotm.git
git remote update mmotm
git checkout 5d06629c100b942a51f02b4d886c116ba3afb32a
vim +/old +166 mm/slab_common.c

5d06629c Vladimir Davydov 2015-01-24  156  					lockdep_is_held(&slab_mutex));
5d06629c Vladimir Davydov 2015-01-24  157  	new = kzalloc(sizeof(struct memcg_cache_array) +
5d06629c Vladimir Davydov 2015-01-24  158  		      new_array_size * sizeof(void *), GFP_KERNEL);
5d06629c Vladimir Davydov 2015-01-24  159  	if (!new)
6f817f4c Vladimir Davydov 2014-10-09  160  		return -ENOMEM;
6f817f4c Vladimir Davydov 2014-10-09  161  
5d06629c Vladimir Davydov 2015-01-24 @162  	memcpy(new->entries, old->entries,
88a0b848 Vladimir Davydov 2015-01-24  163  	       memcg_nr_cache_ids * sizeof(void *));
6f817f4c Vladimir Davydov 2014-10-09  164  
5d06629c Vladimir Davydov 2015-01-24  165  	rcu_assign_pointer(s->memcg_params.memcg_caches, new);
5d06629c Vladimir Davydov 2015-01-24 @166  	if (old)
5d06629c Vladimir Davydov 2015-01-24  167  		kfree_rcu(old, rcu);
6f817f4c Vladimir Davydov 2014-10-09  168  	return 0;
6f817f4c Vladimir Davydov 2014-10-09  169  }

---
0-DAY kernel test infrastructure                Open Source Technology Center
http://lists.01.org/mailman/listinfo/kbuild                 Intel Corporation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
