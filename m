Date: Thu, 15 Feb 2001 11:55:36 +0100
From: Jamie Lokier <lk@tantalophile.demon.co.uk>
Subject: Re: x86 ptep_get_and_clear question
Message-ID: <20010215115536.A1257@pcep-jamie.cern.ch>
References: <200102150150.RAA62793@google.engr.sgi.com> <Pine.LNX.4.30.0102142101290.15070-100000@today.toronto.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.30.0102142101290.15070-100000@today.toronto.redhat.com>; from bcrl@redhat.com on Wed, Feb 14, 2001 at 09:13:11PM -0500
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ben LaHaise <bcrl@redhat.com>
Cc: Kanoj Sarcar <kanoj@google.engr.sgi.com>, linux-mm@kvack.org, mingo@redhat.com, alan@redhat.com
List-ID: <linux-mm.kvack.org>

Ben LaHaise wrote:
> x86 hardware goes back to the page tables whenever there is an attempt to
> change the access it has to the pte.  Ie, if it originally accessed the
> page table for reading, it will go back to the page tables on write.  I
> believe most hardware that performs accessed/dirty bit updates in hardware
> behaves the same way.

I think the scenario in question is this:

Processor 2 has recently done some writes, so the dirty bit is set in
processor 2's TLB.

Processor 1 clears the dirty bit atomically.

Processor 2 does some more writes, and does not check the page table
because the page is already dirty in its TLB.

Result: The later writes on processor 2 do not mark the page dirty.

-- Jamie
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
