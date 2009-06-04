Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 10D326B004D
	for <linux-mm@kvack.org>; Thu,  4 Jun 2009 13:57:14 -0400 (EDT)
Date: Thu, 4 Jun 2009 10:57:01 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch] procfs: provide stack information for threads
Message-Id: <20090604105701.70556a30.akpm@linux-foundation.org>
In-Reply-To: <1244116589.32392.15.camel@wall-e>
References: <1238511505.364.61.camel@matrix>
	<20090401193135.GA12316@elte.hu>
	<1244114628.31230.3.camel@wall-e>
	<20090604043750.e1031e01.akpm@linux-foundation.org>
	<1244116589.32392.15.camel@wall-e>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Stefani Seibold <stefani@seibold.net>
Cc: linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Ingo Molnar <mingo@elte.hu>, Joerg Engel <joern@logfs.org>, Thomas Gleixner <tglx@linutronix.de>
List-ID: <linux-mm.kvack.org>

On Thu, 04 Jun 2009 13:56:29 +0200 Stefani Seibold <stefani@seibold.net> wrote:

> 
> Am Donnerstag, den 04.06.2009, 04:37 -0700 schrieb Andrew Morton:
> > On Thu, 04 Jun 2009 13:23:48 +0200 Stefani Seibold <stefani@seibold.net> wrote:
> > >  - slime done
> > 
> > What's "slime"?
> > 
> 
> Sorry, that was a typo, should be "slim down".

heh, OK.  Good typo.

> > > +	for (i = vma->vm_start; i+PAGE_SIZE <= stkpage; i += PAGE_SIZE) {
> > > +
> > > +		page = follow_page(vma, i, 0);
> > > +
> > > +		if (!IS_ERR(page) && page)
> > 
> > Shouldn't this be !page?
> > 
> 
> No, this is correct... I walk through the top of vma to the first mapped
> page, this is the high water mark of the stack.

Ah, duh, OK.

> > > +					unsigned long stack_start;
> > > +
> > > +					stack_start =
> > > +						((struct proc_maps_private *)
> > > +						m->private)->task->stack_start;
> > 
> > I'd suggested a clearer/cleaner way of implementing this.
> > 
> 
> Sorry, i can not see a problem here. In your last posting you wrote
> thats okay! And i have no idea how to make this expression
> clearer/cleaner.

Add a new intermediate variable:
					unsigned long stack_start;
					struct proc_maps_private *pmp;

					pmp = m->private;
					stack_start = pmp->task->stack_start;


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
