Date: Wed, 20 Feb 2002 14:38:58 +0000 (GMT)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [RFC] Page table sharing
In-Reply-To: <E16dXRt-0001Lo-00@starship.berlin>
Message-ID: <Pine.LNX.4.21.0202201435230.1136-100000@localhost.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Daniel Phillips <phillips@bonn-fries.net>
Cc: Linus Torvalds <torvalds@transmeta.com>, Rik van Riel <riel@conectiva.com.br>, dmccr@us.ibm.com, Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Robert Love <rml@tech9.net>, mingo@redhat.com, Andrew Morton <akpm@zip.com.au>, manfred@colorfullife.com, wli@holomorphy.com
List-ID: <linux-mm.kvack.org>

On Wed, 20 Feb 2002, Daniel Phillips wrote:
> 
> Looking at the current try_to_swap_out code I see only a local invalidate, 
> flush_tlb_page(vma, address), why is that?  How do we know that this mm could 
> not be in context on another cpu?

I made the same mistake a few months ago: not noticing #ifndef CONFIG_SMP
in the header.  arch/i386/kernel/smp.c has the real i386 flush_tlb_page().

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
