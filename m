Date: Mon, 3 Mar 2003 17:56:57 +0100 (CET)
From: Ingo Molnar <mingo@elte.hu>
Reply-To: Ingo Molnar <mingo@elte.hu>
Subject: Re: [patch] remap-file-pages-2.5.63-A0
In-Reply-To: <Pine.LNX.4.44.0303030849050.11244-100000@home.transmeta.com>
Message-ID: <Pine.LNX.4.44.0303031755160.13116-100000@localhost.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: Andrew Morton <akpm@zip.com.au>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, 3 Mar 2003, Linus Torvalds wrote:

> > the attached patch, against BK-curr, is a preparation to make
> > remap_file_pages() usable on swappable vmas as well. When 'swapping out'
> > shared-named mappings the page offset is written into the pte.
> > 
> > it takes one bit from the swap-type bits, otherwise it does not change the
> > pte layout - so it should be easy to adapt any other architecture to this
> > change as well. (this patch does not introduce the protection-bits-in-pte
> > approach used in my previous patch.)
> 
> One question: Why?
> 
> What's wrong with just using the value we use now (0), and just
> calculating the page from the vma/offset information? Why hide the
> offset in the page tables, when there is no need for it?

you mean why in the normal, linear mapping case? No reason, just for
testing. At zap-time we could test whether that pte is linear or not, and
only store it in the swap entry as a file-pte if it's nonlinear.

for swappable sys_file_remap_pages() support it's necessary though, as
they break up the linear mapping without splitting up the vma into
zillions of pieces.

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org">aart@kvack.org</a>
