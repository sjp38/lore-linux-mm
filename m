Message-ID: <20050113210210.51593.qmail@web14323.mail.yahoo.com>
Date: Thu, 13 Jan 2005 13:02:10 -0800 (PST)
From: Kanoj Sarcar <kanojsarcar@yahoo.com>
Subject: Re: smp_rmb in mm/memory.c in 2.6.10
In-Reply-To: <20050113203954.GA6101@holomorphy.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: William Lee Irwin III <wli@holomorphy.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

--- William Lee Irwin III <wli@holomorphy.com> wrote:

> On Thu, Jan 13, 2005 at 12:26:42PM -0800, Kanoj
> Sarcar wrote:
> > The second question is that even though
> truncate_count
> > is declared atomic (ie probably volatile on most
> > architectures), that does not make gcc guarantee
> > anything in terms of ordering, right?
> > Finally, does anyone really believe that a
> smp_rmb()
> > is required in step 2? My logic is that nopage()
> is
> > guaranteed to grab/release (spin)locks etc as part
> of
> > its processing, and that would force the snapshots
> of
> > truncate_count to be properly ordered.
> 
> spin_unlock() does not imply a memory barrier. e.g.
> on ia32 it's
> not even an atomic operation.

In include/asm-i386/spinlock.h, spin_unlock_string has
a "xchgb" (in case its required). That should be
enough  of a barrier for the hardware, no? 

Thanks.

Kanoj

> 
> 
> -- wli
> --
> To unsubscribe, send a message with 'unsubscribe
> linux-mm' in
> the body to majordomo@kvack.org.  For more info on
> Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"aart@kvack.org">
> aart@kvack.org </a>
> 



		
__________________________________ 
Do you Yahoo!? 
Yahoo! Mail - Easier than ever with enhanced search. Learn more.
http://info.mail.yahoo.com/mail_250
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
