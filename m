Date: Fri, 14 Jan 2005 23:34:11 +0100
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: smp_rmb in mm/memory.c in 2.6.10
Message-ID: <20050114223411.GN8709@dualathlon.random>
References: <20050114211441.59635.qmail@web14305.mail.yahoo.com> <Pine.LNX.4.44.0501142127430.3050-100000@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.44.0501142127430.3050-100000@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Kanoj Sarcar <kanojsarcar@yahoo.com>, Anton Blanchard <anton@samba.org>, Andi Kleen <ak@suse.de>, William Lee Irwin III <wli@holomorphy.com>, linux-mm@kvack.org, davem@redhat.com
List-ID: <linux-mm.kvack.org>

> > As to the smp_rmb() part, I believe it is required; we
> > are not talking about compiler reorderings,
On Fri, Jan 14, 2005 at 10:09:17PM +0000, Hugh Dickins wrote:
> Did need to be considered, but I still agree with
> myself that the function call makes it no problem.

I believe gcc is learning how to get around function calls, in this case
it's a different file that we're calling so it's very unlikely to get us
compiler problems.

But the real reason of the smp_rmb is the cpu, the compiler not.

> as I did when posting the patch to remove it).

Woops ... I must have missed it sorry, I owe you an apology! It has been
a failry busy week here around (some kernel testing stuff has been going
on here, eventually the kernel was not to blame so all completed well ;).

> Unless someone sees this differently, I should send a patch to
> restore the smp_rmb(), with a longer code comment on what it's for.

Sure go ahead. I was thinking the same. Originally the code was more
obvious when I did it with two counters, and then Paul improved it with
a single counter but now it deserves a bit more of commentary.

Thanks Hugh and Kanoj!
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
