Date: Thu, 29 Mar 2007 21:59:37 -0500
From: Robin Holt <holt@sgi.com>
Subject: Re: [rfc][patch 1/2] mm: dont account ZERO_PAGE
Message-ID: <20070330025936.GA25722@lnx-holt.americas.sgi.com>
References: <20070329075805.GA6852@wotan.suse.de> <Pine.LNX.4.64.0703291324090.21577@blonde.wat.veritas.com> <20070330014633.GA19407@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070330014633.GA19407@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Hugh Dickins <hugh@veritas.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>, tee@sgi.com, holt@sgi.com
List-ID: <linux-mm.kvack.org>

On Fri, Mar 30, 2007 at 03:46:34AM +0200, Nick Piggin wrote:
> > Oh, it's easy to devise a test-case of that kind, but does it matter
> > in real life?  I admit that what most people run on their 1024-core
> > Altices will be significantly different from what I checked on my
> > laptop back then, but in my case use of the ZERO_PAGE didn't look
> > common enough to make special cases for.
> 
> Yeah I don't have access to the box, but it was a constructed test
> of some kind. However this is basically a dead box situation... on
> smaller systems we could still see performance improvements.

It was not a constructed test.  It was an test application which started
up and read one word from each page to fill the page tables (not sure
why that was done), then forked a process for each cpu.  At that point,
it was supposed start doing computation using data from an NFS accessible
file.  Unfortunately, the file was not found so the application exited
and the machine locked up for hours.

Of course, they assumed something had gone wrong with the system and
repeated the test with the same result.

Thanks,
Robin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
