Message-ID: <41EDAA6E.5000900@mvista.com>
Date: Tue, 18 Jan 2005 16:31:42 -0800
From: Steve Longerbeam <stevel@mvista.com>
MIME-Version: 1.0
Subject: BUG in shared_policy_replace() ?
Content-Type: multipart/mixed;
 boundary="------------020207020808080703030302"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@suse.de>
Cc: linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------020207020808080703030302
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Hi Andi,

Why free the shared policy created to split up an old
policy that spans the whole new range? Ie, see patch.

Steve

--------------020207020808080703030302
Content-Type: text/plain;
 name="mempolicy.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="mempolicy.diff"

--- mm/mempolicy.c.orig	2005-01-18 16:13:35.573273351 -0800
+++ mm/mempolicy.c	2005-01-18 16:24:23.940608135 -0800
@@ -1052,10 +1052,6 @@
 	if (new)
 		sp_insert(sp, new);
 	spin_unlock(&sp->lock);
-	if (new2) {
-		mpol_free(new2->policy);
-		kmem_cache_free(sn_cache, new2);
-	}
 	return 0;
 }
 

--------------020207020808080703030302--
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
