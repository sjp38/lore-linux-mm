Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx109.postini.com [74.125.245.109])
	by kanga.kvack.org (Postfix) with SMTP id 2B1216B004D
	for <linux-mm@kvack.org>; Tue, 27 Nov 2012 19:16:02 -0500 (EST)
Received: by mail-pb0-f41.google.com with SMTP id xa7so9799925pbc.14
        for <linux-mm@kvack.org>; Tue, 27 Nov 2012 16:16:01 -0800 (PST)
Date: Tue, 27 Nov 2012 16:15:59 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: [patch] mm: introduce a common interface for balloon pages mobility
 fix
In-Reply-To: <20121128000355.GA7401@t510.redhat.com>
Message-ID: <alpine.DEB.2.00.1211271614150.22996@chino.kir.corp.google.com>
References: <50a6581a.V3MmP/x4DXU9jUhJ%fengguang.wu@intel.com> <alpine.DEB.2.00.1211161147580.2788@chino.kir.corp.google.com> <20121116201035.GA18145@t510.redhat.com> <alpine.DEB.2.00.1211161402550.17853@chino.kir.corp.google.com>
 <alpine.DEB.2.00.1211271549140.21752@chino.kir.corp.google.com> <20121128000355.GA7401@t510.redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rafael Aquini <aquini@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: kbuild test robot <fengguang.wu@intel.com>, linux-mm@kvack.org, Michal Hocko <mhocko@suse.cz>

It's useful to keep memory defragmented so that all high-order page 
allocations have a chance to succeed, not simply transparent hugepages.  
Thus, allow balloon compaction for any system with memory compaction 
enabled, which is the defconfig.

Signed-off-by: David Rientjes <rientjes@google.com>
---
 mm/Kconfig |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/mm/Kconfig b/mm/Kconfig
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -200,7 +200,7 @@ config SPLIT_PTLOCK_CPUS
 config BALLOON_COMPACTION
 	bool "Allow for balloon memory compaction/migration"
 	def_bool y
-	depends on TRANSPARENT_HUGEPAGE && VIRTIO_BALLOON
+	depends on COMPACTION && VIRTIO_BALLOON
 	help
 	  Memory fragmentation introduced by ballooning might reduce
 	  significantly the number of 2MB contiguous memory blocks that can be

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
