Received: from frodo.biederman.org (IDENT:root@frodo [10.0.0.2])
	by flinx.biederman.org (8.9.3/8.9.3) with ESMTP id JAA21184
	for <linux-mm@kvack.org>; Tue, 30 Jan 2001 09:17:18 -0700
Subject: Re: [PATCH] guard mm->rss with page_table_lock (241p11)
References: <Pine.LNX.4.10.10101300929380.29461-100000@coffee.psychology.mcmaster.ca>
From: ebiederm@xmission.com (Eric W. Biederman)
Date: 30 Jan 2001 08:30:10 -0700
In-Reply-To: Mark Hahn's message of "Tue, 30 Jan 2001 09:32:11 -0500 (EST)"
Message-ID: <m1k87dcb25.fsf@frodo.biederman.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Mark Hahn <hahn@coffee.psychology.mcmaster.ca> writes:

> > > > +	spin_lock(&mm->page_table_lock);
> > > >  	mm->rss++;
> > > > +	spin_unlock(&mm->page_table_lock);
> > > >...
> > > 
> > > Would it not be better to use some sort of atomic add/subtract/clear
> operation
> 
> > > rather than a spinlock? (Which would also give you fewer atomic memory
> access
> 
> > > cycles).
> > 
> > This will unfortunately not do for all platforms. Please read
> > http://marc.theaimsgroup.com/?t=97630768100003&w=2&r=1 for the
> > last discussion of this.
> 
> which can be summarized as "yet another way sparc support screws Linux,
> and DMiller didn't want to fix his mess close to 2.4.0".  it's ridiculous
> for an inconsequential arch like sparc32 to cause fairly noticable problems
> for all other arches.
> 
> if noone beats me, I'll be submitting a patch to fix this silliness in 2.5.

The thing is we need a spinlock to actually change the page tables to
change the rss.  We pretty much get the accounting of rss under the
same spinlock for free.

Eric
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
