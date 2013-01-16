Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx195.postini.com [74.125.245.195])
	by kanga.kvack.org (Postfix) with SMTP id EC5C76B006E
	for <linux-mm@kvack.org>; Wed, 16 Jan 2013 03:15:31 -0500 (EST)
From: Lin Feng <linfeng@cn.fujitsu.com>
Subject: [PATCH 2/2] memory-hotplug: cleanup: removing the arch specific functions without any implementation
Date: Wed, 16 Jan 2013 16:14:19 +0800
Message-Id: <1358324059-9608-3-git-send-email-linfeng@cn.fujitsu.com>
In-Reply-To: <1358324059-9608-1-git-send-email-linfeng@cn.fujitsu.com>
References: <1358324059-9608-1-git-send-email-linfeng@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mhocko@suse.cz, linux-mm@kvack.org, tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com, jbeulich@suse.com, dhowells@redhat.com, wency@cn.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, paul.gortmaker@windriver.com, laijs@cn.fujitsu.com, kamezawa.hiroyu@jp.fujitsu.com, mel@csn.ul.ie, minchan@kernel.org, aquini@redhat.com, jiang.liu@huawei.com, tony.luck@intel.com, fenghua.yu@intel.com, benh@kernel.crashing.org, paulus@samba.org, schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com, davem@davemloft.net, michael@ellerman.id.au, gerald.schaefer@de.ibm.com, gregkh@linuxfoundation.org
Cc: x86@kernel.org, linux390@de.ibm.com, linux-ia64@vger.kernel.org, linux-s390@vger.kernel.org, sparclinux@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org, linfeng@cn.fujitsu.com, tangchen@cn.fujitsu.com

From: Michal Hocko <mhocko@suse.cz>

After introducing CONFIG_HAVE_BOOTMEM_INFO_NODE Kconfig option, the related arch
specific functions become confusing, remove them.

Guys who want to implement memory-hotplug feature on such archs for this part
should look into register_page_bootmem_info_node() and flesh out from top to
end.

Signed-off-by: Michal Hocko <mhocko@suse.cz>
Signed-off-by: Lin Feng <linfeng@cn.fujitsu.com>
---
 arch/ia64/mm/discontig.c  |    5 -----
 arch/powerpc/mm/init_64.c |    5 -----
 arch/s390/mm/vmem.c       |    6 ------
 arch/sparc/mm/init_64.c   |    5 -----
 4 files changed, 0 insertions(+), 21 deletions(-)

diff --git a/arch/ia64/mm/discontig.c b/arch/ia64/mm/discontig.c
index 882a0fd..cb5e1ff 100644
--- a/arch/ia64/mm/discontig.c
+++ b/arch/ia64/mm/discontig.c
@@ -827,9 +827,4 @@ void vmemmap_free(struct page *memmap, unsigned long nr_pages)
 {
 }
 
-void register_page_bootmem_memmap(unsigned long section_nr,
-				  struct page *start_page, unsigned long size)
-{
-	/* TODO */
-}
 #endif
diff --git a/arch/powerpc/mm/init_64.c b/arch/powerpc/mm/init_64.c
index 2969591..7e2246f 100644
--- a/arch/powerpc/mm/init_64.c
+++ b/arch/powerpc/mm/init_64.c
@@ -302,10 +302,5 @@ void vmemmap_free(struct page *memmap, unsigned long nr_pages)
 {
 }
 
-void register_page_bootmem_memmap(unsigned long section_nr,
-				  struct page *start_page, unsigned long size)
-{
-	/* TODO */
-}
 #endif /* CONFIG_SPARSEMEM_VMEMMAP */
 
diff --git a/arch/s390/mm/vmem.c b/arch/s390/mm/vmem.c
index 81e6ba3..fa09c2f 100644
--- a/arch/s390/mm/vmem.c
+++ b/arch/s390/mm/vmem.c
@@ -276,12 +276,6 @@ void vmemmap_free(struct page *memmap, unsigned long nr_pages)
 {
 }
 
-void register_page_bootmem_memmap(unsigned long section_nr,
-				  struct page *start_page, unsigned long size)
-{
-	/* TODO */
-}
-
 /*
  * Add memory segment to the segment list if it doesn't overlap with
  * an already present segment.
diff --git a/arch/sparc/mm/init_64.c b/arch/sparc/mm/init_64.c
index 5afe21a..76ac544 100644
--- a/arch/sparc/mm/init_64.c
+++ b/arch/sparc/mm/init_64.c
@@ -2236,11 +2236,6 @@ void vmemmap_free(struct page *memmap, unsigned long nr_pages)
 {
 }
 
-void register_page_bootmem_memmap(unsigned long section_nr,
-				  struct page *start_page, unsigned long size)
-{
-	/* TODO */
-}
 #endif /* CONFIG_SPARSEMEM_VMEMMAP */
 
 static void prot_init_common(unsigned long page_none,
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
