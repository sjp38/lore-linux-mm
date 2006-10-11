Date: Tue, 10 Oct 2006 23:18:02 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: [patch 4/6] generic_file_buffered_write(): fix page prefaulting
Message-Id: <20061010231802.e42582f7.akpm@osdl.org>
In-Reply-To: <20061010231339.a79c1fae.akpm@osdl.org>
References: <20061010121314.19693.75503.sendpatchset@linux.site>
	<20061010121332.19693.37204.sendpatchset@linux.site>
	<20061010221304.6bef249f.akpm@osdl.org>
	<452C8613.7080708@yahoo.com.au>
	<20061010231150.fb9e30f5.akpm@osdl.org>
	<20061010231243.bc8b834c.akpm@osdl.org>
	<20061010231339.a79c1fae.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
From: Andrew Morton <akpm@osdl.org>
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>, Nick Piggin <npiggin@suse.de>, Linux Memory Management <linux-mm@kvack.org>, Linux Kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

generic_file_buffered_write() is passing the wrong length arg to
fault_in_pages_readable() (I think - please check).


Signed-off-by: Andrew Morton <akpm@osdl.org>
---

 mm/filemap.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff -puN mm/filemap.c~generic_file_buffered_write-fix-page-prefaulting mm/filemap.c
--- a/mm/filemap.c~generic_file_buffered_write-fix-page-prefaulting
+++ a/mm/filemap.c
@@ -2110,7 +2110,7 @@ generic_file_buffered_write(struct kiocb
 		 * same page as we're writing to, without it being marked
 		 * up-to-date.
 		 */
-		fault_in_pages_readable(buf, maxlen);
+		fault_in_pages_readable(buf, bytes);
 
 		page = __grab_cache_page(mapping,index,&cached_page,&lru_pvec);
 		if (!page) {
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
