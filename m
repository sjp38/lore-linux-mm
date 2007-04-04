Date: Wed, 4 Apr 2007 14:32:03 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [rfc] no ZERO_PAGE?
In-Reply-To: <20070404130559.GD19587@v2.random>
Message-ID: <Pine.LNX.4.64.0704041426080.10683@blonde.wat.veritas.com>
References: <20070329075805.GA6852@wotan.suse.de>
 <Pine.LNX.4.64.0703291324090.21577@blonde.wat.veritas.com>
 <20070330024048.GG19407@wotan.suse.de> <20070404033726.GE18507@wotan.suse.de>
 <Pine.LNX.4.64.0704041023040.17341@blonde.wat.veritas.com>
 <20070404102407.GA529@wotan.suse.de> <Pine.LNX.4.64.0704041338450.7416@blonde.wat.veritas.com>
 <20070404130559.GD19587@v2.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: Nick Piggin <npiggin@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>, tee@sgi.com, holt@sgi.com, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Wed, 4 Apr 2007, Andrea Arcangeli wrote:
> On Wed, Apr 04, 2007 at 01:45:06PM +0100, Hugh Dickins wrote:
> > I'm confused.  CONFIG_ZERO_PAGE off is where we'd like to end up: how
> > would turning CONFIG_ZERO_PAGE on in -rc kernels help us to get there?
> 
> He most certainly meant on by default.

Okay, I thought it more diplomatic to label myself as the confused one ;)

> 
> I think if we do this, we also need a zeropage counter in the vm stats
> so that we'll get a measure of the waste and it'll be possible to
> identify apps to optimize/fix.

That's a little unfortunate, since we'd then have to lose the win from
this change, that we issue a writable zeroed page (when VM_WRITE) in
do_anonymous_page, even when it's a read fault, saving subsequent fault.

Wouldn't we?  Or am I confused ;?

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
