Subject: Re: zap_page_range(): TLB flush race
Date: Sun, 9 Apr 2000 00:37:05 +0100 (BST)
In-Reply-To: <200004082331.QAA78522@google.engr.sgi.com> from "Kanoj Sarcar" at Apr 08, 2000 04:31:38 PM
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-Id: <E12e4mo-0003Pn-00@the-village.bc.nu>
From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Kanoj Sarcar <kanoj@google.engr.sgi.com>
Cc: Manfred Spraul <manfreds@colorfullife.com>, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org, torvalds@transmeta.com, davem@redhat.com, alan@lxorguk.ukuu.org.uk
List-ID: <linux-mm.kvack.org>

> > Yes, establish_pte() is broken. We should reverse the calls:
> > 
> > 	set_pte(); /* update the kernel page tables */
> > 	update_mmu(); /* update architecture specific page tables. */
> > 	flush_tlb();  /* and flush the hardware tlb */
> >
> 
> People are aware of this too, it was introduced during the 390 merge. 
> I tried talking to the IBM guy about this, I didn't see a response from
> him ...

Strange since I did and it included you

> I think what we now need is a critical mass, something that will make us
> go "okay, lets just fix these races once and for all".

Basically establish_pte() has to be architecture specific, as some processors
need different orders either to avoid races or to handle cpu specific
limitations.

Alan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
