Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx143.postini.com [74.125.245.143])
	by kanga.kvack.org (Postfix) with SMTP id 2E1426B006E
	for <linux-mm@kvack.org>; Fri, 16 Nov 2012 14:50:15 -0500 (EST)
Received: by mail-pb0-f41.google.com with SMTP id xa7so2352196pbc.14
        for <linux-mm@kvack.org>; Fri, 16 Nov 2012 11:50:14 -0800 (PST)
Date: Fri, 16 Nov 2012 11:50:12 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: [patch] mm: introduce a common interface for balloon pages mobility
 fix
In-Reply-To: <50a6581a.V3MmP/x4DXU9jUhJ%fengguang.wu@intel.com>
Message-ID: <alpine.DEB.2.00.1211161147580.2788@chino.kir.corp.google.com>
References: <50a6581a.V3MmP/x4DXU9jUhJ%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <fengguang.wu@intel.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Rafael Aquini <aquini@redhat.com>, linux-mm@kvack.org, Michal Hocko <mhocko@suse.cz>

On Fri, 16 Nov 2012, kbuild test robot wrote:

> tree:   git://git.kernel.org/pub/scm/linux/kernel/git/mhocko/mm.git since-3.6
> head:   12dfb061e5fd15be23451418da01281625c0eeae
> commit: 86929cfa5f751de3d8be5a846535282730865d8a [365/437] mm: introduce a common interface for balloon pages mobility
> config: make ARCH=sh allyesconfig
> 
> All warnings:
> 
> warning: (BALLOON_COMPACTION && TRANSPARENT_HUGEPAGE) selects COMPACTION which has unmet direct dependencies (MMU)
> warning: (BALLOON_COMPACTION && TRANSPARENT_HUGEPAGE) selects COMPACTION which has unmet direct dependencies (MMU)
> --
> warning: (BALLOON_COMPACTION && TRANSPARENT_HUGEPAGE) selects COMPACTION which has unmet direct dependencies (MMU)
> 

mm: introduce a common interface for balloon pages mobility fix

CONFIG_BALLOON_COMPACTION shouldn't be selecting options that may not be 
supported, so make it depend on memory compaction rather than selecting 
it.  CONFIG_COMPACTION is enabled by default for all configs that support 
it.
    
Signed-off-by: David Rientjes <rientjes@google.com>
---
 mm/Kconfig |    3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/mm/Kconfig b/mm/Kconfig
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -191,8 +191,7 @@ config SPLIT_PTLOCK_CPUS
 # support for memory balloon compaction
 config BALLOON_COMPACTION
 	bool "Allow for balloon memory compaction/migration"
-	select COMPACTION
-	depends on VIRTIO_BALLOON
+	depends on VIRTIO_BALLOON && COMPACTION
 	help
 	  Memory fragmentation introduced by ballooning might reduce
 	  significantly the number of 2MB contiguous memory blocks that can be

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
