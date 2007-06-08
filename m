Date: Fri, 8 Jun 2007 14:35:31 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: memory unplug v4 intro [0/6]
Message-Id: <20070608143531.411c76df.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: mel@csn.ul.ie, y-goto@jp.fujitsu.com, clameter@sgi.com, hugh@veritas.com, "kamezawa.hiroyu@jp.fujitsu.com" <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

Hi,

This is memory unplug base patcheset v4 against 2.6.22-rc4-mm2.
for review and for testers.

Changelog V3 -> V4
- rebased to 2.6.22-rc4-mm2
- cleaned up. it seems simpler than previous ones.
- instread of adding refcnt to anon_vma, using dummy_vma.
- page scan logic is a bit changed.
- order of patches is changed.

We tested this patch on ia64/NUMA.

=
How to use
 - user kernelcore=XXX boot option to create ZONE_MOVABLE.
   Memory unplug itself can work without ZONE_MOVABLE but it will be
   better to use kernelcore= if your section size is big.
  
 - After bootup, execute following.
     # echo "offline" > /sys/devices/system/memory/memoryX/state
 - you can push back offlined memory by following
     # echo "online" > /sys/devices/system/memory/memoryX/state
    
TODO
 - remove memmap after memory unplug. (for sparsemem)
 - more tests and find - page which cannot be freed -
 - Now, there is no check around ZONE_MOVABLE and bootmem.
   I hope bootmem can treat kernelcore=....
 - add better logic to allocate memory for migration.
 - speed up under heavy workload.
 - node hotplug support
 - Should make i386/x86-64/powerpc interface code. But not yet 

Thanks,
-Kame



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
