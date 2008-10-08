Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e8.ny.us.ibm.com (8.13.1/8.13.1) with ESMTP id m983A2Pm018004
	for <linux-mm@kvack.org>; Tue, 7 Oct 2008 23:10:02 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id m983ClkA252696
	for <linux-mm@kvack.org>; Tue, 7 Oct 2008 23:12:47 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m983Ckhu012787
	for <linux-mm@kvack.org>; Tue, 7 Oct 2008 23:12:47 -0400
Date: Tue, 7 Oct 2008 20:12:45 -0700
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [patch][rfc] ddds: "dynamic dynamic data structure" algorithm,
	for adaptive dcache hash table sizing
Message-ID: <20081008031245.GC7101@linux.vnet.ibm.com>
Reply-To: paulmck@linux.vnet.ibm.com
References: <20081007064834.GA5959@wotan.suse.de> <20081007.140825.40261432.davem@davemloft.net> <20081008024813.GC6499@wotan.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20081008024813.GC6499@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: David Miller <davem@davemloft.net>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-netdev@vger.kernel.org, josh@freedesktop.org
List-ID: <linux-mm.kvack.org>

On Wed, Oct 08, 2008 at 04:48:13AM +0200, Nick Piggin wrote:
> On Tue, Oct 07, 2008 at 02:08:25PM -0700, David Miller wrote:
> > From: Nick Piggin <npiggin@suse.de>
> > Date: Tue, 7 Oct 2008 08:48:34 +0200
> > 
> > > I'm cc'ing netdev because Dave did express some interest in using this for
> > > some networking hashes, and network guys in general are pretty cluey when it
> > > comes to hashes and such ;)
> > 
> > Interesting stuff.
> > 
> > Paul, many months ago, forwarded to me a some work done by Josh
> > Triplett called "rcuhashbash" which had similar objectives.  He did
> > post it to linux-kernel, and perhaps even your ideas are inspired by
> > his work, I don't know. :-)
> 
> Hmm yes I did see that. It's not too similar, as it focuses on re-keying
> an existing element into the same hash table. ddds can't do that kind of
> thing (the underlying data structure isn't visible to the algorithm, so
> it can't exactly modify data structures in-place), although in another
> sense it is more general because the transfer function could transfer
> items into another hash table and re-key them as it goes (if it did that,
> it could probably use Josh's "atomic" re-keying algorithm too).
> 
> But largely it does seem like they are orthogonal (if I'm reading
> rcuhashbash correctly).

IIRC, one of the weaknesses of rcuhashbash was that the elements had
to be copied in some cases.  Josh has been working on a variant that
(hopefully) allows elements to be moved without copying, as is required
by dcache.

							Thanx, Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
