Date: Thu, 15 Feb 2001 11:06:25 -0500 (EST)
From: Ben LaHaise <bcrl@redhat.com>
Subject: Re: x86 ptep_get_and_clear question
In-Reply-To: <20010215115536.A1257@pcep-jamie.cern.ch>
Message-ID: <Pine.LNX.4.30.0102151104110.15790-100000@today.toronto.redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jamie Lokier <lk@tantalophile.demon.co.uk>
Cc: Kanoj Sarcar <kanoj@google.engr.sgi.com>, linux-mm@kvack.org, mingo@redhat.com, alan@redhat.com
List-ID: <linux-mm.kvack.org>

On Thu, 15 Feb 2001, Jamie Lokier wrote:

> Ben LaHaise wrote:
> > x86 hardware goes back to the page tables whenever there is an attempt to
> > change the access it has to the pte.  Ie, if it originally accessed the
> > page table for reading, it will go back to the page tables on write.  I
> > believe most hardware that performs accessed/dirty bit updates in hardware
> > behaves the same way.
>
> I think the scenario in question is this:
>
> Processor 2 has recently done some writes, so the dirty bit is set in
> processor 2's TLB.
>
> Processor 1 clears the dirty bit atomically.
>
> Processor 2 does some more writes, and does not check the page table
> because the page is already dirty in its TLB.
>
> Result: The later writes on processor 2 do not mark the page dirty.

Yeah, but the tlb is flushed in those cases (look for flush_tlb_page in
try_to_swap_out).

		-ben

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
