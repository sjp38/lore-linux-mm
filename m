Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f71.google.com (mail-vk0-f71.google.com [209.85.213.71])
	by kanga.kvack.org (Postfix) with ESMTP id 498436B0038
	for <linux-mm@kvack.org>; Thu, 30 Mar 2017 16:11:52 -0400 (EDT)
Received: by mail-vk0-f71.google.com with SMTP id n73so25255717vke.6
        for <linux-mm@kvack.org>; Thu, 30 Mar 2017 13:11:52 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id j57si1359974uaa.67.2017.03.30.13.11.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 30 Mar 2017 13:11:49 -0700 (PDT)
From: Mauro Carvalho Chehab <mchehab@s-opensource.com>
Subject: [PATCH 9/9] kernel-api.rst: fix a series of errors when parsing C files
Date: Thu, 30 Mar 2017 17:11:36 -0300
Message-Id: <5c39bc852b201759de4cf901f7e9ad04715285d9.1490904090.git.mchehab@s-opensource.com>
In-Reply-To: <cover.1490904090.git.mchehab@s-opensource.com>
References: <cover.1490904090.git.mchehab@s-opensource.com>
In-Reply-To: <cover.1490904090.git.mchehab@s-opensource.com>
References: <cover.1490904090.git.mchehab@s-opensource.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux Media Mailing List <linux-media@vger.kernel.org>, Linux Doc Mailing List <linux-doc@vger.kernel.org>
Cc: Mauro Carvalho Chehab <mchehab@s-opensource.com>, Mauro Carvalho Chehab <mchehab@infradead.org>, Jens Axboe <axboe@kernel.dk>, Bjorn Helgaas <bhelgaas@google.com>, Russell King <linux@armlinux.org.uk>, James Morris <james.l.morris@oracle.com>, "Serge E. Hallyn" <serge@hallyn.com>, Mauro Carvalho Chehab <mchehab@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Nicholas Piggin <npiggin@gmail.com>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Michal Hocko <mhocko@suse.com>, Hillf Danton <hillf.zj@alibaba-inc.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, zijun_hu <zijun_hu@htc.com>, Chris Wilson <chris@chris-wilson.co.uk>, Andrey Ryabinin <aryabinin@virtuozzo.com>, linux-block@vger.kernel.org, linux-pci@vger.kernel.org, linux-clk@vger.kernel.org, linux-mm@kvack.org, linux-security-module@vger.kernel.org

./lib/string.c:134: WARNING: Inline emphasis start-string without end-string.
./mm/filemap.c:522: WARNING: Inline interpreted text or phrase reference start-string without end-string.
./mm/filemap.c:1283: ERROR: Unexpected indentation.
./mm/filemap.c:3003: WARNING: Inline interpreted text or phrase reference start-string without end-string.
./mm/vmalloc.c:1544: WARNING: Inline emphasis start-string without end-string.
./mm/page_alloc.c:4245: ERROR: Unexpected indentation.
./ipc/util.c:676: ERROR: Unexpected indentation.
./drivers/pci/irq.c:35: WARNING: Block quote ends without a blank line; unexpected unindent.
./security/security.c:109: ERROR: Unexpected indentation.
./security/security.c:110: WARNING: Definition list ends without a blank line; unexpected unindent.
./block/genhd.c:275: WARNING: Inline strong start-string without end-string.
./block/genhd.c:283: WARNING: Inline strong start-string without end-string.
./include/linux/clk.h:134: WARNING: Inline emphasis start-string without end-string.
./include/linux/clk.h:134: WARNING: Inline emphasis start-string without end-string.
./ipc/util.c:477: ERROR: Unknown target name: "s".

Signed-off-by: Mauro Carvalho Chehab <mchehab@s-opensource.com>
---
 block/genhd.c       |  7 ++++---
 drivers/pci/irq.c   |  2 +-
 include/linux/clk.h |  4 ++--
 ipc/util.c          | 12 +++++++-----
 lib/string.c        |  2 +-
 mm/filemap.c        | 18 ++++++++++--------
 mm/page_alloc.c     |  3 ++-
 mm/vmalloc.c        |  2 +-
 security/security.c | 12 ++++++++----
 9 files changed, 36 insertions(+), 26 deletions(-)

diff --git a/block/genhd.c b/block/genhd.c
index b26a5ea115d0..a53bfd19a0ec 100644
--- a/block/genhd.c
+++ b/block/genhd.c
@@ -271,16 +271,17 @@ void blkdev_show(struct seq_file *seqf, off_t offset)
 /**
  * register_blkdev - register a new block device
  *
- * @major: the requested major device number [1..255]. If @major=0, try to
+ * @major: the requested major device number [1..255]. If @major = 0, try to
  *         allocate any unused major number.
  * @name: the name of the new block device as a zero terminated string
  *
  * The @name must be unique within the system.
  *
- * The return value depends on the @major input parameter.
+ * The return value depends on the @major input parameter:
+ *
  *  - if a major device number was requested in range [1..255] then the
  *    function returns zero on success, or a negative error code
- *  - if any unused major number was requested with @major=0 parameter
+ *  - if any unused major number was requested with @major = 0 parameter
  *    then the return value is the allocated major number in range
  *    [1..255] or a negative error code otherwise
  */
diff --git a/drivers/pci/irq.c b/drivers/pci/irq.c
index 6684f153ab57..f9f2a0324ecc 100644
--- a/drivers/pci/irq.c
+++ b/drivers/pci/irq.c
@@ -31,7 +31,7 @@ static void pci_note_irq_problem(struct pci_dev *pdev, const char *reason)
  * driver).
  *
  * Returns:
- *  a suggestion for fixing it (although the driver is not required to
+ * a suggestion for fixing it (although the driver is not required to
  * act on this).
  */
 enum pci_lost_interrupt_reason pci_lost_interrupt(struct pci_dev *pdev)
diff --git a/include/linux/clk.h b/include/linux/clk.h
index e9d36b3e49de..024cd07870d0 100644
--- a/include/linux/clk.h
+++ b/include/linux/clk.h
@@ -132,8 +132,8 @@ int clk_get_phase(struct clk *clk);
  * @q: clk compared against p
  *
  * Returns true if the two struct clk pointers both point to the same hardware
- * clock node. Put differently, returns true if struct clk *p and struct clk *q
- * share the same struct clk_core object.
+ * clock node. Put differently, returns true if @p and @q
+ * share the same &struct clk_core object.
  *
  * Returns false otherwise. Note that two NULL clks are treated as matching.
  */
diff --git a/ipc/util.c b/ipc/util.c
index 798cad18dd87..3459a16a9df9 100644
--- a/ipc/util.c
+++ b/ipc/util.c
@@ -474,7 +474,7 @@ void ipc_rcu_free(struct rcu_head *head)
  * Check user, group, other permissions for access
  * to ipc resources. return 0 if allowed
  *
- * @flag will most probably be 0 or S_...UGO from <linux/stat.h>
+ * @flag will most probably be 0 or ``S_...UGO`` from <linux/stat.h>
  */
 int ipcperms(struct ipc_namespace *ns, struct kern_ipc_perm *ipcp, short flag)
 {
@@ -672,10 +672,12 @@ int ipc_update_perm(struct ipc64_perm *in, struct kern_ipc_perm *out)
  *
  * This function does some common audit and permissions check for some IPC_XXX
  * cmd and is called from semctl_down, shmctl_down and msgctl_down.
- * It must be called without any lock held and
- *  - retrieves the ipc with the given id in the given table.
- *  - performs some audit and permission check, depending on the given cmd
- *  - returns a pointer to the ipc object or otherwise, the corresponding error.
+ * It must be called without any lock held and:
+ *
+ *   - retrieves the ipc with the given id in the given table.
+ *   - performs some audit and permission check, depending on the given cmd
+ *   - returns a pointer to the ipc object or otherwise, the corresponding
+ *     error.
  *
  * Call holding the both the rwsem and the rcu read lock.
  */
diff --git a/lib/string.c b/lib/string.c
index ed83562a53ae..b5c9a1168d3a 100644
--- a/lib/string.c
+++ b/lib/string.c
@@ -131,7 +131,7 @@ EXPORT_SYMBOL(strncpy);
  * @src: Where to copy the string from
  * @size: size of destination buffer
  *
- * Compatible with *BSD: the result is always a valid
+ * Compatible with ``*BSD``: the result is always a valid
  * NUL-terminated string that fits in the buffer (unless,
  * of course, the buffer size is zero). It does not pad
  * out the result like strncpy() does.
diff --git a/mm/filemap.c b/mm/filemap.c
index 1694623a6289..c5808b7a5fb1 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -519,7 +519,7 @@ EXPORT_SYMBOL(filemap_write_and_wait);
  *
  * Write out and wait upon file offsets lstart->lend, inclusive.
  *
- * Note that `lend' is inclusive (describes the last byte to be written) so
+ * Note that @lend is inclusive (describes the last byte to be written) so
  * that this function can be used to write to the very end-of-file (end = -1).
  */
 int filemap_write_and_wait_range(struct address_space *mapping,
@@ -1277,12 +1277,14 @@ EXPORT_SYMBOL(find_lock_entry);
  *
  * PCG flags modify how the page is returned.
  *
- * FGP_ACCESSED: the page will be marked accessed
- * FGP_LOCK: Page is return locked
- * FGP_CREAT: If page is not present then a new page is allocated using
- *		@gfp_mask and added to the page cache and the VM's LRU
- *		list. The page is returned locked and with an increased
- *		refcount. Otherwise, %NULL is returned.
+ * @fgp_flags can be:
+ *
+ * - FGP_ACCESSED: the page will be marked accessed
+ * - FGP_LOCK: Page is return locked
+ * - FGP_CREAT: If page is not present then a new page is allocated using
+ *   @gfp_mask and added to the page cache and the VM's LRU
+ *   list. The page is returned locked and with an increased
+ *   refcount. Otherwise, NULL is returned.
  *
  * If FGP_LOCK or FGP_CREAT are specified then the function may sleep even
  * if the GFP flags specified for FGP_CREAT are atomic.
@@ -3001,7 +3003,7 @@ EXPORT_SYMBOL(generic_file_write_iter);
  * @gfp_mask: memory allocation flags (and I/O mode)
  *
  * The address_space is to try to release any data against the page
- * (presumably at page->private).  If the release was successful, return `1'.
+ * (presumably at page->private).  If the release was successful, return '1'.
  * Otherwise return zero.
  *
  * This may also be called if PG_fscache is set on a page, indicating that the
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index eaa64d2ffdc5..c1b68edaf106 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -4242,7 +4242,8 @@ EXPORT_SYMBOL(free_pages_exact);
  * nr_free_zone_pages() counts the number of counts pages which are beyond the
  * high watermark within all zones at or below a given zone index.  For each
  * zone, the number of pages is calculated as:
- *     managed_pages - high_pages
+ *
+ *     nr_free_zone_pages = managed_pages - high_pages
  */
 static unsigned long nr_free_zone_pages(int offset)
 {
diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index b4024d688f38..c24db06f15c4 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -1540,7 +1540,7 @@ void vfree_atomic(const void *addr)
  *	have CONFIG_ARCH_HAVE_NMI_SAFE_CMPXCHG, but making the calling
  *	conventions for vfree() arch-depenedent would be a really bad idea)
  *
- *	NOTE: assumes that the object at *addr has a size >= sizeof(llist_node)
+ *	NOTE: assumes that the object at @addr has a size >= sizeof(llist_node)
  */
 void vfree(const void *addr)
 {
diff --git a/security/security.c b/security/security.c
index d0e07f269b2d..23555c5504f6 100644
--- a/security/security.c
+++ b/security/security.c
@@ -103,10 +103,14 @@ static int lsm_append(char *new, char **result)
  * to avoid security registration races. This method may also be used
  * to check if your LSM is currently loaded during kernel initialization.
  *
- * Return true if:
- *	-The passed LSM is the one chosen by user at boot time,
- *	-or the passed LSM is configured as the default and the user did not
- *	 choose an alternate LSM at boot time.
+ * Returns:
+ *
+ * true if:
+ *
+ * - The passed LSM is the one chosen by user at boot time,
+ * - or the passed LSM is configured as the default and the user did not
+ *   choose an alternate LSM at boot time.
+ *
  * Otherwise, return false.
  */
 int __init security_module_enable(const char *module)
-- 
2.9.3


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
