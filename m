Date: Thu, 29 Mar 2001 09:14:32 +0200 (CEST)
From: Ingo Molnar <mingo@elte.hu>
Reply-To: <mingo@elte.hu>
Subject: Re: [patch] pae-2.4.3-C3
In-Reply-To: <200103290610.f2T6A7s282810@saturn.cs.uml.edu>
Message-ID: <Pine.LNX.4.30.0103290754110.918-100000@elte.hu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Albert D. Cahalan" <acahalan@cs.uml.edu>
Cc: Linux Kernel List <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 29 Mar 2001, Albert D. Cahalan wrote:

> > the problem is that redzoning is enabled unconditionally, and SLAB has no
> > information about how crutial alignment is in the case of any particular
> > SLAB cache. The CPU generates a general protection fault if in PAE mode a
> > non-16-byte aligned pgd is loaded into %cr3.
>
> How about just fixing the debug code to align things? Sure it wastes a
> bit of memory, but debug code is like that.

redzoning also catches code which assumes specific alignment.

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
