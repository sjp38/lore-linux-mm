Message-ID: <3E9459E6.5040702@us.ibm.com>
Date: Wed, 09 Apr 2003 10:35:34 -0700
From: Dave Hansen <haveblue@us.ibm.com>
MIME-Version: 1.0
Subject: meminfo documentation take 2
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, Arjan van de Ven <arjanv@redhat.com>
List-ID: <linux-mm.kvack.org>

Arjan pointed me to a lovely RedHat page which goes through some of this
as well: http://www.redhat.com/advice/tips/

I integrated some of it, and took Bill Irwin's suggestion about the
ReverseMaps:

----------------------------------------------------------------------

meminfo:

Provides information about distribution and utilization of memory.  This
varies by architecture and compile options.  The following is from a
16GB PIII, which has highmem enabled.  You may not have all of these fields.

> cat /proc/meminfo

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

    MemTotal: Total usable ram (i.e. physical ram minus a few reserved
              bits and the kernel binary code)
     MemFree: The sum of LowFree+HighFree
     Buffers: Relatively temporary storage for raw disk blocks
              shouldn't get tremendously large (20MB or so)
      Cached: in-memory cache for files read from the disk (the
              pagecache).  Doesn't include SwapCached
  SwapCached: Memory that once was swapped out, is swapped back in but
              still also is in the swapfile (if memory is needed it
              doesn't need to be swapped out AGAIN because it is already
              in the swapfile. This saves I/O)
      Active: Memory that has been used more recently and usually not
              reclaimed unless absolutely necessary.
    Inactive: Memory which has been less recently used.  It is more
              eligible to be reclaimed for other purposes
   HighTotal:
    HighFree: Highmem is all memory above ~860MB of physical memory
              Highmem areas are for use by userspace programs, or
              for the pagecache.  The kernel must use tricks to access
              this memory, making it slower to access than lowmem.
    LowTotal:
     LowFree: Lowmem is memory which can be used for everything that
              highmem can be used for, but it is also availble for the
              kernel's use for its own data structures.  Among many
              other things, it is where everything from the Slab is
              allocated.  Bad things happen when you're out of lowmem.
   SwapTotal: total amount of swap space available
    SwapFree: Memory which has been evicted from RAM, and is temporarily
              on the disk
       Dirty: Memory which is waiting to get written back to the disk
   Writeback: Memory which is actively being written back to the disk
      Mapped: files which have been mmaped, such as libraries
        Slab: in-kernel data structures cache
Committed_AS: An estimate of how much RAM you would need to make a
              99.99% guarantee that there never is OOM (out of memory)
              for this workload. Normally the kernel will overcommit
              memory. That means, say you do a 1GB malloc, nothing
              happens, really. Only when you start USING that malloc
              memory you will get real memory on demand, and just as
              much as you use. So you sort of take a mortgage and hope
              the bank doesn't go bust. Other cases might include when
              you mmap a file that's shared only when you write to it
              and you get a private copy of that data. While it normally
              is shared between processes. The Committed_AS is a
              guesstimate of how much RAM/swap you would need
              worst-case.
  PageTables: amount of memory dedicated to the lowest level of page
              tables.
 ReverseMaps: number of reverse mappings performed
VmallocTotal: total size of vmalloc memory area
 VmallocUsed: amount of vmalloc area which is used
VmallocChunk: largest contigious block of vmalloc area which is free


-- 
Dave Hansen
haveblue@us.ibm.com


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org">aart@kvack.org</a>
