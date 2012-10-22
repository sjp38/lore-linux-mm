Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx103.postini.com [74.125.245.103])
	by kanga.kvack.org (Postfix) with SMTP id EAE386B0062
	for <linux-mm@kvack.org>; Mon, 22 Oct 2012 10:05:40 -0400 (EDT)
From: Glauber Costa <glommer@parallels.com>
Subject: [PATCH 0/2] move kmem_cache_free to common code.
Date: Mon, 22 Oct 2012 18:05:35 +0400
Message-Id: <1350914737-4097-1-git-send-email-glommer@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>

This is some initial work to make kmem_cache_free at least callable from
a common entry point. This will be useful in future work, like kmemcg-slab,
that needs to further change those callers in both slab and slub.

Patch1 is not really a dependency for 2, but it will be for the work I am doing
in kmemcg-slab, so I'm sending both patches for your appreciation.

Glauber Costa (2):
  slab: commonize slab_cache field in struct page
  slab: move kmem_cache_free to common code

 include/linux/mm_types.h |  7 ++-----
 mm/slab.c                | 13 +------------
 mm/slab.h                |  1 +
 mm/slab_common.c         | 17 +++++++++++++++++
 mm/slob.c                | 11 ++++-------
 mm/slub.c                | 29 +++++++++++++----------------
 6 files changed, 38 insertions(+), 40 deletions(-)

-- 
1.7.11.7

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
