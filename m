Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 58A0F6B005A
	for <linux-mm@kvack.org>; Wed, 28 Oct 2009 11:13:07 -0400 (EDT)
Date: Wed, 28 Oct 2009 16:13:02 +0100
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: RFC: Transparent Hugepage support
Message-ID: <20091028151302.GR7744@basil.fritz.box>
References: <20091026185130.GC4868@random.random> <87ljiwk8el.fsf@basil.nowhere.org> <20091027193007.GA6043@random.random> <20091028042805.GJ7744@basil.fritz.box> <20091028120050.GD9640@random.random> <20091028141803.GQ7744@basil.fritz.box> <1256741656.5613.15.camel@aglitke>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1256741656.5613.15.camel@aglitke>
Sender: owner-linux-mm@kvack.org
To: Adam Litke <agl@us.ibm.com>
Cc: Andi Kleen <andi@firstfloor.org>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

> PowerPC does not require specific virtual addresses for huge pages, but
> does require that a consistent page size be used for each slice of the
> virtual address space.  Slices are 256M in size from 0 to 4G and 1TB in
> size above 1TB while huge pages are 64k, 16M, or 16G.  Unless the PPC
> guys can work some more magic with their mmu, split_huge_page() in its
> current form just plain won't work on PowerPC.  That doesn't even take
> into account the (already discussed) page table layout differences
> between x86 and ppc: http://linux-mm.org/PageTableStructure .

it simply won't be able to use Andrea's transparent code until
someone fixes the MMU. Doesn't seem a disaster

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
