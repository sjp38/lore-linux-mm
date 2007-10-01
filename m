Date: Mon, 01 Oct 2007 18:30:52 +0900
From: Yasunori Goto <y-goto@jp.fujitsu.com>
Subject: [Patch / 000](memory hotplug) Fix NULL pointer access of kmem_cache_node when hot-add.
Message-Id: <20071001182329.7A97.Y-GOTO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Christoph Lameter <clameter@sgi.com>, Linux Kernel ML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Yasunori Goto <y-goto@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

Hello.

This patch set is to fix panic due to access NULL pointer of SLUB.

When new memory is hot-added on the new node (or memory less node),
kmem_cache_node for the new node is not prepared,
and panic occurs by it. So, new kmem_cache_node should be created
before new memory is available on the node.

This is the first user of the callback of memory notifier.
So, the first patch is to change some defects of it.

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
