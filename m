Date: Thu, 15 Feb 2001 17:35:47 +0100
From: Jamie Lokier <lk@tantalophile.demon.co.uk>
Subject: Re: x86 ptep_get_and_clear question
Message-ID: <20010215173547.A2079@pcep-jamie.cern.ch>
References: <20010215115536.A1257@pcep-jamie.cern.ch> <Pine.LNX.4.30.0102151104110.15790-100000@today.toronto.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.30.0102151104110.15790-100000@today.toronto.redhat.com>; from bcrl@redhat.com on Thu, Feb 15, 2001 at 11:06:25AM -0500
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ben LaHaise <bcrl@redhat.com>
Cc: Kanoj Sarcar <kanoj@google.engr.sgi.com>, linux-mm@kvack.org, mingo@redhat.com, alan@redhat.com
List-ID: <linux-mm.kvack.org>

Ben LaHaise wrote:
> > Processor 2 has recently done some writes, so the dirty bit is set in
> > processor 2's TLB.
> >
> > Processor 1 clears the dirty bit atomically.
> >
> > Processor 2 does some more writes, and does not check the page table
> > because the page is already dirty in its TLB.
> >
> > Result: The later writes on processor 2 do not mark the page dirty.
> 
> Yeah, but the tlb is flushed in those cases (look for flush_tlb_page in
> try_to_swap_out).

As long as processor 1 waits for the flush on processor 2 to complete
before marking the struct page dirty, that looks fine to me.

-- Jamie
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
