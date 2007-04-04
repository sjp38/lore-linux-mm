Date: Wed, 4 Apr 2007 16:41:46 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [rfc] no ZERO_PAGE?
In-Reply-To: <20070404153451.GH19587@v2.random>
Message-ID: <Pine.LNX.4.64.0704041636550.22242@blonde.wat.veritas.com>
References: <Pine.LNX.4.64.0703291324090.21577@blonde.wat.veritas.com>
 <20070330024048.GG19407@wotan.suse.de> <20070404033726.GE18507@wotan.suse.de>
 <Pine.LNX.4.64.0704041023040.17341@blonde.wat.veritas.com>
 <20070404102407.GA529@wotan.suse.de> <20070404122701.GB19587@v2.random>
 <20070404135530.GA29026@localdomain> <20070404141457.GF19587@v2.random>
 <20070404144421.GA13762@localdomain> <Pine.LNX.4.64.0704041553220.18202@blonde.wat.veritas.com>
 <20070404153451.GH19587@v2.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: Dan Aloni <da-x@monatomic.org>, Nick Piggin <npiggin@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>, tee@sgi.com, holt@sgi.com, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Wed, 4 Apr 2007, Andrea Arcangeli wrote:
> On Wed, Apr 04, 2007 at 04:03:15PM +0100, Hugh Dickins wrote:
> > Maybe Nick will decide to not to mark the readfaults as dirty.
> 
> I don't like to mark the pte readonly and clean,

Nor I: I meant that anonymous readfault should
(perhaps) mark the pte writable but clean.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
