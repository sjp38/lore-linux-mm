From: Andi Kleen <andi@firstfloor.org>
References: <200803071007.493903088@firstfloor.org>
In-Reply-To: <200803071007.493903088@firstfloor.org>
Subject: [PATCH] [2/13] Make get_order(0) return 0
Message-Id: <20080307090712.8CAA21B419C@basil.firstfloor.org>
Date: Fri,  7 Mar 2008 10:07:12 +0100 (CET)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

This is needed for some followup patches. Some old drivers 
(like xd.c) pass 0 to get_order and the compat wrapper for 
the mask allocator doesn't like the resulting underflow.

Signed-off-by: Andi Kleen <ak@suse.de>

---
 include/asm-generic/page.h |    3 +++
 1 file changed, 3 insertions(+)

Index: linux/include/asm-generic/page.h
===================================================================
--- linux.orig/include/asm-generic/page.h
+++ linux/include/asm-generic/page.h
@@ -11,6 +11,9 @@ static __inline__ __attribute_const__ in
 {
 	int order;
 
+	if (size == 0)
+		return 0;
+
 	size = (size - 1) >> (PAGE_SHIFT - 1);
 	order = -1;
 	do {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
