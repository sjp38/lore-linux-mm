Date: Tue, 20 Dec 2005 17:51:58 +0900
From: Yasunori Goto <y-goto@jp.fujitsu.com>
Subject: [Patch] New zone ZONE_EASY_RECLAIM take 4[0/8]
Message-Id: <20051220172637.1B06.Y-GOTO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm <linux-mm@kvack.org>, Linux Kernel ML <linux-kernel@vger.kernel.org>, Linux Hotplug Memory Support <lhms-devel@lists.sourceforge.net>
Cc: Joel Schopp <jschopp@austin.ibm.com>
List-ID: <linux-mm.kvack.org>

Hello.

I rewrote ZONE_EASY_RECLAIM patches. This zone is made for memory hotplug
as a new zone.
It aims to collect the page which is difficult for reclaiming on a some 
areas like a few nodes, (they become sacrifice areas for memory remove),
and it makes other areas this easy reclaim zone to be removed easier. 
The feature like this patch is essential for memory hotplug.

This patch set doesn't include to allocate this zone.
Because it is arch dependence how the kernel divides zones.
But this patch set was tested by temporary test code for it.
(ex, All highmem becomes easy reclaim on i386, or
     Nodes other than node 0 becomes easy reclaime on ia64 with numa emulation.)

Update points from take 3 are followings.

Please comment.

----------------------------

Changes take 3-> take 4
  - Update patches for 2.6.15-rc5-mm3.
  - modify highest_zone() again. i386 never used easy reclaim zone
    at take 3. and rearrange value of __GFP_DMA32, __GFP_HIGHMEM
    and __GFP_EASY_RECLAIM.
  - fix number of index of sysctl_lowmem_reserve_ratio[]
  - add information for /proc/meminfo.
  - add place which __GFP_EASY_RECLAIM is disabled for gfp_mask.
    (shmem, pipe, and symlink)

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
