From: "Albert D. Cahalan" <acahalan@cs.uml.edu>
Message-Id: <200103290610.f2T6A7s282810@saturn.cs.uml.edu>
Subject: Re: [patch] pae-2.4.3-C3
Date: Thu, 29 Mar 2001 01:10:07 -0500 (EST)
In-Reply-To: <Pine.LNX.4.30.0103281151020.3657-200000@elte.hu> from "Ingo Molnar" at Mar 28, 2001 11:57:52 AM
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: mingo@elte.hu
Cc: Linux Kernel List <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Ingo Molnar writes:

> the attached pae-2.4.3-C3 patch fixes the PAE code to work with SLAB
> FORCED_DEBUG (which enables redzoning) too.
> 
> the problem is that redzoning is enabled unconditionally, and SLAB has no
> information about how crutial alignment is in the case of any particular
> SLAB cache. The CPU generates a general protection fault if in PAE mode a
> non-16-byte aligned pgd is loaded into %cr3.

How about just fixing the debug code to align things? Sure it wastes
a bit of memory, but debug code is like that.

Sane alignment might be: largest power-of-two factor of the size,
or 4 bytes, which ever is larger. (adjust "4" per-arch as needed)
For an SMP config, set a minimum alignment equal to the cache line size.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
