Received: from shell0.pdx.osdl.net (fw.osdl.org [65.172.181.6])
	by smtp.osdl.org (8.12.8/8.12.8) with ESMTP id j267Bbqi015177
	(version=TLSv1/SSLv3 cipher=EDH-RSA-DES-CBC3-SHA bits=168 verify=NO)
	for <linux-mm@kvack.org>; Sat, 5 Mar 2005 23:11:37 -0800
Received: from bix (shell0.pdx.osdl.net [10.9.0.31])
	by shell0.pdx.osdl.net (8.13.1/8.11.6) with SMTP id j267BaUd018163
	for <linux-mm@kvack.org>; Sat, 5 Mar 2005 23:11:36 -0800
Date: Sat, 5 Mar 2005 23:11:14 -0800
From: Andrew Morton <akpm@osdl.org>
Subject: Re: Fw: [BK] set_pte() mm/addr arg addition
Message-Id: <20050305231114.1955e941.akpm@osdl.org>
In-Reply-To: <20050305211733.115cce4f.akpm@osdl.org>
References: <20050305211733.115cce4f.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Andrew Morton <akpm@osdl.org> wrote:
>
> From: "David S. Miller" <davem@davemloft.net>
>  To: torvalds@osdl.org
>  Cc: akpm@osdl.org, linux-arch -at- vger
>  Subject: [BK] set_pte() mm/addr arg addition
> 
> 
> 
>  Linus, please pull from:
> 
>  	bk://kernel.bkbits.net/davem/set_pte-2.6
> 
>  to get these changesets.

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2005/03/05 20:48:01-08:00 davem@picasso.davemloft.net 
#   Merge davem@nuts:/disk1/BK/set_pte-2.6
#   into picasso.davemloft.net:/home/davem/src/BK/set_pte-2.6
# 
# mm/swapfile.c
#   2005/03/05 20:47:57-08:00 davem@picasso.davemloft.net +0 -0
#   Auto merged
# 
# mm/rmap.c
#   2005/03/05 20:47:57-08:00 davem@picasso.davemloft.net +0 -0
#   Auto merged
# 
# mm/mremap.c
#   2005/03/05 20:47:57-08:00 davem@picasso.davemloft.net +0 -0
#   Auto merged
# 
# mm/memory.c
#   2005/03/05 20:47:57-08:00 davem@picasso.davemloft.net +0 -0
#   Auto merged
# 
# include/asm-arm/pgtable.h
#   2005/03/05 20:47:56-08:00 davem@picasso.davemloft.net +0 -0
#   Auto merged
# 
# fs/exec.c
#   2005/03/05 20:47:56-08:00 davem@picasso.davemloft.net +0 -0
#   Auto merged
# 
# arch/ppc64/mm/init.c
#   2005/03/05 20:47:56-08:00 davem@picasso.davemloft.net +0 -0
#   Auto merged
# 
# arch/ppc64/mm/hugetlbpage.c
#   2005/03/05 20:47:56-08:00 davem@picasso.davemloft.net +0 -0
#   Auto merged
# 
# ChangeSet
#   2005/03/01 15:38:13-08:00 davem@nuts.davemloft.net 
#   Resolve conflicts.
# 
# arch/ppc64/mm/tlb.c
#   2005/03/01 15:37:54-08:00 davem@nuts.davemloft.net +0 -6
#   Resolve conflicts with bug fix.
# 
# ChangeSet
#   2005/03/01 15:33:45-08:00 davem@nuts.davemloft.net 
#   Resolve conflicts.
# 
# mm/highmem.c
#   2005/03/01 15:04:37-08:00 davem@nuts.davemloft.net +0 -0
#   Auto merged
# 
# arch/arm/mm/consistent.c
#   2005/03/01 15:04:36-08:00 davem@nuts.davemloft.net +0 -0
#   Auto merged
# 
# ChangeSet
#   2005/03/01 15:00:34-08:00 davem@nuts.davemloft.net 
#   [S390]: Fix build after set_pte_at() changes.
#   
#   Signed-off-by: David S. Miller <davem@davemloft.net>
# 
# include/asm-s390/pgtable.h
#   2005/03/01 15:00:00-08:00 davem@nuts.davemloft.net +1 -1
#   [S390]: Fix build after set_pte_at() changes.
# 
# ChangeSet
#   2005/02/27 11:34:35-08:00 davem@nuts.davemloft.net 
#   [SPARC64]: Do the init_mm check inline in set_pte_at().
#   
#   Signed-off-by: David S. Miller <davem@davemloft.net>
# 
# include/asm-sparc64/pgtable.h
#   2005/02/27 11:33:59-08:00 davem@nuts.davemloft.net +8 -5
#   [SPARC64]: Do the init_mm check inline in set_pte_at().
# 
# arch/sparc64/mm/tlb.c
#   2005/02/27 11:33:59-08:00 davem@nuts.davemloft.net +2 -11
#   [SPARC64]: Do the init_mm check inline in set_pte_at().
# 
# ChangeSet
#   2005/02/26 20:51:23-08:00 davem@nuts.davemloft.net 
#   [MM]: Pass correct address down to bottom of page table iterators.
#   
#   Some routines, namely zeromap_pte_range, remap_pte_range,
#   change_pte_range, unmap_area_pte, and map_area_pte, were
#   using a chopped off address.  This causes bogus addresses
#   to be passed into set_pte_at() and friends, resulting
#   in missed TLB flushes and other nasties.
#   
#   Signed-off-by: David S. Miller <davem@davemloft.net>
# 
# mm/vmalloc.c
#   2005/02/26 20:50:16-08:00 davem@nuts.davemloft.net +13 -9
#   [MM]: Pass correct address down to bottom of page table iterators.
# 
# mm/mprotect.c
#   2005/02/26 20:50:16-08:00 davem@nuts.davemloft.net +10 -7
#   [MM]: Pass correct address down to bottom of page table iterators.
# 
# mm/memory.c
#   2005/02/26 20:50:16-08:00 davem@nuts.davemloft.net +7 -5
#   [MM]: Pass correct address down to bottom of page table iterators.
# 
# ChangeSet
#   2005/02/23 19:27:50-08:00 davem@nuts.davemloft.net 
#   [PPC]: Use new set_pte_at() w/mm+address args.
#   
#   Based almost entirely upon an earlier patch by
#   Benjamin Herrenschmidt.
#   
#   Signed-off-by: David S. Miller <davem@davemloft.net>
# 
# include/asm-ppc64/pgtable.h
#   2005/02/23 19:26:53-08:00 davem@nuts.davemloft.net +32 -20
#   [PPC]: Use new set_pte_at() w/mm+address args.
# 
# include/asm-ppc64/pgalloc.h
#   2005/02/23 19:26:53-08:00 davem@nuts.davemloft.net +6 -22
#   [PPC]: Use new set_pte_at() w/mm+address args.
# 
# include/asm-ppc/pgtable.h
#   2005/02/23 19:26:53-08:00 davem@nuts.davemloft.net +33 -28
#   [PPC]: Use new set_pte_at() w/mm+address args.
# 
# include/asm-ppc/highmem.h
#   2005/02/23 19:26:53-08:00 davem@nuts.davemloft.net +1 -1
#   [PPC]: Use new set_pte_at() w/mm+address args.
# 
# arch/ppc64/mm/tlb.c
#   2005/02/23 19:26:53-08:00 davem@nuts.davemloft.net +2 -9
#   [PPC]: Use new set_pte_at() w/mm+address args.
# 
# arch/ppc/mm/tlb.c
#   2005/02/23 19:26:53-08:00 davem@nuts.davemloft.net +0 -20
#   [PPC]: Use new set_pte_at() w/mm+address args.
# 
# arch/ppc/mm/pgtable.c
#   2005/02/23 19:26:53-08:00 davem@nuts.davemloft.net +2 -12
#   [PPC]: Use new set_pte_at() w/mm+address args.
# 
# arch/ppc/mm/init.c
#   2005/02/23 19:26:53-08:00 davem@nuts.davemloft.net +0 -12
#   [PPC]: Use new set_pte_at() w/mm+address args.
# 
# arch/ppc/kernel/dma-mapping.c
#   2005/02/23 19:26:53-08:00 davem@nuts.davemloft.net +5 -2
#   [PPC]: Use new set_pte_at() w/mm+address args.
# 
# ChangeSet
#   2005/02/23 17:46:43-08:00 davem@nuts.davemloft.net 
#   [SPARC64]: Pass mm/addr directly to tlb_batch_add()
#   
#   No longer need to store this information in the pte table
#   page struct.
#   
#   Signed-off-by: David S. Miller <davem@davemloft.net>
# 
# include/asm-sparc64/pgtable.h
#   2005/02/23 17:45:37-08:00 davem@nuts.davemloft.net +6 -5
#   [SPARC64]: Pass mm/addr directly to tlb_batch_add()
# 
# include/asm-sparc64/pgalloc.h
#   2005/02/23 17:45:37-08:00 davem@nuts.davemloft.net +5 -15
#   [SPARC64]: Pass mm/addr directly to tlb_batch_add()
# 
# arch/sparc64/mm/tlb.c
#   2005/02/23 17:45:37-08:00 davem@nuts.davemloft.net +7 -10
#   [SPARC64]: Pass mm/addr directly to tlb_batch_add()
# 
# arch/sparc64/mm/init.c
#   2005/02/23 17:45:36-08:00 davem@nuts.davemloft.net +2 -1
#   [SPARC64]: Pass mm/addr directly to tlb_batch_add()
# 
# arch/sparc64/mm/hugetlbpage.c
#   2005/02/23 17:45:36-08:00 davem@nuts.davemloft.net +6 -4
#   [SPARC64]: Pass mm/addr directly to tlb_batch_add()
# 
# arch/sparc64/mm/generic.c
#   2005/02/23 17:45:36-08:00 davem@nuts.davemloft.net +14 -11
#   [SPARC64]: Pass mm/addr directly to tlb_batch_add()
# 
# ChangeSet
#   2005/02/23 15:42:56-08:00 davem@nuts.davemloft.net 
#   [MM]: Add set_pte_at() which takes 'mm' and 'addr' args.
#   
#   I'm taking a slightly different approach this time around so things
#   are easier to integrate.  Here is the first patch which builds the
#   infrastructure.  Basically:
#   
#   1) Add set_pte_at() which is set_pte() with 'mm' and 'addr' arguments
#      added.  All generic code uses set_pte_at().
#   
#      Most platforms simply get this define:
#   	#define set_pte_at(mm,addr,ptep,pteval) set_pte(ptep,pteval)
#   
#      I chose this method over simply changing all set_pte() call sites
#      because many platforms implement this in assembler and it would
#      take forever to preserve the build and stabilize things if modifying
#      that was necessary.
#   
#      Soon, with platform maintainer's help, we can kill of set_pte() entirely.
#      To be honest, there are only a handful of set_pte() call sites in the
#      arch specific code.
#   
#      Actually, in this patch ppc64 is completely set_pte() free and does not
#      define it.
#   
#   2) pte_clear() gets 'mm' and 'addr' arguments now.
#      This had a cascading effect on many ptep_test_and_*() routines.  Specifically:
#      a) ptep_test_and_clear_{young,dirty}() now take 'vma' and 'address' args.
#      b) ptep_get_and_clear now take 'mm' and 'address' args.
#      c) ptep_mkdirty was deleted, unused by any code.
#      d) ptep_set_wrprotect now takes 'mm' and 'address' args.
#   
#   I've tested this patch as follows:
#   
#   1) compile and run tested on sparc64/SMP
#   2) compile tested on:
#      a) ppc64/SMP
#      b) i386 both with and without PAE enabled
#   
#   Signed-off-by: David S. Miller <davem@davemloft.net>
# 
# mm/vmalloc.c
#   2005/02/23 15:40:53-08:00 davem@nuts.davemloft.net +2 -2
#   [MM]: Add set_pte_at() which takes 'mm' and 'addr' args.
# 
# mm/swapfile.c
#   2005/02/23 15:40:53-08:00 davem@nuts.davemloft.net +2 -1
#   [MM]: Add set_pte_at() which takes 'mm' and 'addr' args.
# 
# mm/rmap.c
#   2005/02/23 15:40:53-08:00 davem@nuts.davemloft.net +2 -2
#   [MM]: Add set_pte_at() which takes 'mm' and 'addr' args.
# 
# mm/mremap.c
#   2005/02/23 15:40:53-08:00 davem@nuts.davemloft.net +1 -1
#   [MM]: Add set_pte_at() which takes 'mm' and 'addr' args.
# 
# mm/mprotect.c
#   2005/02/23 15:40:53-08:00 davem@nuts.davemloft.net +10 -10
#   [MM]: Add set_pte_at() which takes 'mm' and 'addr' args.
# 
# mm/memory.c
#   2005/02/23 15:40:53-08:00 davem@nuts.davemloft.net +21 -18
#   [MM]: Add set_pte_at() which takes 'mm' and 'addr' args.
# 
# mm/highmem.c
#   2005/02/23 15:40:53-08:00 davem@nuts.davemloft.net +4 -2
#   [MM]: Add set_pte_at() which takes 'mm' and 'addr' args.
# 
# mm/fremap.c
#   2005/02/23 15:40:53-08:00 davem@nuts.davemloft.net +3 -3
#   [MM]: Add set_pte_at() which takes 'mm' and 'addr' args.
# 
# include/asm-x86_64/pgtable.h
#   2005/02/23 15:40:53-08:00 davem@nuts.davemloft.net +9 -7
#   [MM]: Add set_pte_at() which takes 'mm' and 'addr' args.
# 
# include/asm-um/pgtable.h
#   2005/02/23 15:40:53-08:00 davem@nuts.davemloft.net +1 -1
#   [MM]: Add set_pte_at() which takes 'mm' and 'addr' args.
# 
# include/asm-um/pgtable-3level.h
#   2005/02/23 15:40:53-08:00 davem@nuts.davemloft.net +1 -0
#   [MM]: Add set_pte_at() which takes 'mm' and 'addr' args.
# 
# include/asm-um/pgtable-2level.h
#   2005/02/23 15:40:53-08:00 davem@nuts.davemloft.net +1 -0
#   [MM]: Add set_pte_at() which takes 'mm' and 'addr' args.
# 
# include/asm-sparc64/pgtable.h
#   2005/02/23 15:40:53-08:00 davem@nuts.davemloft.net +3 -1
#   [MM]: Add set_pte_at() which takes 'mm' and 'addr' args.
# 
# include/asm-sparc/pgtable.h
#   2005/02/23 15:40:53-08:00 davem@nuts.davemloft.net +2 -1
#   [MM]: Add set_pte_at() which takes 'mm' and 'addr' args.
# 
# include/asm-sh64/pgtable.h
#   2005/02/23 15:40:53-08:00 davem@nuts.davemloft.net +2 -1
#   [MM]: Add set_pte_at() which takes 'mm' and 'addr' args.
# 
# include/asm-sh/pgtable.h
#   2005/02/23 15:40:53-08:00 davem@nuts.davemloft.net +2 -2
#   [MM]: Add set_pte_at() which takes 'mm' and 'addr' args.
# 
# include/asm-sh/pgtable-2level.h
#   2005/02/23 15:40:53-08:00 davem@nuts.davemloft.net +2 -0
#   [MM]: Add set_pte_at() which takes 'mm' and 'addr' args.
# 
# include/asm-s390/pgtable.h
#   2005/02/23 15:40:53-08:00 davem@nuts.davemloft.net +11 -16
#   [MM]: Add set_pte_at() which takes 'mm' and 'addr' args.
# 
# include/asm-s390/pgalloc.h
#   2005/02/23 15:40:53-08:00 davem@nuts.davemloft.net +4 -2
#   [MM]: Add set_pte_at() which takes 'mm' and 'addr' args.
# 
# include/asm-ppc64/pgtable.h
#   2005/02/23 15:40:53-08:00 davem@nuts.davemloft.net +12 -9
#   [MM]: Add set_pte_at() which takes 'mm' and 'addr' args.
# 
# include/asm-ppc/pgtable.h
#   2005/02/23 15:40:53-08:00 davem@nuts.davemloft.net +6 -11
#   [MM]: Add set_pte_at() which takes 'mm' and 'addr' args.
# 
# include/asm-ppc/highmem.h
#   2005/02/23 15:40:53-08:00 davem@nuts.davemloft.net +1 -1
#   [MM]: Add set_pte_at() which takes 'mm' and 'addr' args.
# 
# include/asm-parisc/pgtable.h
#   2005/02/23 15:40:53-08:00 davem@nuts.davemloft.net +10 -20
#   [MM]: Add set_pte_at() which takes 'mm' and 'addr' args.
# 
# include/asm-mips/pgtable.h
#   2005/02/23 15:40:53-08:00 davem@nuts.davemloft.net +8 -6
#   [MM]: Add set_pte_at() which takes 'mm' and 'addr' args.
# 
# include/asm-m68k/sun3_pgtable.h
#   2005/02/23 15:40:53-08:00 davem@nuts.davemloft.net +4 -1
#   [MM]: Add set_pte_at() which takes 'mm' and 'addr' args.
# 
# include/asm-m68k/pgtable.h
#   2005/02/23 15:40:53-08:00 davem@nuts.davemloft.net +1 -0
#   [MM]: Add set_pte_at() which takes 'mm' and 'addr' args.
# 
# include/asm-m68k/motorola_pgtable.h
#   2005/02/23 15:40:53-08:00 davem@nuts.davemloft.net +1 -1
#   [MM]: Add set_pte_at() which takes 'mm' and 'addr' args.
# 
# include/asm-m32r/pgtable.h
#   2005/02/23 15:40:53-08:00 davem@nuts.davemloft.net +4 -10
#   [MM]: Add set_pte_at() which takes 'mm' and 'addr' args.
# 
# include/asm-m32r/pgtable-2level.h
#   2005/02/23 15:40:53-08:00 davem@nuts.davemloft.net +2 -1
#   [MM]: Add set_pte_at() which takes 'mm' and 'addr' args.
# 
# include/asm-ia64/pgtable.h
#   2005/02/23 15:40:53-08:00 davem@nuts.davemloft.net +10 -21
#   [MM]: Add set_pte_at() which takes 'mm' and 'addr' args.
# 
# include/asm-i386/pgtable.h
#   2005/02/23 15:40:53-08:00 davem@nuts.davemloft.net +7 -6
#   [MM]: Add set_pte_at() which takes 'mm' and 'addr' args.
# 
# include/asm-i386/pgtable-3level.h
#   2005/02/23 15:40:53-08:00 davem@nuts.davemloft.net +3 -1
#   [MM]: Add set_pte_at() which takes 'mm' and 'addr' args.
# 
# include/asm-i386/pgtable-2level.h
#   2005/02/23 15:40:53-08:00 davem@nuts.davemloft.net +2 -1
#   [MM]: Add set_pte_at() which takes 'mm' and 'addr' args.
# 
# include/asm-generic/pgtable.h
#   2005/02/23 15:40:53-08:00 davem@nuts.davemloft.net +38 -37
#   [MM]: Add set_pte_at() which takes 'mm' and 'addr' args.
# 
# include/asm-frv/pgtable.h
#   2005/02/23 15:40:52-08:00 davem@nuts.davemloft.net +6 -12
#   [MM]: Add set_pte_at() which takes 'mm' and 'addr' args.
# 
# include/asm-cris/pgtable.h
#   2005/02/23 15:40:52-08:00 davem@nuts.davemloft.net +3 -1
#   [MM]: Add set_pte_at() which takes 'mm' and 'addr' args.
# 
# include/asm-arm26/pgtable.h
#   2005/02/23 15:40:52-08:00 davem@nuts.davemloft.net +2 -1
#   [MM]: Add set_pte_at() which takes 'mm' and 'addr' args.
# 
# include/asm-arm/pgtable.h
#   2005/02/23 15:40:52-08:00 davem@nuts.davemloft.net +2 -1
#   [MM]: Add set_pte_at() which takes 'mm' and 'addr' args.
# 
# include/asm-alpha/pgtable.h
#   2005/02/23 15:40:52-08:00 davem@nuts.davemloft.net +5 -1
#   [MM]: Add set_pte_at() which takes 'mm' and 'addr' args.
# 
# fs/exec.c
#   2005/02/23 15:40:52-08:00 davem@nuts.davemloft.net +1 -1
#   [MM]: Add set_pte_at() which takes 'mm' and 'addr' args.
# 
# arch/sparc64/mm/hugetlbpage.c
#   2005/02/23 15:40:52-08:00 davem@nuts.davemloft.net +1 -1
#   [MM]: Add set_pte_at() which takes 'mm' and 'addr' args.
# 
# arch/sparc/mm/highmem.c
#   2005/02/23 15:40:52-08:00 davem@nuts.davemloft.net +1 -1
#   [MM]: Add set_pte_at() which takes 'mm' and 'addr' args.
# 
# arch/sparc/mm/generic.c
#   2005/02/23 15:40:52-08:00 davem@nuts.davemloft.net +6 -6
#   [MM]: Add set_pte_at() which takes 'mm' and 'addr' args.
# 
# arch/sh64/mm/ioremap.c
#   2005/02/23 15:40:52-08:00 davem@nuts.davemloft.net +1 -1
#   [MM]: Add set_pte_at() which takes 'mm' and 'addr' args.
# 
# arch/sh64/mm/hugetlbpage.c
#   2005/02/23 15:40:52-08:00 davem@nuts.davemloft.net +1 -1
#   [MM]: Add set_pte_at() which takes 'mm' and 'addr' args.
# 
# arch/sh/mm/pg-sh7705.c
#   2005/02/23 15:40:52-08:00 davem@nuts.davemloft.net +2 -2
#   [MM]: Add set_pte_at() which takes 'mm' and 'addr' args.
# 
# arch/sh/mm/pg-sh4.c
#   2005/02/23 15:40:52-08:00 davem@nuts.davemloft.net +4 -4
#   [MM]: Add set_pte_at() which takes 'mm' and 'addr' args.
# 
# arch/sh/mm/hugetlbpage.c
#   2005/02/23 15:40:52-08:00 davem@nuts.davemloft.net +1 -1
#   [MM]: Add set_pte_at() which takes 'mm' and 'addr' args.
# 
# arch/s390/mm/init.c
#   2005/02/23 15:40:52-08:00 davem@nuts.davemloft.net +2 -2
#   [MM]: Add set_pte_at() which takes 'mm' and 'addr' args.
# 
# arch/ppc64/mm/init.c
#   2005/02/23 15:40:52-08:00 davem@nuts.davemloft.net +2 -2
#   [MM]: Add set_pte_at() which takes 'mm' and 'addr' args.
# 
# arch/ppc64/mm/hugetlbpage.c
#   2005/02/23 15:40:52-08:00 davem@nuts.davemloft.net +6 -5
#   [MM]: Add set_pte_at() which takes 'mm' and 'addr' args.
# 
# arch/ppc/kernel/dma-mapping.c
#   2005/02/23 15:40:52-08:00 davem@nuts.davemloft.net +4 -2
#   [MM]: Add set_pte_at() which takes 'mm' and 'addr' args.
# 
# arch/parisc/mm/kmap.c
#   2005/02/23 15:40:52-08:00 davem@nuts.davemloft.net +2 -2
#   [MM]: Add set_pte_at() which takes 'mm' and 'addr' args.
# 
# arch/parisc/kernel/pci-dma.c
#   2005/02/23 15:40:52-08:00 davem@nuts.davemloft.net +1 -1
#   [MM]: Add set_pte_at() which takes 'mm' and 'addr' args.
# 
# arch/mips/mm/highmem.c
#   2005/02/23 15:40:52-08:00 davem@nuts.davemloft.net +1 -1
#   [MM]: Add set_pte_at() which takes 'mm' and 'addr' args.
# 
# arch/ia64/mm/hugetlbpage.c
#   2005/02/23 15:40:52-08:00 davem@nuts.davemloft.net +1 -1
#   [MM]: Add set_pte_at() which takes 'mm' and 'addr' args.
# 
# arch/i386/mm/hugetlbpage.c
#   2005/02/23 15:40:52-08:00 davem@nuts.davemloft.net +1 -1
#   [MM]: Add set_pte_at() which takes 'mm' and 'addr' args.
# 
# arch/i386/mm/highmem.c
#   2005/02/23 15:40:52-08:00 davem@nuts.davemloft.net +1 -1
#   [MM]: Add set_pte_at() which takes 'mm' and 'addr' args.
# 
# arch/arm/mm/consistent.c
#   2005/02/23 15:40:52-08:00 davem@nuts.davemloft.net +4 -2
#   [MM]: Add set_pte_at() which takes 'mm' and 'addr' args.
# 
diff -Nru a/arch/arm/mm/consistent.c b/arch/arm/mm/consistent.c
--- a/arch/arm/mm/consistent.c	2005-03-05 23:06:10 -08:00
+++ b/arch/arm/mm/consistent.c	2005-03-05 23:06:10 -08:00
@@ -323,7 +323,7 @@
 void dma_free_coherent(struct device *dev, size_t size, void *cpu_addr, dma_addr_t handle)
 {
 	struct vm_region *c;
-	unsigned long flags;
+	unsigned long flags, addr;
 	pte_t *ptep;
 
 	size = PAGE_ALIGN(size);
@@ -342,11 +342,13 @@
 	}
 
 	ptep = consistent_pte + CONSISTENT_OFFSET(c->vm_start);
+	addr = c->vm_start;
 	do {
-		pte_t pte = ptep_get_and_clear(ptep);
+		pte_t pte = ptep_get_and_clear(&init_mm, addr, ptep);
 		unsigned long pfn;
 
 		ptep++;
+		addr += PAGE_SIZE;
 
 		if (!pte_none(pte) && pte_present(pte)) {
 			pfn = pte_pfn(pte);
diff -Nru a/arch/i386/mm/highmem.c b/arch/i386/mm/highmem.c
--- a/arch/i386/mm/highmem.c	2005-03-05 23:06:10 -08:00
+++ b/arch/i386/mm/highmem.c	2005-03-05 23:06:10 -08:00
@@ -66,7 +66,7 @@
 	 * force other mappings to Oops if they'll try to access
 	 * this pte without first remap it
 	 */
-	pte_clear(kmap_pte-idx);
+	pte_clear(&init_mm, vaddr, kmap_pte-idx);
 	__flush_tlb_one(vaddr);
 #endif
 
diff -Nru a/arch/i386/mm/hugetlbpage.c b/arch/i386/mm/hugetlbpage.c
--- a/arch/i386/mm/hugetlbpage.c	2005-03-05 23:06:10 -08:00
+++ b/arch/i386/mm/hugetlbpage.c	2005-03-05 23:06:10 -08:00
@@ -216,7 +216,7 @@
 	BUG_ON(end & (HPAGE_SIZE - 1));
 
 	for (address = start; address < end; address += HPAGE_SIZE) {
-		pte = ptep_get_and_clear(huge_pte_offset(mm, address));
+		pte = ptep_get_and_clear(mm, address, huge_pte_offset(mm, address));
 		if (pte_none(pte))
 			continue;
 		page = pte_page(pte);
diff -Nru a/arch/ia64/mm/hugetlbpage.c b/arch/ia64/mm/hugetlbpage.c
--- a/arch/ia64/mm/hugetlbpage.c	2005-03-05 23:06:10 -08:00
+++ b/arch/ia64/mm/hugetlbpage.c	2005-03-05 23:06:10 -08:00
@@ -244,7 +244,7 @@
 			continue;
 		page = pte_page(*pte);
 		put_page(page);
-		pte_clear(pte);
+		pte_clear(mm, address, pte);
 	}
 	mm->rss -= (end - start) >> PAGE_SHIFT;
 	flush_tlb_range(vma, start, end);
diff -Nru a/arch/mips/mm/highmem.c b/arch/mips/mm/highmem.c
--- a/arch/mips/mm/highmem.c	2005-03-05 23:06:10 -08:00
+++ b/arch/mips/mm/highmem.c	2005-03-05 23:06:10 -08:00
@@ -75,7 +75,7 @@
 	 * force other mappings to Oops if they'll try to access
 	 * this pte without first remap it
 	 */
-	pte_clear(kmap_pte-idx);
+	pte_clear(&init_mm, vaddr, kmap_pte-idx);
 	local_flush_tlb_one(vaddr);
 #endif
 
diff -Nru a/arch/parisc/kernel/pci-dma.c b/arch/parisc/kernel/pci-dma.c
--- a/arch/parisc/kernel/pci-dma.c	2005-03-05 23:06:10 -08:00
+++ b/arch/parisc/kernel/pci-dma.c	2005-03-05 23:06:10 -08:00
@@ -180,7 +180,7 @@
 		end = PMD_SIZE;
 	do {
 		pte_t page = *pte;
-		pte_clear(pte);
+		pte_clear(&init_mm, vaddr, pte);
 		purge_tlb_start();
 		pdtlb_kernel(orig_vaddr);
 		purge_tlb_end();
diff -Nru a/arch/parisc/mm/kmap.c b/arch/parisc/mm/kmap.c
--- a/arch/parisc/mm/kmap.c	2005-03-05 23:06:10 -08:00
+++ b/arch/parisc/mm/kmap.c	2005-03-05 23:06:10 -08:00
@@ -49,10 +49,10 @@
  * unmap_uncached_page() and save a little code space but I didn't
  * do that since I'm not certain whether this is the right path. -PB
  */
-static void unmap_cached_pte(pte_t * pte, unsigned long arg)
+static void unmap_cached_pte(pte_t * pte, unsigned long addr, unsigned long arg)
 {
 	pte_t page = *pte;
-	pte_clear(pte);
+	pte_clear(&init_mm, addr, pte);
 	if (!pte_none(page)) {
 		if (pte_present(page)) {
 			unsigned long map_nr = pte_pagenr(page);
diff -Nru a/arch/ppc/kernel/dma-mapping.c b/arch/ppc/kernel/dma-mapping.c
--- a/arch/ppc/kernel/dma-mapping.c	2005-03-05 23:06:10 -08:00
+++ b/arch/ppc/kernel/dma-mapping.c	2005-03-05 23:06:10 -08:00
@@ -219,7 +219,8 @@
 	c = vm_region_alloc(&consistent_head, size,
 			    gfp & ~(__GFP_DMA | __GFP_HIGHMEM));
 	if (c) {
-		pte_t *pte = consistent_pte + CONSISTENT_OFFSET(c->vm_start);
+		unsigned long vaddr = c->vm_start;
+		pte_t *pte = consistent_pte + CONSISTENT_OFFSET(vaddr);
 		struct page *end = page + (1 << order);
 
 		/*
@@ -232,9 +233,11 @@
 
 			set_page_count(page, 1);
 			SetPageReserved(page);
-			set_pte(pte, mk_pte(page, pgprot_noncached(PAGE_KERNEL)));
+			set_pte_at(&init_mm, vaddr,
+				   pte, mk_pte(page, pgprot_noncached(PAGE_KERNEL)));
 			page++;
 			pte++;
+			vaddr += PAGE_SIZE;
 		} while (size -= PAGE_SIZE);
 
 		/*
@@ -262,7 +265,7 @@
 void __dma_free_coherent(size_t size, void *vaddr)
 {
 	struct vm_region *c;
-	unsigned long flags;
+	unsigned long flags, addr;
 	pte_t *ptep;
 
 	size = PAGE_ALIGN(size);
@@ -281,11 +284,13 @@
 	}
 
 	ptep = consistent_pte + CONSISTENT_OFFSET(c->vm_start);
+	addr = c->vm_start;
 	do {
-		pte_t pte = ptep_get_and_clear(ptep);
+		pte_t pte = ptep_get_and_clear(&init_mm, addr, ptep);
 		unsigned long pfn;
 
 		ptep++;
+		addr += PAGE_SIZE;
 
 		if (!pte_none(pte) && pte_present(pte)) {
 			pfn = pte_pfn(pte);
diff -Nru a/arch/ppc/mm/init.c b/arch/ppc/mm/init.c
--- a/arch/ppc/mm/init.c	2005-03-05 23:06:10 -08:00
+++ b/arch/ppc/mm/init.c	2005-03-05 23:06:10 -08:00
@@ -490,18 +490,6 @@
 		printk(KERN_INFO "AGP special page: 0x%08lx\n", agp_special_page);
 #endif
 
-	/* Make sure all our pagetable pages have page->mapping
-	   and page->index set correctly. */
-	for (addr = KERNELBASE; addr != 0; addr += PGDIR_SIZE) {
-		struct page *pg;
-		pmd_t *pmd = pmd_offset(pgd_offset_k(addr), addr);
-		if (pmd_present(*pmd)) {
-			pg = pmd_page(*pmd);
-			pg->mapping = (void *) &init_mm;
-			pg->index = addr;
-		}
-	}
-
 	mem_init_done = 1;
 }
 
diff -Nru a/arch/ppc/mm/pgtable.c b/arch/ppc/mm/pgtable.c
--- a/arch/ppc/mm/pgtable.c	2005-03-05 23:06:10 -08:00
+++ b/arch/ppc/mm/pgtable.c	2005-03-05 23:06:10 -08:00
@@ -102,11 +102,6 @@
 
 	if (mem_init_done) {
 		pte = (pte_t *)__get_free_page(GFP_KERNEL|__GFP_REPEAT|__GFP_ZERO);
-		if (pte) {
-			struct page *ptepage = virt_to_page(pte);
-			ptepage->mapping = (void *) mm;
-			ptepage->index = address & PMD_MASK;
-		}
 	} else {
 		pte = (pte_t *)early_get_page();
 		if (pte)
@@ -126,11 +121,8 @@
 #endif
 
 	ptepage = alloc_pages(flags, 0);
-	if (ptepage) {
-		ptepage->mapping = (void *) mm;
-		ptepage->index = address & PMD_MASK;
+	if (ptepage)
 		clear_highpage(ptepage);
-	}
 	return ptepage;
 }
 
@@ -139,7 +131,6 @@
 #ifdef CONFIG_SMP
 	hash_page_sync();
 #endif
-	virt_to_page(pte)->mapping = NULL;
 	free_page((unsigned long)pte);
 }
 
@@ -148,7 +139,6 @@
 #ifdef CONFIG_SMP
 	hash_page_sync();
 #endif
-	ptepage->mapping = NULL;
 	__free_page(ptepage);
 }
 
@@ -298,7 +288,7 @@
 	pg = pte_alloc_kernel(&init_mm, pd, va);
 	if (pg != 0) {
 		err = 0;
-		set_pte(pg, pfn_pte(pa >> PAGE_SHIFT, __pgprot(flags)));
+		set_pte_at(&init_mm, va, pg, pfn_pte(pa >> PAGE_SHIFT, __pgprot(flags)));
 		if (mem_init_done)
 			flush_HPTE(0, va, pmd_val(*pd));
 	}
diff -Nru a/arch/ppc/mm/tlb.c b/arch/ppc/mm/tlb.c
--- a/arch/ppc/mm/tlb.c	2005-03-05 23:06:10 -08:00
+++ b/arch/ppc/mm/tlb.c	2005-03-05 23:06:10 -08:00
@@ -47,26 +47,6 @@
 }
 
 /*
- * Called by ptep_test_and_clear_young()
- */
-void flush_hash_one_pte(pte_t *ptep)
-{
-	struct page *ptepage;
-	struct mm_struct *mm;
-	unsigned long ptephys;
-	unsigned long addr;
-
-	if (Hash == 0)
-		return;
-	
-	ptepage = virt_to_page(ptep);
-	mm = (struct mm_struct *) ptepage->mapping;
-	ptephys = __pa(ptep) & PAGE_MASK;
-	addr = ptepage->index + (((unsigned long)ptep & ~PAGE_MASK) << 10);
-	flush_hash_pages(mm->context, addr, ptephys, 1);
-}
-
-/*
  * Called by ptep_set_access_flags, must flush on CPUs for which the
  * DSI handler can't just "fixup" the TLB on a write fault
  */
diff -Nru a/arch/ppc64/mm/hugetlbpage.c b/arch/ppc64/mm/hugetlbpage.c
--- a/arch/ppc64/mm/hugetlbpage.c	2005-03-05 23:06:10 -08:00
+++ b/arch/ppc64/mm/hugetlbpage.c	2005-03-05 23:06:10 -08:00
@@ -149,7 +149,8 @@
 }
 
 static void set_huge_pte(struct mm_struct *mm, struct vm_area_struct *vma,
-			 struct page *page, pte_t *ptep, int write_access)
+			 unsigned long addr, struct page *page,
+			 pte_t *ptep, int write_access)
 {
 	pte_t entry;
 
@@ -163,7 +164,7 @@
 	entry = pte_mkyoung(entry);
 	entry = pte_mkhuge(entry);
 
-	set_pte(ptep, entry);
+	set_pte_at(mm, addr, ptep, entry);
 }
 
 /*
@@ -316,7 +317,7 @@
 		ptepage = pte_page(entry);
 		get_page(ptepage);
 		dst->rss += (HPAGE_SIZE / PAGE_SIZE);
-		set_pte(dst_pte, entry);
+		set_pte_at(dst, addr, dst_pte, entry);
 
 		addr += HPAGE_SIZE;
 	}
@@ -421,7 +422,7 @@
 
 		pte = *ptep;
 		page = pte_page(pte);
-		pte_clear(ptep);
+		pte_clear(mm, addr, ptep);
 
 		put_page(page);
 	}
@@ -486,7 +487,7 @@
 				goto out;
 			}
 		}
-		set_huge_pte(mm, vma, page, pte, vma->vm_flags & VM_WRITE);
+		set_huge_pte(mm, vma, addr, page, pte, vma->vm_flags & VM_WRITE);
 	}
 out:
 	spin_unlock(&mm->page_table_lock);
diff -Nru a/arch/ppc64/mm/init.c b/arch/ppc64/mm/init.c
--- a/arch/ppc64/mm/init.c	2005-03-05 23:06:10 -08:00
+++ b/arch/ppc64/mm/init.c	2005-03-05 23:06:10 -08:00
@@ -155,7 +155,7 @@
 		ptep = pte_alloc_kernel(&ioremap_mm, pmdp, ea);
 
 		pa = abs_to_phys(pa);
-		set_pte(ptep, pfn_pte(pa >> PAGE_SHIFT, __pgprot(flags)));
+		set_pte_at(&ioremap_mm, ea, ptep, pfn_pte(pa >> PAGE_SHIFT, __pgprot(flags)));
 		spin_unlock(&ioremap_mm.page_table_lock);
 	} else {
 		unsigned long va, vpn, hash, hpteg;
@@ -307,7 +307,7 @@
 
 	do {
 		pte_t page;
-		page = ptep_get_and_clear(pte);
+		page = ptep_get_and_clear(&ioremap_mm, address, pte);
 		address += PAGE_SIZE;
 		pte++;
 		if (pte_none(page))
diff -Nru a/arch/ppc64/mm/tlb.c b/arch/ppc64/mm/tlb.c
--- a/arch/ppc64/mm/tlb.c	2005-03-05 23:06:10 -08:00
+++ b/arch/ppc64/mm/tlb.c	2005-03-05 23:06:10 -08:00
@@ -74,23 +74,12 @@
  * change the existing HPTE to read-only rather than removing it
  * (if we remove it we should clear the _PTE_HPTEFLAGS bits).
  */
-void hpte_update(pte_t *ptep, unsigned long pte, int wrprot)
+void hpte_update(struct mm_struct *mm, unsigned long addr,
+		 unsigned long pte, int wrprot)
 {
-	struct page *ptepage;
-	struct mm_struct *mm;
-	unsigned long addr;
 	int i;
 	unsigned long context = 0;
 	struct ppc64_tlb_batch *batch = &__get_cpu_var(ppc64_tlb_batch);
-
-	ptepage = virt_to_page(ptep);
-	mm = (struct mm_struct *) ptepage->mapping;
-	addr = ptepage->index;
-	if (pte_huge(pte))
-		addr +=  ((unsigned long)ptep & ~PAGE_MASK)
-			/ sizeof(*ptep) * HPAGE_SIZE;
-	else
-		addr += ((unsigned long)ptep & ~PAGE_MASK) * PTRS_PER_PTE;
 
 	if (REGION_ID(addr) == USER_REGION_ID)
 		context = mm->context.id;
diff -Nru a/arch/s390/mm/init.c b/arch/s390/mm/init.c
--- a/arch/s390/mm/init.c	2005-03-05 23:06:10 -08:00
+++ b/arch/s390/mm/init.c	2005-03-05 23:06:10 -08:00
@@ -145,7 +145,7 @@
                 for (tmp = 0 ; tmp < PTRS_PER_PTE ; tmp++,pg_table++) {
                         pte = pfn_pte(pfn, PAGE_KERNEL);
                         if (pfn >= max_low_pfn)
-                                pte_clear(&pte);
+                                pte_clear(&init_mm, 0, &pte);
                         set_pte(pg_table, pte);
                         pfn++;
                 }
@@ -229,7 +229,7 @@
                         for (k = 0 ; k < PTRS_PER_PTE ; k++,pt_dir++) {
                                 pte = pfn_pte(pfn, PAGE_KERNEL);
                                 if (pfn >= max_low_pfn) {
-                                        pte_clear(&pte); 
+                                        pte_clear(&init_mm, 0, &pte); 
                                         continue;
                                 }
                                 set_pte(pt_dir, pte);
diff -Nru a/arch/sh/mm/hugetlbpage.c b/arch/sh/mm/hugetlbpage.c
--- a/arch/sh/mm/hugetlbpage.c	2005-03-05 23:06:10 -08:00
+++ b/arch/sh/mm/hugetlbpage.c	2005-03-05 23:06:10 -08:00
@@ -202,7 +202,7 @@
 		page = pte_page(*pte);
 		put_page(page);
 		for (i = 0; i < (1 << HUGETLB_PAGE_ORDER); i++) {
-			pte_clear(pte);
+			pte_clear(mm, address+(i*PAGE_SIZE), pte);
 			pte++;
 		}
 	}
diff -Nru a/arch/sh/mm/pg-sh4.c b/arch/sh/mm/pg-sh4.c
--- a/arch/sh/mm/pg-sh4.c	2005-03-05 23:06:10 -08:00
+++ b/arch/sh/mm/pg-sh4.c	2005-03-05 23:06:10 -08:00
@@ -56,7 +56,7 @@
 		local_irq_restore(flags);
 		update_mmu_cache(NULL, p3_addr, entry);
 		__clear_user_page((void *)p3_addr, to);
-		pte_clear(pte);
+		pte_clear(&init_mm, p3_addr, pte);
 		up(&p3map_sem[(address & CACHE_ALIAS)>>12]);
 	}
 }
@@ -95,7 +95,7 @@
 		local_irq_restore(flags);
 		update_mmu_cache(NULL, p3_addr, entry);
 		__copy_user_page((void *)p3_addr, from, to);
-		pte_clear(pte);
+		pte_clear(&init_mm, p3_addr, pte);
 		up(&p3map_sem[(address & CACHE_ALIAS)>>12]);
 	}
 }
@@ -103,11 +103,11 @@
 /*
  * For SH-4, we have our own implementation for ptep_get_and_clear
  */
-inline pte_t ptep_get_and_clear(pte_t *ptep)
+inline pte_t ptep_get_and_clear(struct mm_struct *mm, unsigned long addr, pte_t *ptep)
 {
 	pte_t pte = *ptep;
 
-	pte_clear(ptep);
+	pte_clear(mm, addr, ptep);
 	if (!pte_not_present(pte)) {
 		unsigned long pfn = pte_pfn(pte);
 		if (pfn_valid(pfn)) {
diff -Nru a/arch/sh/mm/pg-sh7705.c b/arch/sh/mm/pg-sh7705.c
--- a/arch/sh/mm/pg-sh7705.c	2005-03-05 23:06:10 -08:00
+++ b/arch/sh/mm/pg-sh7705.c	2005-03-05 23:06:10 -08:00
@@ -117,11 +117,11 @@
  * For SH7705, we have our own implementation for ptep_get_and_clear
  * Copied from pg-sh4.c
  */
-inline pte_t ptep_get_and_clear(pte_t *ptep)
+inline pte_t ptep_get_and_clear(struct mm_struct *mm, unsigned long addr, pte_t *ptep)
 {
 	pte_t pte = *ptep;
 
-	pte_clear(ptep);
+	pte_clear(mm, addr, ptep);
 	if (!pte_not_present(pte)) {
 		unsigned long pfn = pte_pfn(pte);
 		if (pfn_valid(pfn)) {
diff -Nru a/arch/sh64/mm/hugetlbpage.c b/arch/sh64/mm/hugetlbpage.c
--- a/arch/sh64/mm/hugetlbpage.c	2005-03-05 23:06:10 -08:00
+++ b/arch/sh64/mm/hugetlbpage.c	2005-03-05 23:06:10 -08:00
@@ -202,7 +202,7 @@
 		page = pte_page(*pte);
 		put_page(page);
 		for (i = 0; i < (1 << HUGETLB_PAGE_ORDER); i++) {
-			pte_clear(pte);
+			pte_clear(mm, address+(i*PAGE_SIZE), pte);
 			pte++;
 		}
 	}
diff -Nru a/arch/sh64/mm/ioremap.c b/arch/sh64/mm/ioremap.c
--- a/arch/sh64/mm/ioremap.c	2005-03-05 23:06:10 -08:00
+++ b/arch/sh64/mm/ioremap.c	2005-03-05 23:06:10 -08:00
@@ -400,7 +400,7 @@
 		return;
 
 	clear_page((void *)ptep);
-	pte_clear(ptep);
+	pte_clear(&init_mm, vaddr, ptep);
 }
 
 unsigned long onchip_remap(unsigned long phys, unsigned long size, const char *name)
diff -Nru a/arch/sparc/mm/generic.c b/arch/sparc/mm/generic.c
--- a/arch/sparc/mm/generic.c	2005-03-05 23:06:10 -08:00
+++ b/arch/sparc/mm/generic.c	2005-03-05 23:06:10 -08:00
@@ -47,7 +47,7 @@
  * They use a pgprot that sets PAGE_IO and does not check the
  * mem_map table as this is independent of normal memory.
  */
-static inline void io_remap_pte_range(pte_t * pte, unsigned long address, unsigned long size,
+static inline void io_remap_pte_range(struct mm_struct *mm, pte_t * pte, unsigned long address, unsigned long size,
 	unsigned long offset, pgprot_t prot, int space)
 {
 	unsigned long end;
@@ -58,7 +58,7 @@
 		end = PMD_SIZE;
 	do {
 		pte_t oldpage = *pte;
-		pte_clear(pte);
+		pte_clear(mm, address, pte);
 		set_pte(pte, mk_pte_io(offset, prot, space));
 		forget_pte(oldpage);
 		address += PAGE_SIZE;
@@ -67,7 +67,7 @@
 	} while (address < end);
 }
 
-static inline int io_remap_pmd_range(pmd_t * pmd, unsigned long address, unsigned long size,
+static inline int io_remap_pmd_range(struct mm_struct *mm, pmd_t * pmd, unsigned long address, unsigned long size,
 	unsigned long offset, pgprot_t prot, int space)
 {
 	unsigned long end;
@@ -78,10 +78,10 @@
 		end = PGDIR_SIZE;
 	offset -= address;
 	do {
-		pte_t * pte = pte_alloc_map(current->mm, pmd, address);
+		pte_t * pte = pte_alloc_map(mm, pmd, address);
 		if (!pte)
 			return -ENOMEM;
-		io_remap_pte_range(pte, address, end - address, address + offset, prot, space);
+		io_remap_pte_range(mm, pte, address, end - address, address + offset, prot, space);
 		address = (address + PMD_SIZE) & PMD_MASK;
 		pmd++;
 	} while (address < end);
@@ -107,7 +107,7 @@
 		error = -ENOMEM;
 		if (!pmd)
 			break;
-		error = io_remap_pmd_range(pmd, from, end - from, offset + from, prot, space);
+		error = io_remap_pmd_range(mm, pmd, from, end - from, offset + from, prot, space);
 		if (error)
 			break;
 		from = (from + PGDIR_SIZE) & PGDIR_MASK;
diff -Nru a/arch/sparc/mm/highmem.c b/arch/sparc/mm/highmem.c
--- a/arch/sparc/mm/highmem.c	2005-03-05 23:06:10 -08:00
+++ b/arch/sparc/mm/highmem.c	2005-03-05 23:06:10 -08:00
@@ -88,7 +88,7 @@
 	 * force other mappings to Oops if they'll try to access
 	 * this pte without first remap it
 	 */
-	pte_clear(kmap_pte-idx);
+	pte_clear(&init_mm, vaddr, kmap_pte-idx);
 /* XXX Fix - Anton */
 #if 0
 	__flush_tlb_one(vaddr);
diff -Nru a/arch/sparc64/mm/generic.c b/arch/sparc64/mm/generic.c
--- a/arch/sparc64/mm/generic.c	2005-03-05 23:06:10 -08:00
+++ b/arch/sparc64/mm/generic.c	2005-03-05 23:06:10 -08:00
@@ -25,8 +25,11 @@
  * side-effect bit will be turned off.  This is used as a
  * performance improvement on FFB/AFB. -DaveM
  */
-static inline void io_remap_pte_range(pte_t * pte, unsigned long address, unsigned long size,
-	unsigned long offset, pgprot_t prot, int space)
+static inline void io_remap_pte_range(struct mm_struct *mm, pte_t * pte,
+				      unsigned long address,
+				      unsigned long size,
+				      unsigned long offset, pgprot_t prot,
+				      int space)
 {
 	unsigned long end;
 
@@ -67,14 +70,14 @@
 			pte_val(entry) &= ~(_PAGE_E);
 		do {
 			BUG_ON(!pte_none(*pte));
-			set_pte(pte, entry);
+			set_pte_at(mm, address, pte, entry);
 			address += PAGE_SIZE;
 			pte++;
 		} while (address < curend);
 	} while (address < end);
 }
 
-static inline int io_remap_pmd_range(pmd_t * pmd, unsigned long address, unsigned long size,
+static inline int io_remap_pmd_range(struct mm_struct *mm, pmd_t * pmd, unsigned long address, unsigned long size,
 	unsigned long offset, pgprot_t prot, int space)
 {
 	unsigned long end;
@@ -85,10 +88,10 @@
 		end = PGDIR_SIZE;
 	offset -= address;
 	do {
-		pte_t * pte = pte_alloc_map(current->mm, pmd, address);
+		pte_t * pte = pte_alloc_map(mm, pmd, address);
 		if (!pte)
 			return -ENOMEM;
-		io_remap_pte_range(pte, address, end - address, address + offset, prot, space);
+		io_remap_pte_range(mm, pte, address, end - address, address + offset, prot, space);
 		pte_unmap(pte);
 		address = (address + PMD_SIZE) & PMD_MASK;
 		pmd++;
@@ -96,7 +99,7 @@
 	return 0;
 }
 
-static inline int io_remap_pud_range(pud_t * pud, unsigned long address, unsigned long size,
+static inline int io_remap_pud_range(struct mm_struct *mm, pud_t * pud, unsigned long address, unsigned long size,
 	unsigned long offset, pgprot_t prot, int space)
 {
 	unsigned long end;
@@ -107,10 +110,10 @@
 		end = PUD_SIZE;
 	offset -= address;
 	do {
-		pmd_t *pmd = pmd_alloc(current->mm, pud, address);
+		pmd_t *pmd = pmd_alloc(mm, pud, address);
 		if (!pud)
 			return -ENOMEM;
-		io_remap_pmd_range(pmd, address, end - address, address + offset, prot, space);
+		io_remap_pmd_range(mm, pmd, address, end - address, address + offset, prot, space);
 		address = (address + PUD_SIZE) & PUD_MASK;
 		pud++;
 	} while (address < end);
@@ -132,11 +135,11 @@
 
 	spin_lock(&mm->page_table_lock);
 	while (from < end) {
-		pud_t *pud = pud_alloc(current->mm, dir, from);
+		pud_t *pud = pud_alloc(mm, dir, from);
 		error = -ENOMEM;
 		if (!pud)
 			break;
-		error = io_remap_pud_range(pud, from, end - from, offset + from, prot, space);
+		error = io_remap_pud_range(mm, pud, from, end - from, offset + from, prot, space);
 		if (error)
 			break;
 		from = (from + PGDIR_SIZE) & PGDIR_MASK;
diff -Nru a/arch/sparc64/mm/hugetlbpage.c b/arch/sparc64/mm/hugetlbpage.c
--- a/arch/sparc64/mm/hugetlbpage.c	2005-03-05 23:06:10 -08:00
+++ b/arch/sparc64/mm/hugetlbpage.c	2005-03-05 23:06:10 -08:00
@@ -62,6 +62,7 @@
 #define mk_pte_huge(entry) do { pte_val(entry) |= _PAGE_SZHUGE; } while (0)
 
 static void set_huge_pte(struct mm_struct *mm, struct vm_area_struct *vma,
+			 unsigned long addr,
 			 struct page *page, pte_t * page_table, int write_access)
 {
 	unsigned long i;
@@ -78,8 +79,9 @@
 	mk_pte_huge(entry);
 
 	for (i = 0; i < (1 << HUGETLB_PAGE_ORDER); i++) {
-		set_pte(page_table, entry);
+		set_pte_at(mm, addr, page_table, entry);
 		page_table++;
+		addr += PAGE_SIZE;
 
 		pte_val(entry) += PAGE_SIZE;
 	}
@@ -116,12 +118,12 @@
 		ptepage = pte_page(entry);
 		get_page(ptepage);
 		for (i = 0; i < (1 << HUGETLB_PAGE_ORDER); i++) {
-			set_pte(dst_pte, entry);
+			set_pte_at(dst, addr, dst_pte, entry);
 			pte_val(entry) += PAGE_SIZE;
 			dst_pte++;
+			addr += PAGE_SIZE;
 		}
 		dst->rss += (HPAGE_SIZE / PAGE_SIZE);
-		addr += HPAGE_SIZE;
 	}
 	return 0;
 
@@ -207,7 +209,7 @@
 		page = pte_page(*pte);
 		put_page(page);
 		for (i = 0; i < (1 << HUGETLB_PAGE_ORDER); i++) {
-			pte_clear(pte);
+			pte_clear(mm, address+(i*PAGE_SIZE), pte);
 			pte++;
 		}
 	}
@@ -261,7 +263,7 @@
 				goto out;
 			}
 		}
-		set_huge_pte(mm, vma, page, pte, vma->vm_flags & VM_WRITE);
+		set_huge_pte(mm, vma, addr, page, pte, vma->vm_flags & VM_WRITE);
 	}
 out:
 	spin_unlock(&mm->page_table_lock);
diff -Nru a/arch/sparc64/mm/init.c b/arch/sparc64/mm/init.c
--- a/arch/sparc64/mm/init.c	2005-03-05 23:06:10 -08:00
+++ b/arch/sparc64/mm/init.c	2005-03-05 23:06:10 -08:00
@@ -431,7 +431,8 @@
 				if (tlb_type == spitfire)
 					val &= ~0x0003fe0000000000UL;
 
-				set_pte (ptep, __pte(val | _PAGE_MODIFIED));
+				set_pte_at(&init_mm, vaddr,
+					   ptep, __pte(val | _PAGE_MODIFIED));
 				trans[i].data += BASE_PAGE_SIZE;
 			}
 		}
diff -Nru a/arch/sparc64/mm/tlb.c b/arch/sparc64/mm/tlb.c
--- a/arch/sparc64/mm/tlb.c	2005-03-05 23:06:10 -08:00
+++ b/arch/sparc64/mm/tlb.c	2005-03-05 23:06:10 -08:00
@@ -41,24 +41,12 @@
 	}
 }
 
-void tlb_batch_add(pte_t *ptep, pte_t orig)
+void tlb_batch_add(struct mm_struct *mm, unsigned long vaddr, pte_t *ptep, pte_t orig)
 {
 	struct mmu_gather *mp = &__get_cpu_var(mmu_gathers);
-	struct page *ptepage;
-	struct mm_struct *mm;
-	unsigned long vaddr, nr;
+	unsigned long nr;
 
-	ptepage = virt_to_page(ptep);
-	mm = (struct mm_struct *) ptepage->mapping;
-
-	/* It is more efficient to let flush_tlb_kernel_range()
-	 * handle these cases.
-	 */
-	if (mm == &init_mm)
-		return;
-
-	vaddr = ptepage->index +
-		(((unsigned long)ptep & ~PAGE_MASK) * PTRS_PER_PTE);
+	vaddr &= PAGE_MASK;
 	if (pte_exec(orig))
 		vaddr |= 0x1UL;
 
diff -Nru a/fs/exec.c b/fs/exec.c
--- a/fs/exec.c	2005-03-05 23:06:10 -08:00
+++ b/fs/exec.c	2005-03-05 23:06:10 -08:00
@@ -328,7 +328,7 @@
 	}
 	mm->rss++;
 	lru_cache_add_active(page);
-	set_pte(pte, pte_mkdirty(pte_mkwrite(mk_pte(
+	set_pte_at(mm, address, pte, pte_mkdirty(pte_mkwrite(mk_pte(
 					page, vma->vm_page_prot))));
 	page_add_anon_rmap(page, vma, address);
 	pte_unmap(pte);
diff -Nru a/include/asm-alpha/pgtable.h b/include/asm-alpha/pgtable.h
--- a/include/asm-alpha/pgtable.h	2005-03-05 23:06:10 -08:00
+++ b/include/asm-alpha/pgtable.h	2005-03-05 23:06:10 -08:00
@@ -22,6 +22,7 @@
  * hook is made available.
  */
 #define set_pte(pteptr, pteval) ((*(pteptr)) = (pteval))
+#define set_pte_at(mm,addr,ptep,pteval) set_pte(ptep,pteval)
 
 /* PMD_SHIFT determines the size of the area a second-level page table can map */
 #define PMD_SHIFT	(PAGE_SHIFT + (PAGE_SHIFT-3))
@@ -235,7 +236,10 @@
 
 extern inline int pte_none(pte_t pte)		{ return !pte_val(pte); }
 extern inline int pte_present(pte_t pte)	{ return pte_val(pte) & _PAGE_VALID; }
-extern inline void pte_clear(pte_t *ptep)	{ pte_val(*ptep) = 0; }
+extern inline void pte_clear(struct mm_struct *mm, unsigned long addr, pte_t *ptep)
+{
+	pte_val(*ptep) = 0;
+}
 
 extern inline int pmd_none(pmd_t pmd)		{ return !pmd_val(pmd); }
 extern inline int pmd_bad(pmd_t pmd)		{ return (pmd_val(pmd) & ~_PFN_MASK) != _PAGE_TABLE; }
diff -Nru a/include/asm-arm/pgtable.h b/include/asm-arm/pgtable.h
--- a/include/asm-arm/pgtable.h	2005-03-05 23:06:10 -08:00
+++ b/include/asm-arm/pgtable.h	2005-03-05 23:06:10 -08:00
@@ -262,7 +262,7 @@
 #define pfn_pte(pfn,prot)	(__pte(((pfn) << PAGE_SHIFT) | pgprot_val(prot)))
 
 #define pte_none(pte)		(!pte_val(pte))
-#define pte_clear(ptep)		set_pte((ptep), __pte(0))
+#define pte_clear(mm,addr,ptep)	set_pte_at((mm),(addr),(ptep), __pte(0))
 #define pte_page(pte)		(pfn_to_page(pte_pfn(pte)))
 #define pte_offset_kernel(dir,addr)	(pmd_page_kernel(*(dir)) + __pte_index(addr))
 #define pte_offset_map(dir,addr)	(pmd_page_kernel(*(dir)) + __pte_index(addr))
@@ -271,6 +271,7 @@
 #define pte_unmap_nested(pte)	do { } while (0)
 
 #define set_pte(ptep, pte)	cpu_set_pte(ptep,pte)
+#define set_pte_at(mm,addr,ptep,pteval) set_pte(ptep,pteval)
 
 /*
  * The following only work if pte_present() is true.
diff -Nru a/include/asm-arm26/pgtable.h b/include/asm-arm26/pgtable.h
--- a/include/asm-arm26/pgtable.h	2005-03-05 23:06:10 -08:00
+++ b/include/asm-arm26/pgtable.h	2005-03-05 23:06:10 -08:00
@@ -154,7 +154,8 @@
 #define pte_none(pte)           (!pte_val(pte))
 #define pte_present(pte)        (pte_val(pte) & _PAGE_PRESENT)
 #define set_pte(pte_ptr, pte)   ((*(pte_ptr)) = (pte))
-#define pte_clear(ptep)         set_pte((ptep), __pte(0))
+#define set_pte_at(mm,addr,ptep,pteval) set_pte(ptep,pteval)
+#define pte_clear(mm,addr,ptep)	set_pte_at((mm),(addr),(ptep), __pte(0))
 
 /* macros to ease the getting of pointers to stuff... */
 #define pgd_offset(mm, addr)	((pgd_t *)(mm)->pgd        + __pgd_index(addr))
diff -Nru a/include/asm-cris/pgtable.h b/include/asm-cris/pgtable.h
--- a/include/asm-cris/pgtable.h	2005-03-05 23:06:10 -08:00
+++ b/include/asm-cris/pgtable.h	2005-03-05 23:06:10 -08:00
@@ -34,6 +34,8 @@
  * hook is made available.
  */
 #define set_pte(pteptr, pteval) ((*(pteptr)) = (pteval))
+#define set_pte_at(mm,addr,ptep,pteval) set_pte(ptep,pteval)
+
 /*
  * (pmds are folded into pgds so this doesn't get actually called,
  * but the define is needed for a generic inline function.)
@@ -101,7 +103,7 @@
 
 #define pte_none(x)	(!pte_val(x))
 #define pte_present(x)	(pte_val(x) & _PAGE_PRESENT)
-#define pte_clear(xp)	do { pte_val(*(xp)) = 0; } while (0)
+#define pte_clear(mm,addr,xp)	do { pte_val(*(xp)) = 0; } while (0)
 
 #define pmd_none(x)	(!pmd_val(x))
 /* by removing the _PAGE_KERNEL bit from the comparision, the same pmd_bad
diff -Nru a/include/asm-frv/pgtable.h b/include/asm-frv/pgtable.h
--- a/include/asm-frv/pgtable.h	2005-03-05 23:06:10 -08:00
+++ b/include/asm-frv/pgtable.h	2005-03-05 23:06:10 -08:00
@@ -173,6 +173,7 @@
 	*(pteptr) = (pteval);				\
 	asm volatile("dcf %M0" :: "U"(*pteptr));	\
 } while(0)
+#define set_pte_at(mm,addr,ptep,pteval) set_pte(ptep,pteval)
 
 #define set_pte_atomic(pteptr, pteval)		set_pte((pteptr), (pteval))
 
@@ -353,7 +354,7 @@
 #undef TEST_VERIFY_AREA
 
 #define pte_present(x)	(pte_val(x) & _PAGE_PRESENT)
-#define pte_clear(xp)	do { set_pte(xp, __pte(0)); } while (0)
+#define pte_clear(mm,addr,xp)	do { set_pte_at(mm, addr, xp, __pte(0)); } while (0)
 
 #define pmd_none(x)	(!pmd_val(x))
 #define pmd_present(x)	(pmd_val(x) & _PAGE_PRESENT)
@@ -390,39 +391,33 @@
 static inline pte_t pte_mkyoung(pte_t pte)	{ (pte).pte |= _PAGE_ACCESSED; return pte; }
 static inline pte_t pte_mkwrite(pte_t pte)	{ (pte).pte &= ~_PAGE_WP; return pte; }
 
-static inline int ptep_test_and_clear_dirty(pte_t *ptep)
+static inline int ptep_test_and_clear_dirty(struct vm_area_struct *vma, unsigned long addr, pte_t *ptep)
 {
 	int i = test_and_clear_bit(_PAGE_BIT_DIRTY, ptep);
 	asm volatile("dcf %M0" :: "U"(*ptep));
 	return i;
 }
 
-static inline int ptep_test_and_clear_young(pte_t *ptep)
+static inline int ptep_test_and_clear_young(struct vm_area_struct *vma, unsigned long addr, pte_t *ptep)
 {
 	int i = test_and_clear_bit(_PAGE_BIT_ACCESSED, ptep);
 	asm volatile("dcf %M0" :: "U"(*ptep));
 	return i;
 }
 
-static inline pte_t ptep_get_and_clear(pte_t *ptep)
+static inline pte_t ptep_get_and_clear(struct mm_struct *mm, unsigned long addr, pte_t *ptep)
 {
 	unsigned long x = xchg(&ptep->pte, 0);
 	asm volatile("dcf %M0" :: "U"(*ptep));
 	return __pte(x);
 }
 
-static inline void ptep_set_wrprotect(pte_t *ptep)
+static inline void ptep_set_wrprotect(struct mm_struct *mm, unsigned long addr, pte_t *ptep)
 {
 	set_bit(_PAGE_BIT_WP, ptep);
 	asm volatile("dcf %M0" :: "U"(*ptep));
 }
 
-static inline void ptep_mkdirty(pte_t *ptep)
-{
-	set_bit(_PAGE_BIT_DIRTY, ptep);
-	asm volatile("dcf %M0" :: "U"(*ptep));
-}
-
 /*
  * Conversion functions: convert a page and protection to a page entry,
  * and a page entry and page directory to the page they refer to.
@@ -512,7 +507,6 @@
 #define __HAVE_ARCH_PTEP_TEST_AND_CLEAR_DIRTY
 #define __HAVE_ARCH_PTEP_GET_AND_CLEAR
 #define __HAVE_ARCH_PTEP_SET_WRPROTECT
-#define __HAVE_ARCH_PTEP_MKDIRTY
 #define __HAVE_ARCH_PTE_SAME
 #include <asm-generic/pgtable.h>
 
diff -Nru a/include/asm-generic/pgtable.h b/include/asm-generic/pgtable.h
--- a/include/asm-generic/pgtable.h	2005-03-05 23:06:10 -08:00
+++ b/include/asm-generic/pgtable.h	2005-03-05 23:06:10 -08:00
@@ -16,7 +16,7 @@
 #ifndef __HAVE_ARCH_SET_PTE_ATOMIC
 #define ptep_establish(__vma, __address, __ptep, __entry)		\
 do {				  					\
-	set_pte(__ptep, __entry);					\
+	set_pte_at((__vma)->vm_mm, (__address), __ptep, __entry);	\
 	flush_tlb_page(__vma, __address);				\
 } while (0)
 #else /* __HAVE_ARCH_SET_PTE_ATOMIC */
@@ -37,26 +37,30 @@
  */
 #define ptep_set_access_flags(__vma, __address, __ptep, __entry, __dirty) \
 do {				  					  \
-	set_pte(__ptep, __entry);					  \
+	set_pte_at((__vma)->vm_mm, (__address), __ptep, __entry);	  \
 	flush_tlb_page(__vma, __address);				  \
 } while (0)
 #endif
 
 #ifndef __HAVE_ARCH_PTEP_TEST_AND_CLEAR_YOUNG
-static inline int ptep_test_and_clear_young(pte_t *ptep)
-{
-	pte_t pte = *ptep;
-	if (!pte_young(pte))
-		return 0;
-	set_pte(ptep, pte_mkold(pte));
-	return 1;
-}
+#define ptep_test_and_clear_young(__vma, __address, __ptep)		\
+({									\
+	pte_t __pte = *(__ptep);					\
+	int r = 1;							\
+	if (!pte_young(__pte))						\
+		r = 0;							\
+	else								\
+		set_pte_at((__vma)->vm_mm, (__address),			\
+			   (__ptep), pte_mkold(__pte));			\
+	r;								\
+})
 #endif
 
 #ifndef __HAVE_ARCH_PTEP_CLEAR_YOUNG_FLUSH
 #define ptep_clear_flush_young(__vma, __address, __ptep)		\
 ({									\
-	int __young = ptep_test_and_clear_young(__ptep);		\
+	int __young;							\
+	__young = ptep_test_and_clear_young(__vma, __address, __ptep);	\
 	if (__young)							\
 		flush_tlb_page(__vma, __address);			\
 	__young;							\
@@ -64,20 +68,24 @@
 #endif
 
 #ifndef __HAVE_ARCH_PTEP_TEST_AND_CLEAR_DIRTY
-static inline int ptep_test_and_clear_dirty(pte_t *ptep)
-{
-	pte_t pte = *ptep;
-	if (!pte_dirty(pte))
-		return 0;
-	set_pte(ptep, pte_mkclean(pte));
-	return 1;
-}
+#define ptep_test_and_clear_dirty(__vma, __address, __ptep)		\
+({									\
+	pte_t __pte = *ptep;						\
+	int r = 1;							\
+	if (!pte_dirty(__pte))						\
+		r = 0;							\
+	else								\
+		set_pte_at((__vma)->vm_mm, (__address), (__ptep),	\
+			   pte_mkclean(__pte));				\
+	r;								\
+})
 #endif
 
 #ifndef __HAVE_ARCH_PTEP_CLEAR_DIRTY_FLUSH
 #define ptep_clear_flush_dirty(__vma, __address, __ptep)		\
 ({									\
-	int __dirty = ptep_test_and_clear_dirty(__ptep);		\
+	int __dirty;							\
+	__dirty = ptep_test_and_clear_dirty(__vma, __address, __ptep);	\
 	if (__dirty)							\
 		flush_tlb_page(__vma, __address);			\
 	__dirty;							\
@@ -85,36 +93,29 @@
 #endif
 
 #ifndef __HAVE_ARCH_PTEP_GET_AND_CLEAR
-static inline pte_t ptep_get_and_clear(pte_t *ptep)
-{
-	pte_t pte = *ptep;
-	pte_clear(ptep);
-	return pte;
-}
+#define ptep_get_and_clear(__mm, __address, __ptep)			\
+({									\
+	pte_t __pte = *(__ptep);					\
+	pte_clear((__mm), (__address), (__ptep));			\
+	__pte;								\
+})
 #endif
 
 #ifndef __HAVE_ARCH_PTEP_CLEAR_FLUSH
 #define ptep_clear_flush(__vma, __address, __ptep)			\
 ({									\
-	pte_t __pte = ptep_get_and_clear(__ptep);			\
+	pte_t __pte;							\
+	__pte = ptep_get_and_clear((__vma)->vm_mm, __address, __ptep);	\
 	flush_tlb_page(__vma, __address);				\
 	__pte;								\
 })
 #endif
 
 #ifndef __HAVE_ARCH_PTEP_SET_WRPROTECT
-static inline void ptep_set_wrprotect(pte_t *ptep)
-{
-	pte_t old_pte = *ptep;
-	set_pte(ptep, pte_wrprotect(old_pte));
-}
-#endif
-
-#ifndef __HAVE_ARCH_PTEP_MKDIRTY
-static inline void ptep_mkdirty(pte_t *ptep)
+static inline void ptep_set_wrprotect(struct mm_struct *mm, unsigned long address, pte_t *ptep)
 {
 	pte_t old_pte = *ptep;
-	set_pte(ptep, pte_mkdirty(old_pte));
+	set_pte_at(mm, address, ptep, pte_wrprotect(old_pte));
 }
 #endif
 
diff -Nru a/include/asm-i386/pgtable-2level.h b/include/asm-i386/pgtable-2level.h
--- a/include/asm-i386/pgtable-2level.h	2005-03-05 23:06:10 -08:00
+++ b/include/asm-i386/pgtable-2level.h	2005-03-05 23:06:10 -08:00
@@ -14,10 +14,11 @@
  * hook is made available.
  */
 #define set_pte(pteptr, pteval) (*(pteptr) = pteval)
+#define set_pte_at(mm,addr,ptep,pteval) set_pte(ptep,pteval)
 #define set_pte_atomic(pteptr, pteval) set_pte(pteptr,pteval)
 #define set_pmd(pmdptr, pmdval) (*(pmdptr) = (pmdval))
 
-#define ptep_get_and_clear(xp)	__pte(xchg(&(xp)->pte_low, 0))
+#define ptep_get_and_clear(mm,addr,xp)	__pte(xchg(&(xp)->pte_low, 0))
 #define pte_same(a, b)		((a).pte_low == (b).pte_low)
 #define pte_page(x)		pfn_to_page(pte_pfn(x))
 #define pte_none(x)		(!(x).pte_low)
diff -Nru a/include/asm-i386/pgtable-3level.h b/include/asm-i386/pgtable-3level.h
--- a/include/asm-i386/pgtable-3level.h	2005-03-05 23:06:10 -08:00
+++ b/include/asm-i386/pgtable-3level.h	2005-03-05 23:06:10 -08:00
@@ -56,6 +56,8 @@
 	smp_wmb();
 	ptep->pte_low = pte.pte_low;
 }
+#define set_pte_at(mm,addr,ptep,pteval) set_pte(ptep,pteval)
+
 #define __HAVE_ARCH_SET_PTE_ATOMIC
 #define set_pte_atomic(pteptr,pteval) \
 		set_64bit((unsigned long long *)(pteptr),pte_val(pteval))
@@ -88,7 +90,7 @@
 #define pmd_offset(pud, address) ((pmd_t *) pud_page(*(pud)) + \
 			pmd_index(address))
 
-static inline pte_t ptep_get_and_clear(pte_t *ptep)
+static inline pte_t ptep_get_and_clear(struct mm_struct *mm, unsigned long addr, pte_t *ptep)
 {
 	pte_t res;
 
diff -Nru a/include/asm-i386/pgtable.h b/include/asm-i386/pgtable.h
--- a/include/asm-i386/pgtable.h	2005-03-05 23:06:10 -08:00
+++ b/include/asm-i386/pgtable.h	2005-03-05 23:06:10 -08:00
@@ -201,7 +201,7 @@
 extern unsigned long pg0[];
 
 #define pte_present(x)	((x).pte_low & (_PAGE_PRESENT | _PAGE_PROTNONE))
-#define pte_clear(xp)	do { set_pte(xp, __pte(0)); } while (0)
+#define pte_clear(mm,addr,xp)	do { set_pte_at(mm, addr, xp, __pte(0)); } while (0)
 
 #define pmd_none(x)	(!pmd_val(x))
 #define pmd_present(x)	(pmd_val(x) & _PAGE_PRESENT)
@@ -243,22 +243,24 @@
 # include <asm/pgtable-2level.h>
 #endif
 
-static inline int ptep_test_and_clear_dirty(pte_t *ptep)
+static inline int ptep_test_and_clear_dirty(struct vm_area_struct *vma, unsigned long addr, pte_t *ptep)
 {
 	if (!pte_dirty(*ptep))
 		return 0;
 	return test_and_clear_bit(_PAGE_BIT_DIRTY, &ptep->pte_low);
 }
 
-static inline int ptep_test_and_clear_young(pte_t *ptep)
+static inline int ptep_test_and_clear_young(struct vm_area_struct *vma, unsigned long addr, pte_t *ptep)
 {
 	if (!pte_young(*ptep))
 		return 0;
 	return test_and_clear_bit(_PAGE_BIT_ACCESSED, &ptep->pte_low);
 }
 
-static inline void ptep_set_wrprotect(pte_t *ptep)		{ clear_bit(_PAGE_BIT_RW, &ptep->pte_low); }
-static inline void ptep_mkdirty(pte_t *ptep)			{ set_bit(_PAGE_BIT_DIRTY, &ptep->pte_low); }
+static inline void ptep_set_wrprotect(struct mm_struct *mm, unsigned long addr, pte_t *ptep)
+{
+	clear_bit(_PAGE_BIT_RW, &ptep->pte_low);
+}
 
 /*
  * Macro to mark a page protection value as "uncacheable".  On processors which do not support
@@ -407,7 +409,6 @@
 #define __HAVE_ARCH_PTEP_TEST_AND_CLEAR_DIRTY
 #define __HAVE_ARCH_PTEP_GET_AND_CLEAR
 #define __HAVE_ARCH_PTEP_SET_WRPROTECT
-#define __HAVE_ARCH_PTEP_MKDIRTY
 #define __HAVE_ARCH_PTE_SAME
 #include <asm-generic/pgtable.h>
 
diff -Nru a/include/asm-ia64/pgtable.h b/include/asm-ia64/pgtable.h
--- a/include/asm-ia64/pgtable.h	2005-03-05 23:06:10 -08:00
+++ b/include/asm-ia64/pgtable.h	2005-03-05 23:06:10 -08:00
@@ -202,6 +202,7 @@
  * the PTE in a page table.  Nothing special needs to be on IA-64.
  */
 #define set_pte(ptep, pteval)	(*(ptep) = (pteval))
+#define set_pte_at(mm,addr,ptep,pteval) set_pte(ptep,pteval)
 
 #define RGN_SIZE	(1UL << 61)
 #define RGN_KERNEL	7
@@ -243,7 +244,7 @@
 
 #define pte_none(pte) 			(!pte_val(pte))
 #define pte_present(pte)		(pte_val(pte) & (_PAGE_P | _PAGE_PROTNONE))
-#define pte_clear(pte)			(pte_val(*(pte)) = 0UL)
+#define pte_clear(mm,addr,pte)		(pte_val(*(pte)) = 0UL)
 /* pte_page() returns the "struct page *" corresponding to the PTE: */
 #define pte_page(pte)			virt_to_page(((pte_val(pte) & _PFN_MASK) + PAGE_OFFSET))
 
@@ -345,7 +346,7 @@
 /* atomic versions of the some PTE manipulations: */
 
 static inline int
-ptep_test_and_clear_young (pte_t *ptep)
+ptep_test_and_clear_young (struct vm_area_struct *vma, unsigned long addr, pte_t *ptep)
 {
 #ifdef CONFIG_SMP
 	if (!pte_young(*ptep))
@@ -355,13 +356,13 @@
 	pte_t pte = *ptep;
 	if (!pte_young(pte))
 		return 0;
-	set_pte(ptep, pte_mkold(pte));
+	set_pte_at(vma->vm_mm, addr, ptep, pte_mkold(pte));
 	return 1;
 #endif
 }
 
 static inline int
-ptep_test_and_clear_dirty (pte_t *ptep)
+ptep_test_and_clear_dirty (struct vm_area_struct *vma, unsigned long addr, pte_t *ptep)
 {
 #ifdef CONFIG_SMP
 	if (!pte_dirty(*ptep))
@@ -371,25 +372,25 @@
 	pte_t pte = *ptep;
 	if (!pte_dirty(pte))
 		return 0;
-	set_pte(ptep, pte_mkclean(pte));
+	set_pte_at(vma->vm_mm, addr, ptep, pte_mkclean(pte));
 	return 1;
 #endif
 }
 
 static inline pte_t
-ptep_get_and_clear (pte_t *ptep)
+ptep_get_and_clear(struct mm_struct *mm, unsigned long addr, pte_t *ptep)
 {
 #ifdef CONFIG_SMP
 	return __pte(xchg((long *) ptep, 0));
 #else
 	pte_t pte = *ptep;
-	pte_clear(ptep);
+	pte_clear(mm, addr, ptep);
 	return pte;
 #endif
 }
 
 static inline void
-ptep_set_wrprotect (pte_t *ptep)
+ptep_set_wrprotect(struct mm_struct *mm, unsigned long addr, pte_t *ptep)
 {
 #ifdef CONFIG_SMP
 	unsigned long new, old;
@@ -400,18 +401,7 @@
 	} while (cmpxchg((unsigned long *) ptep, old, new) != old);
 #else
 	pte_t old_pte = *ptep;
-	set_pte(ptep, pte_wrprotect(old_pte));
-#endif
-}
-
-static inline void
-ptep_mkdirty (pte_t *ptep)
-{
-#ifdef CONFIG_SMP
-	set_bit(_PAGE_D_BIT, ptep);
-#else
-	pte_t old_pte = *ptep;
-	set_pte(ptep, pte_mkdirty(old_pte));
+	set_pte_at(mm, addr, ptep, pte_wrprotect(old_pte));
 #endif
 }
 
@@ -558,7 +548,6 @@
 #define __HAVE_ARCH_PTEP_TEST_AND_CLEAR_DIRTY
 #define __HAVE_ARCH_PTEP_GET_AND_CLEAR
 #define __HAVE_ARCH_PTEP_SET_WRPROTECT
-#define __HAVE_ARCH_PTEP_MKDIRTY
 #define __HAVE_ARCH_PTE_SAME
 #define __HAVE_ARCH_PGD_OFFSET_GATE
 #include <asm-generic/pgtable.h>
diff -Nru a/include/asm-m32r/pgtable-2level.h b/include/asm-m32r/pgtable-2level.h
--- a/include/asm-m32r/pgtable-2level.h	2005-03-05 23:06:10 -08:00
+++ b/include/asm-m32r/pgtable-2level.h	2005-03-05 23:06:10 -08:00
@@ -44,6 +44,7 @@
  * hook is made available.
  */
 #define set_pte(pteptr, pteval) (*(pteptr) = pteval)
+#define set_pte_at(mm,addr,ptep,pteval) set_pte(ptep,pteval)
 #define set_pte_atomic(pteptr, pteval)	set_pte(pteptr, pteval)
 /*
  * (pmds are folded into pgds so this doesnt get actually called,
@@ -60,7 +61,7 @@
 	return (pmd_t *) dir;
 }
 
-#define ptep_get_and_clear(xp)	__pte(xchg(&(xp)->pte, 0))
+#define ptep_get_and_clear(mm,addr,xp)	__pte(xchg(&(xp)->pte, 0))
 #define pte_same(a, b)		(pte_val(a) == pte_val(b))
 #define pte_page(x)		pfn_to_page(pte_pfn(x))
 #define pte_none(x)		(!pte_val(x))
diff -Nru a/include/asm-m32r/pgtable.h b/include/asm-m32r/pgtable.h
--- a/include/asm-m32r/pgtable.h	2005-03-05 23:06:10 -08:00
+++ b/include/asm-m32r/pgtable.h	2005-03-05 23:06:10 -08:00
@@ -176,7 +176,7 @@
 /* page table for 0-4MB for everybody */
 
 #define pte_present(x)	(pte_val(x) & (_PAGE_PRESENT | _PAGE_PROTNONE))
-#define pte_clear(xp)	do { set_pte(xp, __pte(0)); } while (0)
+#define pte_clear(mm,addr,xp)	do { set_pte_at(mm, addr, xp, __pte(0)); } while (0)
 
 #define pmd_none(x)	(!pmd_val(x))
 #define pmd_present(x)	(pmd_val(x) & _PAGE_PRESENT)
@@ -282,26 +282,21 @@
 	return pte;
 }
 
-static inline  int ptep_test_and_clear_dirty(pte_t *ptep)
+static inline  int ptep_test_and_clear_dirty(struct vm_area_struct *vma, unsigned long addr, pte_t *ptep)
 {
 	return test_and_clear_bit(_PAGE_BIT_DIRTY, ptep);
 }
 
-static inline  int ptep_test_and_clear_young(pte_t *ptep)
+static inline  int ptep_test_and_clear_young(struct vm_area_struct *vma, unsigned long addr, pte_t *ptep)
 {
 	return test_and_clear_bit(_PAGE_BIT_ACCESSED, ptep);
 }
 
-static inline void ptep_set_wrprotect(pte_t *ptep)
+static inline void ptep_set_wrprotect(struct mm_struct *mm, unsigned long addr, pte_t *ptep)
 {
 	clear_bit(_PAGE_BIT_WRITE, ptep);
 }
 
-static inline void ptep_mkdirty(pte_t *ptep)
-{
-	set_bit(_PAGE_BIT_DIRTY, ptep);
-}
-
 /*
  * Macro and implementation to make a page protection as uncachable.
  */
@@ -390,7 +385,6 @@
 #define __HAVE_ARCH_PTEP_TEST_AND_CLEAR_DIRTY
 #define __HAVE_ARCH_PTEP_GET_AND_CLEAR
 #define __HAVE_ARCH_PTEP_SET_WRPROTECT
-#define __HAVE_ARCH_PTEP_MKDIRTY
 #define __HAVE_ARCH_PTE_SAME
 #include <asm-generic/pgtable.h>
 
diff -Nru a/include/asm-m68k/motorola_pgtable.h b/include/asm-m68k/motorola_pgtable.h
--- a/include/asm-m68k/motorola_pgtable.h	2005-03-05 23:06:10 -08:00
+++ b/include/asm-m68k/motorola_pgtable.h	2005-03-05 23:06:10 -08:00
@@ -129,7 +129,7 @@
 
 #define pte_none(pte)		(!pte_val(pte))
 #define pte_present(pte)	(pte_val(pte) & (_PAGE_PRESENT | _PAGE_PROTNONE))
-#define pte_clear(ptep)		({ pte_val(*(ptep)) = 0; })
+#define pte_clear(mm,addr,ptep)		({ pte_val(*(ptep)) = 0; })
 
 #define pte_page(pte)		(mem_map + ((unsigned long)(__va(pte_val(pte)) - PAGE_OFFSET) >> PAGE_SHIFT))
 #define pte_pfn(pte)		(pte_val(pte) >> PAGE_SHIFT)
diff -Nru a/include/asm-m68k/pgtable.h b/include/asm-m68k/pgtable.h
--- a/include/asm-m68k/pgtable.h	2005-03-05 23:06:10 -08:00
+++ b/include/asm-m68k/pgtable.h	2005-03-05 23:06:10 -08:00
@@ -26,6 +26,7 @@
 	do{							\
 		*(pteptr) = (pteval);				\
 	} while(0)
+#define set_pte_at(mm,addr,ptep,pteval) set_pte(ptep,pteval)
 
 
 /* PMD_SHIFT determines the size of the area a second-level page table can map */
diff -Nru a/include/asm-m68k/sun3_pgtable.h b/include/asm-m68k/sun3_pgtable.h
--- a/include/asm-m68k/sun3_pgtable.h	2005-03-05 23:06:10 -08:00
+++ b/include/asm-m68k/sun3_pgtable.h	2005-03-05 23:06:10 -08:00
@@ -123,7 +123,10 @@
 
 static inline int pte_none (pte_t pte) { return !pte_val (pte); }
 static inline int pte_present (pte_t pte) { return pte_val (pte) & SUN3_PAGE_VALID; }
-static inline void pte_clear (pte_t *ptep) { pte_val (*ptep) = 0; }
+static inline void pte_clear (struct mm_struct *mm, unsigned long addr, pte_t *ptep)
+{
+	pte_val (*ptep) = 0;
+}
 
 #define pte_pfn(pte)            (pte_val(pte) & SUN3_PAGE_PGNUM_MASK)
 #define pfn_pte(pfn, pgprot) \
diff -Nru a/include/asm-mips/pgtable.h b/include/asm-mips/pgtable.h
--- a/include/asm-mips/pgtable.h	2005-03-05 23:06:10 -08:00
+++ b/include/asm-mips/pgtable.h	2005-03-05 23:06:10 -08:00
@@ -100,14 +100,15 @@
 			buddy->pte_low |= _PAGE_GLOBAL;
 	}
 }
+#define set_pte_at(mm,addr,ptep,pteval) set_pte(ptep,pteval)
 
-static inline void pte_clear(pte_t *ptep)
+static inline void pte_clear(struct mm_struct *mm, unsigned long addr, pte_t *ptep)
 {
 	/* Preserve global status for the pair */
 	if (pte_val(*ptep_buddy(ptep)) & _PAGE_GLOBAL)
-		set_pte(ptep, __pte(_PAGE_GLOBAL));
+		set_pte_at(mm, addr, ptep, __pte(_PAGE_GLOBAL));
 	else
-		set_pte(ptep, __pte(0));
+		set_pte_at(mm, addr, ptep, __pte(0));
 }
 #else
 /*
@@ -130,16 +131,17 @@
 	}
 #endif
 }
+#define set_pte_at(mm,addr,ptep,pteval) set_pte(ptep,pteval)
 
-static inline void pte_clear(pte_t *ptep)
+static inline void pte_clear(struct mm_struct *mm, unsigned long addr, pte_t *ptep)
 {
 #if !defined(CONFIG_CPU_R3000) && !defined(CONFIG_CPU_TX39XX)
 	/* Preserve global status for the pair */
 	if (pte_val(*ptep_buddy(ptep)) & _PAGE_GLOBAL)
-		set_pte(ptep, __pte(_PAGE_GLOBAL));
+		set_pte_at(mm, addr, ptep, __pte(_PAGE_GLOBAL));
 	else
 #endif
-		set_pte(ptep, __pte(0));
+		set_pte_at(mm, addr, ptep, __pte(0));
 }
 #endif
 
diff -Nru a/include/asm-parisc/pgtable.h b/include/asm-parisc/pgtable.h
--- a/include/asm-parisc/pgtable.h	2005-03-05 23:06:10 -08:00
+++ b/include/asm-parisc/pgtable.h	2005-03-05 23:06:10 -08:00
@@ -39,6 +39,7 @@
         do{                                                     \
                 *(pteptr) = (pteval);                           \
         } while(0)
+#define set_pte_at(mm,addr,ptep,pteval) set_pte(ptep,pteval)
 
 #endif /* !__ASSEMBLY__ */
 
@@ -263,7 +264,7 @@
 
 #define pte_none(x)     ((pte_val(x) == 0) || (pte_val(x) & _PAGE_FLUSH))
 #define pte_present(x)	(pte_val(x) & _PAGE_PRESENT)
-#define pte_clear(xp)	do { pte_val(*(xp)) = 0; } while (0)
+#define pte_clear(mm,addr,xp)	do { pte_val(*(xp)) = 0; } while (0)
 
 #define pmd_flag(x)	(pmd_val(x) & PxD_FLAG_MASK)
 #define pmd_address(x)	((unsigned long)(pmd_val(x) &~ PxD_FLAG_MASK) << PxD_VALUE_SHIFT)
@@ -431,7 +432,7 @@
 #define __pte_to_swp_entry(pte)		((swp_entry_t) { pte_val(pte) })
 #define __swp_entry_to_pte(x)		((pte_t) { (x).val })
 
-static inline int ptep_test_and_clear_young(pte_t *ptep)
+static inline int ptep_test_and_clear_young(struct vm_area_struct *vma, unsigned long addr, pte_t *ptep)
 {
 #ifdef CONFIG_SMP
 	if (!pte_young(*ptep))
@@ -441,12 +442,12 @@
 	pte_t pte = *ptep;
 	if (!pte_young(pte))
 		return 0;
-	set_pte(ptep, pte_mkold(pte));
+	set_pte_at(vma->vm_mm, addr, ptep, pte_mkold(pte));
 	return 1;
 #endif
 }
 
-static inline int ptep_test_and_clear_dirty(pte_t *ptep)
+static inline int ptep_test_and_clear_dirty(struct vm_area_struct *vma, unsigned long addr, pte_t *ptep)
 {
 #ifdef CONFIG_SMP
 	if (!pte_dirty(*ptep))
@@ -456,14 +457,14 @@
 	pte_t pte = *ptep;
 	if (!pte_dirty(pte))
 		return 0;
-	set_pte(ptep, pte_mkclean(pte));
+	set_pte_at(vma->vm_mm, addr, ptep, pte_mkclean(pte));
 	return 1;
 #endif
 }
 
 extern spinlock_t pa_dbit_lock;
 
-static inline pte_t ptep_get_and_clear(pte_t *ptep)
+static inline pte_t ptep_get_and_clear(struct mm_struct *mm, unsigned long addr, pte_t *ptep)
 {
 	pte_t old_pte;
 	pte_t pte;
@@ -472,13 +473,13 @@
 	pte = old_pte = *ptep;
 	pte_val(pte) &= ~_PAGE_PRESENT;
 	pte_val(pte) |= _PAGE_FLUSH;
-	set_pte(ptep,pte);
+	set_pte_at(mm,addr,ptep,pte);
 	spin_unlock(&pa_dbit_lock);
 
 	return old_pte;
 }
 
-static inline void ptep_set_wrprotect(pte_t *ptep)
+static inline void ptep_set_wrprotect(struct mm_struct *mm, unsigned long addr, pte_t *ptep)
 {
 #ifdef CONFIG_SMP
 	unsigned long new, old;
@@ -489,17 +490,7 @@
 	} while (cmpxchg((unsigned long *) ptep, old, new) != old);
 #else
 	pte_t old_pte = *ptep;
-	set_pte(ptep, pte_wrprotect(old_pte));
-#endif
-}
-
-static inline void ptep_mkdirty(pte_t *ptep)
-{
-#ifdef CONFIG_SMP
-	set_bit(xlate_pabit(_PAGE_DIRTY_BIT), &pte_val(*ptep));
-#else
-	pte_t old_pte = *ptep;
-	set_pte(ptep, pte_mkdirty(old_pte));
+	set_pte_at(mm, addr, ptep, pte_wrprotect(old_pte));
 #endif
 }
 
@@ -518,7 +509,6 @@
 #define __HAVE_ARCH_PTEP_TEST_AND_CLEAR_DIRTY
 #define __HAVE_ARCH_PTEP_GET_AND_CLEAR
 #define __HAVE_ARCH_PTEP_SET_WRPROTECT
-#define __HAVE_ARCH_PTEP_MKDIRTY
 #define __HAVE_ARCH_PTE_SAME
 #include <asm-generic/pgtable.h>
 
diff -Nru a/include/asm-ppc/highmem.h b/include/asm-ppc/highmem.h
--- a/include/asm-ppc/highmem.h	2005-03-05 23:06:10 -08:00
+++ b/include/asm-ppc/highmem.h	2005-03-05 23:06:10 -08:00
@@ -90,7 +90,7 @@
 #ifdef HIGHMEM_DEBUG
 	BUG_ON(!pte_none(*(kmap_pte+idx)));
 #endif
-	set_pte(kmap_pte+idx, mk_pte(page, kmap_prot));
+	set_pte_at(&init_mm, vaddr, kmap_pte+idx, mk_pte(page, kmap_prot));
 	flush_tlb_page(NULL, vaddr);
 
 	return (void*) vaddr;
@@ -114,7 +114,7 @@
 	 * force other mappings to Oops if they'll try to access
 	 * this pte without first remap it
 	 */
-	pte_clear(kmap_pte+idx);
+	pte_clear(&init_mm, vaddr, kmap_pte+idx);
 	flush_tlb_page(NULL, vaddr);
 #endif
 	dec_preempt_count();
diff -Nru a/include/asm-ppc/pgtable.h b/include/asm-ppc/pgtable.h
--- a/include/asm-ppc/pgtable.h	2005-03-05 23:06:10 -08:00
+++ b/include/asm-ppc/pgtable.h	2005-03-05 23:06:10 -08:00
@@ -448,7 +448,7 @@
 
 #define pte_none(pte)		((pte_val(pte) & ~_PTE_NONE_MASK) == 0)
 #define pte_present(pte)	(pte_val(pte) & _PAGE_PRESENT)
-#define pte_clear(ptep)		do { set_pte((ptep), __pte(0)); } while (0)
+#define pte_clear(mm,addr,ptep)	do { set_pte_at((mm), (addr), (ptep), __pte(0)); } while (0)
 
 #define pmd_none(pmd)		(!pmd_val(pmd))
 #define	pmd_bad(pmd)		(pmd_val(pmd) & _PMD_BAD)
@@ -512,6 +512,17 @@
 }
 
 /*
+ * When flushing the tlb entry for a page, we also need to flush the hash
+ * table entry.  flush_hash_pages is assembler (for speed) in hashtable.S.
+ */
+extern int flush_hash_pages(unsigned context, unsigned long va,
+			    unsigned long pmdval, int count);
+
+/* Add an HPTE to the hash table */
+extern void add_hash_page(unsigned context, unsigned long va,
+			  unsigned long pmdval);
+
+/*
  * Atomic PTE updates.
  *
  * pte_update clears and sets bit atomically, and returns
@@ -542,7 +553,8 @@
  * On machines which use an MMU hash table we avoid changing the
  * _PAGE_HASHPTE bit.
  */
-static inline void set_pte(pte_t *ptep, pte_t pte)
+static inline void set_pte_at(struct mm_struct *mm, unsigned long addr,
+			      pte_t *ptep, pte_t pte)
 {
 #if _PAGE_HASHPTE != 0
 	pte_update(ptep, ~_PAGE_HASHPTE, pte_val(pte) & ~_PAGE_HASHPTE);
@@ -551,43 +563,47 @@
 #endif
 }
 
-extern void flush_hash_one_pte(pte_t *ptep);
-
 /*
  * 2.6 calles this without flushing the TLB entry, this is wrong
  * for our hash-based implementation, we fix that up here
  */
-static inline int ptep_test_and_clear_young(pte_t *ptep)
+#define __HAVE_ARCH_PTEP_TEST_AND_CLEAR_YOUNG
+static inline int __ptep_test_and_clear_young(unsigned int context, unsigned long addr, pte_t *ptep)
 {
 	unsigned long old;
 	old = pte_update(ptep, _PAGE_ACCESSED, 0);
 #if _PAGE_HASHPTE != 0
-	if (old & _PAGE_HASHPTE)
-		flush_hash_one_pte(ptep);
+	if (old & _PAGE_HASHPTE) {
+		unsigned long ptephys = __pa(ptep) & PAGE_MASK;
+		flush_hash_pages(context, addr, ptephys, 1);
+	}
 #endif
 	return (old & _PAGE_ACCESSED) != 0;
 }
+#define ptep_test_and_clear_young(__vma, __addr, __ptep) \
+	__ptep_test_and_clear_young((__vma)->vm_mm->context, __addr, __ptep)
 
-static inline int ptep_test_and_clear_dirty(pte_t *ptep)
+#define __HAVE_ARCH_PTEP_TEST_AND_CLEAR_DIRTY
+static inline int ptep_test_and_clear_dirty(struct vm_area_struct *vma,
+					    unsigned long addr, pte_t *ptep)
 {
 	return (pte_update(ptep, (_PAGE_DIRTY | _PAGE_HWWRITE), 0) & _PAGE_DIRTY) != 0;
 }
 
-static inline pte_t ptep_get_and_clear(pte_t *ptep)
+#define __HAVE_ARCH_PTEP_GET_AND_CLEAR
+static inline pte_t ptep_get_and_clear(struct mm_struct *mm, unsigned long addr,
+				       pte_t *ptep)
 {
 	return __pte(pte_update(ptep, ~_PAGE_HASHPTE, 0));
 }
 
-static inline void ptep_set_wrprotect(pte_t *ptep)
+#define __HAVE_ARCH_PTEP_SET_WRPROTECT
+static inline void ptep_set_wrprotect(struct mm_struct *mm, unsigned long addr,
+				      pte_t *ptep)
 {
 	pte_update(ptep, (_PAGE_RW | _PAGE_HWWRITE), 0);
 }
 
-static inline void ptep_mkdirty(pte_t *ptep)
-{
-	pte_update(ptep, 0, _PAGE_DIRTY);
-}
-
 #define __HAVE_ARCH_PTEP_SET_ACCESS_FLAGS
 static inline void __ptep_set_access_flags(pte_t *ptep, pte_t entry, int dirty)
 {
@@ -607,6 +623,7 @@
  */
 #define pgprot_noncached(prot)	(__pgprot(pgprot_val(prot) | _PAGE_NO_CACHE | _PAGE_GUARDED))
 
+#define __HAVE_ARCH_PTE_SAME
 #define pte_same(A,B)	(((pte_val(A) ^ pte_val(B)) & ~_PAGE_HASHPTE) == 0)
 
 /*
@@ -659,17 +676,6 @@
 extern void paging_init(void);
 
 /*
- * When flushing the tlb entry for a page, we also need to flush the hash
- * table entry.  flush_hash_pages is assembler (for speed) in hashtable.S.
- */
-extern int flush_hash_pages(unsigned context, unsigned long va,
-			    unsigned long pmdval, int count);
-
-/* Add an HPTE to the hash table */
-extern void add_hash_page(unsigned context, unsigned long va,
-			  unsigned long pmdval);
-
-/*
  * Encode and decode a swap entry.
  * Note that the bits we use in a PTE for representing a swap entry
  * must not include the _PAGE_PRESENT bit, the _PAGE_FILE bit, or the
@@ -741,15 +747,9 @@
 
 extern int get_pteptr(struct mm_struct *mm, unsigned long addr, pte_t **ptep);
 
-#endif /* !__ASSEMBLY__ */
-
-#define __HAVE_ARCH_PTEP_TEST_AND_CLEAR_YOUNG
-#define __HAVE_ARCH_PTEP_TEST_AND_CLEAR_DIRTY
-#define __HAVE_ARCH_PTEP_GET_AND_CLEAR
-#define __HAVE_ARCH_PTEP_SET_WRPROTECT
-#define __HAVE_ARCH_PTEP_MKDIRTY
-#define __HAVE_ARCH_PTE_SAME
 #include <asm-generic/pgtable.h>
+
+#endif /* !__ASSEMBLY__ */
 
 #endif /* _PPC_PGTABLE_H */
 #endif /* __KERNEL__ */
diff -Nru a/include/asm-ppc64/pgalloc.h b/include/asm-ppc64/pgalloc.h
--- a/include/asm-ppc64/pgalloc.h	2005-03-05 23:06:10 -08:00
+++ b/include/asm-ppc64/pgalloc.h	2005-03-05 23:06:10 -08:00
@@ -48,42 +48,26 @@
 #define pmd_populate(mm, pmd, pte_page) \
 	pmd_populate_kernel(mm, pmd, page_address(pte_page))
 
-static inline pte_t *
-pte_alloc_one_kernel(struct mm_struct *mm, unsigned long address)
+static inline pte_t *pte_alloc_one_kernel(struct mm_struct *mm, unsigned long address)
 {
-	pte_t *pte;
-	pte = kmem_cache_alloc(zero_cache, GFP_KERNEL|__GFP_REPEAT);
-	if (pte) {
-		struct page *ptepage = virt_to_page(pte);
-		ptepage->mapping = (void *) mm;
-		ptepage->index = address & PMD_MASK;
-	}
-	return pte;
+	return kmem_cache_alloc(zero_cache, GFP_KERNEL|__GFP_REPEAT);
 }
 
-static inline struct page *
-pte_alloc_one(struct mm_struct *mm, unsigned long address)
+static inline struct page *pte_alloc_one(struct mm_struct *mm, unsigned long address)
 {
-	pte_t *pte;
-	pte = kmem_cache_alloc(zero_cache, GFP_KERNEL|__GFP_REPEAT);
-	if (pte) {
-		struct page *ptepage = virt_to_page(pte);
-		ptepage->mapping = (void *) mm;
-		ptepage->index = address & PMD_MASK;
-		return ptepage;
-	}
+	pte_t *pte = kmem_cache_alloc(zero_cache, GFP_KERNEL|__GFP_REPEAT);
+	if (pte)
+		return virt_to_page(pte);
 	return NULL;
 }
 		
 static inline void pte_free_kernel(pte_t *pte)
 {
-	virt_to_page(pte)->mapping = NULL;
 	kmem_cache_free(zero_cache, pte);
 }
 
 static inline void pte_free(struct page *ptepage)
 {
-	ptepage->mapping = NULL;
 	kmem_cache_free(zero_cache, page_address(ptepage));
 }
 
diff -Nru a/include/asm-ppc64/pgtable.h b/include/asm-ppc64/pgtable.h
--- a/include/asm-ppc64/pgtable.h	2005-03-05 23:06:10 -08:00
+++ b/include/asm-ppc64/pgtable.h	2005-03-05 23:06:10 -08:00
@@ -315,9 +315,10 @@
  * batch, doesn't actually triggers the hash flush immediately,
  * you need to call flush_tlb_pending() to do that.
  */
-extern void hpte_update(pte_t *ptep, unsigned long pte, int wrprot);
+extern void hpte_update(struct mm_struct *mm, unsigned long addr, unsigned long pte,
+			int wrprot);
 
-static inline int ptep_test_and_clear_young(pte_t *ptep)
+static inline int __ptep_test_and_clear_young(struct mm_struct *mm, unsigned long addr, pte_t *ptep)
 {
 	unsigned long old;
 
@@ -325,18 +326,25 @@
 		return 0;
 	old = pte_update(ptep, _PAGE_ACCESSED);
 	if (old & _PAGE_HASHPTE) {
-		hpte_update(ptep, old, 0);
+		hpte_update(mm, addr, old, 0);
 		flush_tlb_pending();
 	}
 	return (old & _PAGE_ACCESSED) != 0;
 }
+#define __HAVE_ARCH_PTEP_TEST_AND_CLEAR_YOUNG
+#define ptep_test_and_clear_young(__vma, __addr, __ptep)		   \
+({									   \
+	int __r;							   \
+	__r = __ptep_test_and_clear_young((__vma)->vm_mm, __addr, __ptep); \
+	__r;								   \
+})
 
 /*
  * On RW/DIRTY bit transitions we can avoid flushing the hpte. For the
  * moment we always flush but we need to fix hpte_update and test if the
  * optimisation is worth it.
  */
-static inline int ptep_test_and_clear_dirty(pte_t *ptep)
+static inline int __ptep_test_and_clear_dirty(struct mm_struct *mm, unsigned long addr, pte_t *ptep)
 {
 	unsigned long old;
 
@@ -344,11 +352,19 @@
 		return 0;
 	old = pte_update(ptep, _PAGE_DIRTY);
 	if (old & _PAGE_HASHPTE)
-		hpte_update(ptep, old, 0);
+		hpte_update(mm, addr, old, 0);
 	return (old & _PAGE_DIRTY) != 0;
 }
+#define __HAVE_ARCH_PTEP_TEST_AND_CLEAR_DIRTY
+#define ptep_test_and_clear_dirty(__vma, __addr, __ptep)		   \
+({									   \
+	int __r;							   \
+	__r = __ptep_test_and_clear_dirty((__vma)->vm_mm, __addr, __ptep); \
+	__r;								   \
+})
 
-static inline void ptep_set_wrprotect(pte_t *ptep)
+#define __HAVE_ARCH_PTEP_SET_WRPROTECT
+static inline void ptep_set_wrprotect(struct mm_struct *mm, unsigned long addr, pte_t *ptep)
 {
 	unsigned long old;
 
@@ -356,7 +372,7 @@
        		return;
 	old = pte_update(ptep, _PAGE_RW);
 	if (old & _PAGE_HASHPTE)
-		hpte_update(ptep, old, 0);
+		hpte_update(mm, addr, old, 0);
 }
 
 /*
@@ -370,42 +386,46 @@
 #define __HAVE_ARCH_PTEP_CLEAR_YOUNG_FLUSH
 #define ptep_clear_flush_young(__vma, __address, __ptep)		\
 ({									\
-	int __young = ptep_test_and_clear_young(__ptep);		\
+	int __young = __ptep_test_and_clear_young((__vma)->vm_mm, __address, \
+						  __ptep);		\
 	__young;							\
 })
 
 #define __HAVE_ARCH_PTEP_CLEAR_DIRTY_FLUSH
 #define ptep_clear_flush_dirty(__vma, __address, __ptep)		\
 ({									\
-	int __dirty = ptep_test_and_clear_dirty(__ptep);		\
+	int __dirty = __ptep_test_and_clear_dirty((__vma)->vm_mm, __address, \
+						  __ptep); 		\
 	flush_tlb_page(__vma, __address);				\
 	__dirty;							\
 })
 
-static inline pte_t ptep_get_and_clear(pte_t *ptep)
+#define __HAVE_ARCH_PTEP_GET_AND_CLEAR
+static inline pte_t ptep_get_and_clear(struct mm_struct *mm, unsigned long addr, pte_t *ptep)
 {
 	unsigned long old = pte_update(ptep, ~0UL);
 
 	if (old & _PAGE_HASHPTE)
-		hpte_update(ptep, old, 0);
+		hpte_update(mm, addr, old, 0);
 	return __pte(old);
 }
 
-static inline void pte_clear(pte_t * ptep)
+static inline void pte_clear(struct mm_struct *mm, unsigned long addr, pte_t * ptep)
 {
 	unsigned long old = pte_update(ptep, ~0UL);
 
 	if (old & _PAGE_HASHPTE)
-		hpte_update(ptep, old, 0);
+		hpte_update(mm, addr, old, 0);
 }
 
 /*
  * set_pte stores a linux PTE into the linux page table.
  */
-static inline void set_pte(pte_t *ptep, pte_t pte)
+static inline void set_pte_at(struct mm_struct *mm, unsigned long addr,
+			      pte_t *ptep, pte_t pte)
 {
 	if (pte_present(*ptep)) {
-		pte_clear(ptep);
+		pte_clear(mm, addr, ptep);
 		flush_tlb_pending();
 	}
 	*ptep = __pte(pte_val(pte)) & ~_PAGE_HPTEFLAGS;
@@ -443,6 +463,7 @@
  */
 #define pgprot_noncached(prot)	(__pgprot(pgprot_val(prot) | _PAGE_NO_CACHE | _PAGE_GUARDED))
 
+#define __HAVE_ARCH_PTE_SAME
 #define pte_same(A,B)	(((pte_val(A) ^ pte_val(B)) & ~_PAGE_HPTEFLAGS) == 0)
 
 extern unsigned long ioremap_bot, ioremap_base;
@@ -550,14 +571,8 @@
 	return pt;
 }
 
-#endif /* __ASSEMBLY__ */
-
-#define __HAVE_ARCH_PTEP_TEST_AND_CLEAR_YOUNG
-#define __HAVE_ARCH_PTEP_TEST_AND_CLEAR_DIRTY
-#define __HAVE_ARCH_PTEP_GET_AND_CLEAR
-#define __HAVE_ARCH_PTEP_SET_WRPROTECT
-#define __HAVE_ARCH_PTEP_MKDIRTY
-#define __HAVE_ARCH_PTE_SAME
 #include <asm-generic/pgtable.h>
+
+#endif /* __ASSEMBLY__ */
 
 #endif /* _PPC64_PGTABLE_H */
diff -Nru a/include/asm-s390/pgalloc.h b/include/asm-s390/pgalloc.h
--- a/include/asm-s390/pgalloc.h	2005-03-05 23:06:10 -08:00
+++ b/include/asm-s390/pgalloc.h	2005-03-05 23:06:10 -08:00
@@ -130,8 +130,10 @@
 
 	pte = (pte_t *)__get_free_page(GFP_KERNEL|__GFP_REPEAT);
 	if (pte != NULL) {
-		for (i=0; i < PTRS_PER_PTE; i++)
-			pte_clear(pte+i);
+		for (i=0; i < PTRS_PER_PTE; i++) {
+			pte_clear(mm, vmaddr, pte+i);
+			vmaddr += PAGE_SIZE;
+		}
 	}
 	return pte;
 }
diff -Nru a/include/asm-s390/pgtable.h b/include/asm-s390/pgtable.h
--- a/include/asm-s390/pgtable.h	2005-03-05 23:06:10 -08:00
+++ b/include/asm-s390/pgtable.h	2005-03-05 23:06:10 -08:00
@@ -322,6 +322,7 @@
 {
 	*pteptr = pteval;
 }
+#define set_pte_at(mm,addr,ptep,pteval) set_pte(ptep,pteval)
 
 /*
  * pgd/pmd/pte query functions
@@ -457,7 +458,7 @@
 
 #endif /* __s390x__ */
 
-extern inline void pte_clear(pte_t *ptep)
+extern inline void pte_clear(struct mm_struct *mm, unsigned long addr, pte_t *ptep)
 {
 	pte_val(*ptep) = _PAGE_INVALID_EMPTY;
 }
@@ -521,7 +522,7 @@
 	return pte;
 }
 
-static inline int ptep_test_and_clear_young(pte_t *ptep)
+static inline int ptep_test_and_clear_young(struct vm_area_struct *vma, unsigned long addr, pte_t *ptep)
 {
 	return 0;
 }
@@ -531,10 +532,10 @@
 			unsigned long address, pte_t *ptep)
 {
 	/* No need to flush TLB; bits are in storage key */
-	return ptep_test_and_clear_young(ptep);
+	return ptep_test_and_clear_young(vma, address, ptep);
 }
 
-static inline int ptep_test_and_clear_dirty(pte_t *ptep)
+static inline int ptep_test_and_clear_dirty(struct vm_area_struct *vma, unsigned long addr, pte_t *ptep)
 {
 	return 0;
 }
@@ -544,13 +545,13 @@
 			unsigned long address, pte_t *ptep)
 {
 	/* No need to flush TLB; bits are in storage key */
-	return ptep_test_and_clear_dirty(ptep);
+	return ptep_test_and_clear_dirty(vma, address, ptep);
 }
 
-static inline pte_t ptep_get_and_clear(pte_t *ptep)
+static inline pte_t ptep_get_and_clear(struct mm_struct *mm, unsigned long addr, pte_t *ptep)
 {
 	pte_t pte = *ptep;
-	pte_clear(ptep);
+	pte_clear(mm, addr, ptep);
 	return pte;
 }
 
@@ -573,19 +574,14 @@
 				      : "=m" (*ptep) : "m" (*ptep),
 				        "a" (ptep), "a" (address) );
 #endif /* __s390x__ */
-	pte_clear(ptep);
+	pte_val(*ptep) = _PAGE_INVALID_EMPTY;
 	return pte;
 }
 
-static inline void ptep_set_wrprotect(pte_t *ptep)
+static inline void ptep_set_wrprotect(struct mm_struct *mm, unsigned long addr, pte_t *ptep)
 {
 	pte_t old_pte = *ptep;
-	set_pte(ptep, pte_wrprotect(old_pte));
-}
-
-static inline void ptep_mkdirty(pte_t *ptep)
-{
-	pte_mkdirty(*ptep);
+	set_pte_at(mm, addr, ptep, pte_wrprotect(old_pte));
 }
 
 static inline void
@@ -802,7 +798,6 @@
 #define __HAVE_ARCH_PTEP_GET_AND_CLEAR
 #define __HAVE_ARCH_PTEP_CLEAR_FLUSH
 #define __HAVE_ARCH_PTEP_SET_WRPROTECT
-#define __HAVE_ARCH_PTEP_MKDIRTY
 #define __HAVE_ARCH_PTE_SAME
 #define __HAVE_ARCH_PAGE_TEST_AND_CLEAR_DIRTY
 #define __HAVE_ARCH_PAGE_TEST_AND_CLEAR_YOUNG
diff -Nru a/include/asm-sh/pgtable-2level.h b/include/asm-sh/pgtable-2level.h
--- a/include/asm-sh/pgtable-2level.h	2005-03-05 23:06:10 -08:00
+++ b/include/asm-sh/pgtable-2level.h	2005-03-05 23:06:10 -08:00
@@ -41,6 +41,8 @@
  * hook is made available.
  */
 #define set_pte(pteptr, pteval) (*(pteptr) = pteval)
+#define set_pte_at(mm,addr,ptep,pteval) set_pte(ptep,pteval)
+
 /*
  * (pmds are folded into pgds so this doesn't get actually called,
  * but the define is needed for a generic inline function.)
diff -Nru a/include/asm-sh/pgtable.h b/include/asm-sh/pgtable.h
--- a/include/asm-sh/pgtable.h	2005-03-05 23:06:10 -08:00
+++ b/include/asm-sh/pgtable.h	2005-03-05 23:06:10 -08:00
@@ -164,7 +164,7 @@
 
 #define pte_none(x)	(!pte_val(x))
 #define pte_present(x)	(pte_val(x) & (_PAGE_PRESENT | _PAGE_PROTNONE))
-#define pte_clear(xp)	do { set_pte(xp, __pte(0)); } while (0)
+#define pte_clear(mm,addr,xp)	do { set_pte_at(mm, addr, xp, __pte(0)); } while (0)
 
 #define pmd_none(x)	(!pmd_val(x))
 #define pmd_present(x)	(pmd_val(x) & _PAGE_PRESENT)
@@ -290,7 +290,7 @@
 
 #if defined(CONFIG_CPU_SH4) || defined(CONFIG_SH7705_CACHE_32KB)
 #define __HAVE_ARCH_PTEP_GET_AND_CLEAR
-extern pte_t ptep_get_and_clear(pte_t *ptep);
+extern pte_t ptep_get_and_clear(struct mm_struct *mm, unsigned long addr, pte_t *ptep);
 #endif
 
 #include <asm-generic/pgtable.h>
diff -Nru a/include/asm-sh64/pgtable.h b/include/asm-sh64/pgtable.h
--- a/include/asm-sh64/pgtable.h	2005-03-05 23:06:10 -08:00
+++ b/include/asm-sh64/pgtable.h	2005-03-05 23:06:10 -08:00
@@ -136,6 +136,7 @@
 	 */
 	*(xp) = (x & NPHYS_SIGN) ? (x | NPHYS_MASK) : x;
 }
+#define set_pte_at(mm,addr,ptep,pteval) set_pte(ptep,pteval)
 
 static __inline__ void pmd_set(pmd_t *pmdp,pte_t *ptep)
 {
@@ -383,7 +384,7 @@
  */
 #define _PTE_EMPTY	0x0
 #define pte_present(x)	(pte_val(x) & _PAGE_PRESENT)
-#define pte_clear(xp)	(set_pte(xp, __pte(_PTE_EMPTY)))
+#define pte_clear(mm,addr,xp)	(set_pte_at(mm, addr, xp, __pte(_PTE_EMPTY)))
 #define pte_none(x)	(pte_val(x) == _PTE_EMPTY)
 
 /*
diff -Nru a/include/asm-sparc/pgtable.h b/include/asm-sparc/pgtable.h
--- a/include/asm-sparc/pgtable.h	2005-03-05 23:06:10 -08:00
+++ b/include/asm-sparc/pgtable.h	2005-03-05 23:06:10 -08:00
@@ -157,7 +157,7 @@
 }
 
 #define pte_present(pte) BTFIXUP_CALL(pte_present)(pte)
-#define pte_clear(pte) BTFIXUP_CALL(pte_clear)(pte)
+#define pte_clear(mm,addr,pte) BTFIXUP_CALL(pte_clear)(pte)
 
 BTFIXUPDEF_CALL_CONST(int, pmd_bad, pmd_t)
 BTFIXUPDEF_CALL_CONST(int, pmd_present, pmd_t)
@@ -339,6 +339,7 @@
 BTFIXUPDEF_CALL(void, set_pte, pte_t *, pte_t)
 
 #define set_pte(ptep,pteval) BTFIXUP_CALL(set_pte)(ptep,pteval)
+#define set_pte_at(mm,addr,ptep,pteval) set_pte(ptep,pteval)
 
 struct seq_file;
 BTFIXUPDEF_CALL(void, mmu_info, struct seq_file *)
diff -Nru a/include/asm-sparc64/pgalloc.h b/include/asm-sparc64/pgalloc.h
--- a/include/asm-sparc64/pgalloc.h	2005-03-05 23:06:10 -08:00
+++ b/include/asm-sparc64/pgalloc.h	2005-03-05 23:06:10 -08:00
@@ -191,25 +191,17 @@
 
 static inline pte_t *pte_alloc_one_kernel(struct mm_struct *mm, unsigned long address)
 {
-	pte_t *pte = __pte_alloc_one_kernel(mm, address);
-	if (pte) {
-		struct page *page = virt_to_page(pte);
-		page->mapping = (void *) mm;
-		page->index = address & PMD_MASK;
-	}
-	return pte;
+	return __pte_alloc_one_kernel(mm, address);
 }
 
 static inline struct page *
 pte_alloc_one(struct mm_struct *mm, unsigned long addr)
 {
 	pte_t *pte = __pte_alloc_one_kernel(mm, addr);
-	if (pte) {
-		struct page *page = virt_to_page(pte);
-		page->mapping = (void *) mm;
-		page->index = addr & PMD_MASK;
-		return page;
-	}
+
+	if (pte)
+		return virt_to_page(pte);
+
 	return NULL;
 }
 
@@ -246,13 +238,11 @@
 
 static inline void pte_free_kernel(pte_t *pte)
 {
-	virt_to_page(pte)->mapping = NULL;
 	free_pte_fast(pte);
 }
 
 static inline void pte_free(struct page *ptepage)
 {
-	ptepage->mapping = NULL;
 	free_pte_fast(page_address(ptepage));
 }
 
diff -Nru a/include/asm-sparc64/pgtable.h b/include/asm-sparc64/pgtable.h
--- a/include/asm-sparc64/pgtable.h	2005-03-05 23:06:10 -08:00
+++ b/include/asm-sparc64/pgtable.h	2005-03-05 23:06:10 -08:00
@@ -15,6 +15,7 @@
 #include <asm-generic/pgtable-nopud.h>
 
 #include <linux/config.h>
+#include <linux/compiler.h>
 #include <asm/spitfire.h>
 #include <asm/asi.h>
 #include <asm/system.h>
@@ -333,18 +334,23 @@
 #define pte_unmap_nested(pte)		do { } while (0)
 
 /* Actual page table PTE updates.  */
-extern void tlb_batch_add(pte_t *ptep, pte_t orig);
+extern void tlb_batch_add(struct mm_struct *mm, unsigned long vaddr, pte_t *ptep, pte_t orig);
 
-static inline void set_pte(pte_t *ptep, pte_t pte)
+static inline void set_pte_at(struct mm_struct *mm, unsigned long addr, pte_t *ptep, pte_t pte)
 {
 	pte_t orig = *ptep;
 
 	*ptep = pte;
-	if (pte_present(orig))
-		tlb_batch_add(ptep, orig);
+
+	/* It is more efficient to let flush_tlb_kernel_range()
+	 * handle init_mm tlb flushes.
+	 */
+	if (likely(mm != &init_mm) && (pte_val(orig) & _PAGE_VALID))
+		tlb_batch_add(mm, addr, ptep, orig);
 }
 
-#define pte_clear(ptep)		set_pte((ptep), __pte(0UL))
+#define pte_clear(mm,addr,ptep)		\
+	set_pte_at((mm), (addr), (ptep), __pte(0UL))
 
 extern pgd_t swapper_pg_dir[1];
 
diff -Nru a/include/asm-um/pgtable-2level.h b/include/asm-um/pgtable-2level.h
--- a/include/asm-um/pgtable-2level.h	2005-03-05 23:06:10 -08:00
+++ b/include/asm-um/pgtable-2level.h	2005-03-05 23:06:10 -08:00
@@ -59,6 +59,7 @@
 	*pteptr = pte_mknewpage(pteval);
 	if(pte_present(*pteptr)) *pteptr = pte_mknewprot(*pteptr);
 }
+#define set_pte_at(mm,addr,ptep,pteval) set_pte(ptep,pteval)
 
 #define set_pmd(pmdptr, pmdval) (*(pmdptr) = (pmdval))
 
diff -Nru a/include/asm-um/pgtable-3level.h b/include/asm-um/pgtable-3level.h
--- a/include/asm-um/pgtable-3level.h	2005-03-05 23:06:10 -08:00
+++ b/include/asm-um/pgtable-3level.h	2005-03-05 23:06:10 -08:00
@@ -84,6 +84,7 @@
 	*pteptr = pte_mknewpage(*pteptr);
 	if(pte_present(*pteptr)) *pteptr = pte_mknewprot(*pteptr);
 }
+#define set_pte_at(mm,addr,ptep,pteval) set_pte(ptep,pteval)
 
 #define set_pmd(pmdptr, pmdval) set_64bit((phys_t *) (pmdptr), pmd_val(pmdval))
 
diff -Nru a/include/asm-um/pgtable.h b/include/asm-um/pgtable.h
--- a/include/asm-um/pgtable.h	2005-03-05 23:06:10 -08:00
+++ b/include/asm-um/pgtable.h	2005-03-05 23:06:10 -08:00
@@ -142,7 +142,7 @@
 #define PAGE_PTR(address) \
 ((unsigned long)(address)>>(PAGE_SHIFT-SIZEOF_PTR_LOG2)&PTR_MASK&~PAGE_MASK)
 
-#define pte_clear(xp) pte_set_val(*(xp), (phys_t) 0, __pgprot(_PAGE_NEWPAGE))
+#define pte_clear(mm,addr,xp) pte_set_val(*(xp), (phys_t) 0, __pgprot(_PAGE_NEWPAGE))
 
 #define pmd_none(x)	(!(pmd_val(x) & ~_PAGE_NEWPAGE))
 #define	pmd_bad(x)	((pmd_val(x) & (~PAGE_MASK & ~_PAGE_USER)) != _KERNPG_TABLE)
diff -Nru a/include/asm-x86_64/pgtable.h b/include/asm-x86_64/pgtable.h
--- a/include/asm-x86_64/pgtable.h	2005-03-05 23:06:10 -08:00
+++ b/include/asm-x86_64/pgtable.h	2005-03-05 23:06:10 -08:00
@@ -73,6 +73,7 @@
 {
 	pte_val(*dst) = pte_val(val);
 } 
+#define set_pte_at(mm,addr,ptep,pteval) set_pte(ptep,pteval)
 
 static inline void set_pmd(pmd_t *dst, pmd_t val)
 {
@@ -102,7 +103,7 @@
 #define pud_page(pud) \
 ((unsigned long) __va(pud_val(pud) & PHYSICAL_PAGE_MASK))
 
-#define ptep_get_and_clear(xp)	__pte(xchg(&(xp)->pte, 0))
+#define ptep_get_and_clear(mm,addr,xp)	__pte(xchg(&(xp)->pte, 0))
 #define pte_same(a, b)		((a).pte == (b).pte)
 
 #define PMD_SIZE	(1UL << PMD_SHIFT)
@@ -224,7 +225,7 @@
 
 #define pte_none(x)	(!pte_val(x))
 #define pte_present(x)	(pte_val(x) & (_PAGE_PRESENT | _PAGE_PROTNONE))
-#define pte_clear(xp)	do { set_pte(xp, __pte(0)); } while (0)
+#define pte_clear(mm,addr,xp)	do { set_pte_at(mm, addr, xp, __pte(0)); } while (0)
 
 #define pages_to_mb(x) ((x) >> (20-PAGE_SHIFT))	/* FIXME: is this
 						   right? */
@@ -263,22 +264,24 @@
 extern inline pte_t pte_mkyoung(pte_t pte)	{ set_pte(&pte, __pte(pte_val(pte) | _PAGE_ACCESSED)); return pte; }
 extern inline pte_t pte_mkwrite(pte_t pte)	{ set_pte(&pte, __pte(pte_val(pte) | _PAGE_RW)); return pte; }
 
-static inline int ptep_test_and_clear_dirty(pte_t *ptep)
+static inline int ptep_test_and_clear_dirty(struct vm_area_struct *vma, unsigned long addr, pte_t *ptep)
 {
 	if (!pte_dirty(*ptep))
 		return 0;
 	return test_and_clear_bit(_PAGE_BIT_DIRTY, ptep);
 }
 
-static inline int ptep_test_and_clear_young(pte_t *ptep)
+static inline int ptep_test_and_clear_young(struct vm_area_struct *vma, unsigned long addr, pte_t *ptep)
 {
 	if (!pte_young(*ptep))
 		return 0;
 	return test_and_clear_bit(_PAGE_BIT_ACCESSED, ptep);
 }
 
-static inline void ptep_set_wrprotect(pte_t *ptep)		{ clear_bit(_PAGE_BIT_RW, ptep); }
-static inline void ptep_mkdirty(pte_t *ptep)			{ set_bit(_PAGE_BIT_DIRTY, ptep); }
+static inline void ptep_set_wrprotect(struct mm_struct *mm, unsigned long addr, pte_t *ptep)
+{
+	clear_bit(_PAGE_BIT_RW, ptep);
+}
 
 /*
  * Macro to mark a page protection value as "uncacheable".
@@ -419,7 +422,6 @@
 #define __HAVE_ARCH_PTEP_TEST_AND_CLEAR_DIRTY
 #define __HAVE_ARCH_PTEP_GET_AND_CLEAR
 #define __HAVE_ARCH_PTEP_SET_WRPROTECT
-#define __HAVE_ARCH_PTEP_MKDIRTY
 #define __HAVE_ARCH_PTE_SAME
 #include <asm-generic/pgtable.h>
 
diff -Nru a/mm/fremap.c b/mm/fremap.c
--- a/mm/fremap.c	2005-03-05 23:06:10 -08:00
+++ b/mm/fremap.c	2005-03-05 23:06:10 -08:00
@@ -45,7 +45,7 @@
 	} else {
 		if (!pte_file(pte))
 			free_swap_and_cache(pte_to_swp_entry(pte));
-		pte_clear(ptep);
+		pte_clear(mm, addr, ptep);
 	}
 }
 
@@ -94,7 +94,7 @@
 
 	mm->rss++;
 	flush_icache_page(vma, page);
-	set_pte(pte, mk_pte(page, prot));
+	set_pte_at(mm, addr, pte, mk_pte(page, prot));
 	page_add_file_rmap(page);
 	pte_val = *pte;
 	pte_unmap(pte);
@@ -139,7 +139,7 @@
 
 	zap_pte(mm, vma, addr, pte);
 
-	set_pte(pte, pgoff_to_pte(pgoff));
+	set_pte_at(mm, addr, pte, pgoff_to_pte(pgoff));
 	pte_val = *pte;
 	pte_unmap(pte);
 	update_mmu_cache(vma, addr, pte_val);
diff -Nru a/mm/highmem.c b/mm/highmem.c
--- a/mm/highmem.c	2005-03-05 23:06:10 -08:00
+++ b/mm/highmem.c	2005-03-05 23:06:10 -08:00
@@ -90,7 +90,8 @@
 		 * So no dangers, even with speculative execution.
 		 */
 		page = pte_page(pkmap_page_table[i]);
-		pte_clear(&pkmap_page_table[i]);
+		pte_clear(&init_mm, (unsigned long)page_address(page),
+			  &pkmap_page_table[i]);
 
 		set_page_address(page, NULL);
 	}
@@ -138,7 +139,8 @@
 		}
 	}
 	vaddr = PKMAP_ADDR(last_pkmap_nr);
-	set_pte(&(pkmap_page_table[last_pkmap_nr]), mk_pte(page, kmap_prot));
+	set_pte_at(&init_mm, vaddr,
+		   &(pkmap_page_table[last_pkmap_nr]), mk_pte(page, kmap_prot));
 
 	pkmap_count[last_pkmap_nr] = 1;
 	set_page_address(page, (void *)vaddr);
diff -Nru a/mm/memory.c b/mm/memory.c
--- a/mm/memory.c	2005-03-05 23:06:10 -08:00
+++ b/mm/memory.c	2005-03-05 23:06:10 -08:00
@@ -277,7 +277,7 @@
 	/* pte contains position in swap, so copy. */
 	if (!pte_present(pte)) {
 		copy_swap_pte(dst_mm, src_mm, pte);
-		set_pte(dst_pte, pte);
+		set_pte_at(dst_mm, addr, dst_pte, pte);
 		return;
 	}
 	pfn = pte_pfn(pte);
@@ -291,7 +291,7 @@
 		page = pfn_to_page(pfn);
 
 	if (!page || PageReserved(page)) {
-		set_pte(dst_pte, pte);
+		set_pte_at(dst_mm, addr, dst_pte, pte);
 		return;
 	}
 
@@ -300,7 +300,7 @@
 	 * in the parent and the child
 	 */
 	if ((vm_flags & (VM_SHARED | VM_MAYWRITE)) == VM_MAYWRITE) {
-		ptep_set_wrprotect(src_pte);
+		ptep_set_wrprotect(src_mm, addr, src_pte);
 		pte = *src_pte;
 	}
 
@@ -315,7 +315,7 @@
 	dst_mm->rss++;
 	if (PageAnon(page))
 		dst_mm->anon_rss++;
-	set_pte(dst_pte, pte);
+	set_pte_at(dst_mm, addr, dst_pte, pte);
 	page_dup_rmap(page);
 }
 
@@ -501,14 +501,15 @@
 				     page->index > details->last_index))
 					continue;
 			}
-			pte = ptep_get_and_clear(ptep);
+			pte = ptep_get_and_clear(tlb->mm, address+offset, ptep);
 			tlb_remove_tlb_entry(tlb, ptep, address+offset);
 			if (unlikely(!page))
 				continue;
 			if (unlikely(details) && details->nonlinear_vma
 			    && linear_page_index(details->nonlinear_vma,
 					address+offset) != page->index)
-				set_pte(ptep, pgoff_to_pte(page->index));
+				set_pte_at(tlb->mm, address+offset,
+					   ptep, pgoff_to_pte(page->index));
 			if (pte_dirty(pte))
 				set_page_dirty(page);
 			if (PageAnon(page))
@@ -528,7 +529,7 @@
 			continue;
 		if (!pte_file(pte))
 			free_swap_and_cache(pte_to_swp_entry(pte));
-		pte_clear(ptep);
+		pte_clear(tlb->mm, address+offset, ptep);
 	}
 	pte_unmap(ptep-1);
 }
@@ -985,19 +986,21 @@
 
 EXPORT_SYMBOL(get_user_pages);
 
-static void zeromap_pte_range(pte_t * pte, unsigned long address,
-                                     unsigned long size, pgprot_t prot)
+static void zeromap_pte_range(struct mm_struct *mm, pte_t * pte,
+			      unsigned long address,
+			      unsigned long size, pgprot_t prot)
 {
-	unsigned long end;
+	unsigned long base, end;
 
+	base = address & PMD_MASK;
 	address &= ~PMD_MASK;
 	end = address + size;
 	if (end > PMD_SIZE)
 		end = PMD_SIZE;
 	do {
-		pte_t zero_pte = pte_wrprotect(mk_pte(ZERO_PAGE(address), prot));
+		pte_t zero_pte = pte_wrprotect(mk_pte(ZERO_PAGE(base+address), prot));
 		BUG_ON(!pte_none(*pte));
-		set_pte(pte, zero_pte);
+		set_pte_at(mm, base+address, pte, zero_pte);
 		address += PAGE_SIZE;
 		pte++;
 	} while (address && (address < end));
@@ -1017,7 +1020,7 @@
 		pte_t * pte = pte_alloc_map(mm, pmd, base + address);
 		if (!pte)
 			return -ENOMEM;
-		zeromap_pte_range(pte, base + address, end - address, prot);
+		zeromap_pte_range(mm, pte, base + address, end - address, prot);
 		pte_unmap(pte);
 		address = (address + PMD_SIZE) & PMD_MASK;
 		pmd++;
@@ -1098,11 +1101,13 @@
  * in null mappings (currently treated as "copy-on-access")
  */
 static inline void
-remap_pte_range(pte_t * pte, unsigned long address, unsigned long size,
+remap_pte_range(struct mm_struct *mm, pte_t * pte,
+		unsigned long address, unsigned long size,
 		unsigned long pfn, pgprot_t prot)
 {
-	unsigned long end;
+	unsigned long base, end;
 
+	base = address & PMD_MASK;
 	address &= ~PMD_MASK;
 	end = address + size;
 	if (end > PMD_SIZE)
@@ -1110,7 +1115,7 @@
 	do {
 		BUG_ON(!pte_none(*pte));
 		if (!pfn_valid(pfn) || PageReserved(pfn_to_page(pfn)))
- 			set_pte(pte, pfn_pte(pfn, prot));
+			set_pte_at(mm, base+address, pte, pfn_pte(pfn, prot));
 		address += PAGE_SIZE;
 		pfn++;
 		pte++;
@@ -1133,7 +1138,7 @@
 		pte_t * pte = pte_alloc_map(mm, pmd, base + address);
 		if (!pte)
 			return -ENOMEM;
-		remap_pte_range(pte, base + address, end - address,
+		remap_pte_range(mm, pte, base + address, end - address,
 				(address >> PAGE_SHIFT) + pfn, prot);
 		pte_unmap(pte);
 		address = (address + PMD_SIZE) & PMD_MASK;
@@ -1751,7 +1756,7 @@
 	unlock_page(page);
 
 	flush_icache_page(vma, page);
-	set_pte(page_table, pte);
+	set_pte_at(mm, address, page_table, pte);
 	page_add_anon_rmap(page, vma, address);
 
 	if (write_access) {
@@ -1815,7 +1820,7 @@
 		page_add_anon_rmap(page, vma, addr);
 	}
 
-	set_pte(page_table, entry);
+	set_pte_at(mm, addr, page_table, entry);
 	pte_unmap(page_table);
 
 	/* No need to invalidate - it was non-present before */
@@ -1928,7 +1933,7 @@
 		entry = mk_pte(new_page, vma->vm_page_prot);
 		if (write_access)
 			entry = maybe_mkwrite(pte_mkdirty(entry), vma);
-		set_pte(page_table, entry);
+		set_pte_at(mm, address, page_table, entry);
 		if (anon) {
 			lru_cache_add_active(new_page);
 			page_add_anon_rmap(new_page, vma, address);
@@ -1972,7 +1977,7 @@
 	 */
 	if (!vma->vm_ops || !vma->vm_ops->populate || 
 			(write_access && !(vma->vm_flags & VM_SHARED))) {
-		pte_clear(pte);
+		pte_clear(mm, address, pte);
 		return do_no_page(mm, vma, address, write_access, pte, pmd);
 	}
 
diff -Nru a/mm/mprotect.c b/mm/mprotect.c
--- a/mm/mprotect.c	2005-03-05 23:06:10 -08:00
+++ b/mm/mprotect.c	2005-03-05 23:06:10 -08:00
@@ -26,11 +26,11 @@
 #include <asm/tlbflush.h>
 
 static inline void
-change_pte_range(pmd_t *pmd, unsigned long address,
+change_pte_range(struct mm_struct *mm, pmd_t *pmd, unsigned long address,
 		unsigned long size, pgprot_t newprot)
 {
 	pte_t * pte;
-	unsigned long end;
+	unsigned long base, end;
 
 	if (pmd_none(*pmd))
 		return;
@@ -40,6 +40,7 @@
 		return;
 	}
 	pte = pte_offset_map(pmd, address);
+	base = address & PMD_MASK;
 	address &= ~PMD_MASK;
 	end = address + size;
 	if (end > PMD_SIZE)
@@ -52,8 +53,8 @@
 			 * bits by wiping the pte and then setting the new pte
 			 * into place.
 			 */
-			entry = ptep_get_and_clear(pte);
-			set_pte(pte, pte_modify(entry, newprot));
+			entry = ptep_get_and_clear(mm, base + address, pte);
+			set_pte_at(mm, base + address, pte, pte_modify(entry, newprot));
 		}
 		address += PAGE_SIZE;
 		pte++;
@@ -62,11 +63,11 @@
 }
 
 static inline void
-change_pmd_range(pud_t *pud, unsigned long address,
-		unsigned long size, pgprot_t newprot)
+change_pmd_range(struct mm_struct *mm, pud_t *pud, unsigned long address,
+		 unsigned long size, pgprot_t newprot)
 {
 	pmd_t * pmd;
-	unsigned long end;
+	unsigned long base, end;
 
 	if (pud_none(*pud))
 		return;
@@ -76,23 +77,24 @@
 		return;
 	}
 	pmd = pmd_offset(pud, address);
+	base = address & PUD_MASK;
 	address &= ~PUD_MASK;
 	end = address + size;
 	if (end > PUD_SIZE)
 		end = PUD_SIZE;
 	do {
-		change_pte_range(pmd, address, end - address, newprot);
+		change_pte_range(mm, pmd, base + address, end - address, newprot);
 		address = (address + PMD_SIZE) & PMD_MASK;
 		pmd++;
 	} while (address && (address < end));
 }
 
 static inline void
-change_pud_range(pgd_t *pgd, unsigned long address,
-		unsigned long size, pgprot_t newprot)
+change_pud_range(struct mm_struct *mm, pgd_t *pgd, unsigned long address,
+		 unsigned long size, pgprot_t newprot)
 {
 	pud_t * pud;
-	unsigned long end;
+	unsigned long base, end;
 
 	if (pgd_none(*pgd))
 		return;
@@ -102,12 +104,13 @@
 		return;
 	}
 	pud = pud_offset(pgd, address);
+	base = address & PGDIR_MASK;
 	address &= ~PGDIR_MASK;
 	end = address + size;
 	if (end > PGDIR_SIZE)
 		end = PGDIR_SIZE;
 	do {
-		change_pmd_range(pud, address, end - address, newprot);
+		change_pmd_range(mm, pud, base + address, end - address, newprot);
 		address = (address + PUD_SIZE) & PUD_MASK;
 		pud++;
 	} while (address && (address < end));
@@ -130,7 +133,7 @@
 		next = (start + PGDIR_SIZE) & PGDIR_MASK;
 		if (next <= start || next > end)
 			next = end;
-		change_pud_range(pgd, start, next - start, newprot);
+		change_pud_range(mm, pgd, start, next - start, newprot);
 		start = next;
 		pgd++;
 	}
diff -Nru a/mm/mremap.c b/mm/mremap.c
--- a/mm/mremap.c	2005-03-05 23:06:10 -08:00
+++ b/mm/mremap.c	2005-03-05 23:06:10 -08:00
@@ -149,7 +149,7 @@
 			if (dst) {
 				pte_t pte;
 				pte = ptep_clear_flush(vma, old_addr, src);
-				set_pte(dst, pte);
+				set_pte_at(mm, new_addr, dst, pte);
 			} else
 				error = -ENOMEM;
 			pte_unmap_nested(src);
diff -Nru a/mm/rmap.c b/mm/rmap.c
--- a/mm/rmap.c	2005-03-05 23:06:10 -08:00
+++ b/mm/rmap.c	2005-03-05 23:06:10 -08:00
@@ -593,7 +593,7 @@
 			list_add(&mm->mmlist, &init_mm.mmlist);
 			spin_unlock(&mmlist_lock);
 		}
-		set_pte(pte, swp_entry_to_pte(entry));
+		set_pte_at(mm, address, pte, swp_entry_to_pte(entry));
 		BUG_ON(pte_file(*pte));
 		mm->anon_rss--;
 	}
@@ -695,7 +695,7 @@
 
 		/* If nonlinear, store the file page offset in the pte. */
 		if (page->index != linear_page_index(vma, address))
-			set_pte(pte, pgoff_to_pte(page->index));
+			set_pte_at(mm, address, pte, pgoff_to_pte(page->index));
 
 		/* Move the dirty bit to the physical page now the pte is gone. */
 		if (pte_dirty(pteval))
diff -Nru a/mm/swapfile.c b/mm/swapfile.c
--- a/mm/swapfile.c	2005-03-05 23:06:10 -08:00
+++ b/mm/swapfile.c	2005-03-05 23:06:10 -08:00
@@ -433,7 +433,8 @@
 {
 	vma->vm_mm->rss++;
 	get_page(page);
-	set_pte(dir, pte_mkold(mk_pte(page, vma->vm_page_prot)));
+	set_pte_at(vma->vm_mm, address, dir,
+		   pte_mkold(mk_pte(page, vma->vm_page_prot)));
 	page_add_anon_rmap(page, vma, address);
 	swap_free(entry);
 }
diff -Nru a/mm/vmalloc.c b/mm/vmalloc.c
--- a/mm/vmalloc.c	2005-03-05 23:06:10 -08:00
+++ b/mm/vmalloc.c	2005-03-05 23:06:10 -08:00
@@ -26,7 +26,7 @@
 static void unmap_area_pte(pmd_t *pmd, unsigned long address,
 				  unsigned long size)
 {
-	unsigned long end;
+	unsigned long base, end;
 	pte_t *pte;
 
 	if (pmd_none(*pmd))
@@ -38,6 +38,7 @@
 	}
 
 	pte = pte_offset_kernel(pmd, address);
+	base = address & PMD_MASK;
 	address &= ~PMD_MASK;
 	end = address + size;
 	if (end > PMD_SIZE)
@@ -45,7 +46,7 @@
 
 	do {
 		pte_t page;
-		page = ptep_get_and_clear(pte);
+		page = ptep_get_and_clear(&init_mm, base + address, pte);
 		address += PAGE_SIZE;
 		pte++;
 		if (pte_none(page))
@@ -59,7 +60,7 @@
 static void unmap_area_pmd(pud_t *pud, unsigned long address,
 				  unsigned long size)
 {
-	unsigned long end;
+	unsigned long base, end;
 	pmd_t *pmd;
 
 	if (pud_none(*pud))
@@ -71,13 +72,14 @@
 	}
 
 	pmd = pmd_offset(pud, address);
+	base = address & PUD_MASK;
 	address &= ~PUD_MASK;
 	end = address + size;
 	if (end > PUD_SIZE)
 		end = PUD_SIZE;
 
 	do {
-		unmap_area_pte(pmd, address, end - address);
+		unmap_area_pte(pmd, base + address, end - address);
 		address = (address + PMD_SIZE) & PMD_MASK;
 		pmd++;
 	} while (address < end);
@@ -87,7 +89,7 @@
 			   unsigned long size)
 {
 	pud_t *pud;
-	unsigned long end;
+	unsigned long base, end;
 
 	if (pgd_none(*pgd))
 		return;
@@ -98,13 +100,14 @@
 	}
 
 	pud = pud_offset(pgd, address);
+	base = address & PGDIR_MASK;
 	address &= ~PGDIR_MASK;
 	end = address + size;
 	if (end > PGDIR_SIZE)
 		end = PGDIR_SIZE;
 
 	do {
-		unmap_area_pmd(pud, address, end - address);
+		unmap_area_pmd(pud, base + address, end - address);
 		address = (address + PUD_SIZE) & PUD_MASK;
 		pud++;
 	} while (address && (address < end));
@@ -114,8 +117,9 @@
 			       unsigned long size, pgprot_t prot,
 			       struct page ***pages)
 {
-	unsigned long end;
+	unsigned long base, end;
 
+	base = address & PMD_MASK;
 	address &= ~PMD_MASK;
 	end = address + size;
 	if (end > PMD_SIZE)
@@ -127,7 +131,7 @@
 		if (!page)
 			return -ENOMEM;
 
-		set_pte(pte, mk_pte(page, prot));
+		set_pte_at(&init_mm, base + address, pte, mk_pte(page, prot));
 		address += PAGE_SIZE;
 		pte++;
 		(*pages)++;
@@ -151,7 +155,7 @@
 		pte_t * pte = pte_alloc_kernel(&init_mm, pmd, base + address);
 		if (!pte)
 			return -ENOMEM;
-		if (map_area_pte(pte, address, end - address, prot, pages))
+		if (map_area_pte(pte, base + address, end - address, prot, pages))
 			return -ENOMEM;
 		address = (address + PMD_SIZE) & PMD_MASK;
 		pmd++;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
