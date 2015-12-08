Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f42.google.com (mail-qg0-f42.google.com [209.85.192.42])
	by kanga.kvack.org (Postfix) with ESMTP id 386A66B0257
	for <linux-mm@kvack.org>; Tue,  8 Dec 2015 11:18:56 -0500 (EST)
Received: by qgec40 with SMTP id c40so23104927qge.2
        for <linux-mm@kvack.org>; Tue, 08 Dec 2015 08:18:56 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 72si4036697qkw.84.2015.12.08.08.18.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Dec 2015 08:18:25 -0800 (PST)
Subject: [RFC PATCH V2 0/9] slab: cleanup and bulk API for SLAB
From: Jesper Dangaard Brouer <brouer@redhat.com>
Date: Tue, 08 Dec 2015 17:18:22 +0100
Message-ID: <20151208161751.21945.53936.stgit@firesoul>
In-Reply-To: <20151203155600.3589.86568.stgit@firesoul>
References: <20151203155600.3589.86568.stgit@firesoul>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Christoph Lameter <cl@linux.com>, Vladimir Davydov <vdavydov@virtuozzo.com>, Jesper Dangaard Brouer <brouer@redhat.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>

RFC series for code sharing between SLUB and SLAB, and dedublication
of code in SLAB, as Christoph requested.  See questions in code.

Plus adding bulk API implemenation for SLAB.

---

Jesper Dangaard Brouer (9):
      mm/slab: move SLUB alloc hooks to common mm/slab.h
      mm: generalize avoid fault-inject on bootstrap kmem_cache
      slab: use slab_pre_alloc_hook in SLAB allocator
      mm: kmemcheck skip object if slab allocation failed
      slab: use slab_post_alloc_hook in SLAB allocator
      slab: implement bulk alloc in SLAB allocator
      slab: avoid running debug SLAB code with IRQs disabled for alloc_bulk
      slab: implement bulk free in SLAB allocator
      slab: annotate code to generate more compact asm code


 mm/failslab.c  |    2 +
 mm/kmemcheck.c |    3 +
 mm/slab.c      |  122 +++++++++++++++++++++++++++++++++++---------------------
 mm/slab.h      |   92 ++++++++++++++++++++++++++++++++++++++++++
 mm/slub.c      |   54 -------------------------
 5 files changed, 174 insertions(+), 99 deletions(-)

--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
