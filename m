Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 4DC2A6B004F
	for <linux-mm@kvack.org>; Mon, 15 Jun 2009 11:15:49 -0400 (EDT)
Date: Mon, 15 Jun 2009 17:24:28 +0200
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH 00/22] HWPOISON: Intro (v5)
Message-ID: <20090615152427.GF31969@one.firstfloor.org>
References: <20090615024520.786814520@intel.com> <4A35BD7A.9070208@linux.vnet.ibm.com> <20090615042753.GA20788@localhost> <Pine.LNX.4.64.0906151341160.25162@sister.anvils> <20090615140019.4e405d37@lxorguk.ukuu.org.uk> <20090615132934.GE31969@one.firstfloor.org> <20090615154832.73c89733@lxorguk.ukuu.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090615154832.73c89733@lxorguk.ukuu.org.uk>
Sender: owner-linux-mm@kvack.org
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Cc: Andi Kleen <andi@firstfloor.org>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Wu Fengguang <fengguang.wu@intel.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Ingo Molnar <mingo@elte.hu>, Mel Gorman <mel@csn.ul.ie>, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Nick Piggin <npiggin@suse.de>, "riel@redhat.com" <riel@redhat.com>, "chris.mason@oracle.com" <chris.mason@oracle.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

> Everyone I knew in the business end of deploying Linux turned on panics
> for I/O errors, reboot on panic and all the rest of those.

oops=panic already implies panic on all machine check exceptions, so they will
be fine then (assuming this is the best strategy for availability 
for them, which I personally find quite doubtful, but we can discuss this some 
other time)

> Really - so if your design is wrong for the way PPC wants to work what
> are we going to do ? It's not a requirement that PPC64 support is there

Then we change the code. Or if it's too difficult don't support their stuff.
After all it's not cast in stone. That said I doubt the PPC requirements will 
be much different than what we have.

> I'd guess that zSeries has some rather different views on how ECC
> failures propogate through the hypervisors for example, including the
> fact that a failed page can be unfailed which you don't seem to allow for.

That's correct.

That's because unpoisioning is quite hard -- you need some kind
of synchronization point for all the error handling and that's
the poisoned page and if it unposions itself then you need
some very heavy weight synchronization to avoid handling errors
multiple time. I looked at it, but it's quite messy.

Also it's of somewhat dubious value.

> 
> (You can unfail pages on x86 as well it appears by scrubbing them via DMA
> - yes ?)

Not architectually. Also the other problem is not just unpoisoning them,
but finding out if the page is permenantly bad or just temporarily.

-Andi
-- 
ak@linux.intel.com -- Speaking for myself only.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
