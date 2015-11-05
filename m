Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f174.google.com (mail-yk0-f174.google.com [209.85.160.174])
	by kanga.kvack.org (Postfix) with ESMTP id D0F6D82F64
	for <linux-mm@kvack.org>; Thu,  5 Nov 2015 10:37:42 -0500 (EST)
Received: by ykba4 with SMTP id a4so136880960ykb.3
        for <linux-mm@kvack.org>; Thu, 05 Nov 2015 07:37:42 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 199si4930713vkv.197.2015.11.05.07.37.41
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 05 Nov 2015 07:37:42 -0800 (PST)
Subject: [PATCH V2 0/2] SLUB bulk API interactions with kmem cgroup
From: Jesper Dangaard Brouer <brouer@redhat.com>
Date: Thu, 05 Nov 2015 16:37:39 +0100
Message-ID: <20151105153704.1115.10475.stgit@firesoul>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: vdavydov@virtuozzo.com, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, Jesper Dangaard Brouer <brouer@redhat.com>

I fixed some bugs for kmem cgroup interaction with SLUB bulk API,
compiled kernel with CONFIG_MEMCG_KMEM=y, but I don't known how to
setup kmem cgroups for slab, thus this is mostly untested.

I will appriciate anyone who can give me a simple setup script...

---

Jesper Dangaard Brouer (2):
      slub: fix kmem cgroup bug in kmem_cache_alloc_bulk
      slub: add missing kmem cgroup support to kmem_cache_free_bulk


 mm/slub.c |   17 +++++++++++------
 1 file changed, 11 insertions(+), 6 deletions(-)

--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
