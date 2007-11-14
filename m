Subject: Re: [PATCH 3/3] nfs: use ->mmap_prepare() to avoid an AB-BA
	deadlock
From: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <20071114222448.GE31048@wotan.suse.de>
References: <20071114200136.009242000@chello.nl>
	 <20071114201528.514434000@chello.nl> <20071114212246.GA31048@wotan.suse.de>
	 <1195075905.22457.3.camel@lappy>
	 <1195076485.7584.66.camel@heimdal.trondhjem.org>
	 <1195077034.22457.6.camel@lappy>
	 <1195078730.7584.86.camel@heimdal.trondhjem.org>
	 <20071114222448.GE31048@wotan.suse.de>
Content-Type: text/plain
Date: Wed, 14 Nov 2007 17:53:48 -0500
Message-Id: <1195080828.7584.96.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-fsdevel@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

On Wed, 2007-11-14 at 23:24 +0100, Nick Piggin wrote:

> mmap()s can be different from read in that the syscall may have little
> relation to when the data gets used. But I guess it's still a best
> effort thing. Fair enough.

Agreed that mmap() is special and very problematic on NFS. However I
can't see how we can improve on the existing models short of some
significant protocol modifications, and so far, nobody has presented the
IETF with a good case for why they need this level of cache consistency.

Cheers
   Trond

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
