Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 5AAC46B005C
	for <linux-mm@kvack.org>; Mon, 20 Jul 2009 06:39:44 -0400 (EDT)
Date: Mon, 20 Jul 2009 12:39:44 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [RFC/PATCH] mm: Pass virtual address to [__]p{te,ud,md}_free_tlb()
Message-ID: <20090720103944.GC7070@wotan.suse.de>
References: <20090715074952.A36C7DDDB2@ozlabs.org> <20090715135620.GD7298@wotan.suse.de> <1248073873.13067.31.camel@pasglop> <20090720080502.GG7298@wotan.suse.de> <1248083961.30899.5.camel@pasglop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1248083961.30899.5.camel@pasglop>
Sender: owner-linux-mm@kvack.org
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Linux Memory Management <linux-mm@kvack.org>, Linux-Arch <linux-arch@vger.kernel.org>, linux-kernel@vger.kernel.org, linuxppc-dev@ozlabs.org, Hugh Dickins <hugh@tiscali.co.uk>, Linus Torvalds <torvalds@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Mon, Jul 20, 2009 at 07:59:21PM +1000, Benjamin Herrenschmidt wrote:
> On Mon, 2009-07-20 at 10:05 +0200, Nick Piggin wrote:
> > 
> > Unless anybody has other preferences, just send it straight to Linus in
> > the next merge window -- if any conflicts did come up anyway they would
> > be trivial. You could just check against linux-next before doing so, and
> > should see if it is going to cause problems for any arch pull...
> 
> Well, the problem is that powerpc-next will need that patch, which means
> that if I don't put it in my tree, Steven won't be able to build
> powerpc-next as part of linux-next until the patch is merged. Hence my
> question, what's the best way to handle that :-) There isn't an mm-next
> is there ? If there was, I could tell Steven to always pull powerpc
> after mm for example. Or I can put it in a git tree of its own with a
> dependency for Steven to pull.

No I don't think there is an mm-next. But Steven will hold individual
patches to correct intermediate issues like this, won't he?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
