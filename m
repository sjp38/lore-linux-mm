Received: from atlas.iskon.hr (atlas.iskon.hr [213.191.131.6])
	by inje.iskon.hr (8.9.3/8.9.3/Debian 8.9.3-6) with ESMTP id WAA14945
	for <linux-mm@kvack.org>; Thu, 6 Jul 2000 22:13:12 +0200
Subject: Re: Tell me about ZONE_DMA
References: <20000705212704Z131198-21004+106@kanga.kvack.org>
Reply-To: zlatko@iskon.hr
From: Zlatko Calusic <zlatko@iskon.hr>
Date: 06 Jul 2000 22:03:43 +0200
In-Reply-To: Timur Tabi's message of "Wed, 05 Jul 2000 16:13:52 -0500"
Message-ID: <87ya3fjaao.fsf@atlas.iskon.hr>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linux MM mailing list <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Timur Tabi <ttabi@interactivesi.com> writes:

> I'm trying to understand the differences between the three zones, ZONE_DMA,
> ZONE_NORMAL,and ZONE_HIGHMEM.  I've searched the source code (I'm getting pretty
> good at understanding the kernel memory allocator), but I can't figure out what
> physical regions of memory belong to each zone.  Where is that determined?
> 

First, let's assume we're talking here about i386 architecture,
because I know nothing about other architectures.

ZONE_DMA is lower 16MB of physical memory. It is special because ISA
cards can do DMA only to this part of memory.

ZONE_NORMAL is a memory that is mapped in address space of the CPU. We
use 3:1 GB split of the CPU address space. Lower 3GB is user memory,
upper 1GB is kernel and also whole physical memory has to be mapped
there (modulo vmalloc area, not very relevant for the discussion).

With 1GB of physical memory or more, extra memory above ~960MB is in
ZONE_HIGHMEM. Somebody else will explain this memory area better, so I
won't bother writing wrong facts. I haven't investigated high memory
very much.

> Also, I get this eerie feeling that it's possible for a physical page to exist
> in more than one zone.  Is that true?
> 

No. Every physical page is in exactly one zone, depending on its
address, see above.

Hope it helps.
-- 
Zlatko
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
