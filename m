Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 203536B004D
	for <linux-mm@kvack.org>; Mon, 27 Jul 2009 22:55:36 -0400 (EDT)
Subject: Re: [PATCH] mm: Make it easier to catch NULL cache names
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
In-Reply-To: <alpine.LFD.2.01.0907271951390.3186@localhost.localdomain>
References: <1248745735.30993.38.camel@pasglop>
	 <alpine.LFD.2.01.0907271951390.3186@localhost.localdomain>
Content-Type: text/plain
Date: Tue, 28 Jul 2009 12:55:39 +1000
Message-Id: <1248749739.30993.39.camel@pasglop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux Kernel list <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Mon, 2009-07-27 at 19:52 -0700, Linus Torvalds wrote:
> 
> On Tue, 28 Jul 2009, Benjamin Herrenschmidt wrote:
> >
> > Right now, if you inadvertently pass NULL to kmem_cache_create() at boot
> > time, it crashes much later after boot somewhere deep inside sysfs which
> > makes it very non obvious to figure out what's going on.
> 
> Please don't do BUG_ON() when there are alternatives.
> 
> In this case, something like
> 
> 	if (WARN_ON(!name))
> 		return NULL;
> 
> would probably have worked too.

Fair enough..  I'll send a new patch.

Cheers,
Ben.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
