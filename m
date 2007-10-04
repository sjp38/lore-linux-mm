Message-Id: <20071004040005.171632278@sgi.com>
References: <20071004035935.042951211@sgi.com>
Date: Wed, 03 Oct 2007 20:59:50 -0700
From: Christoph Lameter <clameter@sgi.com>
Subject: [15/18] Fallback for temporary order 2 allocation
Content-Disposition: inline; filename=vcompound_crypto
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Dan Williams <dan.j.williams@intel.com>
List-ID: <linux-mm.kvack.org>

The cryto subsystem needs an order 2 allocation. This is a temporary buffer
for xoring data so we can safely allow fallback.

Cc: Dan Williams <dan.j.williams@intel.com>
Signed-off-by: Christoph Lameter <clameter@sgi.com>

---
 crypto/xor.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

Index: linux-2.6/crypto/xor.c
===================================================================
--- linux-2.6.orig/crypto/xor.c	2007-10-03 18:11:20.000000000 -0700
+++ linux-2.6/crypto/xor.c	2007-10-03 18:12:14.000000000 -0700
@@ -101,7 +101,7 @@ calibrate_xor_blocks(void)
 	void *b1, *b2;
 	struct xor_block_template *f, *fastest;
 
-	b1 = (void *) __get_free_pages(GFP_KERNEL, 2);
+	b1 = (void *) __get_free_pages(GFP_VFALLBACK, 2);
 	if (!b1) {
 		printk(KERN_WARNING "xor: Yikes!  No memory available.\n");
 		return -ENOMEM;

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
