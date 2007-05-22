Date: Tue, 22 May 2007 15:58:24 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [Patch] memory unplug v3 [0/4]
Message-Id: <20070522155824.563f5873.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linux-MM <linux-mm@kvack.org>
Cc: mel@csn.ul.ie, y-goto@jp.fujitsu.com, clameter@sgi.com
List-ID: <linux-mm.kvack.org>

This is memory unplug base patcheset v3 against 2.6.22-rc1-mm1.
just for review and for testers.

Changelog V2->V3
 - Using Meln's page grouping method. this simplifies the whole patch set.
   MIGRATE_ISOLATE migratetype is added.
 - restructured patch series.
 - rebased to 2.6.22-rc1-mm1.
 - page is isolated ASAP patch is removed.
 - several fixes.

We tested this patch on ia64/NUMA and ia64/SMP. 

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

If you have a request to add interface for test, please tell me.

4 patches are there
[1] page isolation patch
[2] migration by kernel patch
[3] page hot removal patch
[4] ia64 interface patch


Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
