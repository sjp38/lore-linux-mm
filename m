Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 550B76B00A2
	for <linux-mm@kvack.org>; Sun,  2 Jan 2011 21:50:02 -0500 (EST)
Date: Sun, 02 Jan 2011 18:48:01 -0500
Message-Id: <E1PZXeb-0004AV-2b@tytso-glaptop>
Subject: Should we be using unlikely() around tests of GFP_ZERO?
From: "Theodore Ts'o" <tytso@mit.edu>
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Matt Mackall <mpm@selenic.com>, linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>


Given the patches being busily submitted by trivial patch submitters to
make use kmem_cache_zalloc(), et. al, I believe we should remove the
unlikely() tests around the (gfp_flags & __GFP_ZERO) tests, such as:

-	if (unlikely((flags & __GFP_ZERO) && objp))
+	if ((flags & __GFP_ZERO) && objp)
		memset(objp, 0, obj_size(cachep));

Agreed?  If so, I'll send a patch...

	    					- Ted

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
