Date: Wed, 17 Nov 1999 20:46:04 +0100 (CET)
From: Ingo Molnar <mingo@chiara.csoma.elte.hu>
Subject: [patch] zoned-2.3.28-K4
Message-ID: <Pine.LNX.4.10.9911172042220.5725-100000@chiara.csoma.elte.hu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.rutgers.edu
Cc: Linus Torvalds <torvalds@transmeta.com>
List-ID: <linux-mm.kvack.org>

the latest patchset is at:

	http://www.redhat.com/~mingo/zoned-2.3.28-K4

-- mingo

Changes in zoned-2.3.28-K4:

- Russell King's task reference counter fix

- Petr Vandrovec's ncpfs-in-highmem patch


Changes in zoned-2.3.28-K2:

- fixed stupid oom bug reported by Jeff and others, introduced in J5

- fixed memory balancing

- show_free_areas() bug fixed.

- (includes Russell King's procfs fix)


Changes in zoned-2.3.28-J5:

- further page_alloc.c cleanups/speedups.

- Alan and Rogier convinced me to optimize the 'top level zone is empty'
  case a bit more.

- show_free_areas() works again.

- some more include file fixes


Changes in zoned-2.3.28-H2:

- fixed NFS to work out of high memory - tested with moderate load. All
  NFS caches (directory, symlink, data, etc.) are in high memory.

- modules fix ...

- page->virtual is filled out for non-highmem pages too, this is a
  nice speedup in certain cases.

- fixed a bug in highmem support which might cause user-datapage
  corruption in certain cases.


Changes in zoned-2.3.28-G5:

- this one should actually compile if modules support is turned on ...


Changes in zoned-2.3.28-G4:

- implemented 'zone chains' zonelist_t and gfp_mask indexed zonelists[]
  speedups (Linus' idea) to handle fallback zones. This should enable
  advanced NUMA-style allocations as well. [fallback to different CPUs is 
  possible via changing build_zonelists().]

- <=16MB RAM boxes should boot just fine now.

- added page->zone for easier deallocation and generic cleanliness. This
  also helps NUMA.

- cleaned up the page-allocator namespace, there are only two 'core'
  page-allocation functions left: __alloc_pages() and __free_pages_ok().

- modules should compile again.

- we are now inlining the 'put_page_testzero()' part of __free_page_ok.
  This is subtle as page->count for reserved pages is now 'rotating' -
  this is fine though and lets us to put the rare PageReserved() branch
  into __free_page_ok().

- cleaned up pgtable.h, split into lowlevel and highlevel parts, this
  fixes dependencies in mm.h & misc.c.

- serial.c didnt clear freshly allocated bootmem - as a result now all
  bootmem allocations are explicitly cleared, it's not performance
  critical anyway.

- fixed code,data,initmem reporting.

- fixed boot task's swapper_pg_dir clearing

-- mingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
