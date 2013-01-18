Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx115.postini.com [74.125.245.115])
	by kanga.kvack.org (Postfix) with SMTP id 68A9E6B0006
	for <linux-mm@kvack.org>; Fri, 18 Jan 2013 02:55:47 -0500 (EST)
From: Lin Feng <linfeng@cn.fujitsu.com>
Subject: [PATCH] memory-hotplug: mm/Kconfig: move auto selects from MEMORY_HOTPLUG to MEMORY_HOTREMOVE as needed
Date: Fri, 18 Jan 2013 15:54:36 +0800
Message-Id: <1358495676-4488-1-git-send-email-linfeng@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, kamezawa.hiroyu@jp.fujitsu.com
Cc: mhocko@suse.cz, mel@csn.ul.ie, minchan@kernel.org, aquini@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, wency@cn.fujitsu.com, tangchen@cn.fujitsu.com, laijs@cn.fujitsu.com, Lin Feng <linfeng@cn.fujitsu.com>

Since we have 2 config options called MEMORY_HOTPLUG and MEMORY_HOTREMOVE
used for memory hot-add and hot-remove separately, and codes in function
register_page_bootmem_info_node() are only used for collecting infomation
for hot-remove(commit 04753278), so move it to MEMORY_HOTREMOVE.

Besides page_isolation.c selected by MEMORY_ISOLATION under MEMORY_HOTPLUG
is also such case, move it too.

Signed-off-by: Lin Feng <linfeng@cn.fujitsu.com>
---
 mm/Kconfig |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/Kconfig b/mm/Kconfig
index f8c5799..a96c010 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -172,8 +172,6 @@ config HAVE_BOOTMEM_INFO_NODE
 # eventually, we can have this option just 'select SPARSEMEM'
 config MEMORY_HOTPLUG
 	bool "Allow for memory hot-add"
-	select MEMORY_ISOLATION
-	select HAVE_BOOTMEM_INFO_NODE if X86_64
 	depends on SPARSEMEM || X86_64_ACPI_NUMA
 	depends on HOTPLUG && ARCH_ENABLE_MEMORY_HOTPLUG
 	depends on (IA64 || X86 || PPC_BOOK3S_64 || SUPERH || S390)
@@ -184,6 +182,8 @@ config MEMORY_HOTPLUG_SPARSE
 
 config MEMORY_HOTREMOVE
 	bool "Allow for memory hot remove"
+	select MEMORY_ISOLATION
+	select HAVE_BOOTMEM_INFO_NODE if X86_64
 	depends on MEMORY_HOTPLUG && ARCH_ENABLE_MEMORY_HOTREMOVE
 	depends on MIGRATION
 
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
