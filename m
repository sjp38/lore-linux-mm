Message-ID: <42BA5F5C.3080101@yahoo.com.au>
Date: Thu, 23 Jun 2005 17:06:04 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: [patch][rfc] 1/5: comment for mm/rmap.c
References: <42BA5F37.6070405@yahoo.com.au>
In-Reply-To: <42BA5F37.6070405@yahoo.com.au>
Content-Type: multipart/mixed;
 boundary="------------070204050208010906070700"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel <linux-kernel@vger.kernel.org>, Linux Memory Management <linux-mm@kvack.org>
Cc: Hugh Dickins <hugh@veritas.com>, Badari Pulavarty <pbadari@us.ibm.com>
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------070204050208010906070700
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

1/5

--------------070204050208010906070700
Content-Type: text/plain;
 name="mm-comment-rmap.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="mm-comment-rmap.patch"

Just be clear that VM_RESERVED pages here are a bug, and the test
is not there because they are expected.

Signed-off-by: Nick Piggin <npiggin@suse.de>

Index: linux-2.6/mm/rmap.c
===================================================================
--- linux-2.6.orig/mm/rmap.c
+++ linux-2.6/mm/rmap.c
@@ -532,6 +532,8 @@ static int try_to_unmap_one(struct page 
 	 * If the page is mlock()d, we cannot swap it out.
 	 * If it's recently referenced (perhaps page_referenced
 	 * skipped over this mm) then we should reactivate it.
+	 *
+	 * Pages belonging to VM_RESERVED regions should not happen here.
 	 */
 	if ((vma->vm_flags & (VM_LOCKED|VM_RESERVED)) ||
 			ptep_clear_flush_young(vma, address, pte)) {

--------------070204050208010906070700--
Send instant messages to your online friends http://au.messenger.yahoo.com 
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
