Message-ID: <41C943F0.4090006@yahoo.com.au>
Date: Wed, 22 Dec 2004 20:52:48 +1100
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: [PATCH 1/11] parentheses to x86-64 macro
References: <41C94361.6070909@yahoo.com.au>
In-Reply-To: <41C94361.6070909@yahoo.com.au>
Content-Type: multipart/mixed;
 boundary="------------070805040007090300030203"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@osdl.org>
Cc: Andrew Morton <akpm@osdl.org>, Andi Kleen <ak@suse.de>, Hugh Dickins <hugh@veritas.com>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------070805040007090300030203
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

1/11

Not strictly a 4level patch, but a warning was spat at me at one
stage during my travels.


--------------070805040007090300030203
Content-Type: text/plain;
 name="x86-64-fix-macro.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x86-64-fix-macro.patch"



Add parentheses to x86-64's pgd_index's arguments

Signed-off-by: Nick Piggin <nickpiggin@yahoo.com.au>


---

 linux-2.6-npiggin/include/asm-x86_64/pgtable.h |    2 +-
 1 files changed, 1 insertion(+), 1 deletion(-)

diff -puN include/asm-x86_64/pgtable.h~x86-64-fix-macro include/asm-x86_64/pgtable.h
--- linux-2.6/include/asm-x86_64/pgtable.h~x86-64-fix-macro	2004-12-22 20:29:41.000000000 +1100
+++ linux-2.6-npiggin/include/asm-x86_64/pgtable.h	2004-12-22 20:35:55.000000000 +1100
@@ -311,7 +311,7 @@ static inline int pmd_large(pmd_t pte) {
 
 /* PGD - Level3 access */
 /* to find an entry in a page-table-directory. */
-#define pgd_index(address) ((address >> PGDIR_SHIFT) & (PTRS_PER_PGD-1))
+#define pgd_index(address) (((address) >> PGDIR_SHIFT) & (PTRS_PER_PGD-1))
 static inline pgd_t *__pgd_offset_k(pgd_t *pgd, unsigned long address)
 { 
 	return pgd + pgd_index(address);

_

--------------070805040007090300030203--
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
