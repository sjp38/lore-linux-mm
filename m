Date: Wed, 4 Apr 2007 17:34:51 +0200
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: [rfc] no ZERO_PAGE?
Message-ID: <20070404153451.GH19587@v2.random>
References: <Pine.LNX.4.64.0703291324090.21577@blonde.wat.veritas.com> <20070330024048.GG19407@wotan.suse.de> <20070404033726.GE18507@wotan.suse.de> <Pine.LNX.4.64.0704041023040.17341@blonde.wat.veritas.com> <20070404102407.GA529@wotan.suse.de> <20070404122701.GB19587@v2.random> <20070404135530.GA29026@localdomain> <20070404141457.GF19587@v2.random> <20070404144421.GA13762@localdomain> <Pine.LNX.4.64.0704041553220.18202@blonde.wat.veritas.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0704041553220.18202@blonde.wat.veritas.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Dan Aloni <da-x@monatomic.org>, Nick Piggin <npiggin@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>, tee@sgi.com, holt@sgi.com, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Wed, Apr 04, 2007 at 04:03:15PM +0100, Hugh Dickins wrote:
> Maybe Nick will decide to not to mark the readfaults as dirty.

I don't like to mark the pte readonly and clean, we'd be still
optimizing for the current ZERO_PAGE users and even for those it would
generate a unnecessary page fault if they later write to it. If any
legitimate ZERO_PAGE user really exists, then we should keep mapping
the ZERO_PAGE into it and fix the scalability issue associated with
it, instead of allocating a new page in readonly mode.

Marking anonymous pages readonly and clean so they can be collected
w/o swapping still is desiderable for glibc through madvise (madvise
would later need to be called again before starting using the
collectable anon pages to store information into it), but that's
an entirely different topic ;)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
