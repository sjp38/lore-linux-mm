From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: shutdown panic in mm_release (really flush_tlb_others?) (fwd) 
In-reply-to: Your message of "Thu, 26 Feb 2004 16:45:23 -0800."
             <20040226164523.660a5496.rddunlap@osdl.org>
Date: Fri, 27 Feb 2004 16:23:56 +1100
Message-Id: <20040227054531.DD8362C2A2@lists.samba.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Randy.Dunlap" <rddunlap@osdl.org>
Cc: linux-mm@kvack.org, mbligh@aracnet.com, akpm <akpm@osdl.org>, lkml <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

In message <20040226164523.660a5496.rddunlap@osdl.org> you write:
> Martin's patch didn't help me the first time that I tried it,
> but I'll try it again.  Rusty, is the patch that you posted
> complete (regarding arch/i386/kernel/smp.c), or are there other
> patch components that I might need?  It's queued up for next...

Um, please don't confuse my hotplug cpus patch with the half-assed
attempt to take CPUs down on shutdown.

Rusty.
--
  Anyone who quotes me in their sig is an idiot. -- Rusty Russell.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
