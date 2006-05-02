Date: Tue, 02 May 2006 20:30:38 +0900
From: Yasunori Goto <y-goto@jp.fujitsu.com>
Subject: [Patch 000/003] pgdat allocation and update for ia64 of memory hotplug.
Message-Id: <20060502201614.CF14.Y-GOTO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Yasunori Goto <y-goto@jp.fujitsu.com>, Linux Kernel ML <linux-kernel@vger.kernel.org>, "Luck, Tony" <tony.luck@intel.com>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hello.

These are parts of patches for new nodes addition v4.
When new node is added, new pgdat must be allocated and initialized.
But, ia64 has copies of node_data[] on each node. So, kernel has to
allocate not only pgdat but also its copies area. and all of copies
must be updated at hot-add. These are patches for it.

This patch is for 2.6.17-rc3-mm1.

Please apply.

------------------------------------------------------------

Change log from v4 of node hot-add.
  - update for 2.6.17-rc3-mm1.

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
