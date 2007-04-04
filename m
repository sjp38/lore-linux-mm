Date: Wed, 4 Apr 2007 13:45:06 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [rfc] no ZERO_PAGE?
In-Reply-To: <20070404102407.GA529@wotan.suse.de>
Message-ID: <Pine.LNX.4.64.0704041338450.7416@blonde.wat.veritas.com>
References: <20070329075805.GA6852@wotan.suse.de>
 <Pine.LNX.4.64.0703291324090.21577@blonde.wat.veritas.com>
 <20070330024048.GG19407@wotan.suse.de> <20070404033726.GE18507@wotan.suse.de>
 <Pine.LNX.4.64.0704041023040.17341@blonde.wat.veritas.com>
 <20070404102407.GA529@wotan.suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>, tee@sgi.com, holt@sgi.com, Andrea Arcangeli <andrea@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Wed, 4 Apr 2007, Nick Piggin wrote:
> 
> No, you have a point, but if we have to ask people to recompile 
> with CONFIG_ZERO_PAGE, then it isn't much harder to ask them to
> apply a patch first.
> 
> But for a potential mainline merge, maybe starting with a CONFIG
> option is a good idea -- defaulting to off, and we could start by
> turning it on just in -rc kernels for a few releases, to get a bit
> more confidence?

I'm confused.  CONFIG_ZERO_PAGE off is where we'd like to end up: how
would turning CONFIG_ZERO_PAGE on in -rc kernels help us to get there?

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
