Date: Thu, 6 Apr 2000 20:30:24 +0200
From: Jamie Lokier <lk@tantalophile.demon.co.uk>
Subject: Re: Query on memory management
Message-ID: <20000406203023.A11979@pcep-jamie.cern.ch>
References: <OF65849FAF.07536636-ON862568B9.004B90AB@hso.link.com> <20000406173056.08616@colin.muc.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20000406173056.08616@colin.muc.de>; from Andi Kleen on Thu, Apr 06, 2000 at 05:30:56PM +0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@muc.de>
Cc: Mark_H_Johnson@Raytheon.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Andi Kleen wrote:
> > (4) Is there a "hook" for user defined page replacement or page fault
> > handling? I could not find one.
> 
> Just mprotect() the data in user space and set a signal handler for SIGSEGV
> The fault address can be read from the sigcontext_struct passed to the
> signal handler.

But note that this does not handle page faults when systems calls access
the memory.  I.e. you'll get EFAULTs when you read/write/ioctl the
protected memory region instead of triggering your SEGV handler.

enjoy,
-- Jamie
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
