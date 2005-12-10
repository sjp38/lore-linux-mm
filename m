Date: Sat, 10 Dec 2005 20:02:36 +0900
From: Yasunori Goto <y-goto@jp.fujitsu.com>
Subject: [Patch] New zone ZONE_EASY_RECLAIM take 3[0/5]
Message-Id: <20051210193610.4824.Y-GOTO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm <linux-mm@kvack.org>, Linux Hotplug Memory Support <lhms-devel@lists.sourceforge.net>
Cc: Joel Schopp <jschopp@austin.ibm.com>
List-ID: <linux-mm.kvack.org>

Hello.

I updated ZONE_EASY_RECLAIM patches.

ZONE_EASY_RECLAIM is made for memory hotplug.
It aims to collect the page which is difficult for removing on a some 
areas like a few nodes, and it makes other areas this zone to be
removed easier.

Update points are followings.

Please comment.

----------------------------

Changes take 2-> take 3
  - Update patches for 2.6.15-rc5-mm1.
  - modify highest_zone() to avoid panic on i386. 
  - fix value of sysctl_lowmem_reserve_ratio[]
  - define is_higher_zone(). it can be used on other place.


Changes take 1-> take 2
  - In -mm tree, ZONE_DMA32 is already included. So, I recreate 
    ZONE_EASY_RECLAIM as 5th zone against 2.6.14-mm1. It is difference of
    previous one.


-- 
Yasunori Goto 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
