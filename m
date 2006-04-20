Date: Thu, 20 Apr 2006 19:03:24 +0900
From: Yasunori Goto <y-goto@jp.fujitsu.com>
Subject: [Patch: 000/006] pgdat allocation for new node add
Message-Id: <20060420185123.EE48.Y-GOTO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Linux Kernel ML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Yasunori Goto <y-goto@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

Hello.

These are parts of patches for new nodes addition v4.
When new node is added, new pgdat is allocated and initialized by this patch.
These includes...
  - specify node id at add_memory().
  - start kswapd for new node.
  - allocate pgdat and register its address to node_data[].

This set includes node_data[] updater for generic arch.
Ia64 has copies of node_data[] on each node.
But, this patch set doesn't include patches to update them.
I'll post them later.


This patch is for 2.6.17-rc1-mm3.

Please apply.

------------------------------------------------------------

Change log from v4 of node hot-add.
  - generic pgdat allocation is picked up.
  - update for 2.6.17-rc1-mm3.

V4 of post is here.
<description>
http://marc.theaimsgroup.com/?l=linux-mm&m=114258404023573&w=2
<patches>
http://marc.theaimsgroup.com/?l=linux-mm&w=2&r=1&s=memory+hotplug+node+v.4.&q=b



-- 
Yasunori Goto 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
