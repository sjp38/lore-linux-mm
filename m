Date: Fri, 12 Oct 2007 11:24:09 +0900
From: Yasunori Goto <y-goto@jp.fujitsu.com>
Subject: [Patch 000/002] Make kmem_cache_node for SLUB on memory online to avoid panic(take 2)
In-Reply-To: <20071012111008.B995.Y-GOTO@jp.fujitsu.com>
References: <20071012111008.B995.Y-GOTO@jp.fujitsu.com>
Message-Id: <20071012112236.B99B.Y-GOTO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Christoph Lameter <clameter@sgi.com>, Hiroyuki KAMEZAWA <kamezawa.hiroyu@jp.fujitsu.com>, Linux Kernel ML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

This patch set is to fix panic due to access NULL pointer of SLUB.

When new memory is hot-added on the new node (or memory less node),
kmem_cache_node for the new node is not prepared,
and panic occurs by it. So, kmem_cache_node should be created for the node
before new memory is available on the node.
Incidentally, it is freed on memory offline if it becomes not necessary.

This is the first user of the callback of memory notifier, and
requires its rearrange patch set.

This patch set is for 2.6.23-rc8-mm2.
I tested this patch on my ia64 box.

Please apply.

Bye.


-- 
Yasunori Goto 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
