Date: Thu, 18 Oct 2007 12:20:38 +0900
From: Yasunori Goto <y-goto@jp.fujitsu.com>
Subject: [Patch 000/002](memory hotplug) Rearrange notifier of memory hotplug (take 2)
Message-Id: <20071018120343.5146.Y-GOTO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Yasunori Goto <y-goto@jp.fujitsu.com>, Christoph Lameter <clameter@sgi.com>, Linux Kernel ML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hello.

This patch set is to rearrange event notifier for memory hotplug,
because the old notifier has some defects. For example, there is no
information like new memory's pfn and # of pages for callback functions.

Fortunately, nothing uses this notifier so far, there is no impact by
this change. (SLUB will use this after this patch set to make
kmem_cache_node structure).

In addition, descriptions of notifer is added to memory hotplug
document.

This patch was a part of patch set to make kmem_cache_node of SLUB 
to avoid panic of memory online. But, I think this change becomes
not only for SLUB but also for others. So, I extracted this from it.

This patch set is for 2.6.23-mm1.
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
