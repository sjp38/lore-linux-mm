Content-Type: text/plain;
  charset="iso-8859-1"
From: Daniel Phillips <phillips@bonn-fries.net>
Subject: Re: [RFC] Page table sharing
Date: Wed, 20 Feb 2002 15:57:37 +0100
References: <Pine.LNX.4.21.0202201435230.1136-100000@localhost.localdomain>
In-Reply-To: <Pine.LNX.4.21.0202201435230.1136-100000@localhost.localdomain>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Message-Id: <E16dYBd-0001M9-00@starship.berlin>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Linus Torvalds <torvalds@transmeta.com>, Rik van Riel <riel@conectiva.com.br>, dmccr@us.ibm.com, Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Robert Love <rml@tech9.net>, mingo@redhat.com, Andrew Morton <akpm@zip.com.au>, manfred@colorfullife.com, wli@holomorphy.com
List-ID: <linux-mm.kvack.org>

On February 20, 2002 03:38 pm, Hugh Dickins wrote:
> On Wed, 20 Feb 2002, Daniel Phillips wrote:
> > 
> > Looking at the current try_to_swap_out code I see only a local invalidate, 
> > flush_tlb_page(vma, address), why is that?  How do we know that this mm could 
> > not be in context on another cpu?
> 
> I made the same mistake a few months ago: not noticing #ifndef CONFIG_SMP
> in the header.  arch/i386/kernel/smp.c has the real i386 flush_tlb_page().

OK, well if I'm making the same mistakes then I'm likely on the right track ;)

So it seems that what we need for tlb invalidate of shared page tables is
not worse than what we already have, though there's some extra bookkeeping 
to handle.

Why would we run into your page dirty propagation problem with shared page
tables and not with the current code?

-- 
Daniel
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
