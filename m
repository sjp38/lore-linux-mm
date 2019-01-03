Return-Path: <linux-kernel-owner@vger.kernel.org>
From: Roman Penyaev <rpenyaev@suse.de>
Subject: [PATCH 0/3] mm/vmalloc: fix size check and few cleanups
Date: Thu,  3 Jan 2019 15:59:51 +0100
Message-Id: <20190103145954.16942-1-rpenyaev@suse.de>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-kernel-owner@vger.kernel.org
Cc: Roman Penyaev <rpenyaev@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Joe Perches <joe@perches.com>, "Luis R. Rodriguez" <mcgrof@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

The first patch in series fixes size check for remap_vmalloc_range_partial()
which can lead to kernel crash by unfaithful userspace mapping.  Others two
are minor cleanups.

Roman Penyaev (3):
  mm/vmalloc: fix size check for remap_vmalloc_range_partial()
  mm/vmalloc: do not call kmemleak_free() on not yet accounted memory
  mm/vmalloc: pass VM_USERMAP flags directly to __vmalloc_node_range()

 mm/vmalloc.c | 48 ++++++++++++++++++++----------------------------
 1 file changed, 20 insertions(+), 28 deletions(-)

Signed-off-by: Roman Penyaev <rpenyaev@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: Joe Perches <joe@perches.com>
Cc: "Luis R. Rodriguez" <mcgrof@kernel.org>
Cc: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org
-- 
2.19.1
