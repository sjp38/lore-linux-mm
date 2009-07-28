Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id B275A6B004D
	for <linux-mm@kvack.org>; Tue, 28 Jul 2009 03:39:16 -0400 (EDT)
Subject: Re: [PATCH] mm: Make it easier to catch NULL cache names
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
In-Reply-To: <alpine.DEB.2.00.0907272200520.22207@chino.kir.corp.google.com>
References: <1248745735.30993.38.camel@pasglop>
	 <alpine.LFD.2.01.0907271951390.3186@localhost.localdomain>
	 <1248749739.30993.39.camel@pasglop>
	 <alpine.DEB.2.00.0907272200520.22207@chino.kir.corp.google.com>
Content-Type: text/plain
Date: Tue, 28 Jul 2009 17:39:10 +1000
Message-Id: <1248766750.30993.51.camel@pasglop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Linux Kernel list <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Mon, 2009-07-27 at 22:01 -0700, David Rientjes wrote:
> On Tue, 28 Jul 2009, Benjamin Herrenschmidt wrote:
> 
> > > Please don't do BUG_ON() when there are alternatives.
> > > 
> > > In this case, something like
> > > 
> > > 	if (WARN_ON(!name))
> > > 		return NULL;
> > > 
> > > would probably have worked too.
> > 
> > Fair enough..  I'll send a new patch.
> > 
> 
> Actually needs goto err, not return NULL, to appropriately panic when 
> SLAB_PANIC is set.

Rats ! Why is it the trivial ones that are sooo hard :-)

New patch will have to wait til tomorrow, on my way home now.

Cheers,
Ben.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
