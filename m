Date: Fri, 25 Aug 2000 23:59:03 -0400 (EDT)
From: "Benjamin C.R. LaHaise" <blah@kvack.org>
Subject: Re: pgd/pmd/pte and x86 kernel virtual addresses
In-Reply-To: <20000825185716Z131186-247+10@kanga.kvack.org>
Message-ID: <Pine.LNX.3.96.1000825235248.27724A-100000@kanga.kvack.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Timur Tabi <ttabi@interactivesi.com>
Cc: Linux MM mailing list <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Fri, 25 Aug 2000, Timur Tabi wrote:

> If I use ioremap_nocache(), I effectively have two virtual pointers to the same
> physical pointer.  The first is the normal virtual pointer for kernel memory,
> and the second is the one returned by ioremap_nocache().  I was under the
> understanding that caching is enabled on physical pages only, so it shouldn't
> matter which virtual address I use.  Is that correct?

No.  Depending on which virtual address you use, you will get different
behaviour (cached vs not).

> MTRR's are not an option, because chances are we won't have any free MTRR's to
> work with.  Besides, I can do what I want on Windows 2000 without MTRR's.  My
> driver is for a device which sits on the memory bus itself and responds to
> memory reads/writes.  If I can't disable caching, I can't talk to the device.

Ummm, then why is it in the range of normally cachable memory?  On Pentium
class machines there is a signal which indicates if a given memory access
is cachable/not.  On P6/later K6s/K7s you must use the MTRRs.

> The odd thing is that ioremap_nocache() did work at one point, but not any
> more, and I can't figure out why.

Technically ioremap should only be used on io addresses.  What in
particular is not working -- is the mapping incorrect, or is the mapping
being cached?  If the mapping is still being cached from previous
accesses, you will need to flush the CPU's cache of any stale cache lines.

		-ben

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
