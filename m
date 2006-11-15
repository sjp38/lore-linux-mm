Date: Wed, 15 Nov 2006 18:36:43 +0100
From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH 0/3] node-aware skb allocations
Message-ID: <20061115173643.GA17695@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org, davem@davemloft.net
Cc: netdev@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

This is the final version of the node-aware skb allocations,
implementing davem's suggestion of storing the numa node in
struct device.  I'd love to get this into 2.6.20 now that I
don't hear negative comments about it anymre, but I wonder
how.  The first patch toches mm/slab.c, the second struct device
and assorted files and only the last one is actually in the networking
code.  Should Dave push all this through net-2.6.20 or should we
get it in purely through -mm?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
