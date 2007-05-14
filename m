Message-Id: <20070514131904.440041502@chello.nl>
Date: Mon, 14 May 2007 15:19:04 +0200
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [PATCH 0/5] make slab gfp fair
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Thomas Graf <tgraf@suug.ch>, David Miller <davem@davemloft.net>, Andrew Morton <akpm@linux-foundation.org>, Daniel Phillips <phillips@google.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Christoph Lameter <clameter@sgi.com>, Matt Mackall <mpm@selenic.com>
List-ID: <linux-mm.kvack.org>

In the interest of creating a reserve based allocator; we need to make the slab
allocator (*sigh*, all three) fair with respect to GFP flags.

That is, we need to protect memory from being used by easier gfp flags than it
was allocated with. If our reserve is placed below GFP_ATOMIC, we do not want a
GFP_KERNEL allocation to walk away with it - a scenario that is perfectly
possible with the current allocators.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
