Received: from zange.cs.tu-berlin.de (pokam@zange.cs.tu-berlin.de [130.149.31.198])
	by mail.cs.tu-berlin.de (8.9.1/8.9.1) with ESMTP id MAA05983
	for <linux-mm@kvack.org>; Sat, 28 Aug 1999 12:03:45 +0200 (MET DST)
From: Gilles Pokam <pokam@cs.tu-berlin.de>
Received: (from pokam@localhost)
	by zange.cs.tu-berlin.de (8.9.1/8.9.0) id MAA29351
	for linux-mm@kvack.org; Sat, 28 Aug 1999 12:03:42 +0200 (MET DST)
Message-Id: <199908281003.MAA29351@zange.cs.tu-berlin.de>
Subject: question on remap_page_range()
Date: Sat, 28 Aug 1999 12:03:41 +0200 (MET DST)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi everyone,

I have some questions about the behavior of the remap_page_range function as 
well as the ioremap. 

1. remap_page_range (as well as ioremap or vremap) takes a "physical address"
   as argument. In Rubini's book it is said that the so-called "physical
   address" is in reality a virtual address offset by PAGE_OFFSET from the 
   real physical address:
	phys = real_phys + PAGE_OFFSET 
   In x86 2.0.x kernel i had no problems with this convertion because the
   PAGE_OFFSET is almost defined to be 0, so that phys = virt address.

2. But now i have tried to run my code on a x86 2.2.x kernel and the 
   remap_page_range function fails! When i ignore the PAGE_OFFSET macro
   it works strangely ...! 

  My question is, what is the definition of the physical address in the
  remap_page_range and vremap functions ?

  Regards 
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
