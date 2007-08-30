From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: speeding up swapoff
References: <1188394172.22156.67.camel@localhost>
	<Pine.LNX.4.64.0708291558480.27467@blonde.wat.veritas.com>
Date: Thu, 30 Aug 2007 02:27:29 -0600
In-Reply-To: <Pine.LNX.4.64.0708291558480.27467@blonde.wat.veritas.com> (Hugh
	Dickins's message of "Wed, 29 Aug 2007 16:36:37 +0100 (BST)")
Message-ID: <m1d4x52zri.fsf@ebiederm.dsl.xmission.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Daniel Drake <ddrake@brontes3d.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Hugh Dickins <hugh@veritas.com> writes:

> The speedups I've imagined making, were a need demonstrated, have
> been more on the lines of batching (dealing with a range of pages
> in one go) and hashing (using the swapmap's ushort, so often 1 or
> 2 or 3, to hold an indicator of where to look for its references).

There is one other possibility.  Typically the swap code is using
compatibility disk I/O functions instead of the best the kernel
can offer.  I haven't looked recently but it might be worth just
making certain that there isn't some low-level optimization or
cleanup possible on that path.  Although I may just be thinking
of swapfiles.

I know there were tremendous gains ago when I removed the functions
that wrote pages synchronously to swapfiles.

Eric

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
