Message-ID: <20050113212912.93033.qmail@web14308.mail.yahoo.com>
Date: Thu, 13 Jan 2005 13:29:12 -0800 (PST)
From: Kanoj Sarcar <kanojsarcar@yahoo.com>
Subject: Re: smp_rmb in mm/memory.c in 2.6.10
In-Reply-To: <20050113210624.GG20738@wotan.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@suse.de>
Cc: William Lee Irwin III <wli@holomorphy.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

--- Andi Kleen <ak@suse.de> wrote:

> > In include/asm-i386/spinlock.h, spin_unlock_string
> has
> > a "xchgb" (in case its required). That should be
> > enough  of a barrier for the hardware, no? 
> 
> It is, but only for broken PPros or OOSTORE system
> (currently only VIA C3). For kernels compiled for
> non broken CPUs  
> there isn't any kind of barrier. 
> 
> -Andi

Okay, I think I see what you and wli meant. But the
assumption that spin_lock will order memory operations
is still correct, right?

Going back to what I meant in the first place, the
memory.c code is doing something like 1. read
truncate_count, 2. invoke nopage, which will probably
get locks, which will ensure the read of
truncate_count is complete, right? So, the original
point that smp_rmb() is not required (at least in the
position it currently is in) still holds, correct?

Thanks.

Kanoj


		
__________________________________ 
Do you Yahoo!? 
Take Yahoo! Mail with you! Get it on your mobile phone. 
http://mobile.yahoo.com/maildemo 
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
