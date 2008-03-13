Date: Thu, 13 Mar 2008 10:40:28 -0700
From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: [PATCH -mmotm] mm: highmem kernel-doc additions
Message-Id: <20080313104028.b43db9ea.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
From: Randy Dunlap <randy.dunlap@oracle.com>
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: akpm <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Add kernel-doc comments to highmem.c.

Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>
---
 mm/highmem.c |   30 ++++++++++++++++++++++++++----
 1 file changed, 26 insertions(+), 4 deletions(-)

--- linux-2.6.25-rc5.orig/mm/highmem.c
+++ linux-2.6.25-rc5/mm/highmem.c
@@ -104,8 +104,9 @@ static void flush_all_zero_pkmaps(void)
 	flush_tlb_kernel_range(PKMAP_ADDR(0), PKMAP_ADDR(LAST_PKMAP));
 }
 
-/* Flush all unused kmap mappings in order to remove stray
-   mappings. */
+/**
+ * kmap_flush_unused - flush all unused kmap mappings in order to remove stray mappings
+ */
 void kmap_flush_unused(void)
 {
 	spin_lock(&kmap_lock);
@@ -163,6 +164,14 @@ start:
 	return vaddr;
 }
 
+/**
+ * kmap_high - map a highmem page into memory
+ * @page: &struct page to map
+ *
+ * Returns the page's virtual memory address.
+ *
+ * We cannot call this from interrupts, as it may block.
+ */
 void *kmap_high(struct page *page)
 {
 	unsigned long vaddr;
@@ -170,8 +179,6 @@ void *kmap_high(struct page *page)
 	/*
 	 * For highmem pages, we can't trust "virtual" until
 	 * after we have the lock.
-	 *
-	 * We cannot call this from interrupts, as it may block
 	 */
 	spin_lock(&kmap_lock);
 	vaddr = (unsigned long)page_address(page);
@@ -185,6 +192,10 @@ void *kmap_high(struct page *page)
 
 EXPORT_SYMBOL(kmap_high);
 
+/**
+ * kunmap_high - map a highmem page into memory
+ * @page: &struct page to unmap
+ */
 void kunmap_high(struct page *page)
 {
 	unsigned long vaddr;
@@ -259,6 +270,12 @@ static struct page_address_slot *page_sl
 	return &page_address_htable[hash_ptr(page, PA_HASH_ORDER)];
 }
 
+/**
+ * page_address - get the mapped virtual address of a page
+ * @page: &struct page to get the virtual address of
+ *
+ * Returns the page's virtual address.
+ */
 void *page_address(struct page *page)
 {
 	unsigned long flags;
@@ -288,6 +305,11 @@ done:
 
 EXPORT_SYMBOL(page_address);
 
+/**
+ * set_page_address - set a page's virtual address
+ * @page: &struct page to set
+ * @virtual: virtual address to use
+ */
 void set_page_address(struct page *page, void *virtual)
 {
 	unsigned long flags;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
