Date: Thu, 4 Aug 2005 17:32:16 +0100
From: Russell King <rmk+lkml@arm.linux.org.uk>
Subject: Re: [patch 2.6.13-rc4] fix get_user_pages bug
Message-ID: <20050804173215.I32154@flint.arm.linux.org.uk>
References: <Pine.LNX.4.58.0508021127120.3341@g5.osdl.org> <Pine.LNX.4.61.0508022001420.6744@goblin.wat.veritas.com> <Pine.LNX.4.58.0508021244250.3341@g5.osdl.org> <Pine.LNX.4.61.0508022150530.10815@goblin.wat.veritas.com> <42F09B41.3050409@yahoo.com.au> <Pine.LNX.4.58.0508030902380.3341@g5.osdl.org> <20050804141457.GA1178@localhost.localdomain> <42F2266F.30008@yahoo.com.au> <20050804150053.GA1346@localhost.localdomain> <Pine.LNX.4.61.0508041618020.4668@goblin.wat.veritas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.61.0508041618020.4668@goblin.wat.veritas.com>; from hugh@veritas.com on Thu, Aug 04, 2005 at 04:35:06PM +0100
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Alexander Nyberg <alexn@telia.com>, Linus Torvalds <torvalds@osdl.org>, Nick Piggin <nickpiggin@yahoo.com.au>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Andrew Morton <akpm@osdl.org>, Robin Holt <holt@sgi.com>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Ingo Molnar <mingo@elte.hu>, Roland McGrath <roland@redhat.com>, Andi Kleen <ak@suse.de>
List-ID: <linux-mm.kvack.org>

On Thu, Aug 04, 2005 at 04:35:06PM +0100, Hugh Dickins wrote:
> And it does miss arm, the only arch which actually needs changing
> right now, if we simply restore the original values which Nick shifted
> - although arm references the VM_FAULT_ codes in some places, it also
> uses "> 0".  arm26 looks at first as if it needs changing too, but
> a closer look shows it's remapping the faults and is okay - agreed?

Your patch doesn't look right.  Firstly, I'd rather stay away from
switch() if at all possible - past experience has shown that it
generates inherently poor code on ARM.  Whether that's still true
or not I've no idea, but I don't particularly want to find out at
the moment.

> Restore VM_FAULT_SIGBUS, VM_FAULT_MINOR and VM_FAULT_MAJOR to their
> original values, so that arches which have them hardcoded will still
> work before they're cleaned up.  And correct arm to use the VM_FAULT_
> codes throughout, not assuming MINOR and MAJOR are the only ones > 0.

And the above rules this out.

As I say, I fixed ARM this morning, so changing these constants will
break it again.  Let's just wait for things to stabilise instead of
trying to race with architecture maintainers...

-- 
Russell King
 Linux kernel    2.6 ARM Linux   - http://www.arm.linux.org.uk/
 maintainer of:  2.6 Serial core
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
