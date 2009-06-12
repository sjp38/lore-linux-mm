Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id ED0AD6B0055
	for <linux-mm@kvack.org>; Fri, 12 Jun 2009 05:47:50 -0400 (EDT)
Date: Fri, 12 Jun 2009 11:49:19 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: slab: setup allocators earlier in the boot sequence
Message-ID: <20090612094918.GH24044@wotan.suse.de>
References: <20090612075427.GA24044@wotan.suse.de> <1244793592.30512.17.camel@penberg-laptop> <20090612080236.GB24044@wotan.suse.de> <1244793879.30512.19.camel@penberg-laptop> <1244796291.7172.87.camel@pasglop> <84144f020906120149k6cbe5177vef1944d9d216e8b2@mail.gmail.com> <20090612091304.GE24044@wotan.suse.de> <1244798660.7172.102.camel@pasglop> <20090612093046.GG24044@wotan.suse.de> <1244799865.7172.112.camel@pasglop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1244799865.7172.112.camel@pasglop>
Sender: owner-linux-mm@kvack.org
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Linus Torvalds <torvalds@linux-foundation.org>, Linux Kernel list <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, mingo@elte.hu, cl@linux-foundation.org, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Fri, Jun 12, 2009 at 07:44:25PM +1000, Benjamin Herrenschmidt wrote:
> On Fri, 2009-06-12 at 11:30 +0200, Nick Piggin wrote:
> > On Fri, Jun 12, 2009 at 07:24:20PM +1000, Benjamin Herrenschmidt wrote:
> > Yeah but it doesn't do it in the page allocator so it isn't
> > really useful as a general allocator flags tweak. ATM it only
> > helps this case of slab allocator hackery.
> 
> I though I did it in page_alloc.c too but I'm happy to be told what I
> missed :-) The intend is certainly do have a general allocator flag
> tweak.

Oh, no I missed that sorry you did. I'd be a bit worried about
wanting it as a general allocator tweak. Even suspending IO
for suspend/resume... it would be better to try solving that
ordering by design and if not then perhaps add something
to mm/vmscan.c rather than modify gfp flags all the way
down.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
