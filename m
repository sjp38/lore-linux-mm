In-reply-to: <20070326234957.6b287dda.akpm@linux-foundation.org> (message from
	Andrew Morton on Mon, 26 Mar 2007 23:49:57 -0800)
Subject: Re: [patch resend v4] update ctime and mtime for mmaped write
References: <E1HVZyn-0008T8-00@dorka.pomaz.szeredi.hu>
	<20070326140036.f3352f81.akpm@linux-foundation.org>
	<E1HVwy4-0002UD-00@dorka.pomaz.szeredi.hu>
	<20070326153153.817b6a82.akpm@linux-foundation.org>
	<E1HW5am-0003Mc-00@dorka.pomaz.szeredi.hu>
	<20070326232214.ee92d8c4.akpm@linux-foundation.org>
	<E1HW6Ec-0003Tv-00@dorka.pomaz.szeredi.hu> <20070326234957.6b287dda.akpm@linux-foundation.org>
Message-Id: <E1HW6eb-0003WX-00@dorka.pomaz.szeredi.hu>
From: Miklos Szeredi <miklos@szeredi.hu>
Date: Tue, 27 Mar 2007 10:03:41 +0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: a.p.zijlstra@chello.nl, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> > > There is surely no need to duplicate all that.
> > 
> > Yeah, we could teach generic_writepages() to conditionally not submit
> > for io just test/clear pte dirtyness.
> > 
> > Maybe that would be somewhat cleaner, dunno.
> > 
> > Then there are the ram backed filesystems, which don't have dirty
> > accounting and radix trees, and for which this pte walking is still
> > needed to provide semantics consistent with normal filesystems.
> 
> hm.
> 
> I don't know how important all this is, really - we've had this bug for
> ever and presumably we've already trained everyone to work around it.
> 
> What usage scenarios are people actually hurting from?  Is there anything
> interesting in the mysterious Novell Bugzilla #206431?

That's just a failing LTP testcase, not quite real life ;)

But Peter Staubach says a RH custumer has files written thorugh mmap,
which are not being backed up.

> Perhaps we can get away with doing something half-assed which covers most
> requirements...

OK.  At least I can split the patch into two half asses.

The big question is tmpfs and friends.  Those won't get any timestamp
update without additional page table walking.

Miklos

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
