Return-Path: <owner-linux-mm@kvack.org>
From: Joe Perches <joe@perches.com>
Subject: [PATCH 0/6] treewide: kmem_cache_alloc GFP_ZERO cleanups
Date: Thu, 29 Aug 2013 13:11:04 -0700
Message-Id: <cover.1377806578.git.joe@perches.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: intel-gfx@lists.freedesktop.org, dri-devel@lists.freedesktop.org, linux-fsdevel@vger.kernel.org, linux-aio@kvack.org, ceph-devel@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-mm@kvack.org

Just a few cleanups to use zalloc style calls and reduce
the uses of __GFP_ZERO for kmem_cache_alloc[_node] uses.

Use the more kernel normal zalloc style.

Joe Perches (6):
  slab/block: Add and use kmem_cache_zalloc_node
  block: Convert kmem_cache_alloc(...GFP_ZERO) to kmem_cache_zalloc
  i915_gem: Convert kmem_cache_alloc(...GFP_ZERO) to kmem_cache_zalloc
  aio: Convert kmem_cache_alloc(...GFP_ZERO) to kmem_cache_zalloc
  ceph: Convert kmem_cache_alloc(...GFP_ZERO) to kmem_cache_zalloc
  f2fs: Convert kmem_cache_alloc(...GFP_ZERO) to kmem_cache_zalloc

 block/blk-core.c                |  3 +--
 block/blk-integrity.c           |  3 +--
 block/blk-ioc.c                 |  6 ++----
 block/cfq-iosched.c             | 10 ++++------
 drivers/gpu/drm/i915/i915_gem.c |  2 +-
 fs/aio.c                        |  2 +-
 fs/ceph/dir.c                   |  2 +-
 fs/ceph/file.c                  |  2 +-
 fs/f2fs/super.c                 |  2 +-
 include/linux/slab.h            |  5 +++++
 10 files changed, 18 insertions(+), 19 deletions(-)

-- 
1.8.1.2.459.gbcd45b4.dirty

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
