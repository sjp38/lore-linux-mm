Received: from luxury.wat.veritas.com([10.10.192.121]) (1444 bytes) by megami.veritas.com
	via sendmail with P:esmtp/R:smart_host/T:smtp
	(sender: <hugh@veritas.com>)
	id <m14kptx-00019DC@megami.veritas.com>
	for <linux-mm@kvack.org>; Wed, 4 Apr 2001 09:12:57 -0700 (PDT)
	(Smail-3.2.0.101 1997-Dec-17 #4 built 1999-Aug-24)
Date: Wed, 4 Apr 2001 17:13:44 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: pte_young/pte_mkold/pte_mkyoung
In-Reply-To: <200104041600.RAA01119@raistlin.arm.linux.org.uk>
Message-ID: <Pine.LNX.4.21.0104041711060.1126-100000@localhost.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: rmk@arm.linux.org.uk
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 4 Apr 2001 rmk@arm.linux.org.uk wrote:
> 
> We currently seem to have:
> 	2 references to pte_mkyoung()
> 	1 reference to pte_mkold()
> 	0 references to pte_young()
> 
> This tells me that we're no longer using the hardware page tables on x86
> for page aging, which leads me nicely on to the following question.
> 
> Are there currently any plans to use the hardware page aging bits in the
> future, and if there are, would architectures that don't have them be
> required to have them?
> 
> I'm asking this question because for some time (1.3 onwards), the ARM
> architecture has had some code to handle software emulation of the young
> and dirty bits.  If its not required, then I'd like to get rid of this
> software emulation.

You may be out of luck: mm/vmscan.c try_to_swap_out() has

	if (ptep_test_and_clear_young(page_table)) {

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
