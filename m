Date: Mon, 5 Mar 2001 11:52:19 +0100
From: Andi Kleen <ak@muc.de>
Subject: Re: Shared mmaps
Message-ID: <20010305115219.A573@fred.local>
References: <20010304211053.F1865@parcelfarce.linux.theplanet.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20010304211053.F1865@parcelfarce.linux.theplanet.co.uk>; from matthew@wil.cx on Sun, Mar 04, 2001 at 10:10:53PM +0100
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Matthew Wilcox <matthew@wil.cx>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, Mar 04, 2001 at 10:10:53PM +0100, Matthew Wilcox wrote:
> Sparc & IA64 use a flag in the task_struct to indicate that they're trying
> to allocate an mmap which is shared.  That's really ugly, let's just pass
> the flags in to the get_mapped_area function instead.  I had to invent a
> new flag for this because mremap's flags are different to mmap's (bah!)
> 
> Comments?

With some extensions I would also find it useful for x86-64 for the 32bit
mmap emulation (currently it's using a current-> hack)
For that flags would need to be passed to TASK_UNMAPPED_BASE.


-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
