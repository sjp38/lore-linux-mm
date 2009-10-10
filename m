Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 663836B004D
	for <linux-mm@kvack.org>; Sat, 10 Oct 2009 17:10:33 -0400 (EDT)
Date: Sat, 10 Oct 2009 23:10:24 +0200
From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [PATCH 00/31] Swap over NFS -v20
Message-ID: <20091010211024.GB14051@elf.ucw.cz>
References: <1254405858-15651-1-git-send-email-sjayaraman@suse.de>
 <20091001174201.GA30068@infradead.org>
 <1254692482.21044.15.camel@laptop>
 <20091010120614.GC1811@ucw.cz>
 <1255177421.11081.0.camel@twins>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1255177421.11081.0.camel@twins>
Sender: owner-linux-mm@kvack.org
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Christoph Hellwig <hch@infradead.org>, Suresh Jayaraman <sjayaraman@suse.de>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org, Neil Brown <neilb@suse.de>, Miklos Szeredi <mszeredi@suse.cz>, Wouter Verhelst <w@uter.be>, trond.myklebust@fys.uio.no
List-ID: <linux-mm.kvack.org>

On Sat 2009-10-10 14:23:41, Peter Zijlstra wrote:
> On Sat, 2009-10-10 at 14:06 +0200, Pavel Machek wrote:
> > Hi!
> > 
> > > > One of them
> > > > would be the whole VM/net work to just make swap over nbd/iscsi safe.
> > > 
> > > Getting those two 'fixed' is going to be tons of interesting work
> > > because they involve interaction with userspace daemons.
> > > 
> > > NBD has fairly simple userspace, but iSCSI has a rather large userspace
> > > footprint and a rather complicated user/kernel interaction which will be
> > > mighty interesting to get allocation safe.
> > > 
> > > Ideally the swap-over-$foo bits have no userspace component.
> > > 
> > > That said, Wouter is the NBD userspace maintainer and has expressed
> > > interest into looking at making that work, but its sure going to be
> > > non-trivial, esp. since exposing PF_MEMALLOC to userspace is a, not over
> > > my dead-bodym like thing.
> > 
> > Well, as long as nbd-server is on separate machine (with real swap),
> > safe swapping over network should be ok, without PF_MEMALLOC for
> > userspace or similar nightmares, right?
> 
> Nope, as soon as the nbd-client looses its connection you're up shit
> creek.

Oops, right. Putting reconnect logic into the kernel would make sense.

I misunderstood your proposal. I thought you'd want to put
nbd-_server_ into the kernel too. I guess we violently agree that
that's unneccessary.
									Pavel
-- 
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blog.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
