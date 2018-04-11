Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id AF1876B0007
	for <linux-mm@kvack.org>; Wed, 11 Apr 2018 02:03:27 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id z13so403396pfe.21
        for <linux-mm@kvack.org>; Tue, 10 Apr 2018 23:03:27 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id j87si352836pfk.78.2018.04.10.23.03.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 10 Apr 2018 23:03:26 -0700 (PDT)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH v2 0/2] Fix __GFP_ZERO vs constructor
Date: Tue, 10 Apr 2018 23:03:18 -0700
Message-Id: <20180411060320.14458-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Matthew Wilcox <mawilcox@microsoft.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Jan Kara <jack@suse.cz>, Jeff Layton <jlayton@redhat.com>, Mel Gorman <mgorman@techsingularity.net>

From: Matthew Wilcox <mawilcox@microsoft.com>

v1->v2:
 - Added review/ack tags (thanks!)
 - Switched the order of the patches
 - Reworded commit message of the patch which actually fixes the bug
 - Moved slab debug patches under CONFIG_DEBUG_VM to check _every_
   allocation and added checks in the slowpath for the allocations which
   end up allocating a page.

Matthew Wilcox (2):
  Fix NULL pointer in page_cache_tree_insert
  slab: __GFP_ZERO is incompatible with a constructor

 mm/filemap.c | 9 ++++-----
 mm/slab.c    | 7 ++++---
 mm/slab.h    | 7 +++++++
 mm/slob.c    | 4 +++-
 mm/slub.c    | 5 +++--
 5 files changed, 21 insertions(+), 11 deletions(-)

-- 
2.16.3
