Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id D09CD6B006A
	for <linux-mm@kvack.org>; Sat, 31 Oct 2009 17:33:09 -0400 (EDT)
Subject: Re: RFC: Transparent Hugepage support
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
In-Reply-To: <1256741656.5613.15.camel@aglitke>
References: <20091026185130.GC4868@random.random>
	 <87ljiwk8el.fsf@basil.nowhere.org> <20091027193007.GA6043@random.random>
	 <20091028042805.GJ7744@basil.fritz.box>
	 <20091028120050.GD9640@random.random>
	 <20091028141803.GQ7744@basil.fritz.box>  <1256741656.5613.15.camel@aglitke>
Content-Type: text/plain; charset="UTF-8"
Date: Sun, 01 Nov 2009 08:32:37 +1100
Message-ID: <1257024757.7907.19.camel@pasglop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Adam Litke <agl@us.ibm.com>
Cc: Andi Kleen <andi@firstfloor.org>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Wed, 2009-10-28 at 09:54 -0500, Adam Litke wrote:
> 
> PowerPC does not require specific virtual addresses for huge pages, but
> does require that a consistent page size be used for each slice of the
> virtual address space.  Slices are 256M in size from 0 to 4G and 1TB in
> size above 1TB while huge pages are 64k, 16M, or 16G.  Unless the PPC
> guys can work some more magic with their mmu, split_huge_page() in its
> current form just plain won't work on PowerPC.  That doesn't even take
> into account the (already discussed) page table layout differences
> between x86 and ppc: http://linux-mm.org/PageTableStructure . 

Note: this is server powerpc's. Embedded ones are more flexible but on
server we have this limitation and not much we can do about it.

Note also that the "slice" sizes are a SW thing. HW segments are either
256M or 1T (the later being supported only on some processors), and
linux maintains that concept of "slices" in order to simplify the
tracking of said segments and to use 1T when available.

Ben.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
