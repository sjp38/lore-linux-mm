Received: from westrelay05.boulder.ibm.com (westrelay05.boulder.ibm.com [9.17.193.33])
	by e31.co.us.ibm.com (8.12.9/8.12.2) with ESMTP id h390n2gJ078948
	for <linux-mm@kvack.org>; Tue, 8 Apr 2003 20:49:02 -0400
Received: from nighthawk.sr71.net (dyn9-47-17-110.beaverton.ibm.com [9.47.17.110])
	by westrelay05.boulder.ibm.com (8.12.8/NCO/VER6.5) with ESMTP id h390o9WE144312
	for <linux-mm@kvack.org>; Tue, 8 Apr 2003 18:50:09 -0600
Received: from us.ibm.com (dave@localhost [127.0.0.1])
	by nighthawk.sr71.net (8.12.3/8.12.3/Debian-6.3) with ESMTP id h390nkT7016548
	for <linux-mm@kvack.org>; Tue, 8 Apr 2003 17:49:47 -0700
Message-ID: <3E936E2A.4080400@us.ibm.com>
Date: Tue, 08 Apr 2003 17:49:46 -0700
From: Dave Hansen <haveblue@us.ibm.com>
MIME-Version: 1.0
Subject: meminfo documentation
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

I'm trying to document all of the fields in /proc/meminfo for future
inclusion into Documentation/filesystems/proc.txt

Does anyone has comments to add, or corrections for mine?

----------------------------------------------------------------------

Provides information about distribution and utilization of memory.  This
varies by architecture and compile options.  The following is from a
16GB PIII, which has highmem enabled.  You may not have all of these fields.

MemTotal:     16344972 kB
MemFree:      13634064 kB
Buffers:          3656 kB
Cached:        1195708 kB
SwapCached:          0 kB
Active:         891636 kB
Inactive:      1077224 kB
HighTotal:    15597528 kB
HighFree:     13629632 kB
LowTotal:       747444 kB
LowFree:          4432 kB
SwapTotal:           0 kB
SwapFree:            0 kB
Dirty:             968 kB
Writeback:           0 kB
Mapped:         280372 kB
Slab:           684068 kB
Committed_AS:  1576424 kB
PageTables:      24448 kB
ReverseMaps:   1080904
VmallocTotal:   112216 kB
VmallocUsed:       428 kB
VmallocChunk:   111088 kB

MemTotal:     HighTotal + LowTotal
MemFree:      LowFree + HighFree

Buffers:      relatively temporary storage for raw disk blocks
              shouldn't get tremendously large (20MB or so)
Cached:       in-memory cache for files read from the disk (the page
              cache)
SwapCached:   things which were "Cached", but have now been
              swapped out to disk.

Active:
Inactive:

HighTotal:
HighFree:     Highmem areas are for use by userspace programs, or
              for the pagecache.

LowTotal:
LowFree:      Lowmem is memory which can be used for everything that
              highmem can be used for, but it is also availble for the
              kernel's use.  Among many other things, it is where
              everything from the Slab is allocated.  Bad things happen
              when you're out of lowmem.

SwapTotal:    total amount of swap space available
SwapFree:     Memory which has been evicted from RAM, and is temporarily
              on the disk
Dirty:        Memory which is waiting to get written back to the disk

Writeback:    Memory which is actively being written back to the disk

Mapped:       files which have been mmaped, such as libraries

Slab:         in-kernel data structures cache

Committed_AS:

PageTables:

ReverseMaps:  number of rmap pte chains

VmallocTotal: total size of vmalloc memory area
VmallocUsed:  amount of vmalloc area which is used
VmallocChunk: largest contigious block of vmalloc area which is free


-- 
Dave Hansen
haveblue@us.ibm.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org">aart@kvack.org</a>
