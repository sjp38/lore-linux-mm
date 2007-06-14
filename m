Date: Thu, 14 Jun 2007 15:56:30 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC] memory unplug v5 [0/6] intro
Message-Id: <20070614155630.04f8170c.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: mel@csn.ul.ie, y-goto@jp.fujitsu.com, clameter@sgi.com, hugh@veritas.com, "kamezawa.hiroyu@jp.fujitsu.com" <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

Hi,

This is a memory unplug base patch set v5 against 2.6.22-rc4-mm2
for review and testers.

Plan:
Maybe this will be the last post before OLS. I'd like to remove [RFC} 
and post this set as [PATCH] in July. If you have any concerns, please tell me.

Changelog V4->V5
 - reflected commetns on v4. no big changes in logic.
 - anon_vma_hold/rel functions are removed. Uses more direct way.
 - restructured page isolation patchset. maybe simpler than previous ones.
 - use pageblock_nr_pages.
 - adjusted other patches 
 

We tested this patch on ia64/NUMA.

How to use
 - user kernelcore=XXX boot option to create ZONE_MOVABLE.
   Memory unplug itself can work without ZONE_MOVABLE (if you allow retrying..)
   but it will be better to use kernelcore= if your section size is big.
  
 - After bootup, execute following.
     # echo "offline" > /sys/devices/system/memory/memoryX/state
 - you can push back offlined memory by following
     # echo "online" > /sys/devices/system/memory/memoryX/state

TODO
 - more tests.
 - Now, there is no check around ZONE_MOVABLE and bootmem.
   I hope bootmem can treat kernelcore=....
 - add better logic to allocate memory for migration. 
   Problems here are that we have no way to rememeber "How page is allocated".
   cpusets info and policy info is in "task_struct", which cannot be accessed
   from a page struct..maybe what we can do is (1) add more information to page 
   or (2) use just a simple way. or (3) some magical technique...
 - node hotplug support
 - Should make i386/x86-64/powerpc interface code. But not yet 
 - remove memmap after memory unplug. (for sparsemem)

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
