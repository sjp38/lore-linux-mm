Date: Thu, 24 May 2001 16:23:32 +0200 (CEST)
From: Mike Galbraith <mikeg@wen-online.de>
Subject: Re: [RFC][PATCH] Re: Linux 2.4.4-ac10
In-Reply-To: <Pine.LNX.4.33.0105240800020.10469-100000@duckman.distro.conectiva>
Message-ID: <Pine.LNX.4.33.0105241557160.894-100000@mikeg.weiden.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, Ingo Oeser <ingo.oeser@informatik.tu-chemnitz.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 24 May 2001, Rik van Riel wrote:

> > > > OK.. let's forget about throughput for a moment and consider
> > > > those annoying reports of 0 order allocations failing :)
> > >
> > > Those are ok.  All failing 0 order allocations are either
> > > atomic allocations or GFP_BUFFER allocations.  I guess we
> > > should just remove the printk()  ;)
> >
> > Hmm.  The guy who's box locks up on him after a burst of these
> > probably doesn't think these failures are very OK ;-)  I don't
> > think order 0 failing is cool at all.. ever.
>
> You may not think it's cool, but it's needed in order to
> prevent deadlocks. Just because an allocation cannot do
> disk IO or sleep, that's no reason to loop around like
> crazy in __alloc_pages() and hang the machine ... ;)

True, but if we have resources available there's no excuse for a
failure.  Well, yes there is.  If the cost of that resource is
higher than the value of letting the allocation succeed.  We have
no data on the value of success, but we do plan on consuming the
reclaimable pool and do that (must), so I still think turning
these resources loose at strategic moments is logically sound.
(doesn't mean there's not a better way.. it's just an easy way)

I'd really like someone who has this problem to try the patch to
see if it does help.  I don't have this darn problem myself, so
I'm left holding a bag of idle curiosity. ;-)

	Cheers,

	-Mike

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
