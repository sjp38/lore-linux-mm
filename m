Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id F0C0A6B0055
	for <linux-mm@kvack.org>; Mon, 20 Jul 2009 04:10:53 -0400 (EDT)
Date: Mon, 20 Jul 2009 10:10:54 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [RFC/PATCH] mm: Pass virtual address to [__]p{te,ud,md}_free_tlb()
Message-ID: <20090720081054.GH7298@wotan.suse.de>
References: <20090715074952.A36C7DDDB2@ozlabs.org> <20090715135620.GD7298@wotan.suse.de> <1247709255.27937.5.camel@pasglop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1247709255.27937.5.camel@pasglop>
Sender: owner-linux-mm@kvack.org
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Linux Memory Management <linux-mm@kvack.org>, Linux-Arch <linux-arch@vger.kernel.org>, linux-kernel@vger.kernel.org, linuxppc-dev@ozlabs.org, Hugh Dickins <hugh@tiscali.co.uk>
List-ID: <linux-mm.kvack.org>

On Thu, Jul 16, 2009 at 11:54:15AM +1000, Benjamin Herrenschmidt wrote:
> On Wed, 2009-07-15 at 15:56 +0200, Nick Piggin wrote:
> > Interesting arrangement. So are these last level ptes modifieable
> > from userspace or something? If not, I wonder if you could manage
> > them as another level of pointers with the existing pagetable
> > functions?
> 
> I don't understand what you mean. Basically, the TLB contains PMD's.

Maybe I don't understand your description correctly. The TLB contains
PMDs, but you say the HW still logically performs another translation
step using entries in the PMD pages? If I understand that correctly,
then generic mm does not actually care and would logically fit better
if those entries were "linux ptes". The pte invalidation routines
give the virtual address, which you could use to invalidate the TLB.
 

> There's nothing to change to the existing page table layout :-) But
> because they appear as large page TLB entries that cover the virtual
> space covered by a PMD, they need to be invalidated using virtual
> addresses when PMDs are removed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
