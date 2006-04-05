Date: Wed, 05 Apr 2006 19:57:08 +0900
From: Yasunori Goto <y-goto@jp.fujitsu.com>
Subject: [Patch:000/004] wait_table and zonelist initializing for memory hotadd
Message-Id: <20060405192737.3C3F.Y-GOTO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Linux Kernel ML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Yasunori Goto <y-goto@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

Hi.

These are parts of patches for new nodes addition v4.
I picked them up because v4 might be a bit too many patches.
These patches can be used even when a new zone becomes available.
When empty zone becomes not empty, wait_table must be initialized,
and zonelists must be updated.
So, They are a good group for once post.

  ex) x86-64 is good example of new zone addition.
      - System boot up with memory under 4G address.
        All of memory will be ZONE_DMA32.
      - Then hot-add over 4G memory. It becomes ZONE_NORMAL. But, 
        wait table of zone normal is not initialized at this time.

This patch is for 2.6.17-rc1-mm1.

Please apply.

----------------------------
Change log from v4 of hot-add.
  - update for 2.6.17-rc1-mm1.
  - change allocation for wait_table from kmalloc() to vmalloc().
    vmalloc() is enough for it.

V4 of post is here.
<description>
http://marc.theaimsgroup.com/?l=linux-mm&w=2&r=1&s=memory+hotplug+node+v.4&q=b
<patches>
http://marc.theaimsgroup.com/?l=linux-mm&w=2&r=1&s=memory+hotplug+node+v.4.&q=b



-- 
Yasunori Goto 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
