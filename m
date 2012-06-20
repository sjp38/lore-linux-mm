Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx199.postini.com [74.125.245.199])
	by kanga.kvack.org (Postfix) with SMTP id 411696B005A
	for <linux-mm@kvack.org>; Wed, 20 Jun 2012 17:01:57 -0400 (EDT)
From: Glauber Costa <glommer@parallels.com>
Subject: [PATCH 0/4] cache-specific changes for memcg (preparation)
Date: Thu, 21 Jun 2012 00:59:15 +0400
Message-Id: <1340225959-1966-1-git-send-email-glommer@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: linux-mm@kvack.org, Cristoph Lameter <cl@linux.com>, David Rientjes <rientjes@google.com>

Pekka,

Please consider merging the following patches.
Patches 1-3 are around for a while, specially 1 and 3.

Patch #4 is a bit newer, and got less reviews (reviews appreciated),
but I am using it myself without further problems.

Feel free to pick all of them, or part of them, the way you prefer.

Glauber Costa (4):
  slab: rename gfpflags to allocflags
  Wipe out CFLGS_OFF_SLAB from flags during initial slab creation
  slab: move FULL state transition to an initcall
  don't do __ClearPageSlab before freeing slab page.

 include/linux/slab_def.h |    2 +-
 mm/page_alloc.c          |    5 ++++-
 mm/slab.c                |   29 +++++++++++++++--------------
 mm/slob.c                |    1 -
 mm/slub.c                |    1 -
 5 files changed, 20 insertions(+), 18 deletions(-)

-- 
1.7.10.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
