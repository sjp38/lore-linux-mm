Date: Tue, 10 Oct 2006 23:18:05 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: [patch 5/6] generic_file_buffered_write(): max_len cleanup
Message-Id: <20061010231805.3517f5e1.akpm@osdl.org>
In-Reply-To: <20061010231424.db88931f.akpm@osdl.org>
References: <20061010121314.19693.75503.sendpatchset@linux.site>
	<20061010121332.19693.37204.sendpatchset@linux.site>
	<20061010221304.6bef249f.akpm@osdl.org>
	<452C8613.7080708@yahoo.com.au>
	<20061010231150.fb9e30f5.akpm@osdl.org>
	<20061010231243.bc8b834c.akpm@osdl.org>
	<20061010231339.a79c1fae.akpm@osdl.org>
	<20061010231424.db88931f.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
From: Andrew Morton <akpm@osdl.org>
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>, Nick Piggin <npiggin@suse.de>, Linux Memory Management <linux-mm@kvack.org>, Linux Kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

More dirty code.

Signed-off-by: Andrew Morton <akpm@osdl.org>
---

 mm/filemap.c |    5 +----
 1 file changed, 1 insertion(+), 4 deletions(-)

diff -puN mm/filemap.c~generic_file_buffered_write-max_len-cleanup mm/filemap.c
--- a/mm/filemap.c~generic_file_buffered_write-max_len-cleanup
+++ a/mm/filemap.c
@@ -2090,7 +2090,6 @@ generic_file_buffered_write(struct kiocb
 	do {
 		pgoff_t index;		/* Pagecache index for current page */
 		unsigned long offset;	/* Offset into pagecache page */
-		unsigned long maxlen;	/* Bytes remaining in current iovec */
 		size_t bytes;		/* Bytes to write to page */
 		size_t copied;		/* Bytes copied from user */
 
@@ -2100,9 +2099,7 @@ generic_file_buffered_write(struct kiocb
 		if (bytes > count)
 			bytes = count;
 
-		maxlen = cur_iov->iov_len - iov_offset;
-		if (maxlen > bytes)
-			maxlen = bytes;
+		bytes = min(cur_iov->iov_len - iov_offset, bytes);
 
 		/*
 		 * Bring in the user page that we will copy from _first_.
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
