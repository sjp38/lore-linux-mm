Date: Sun, 19 Aug 2001 03:00:42 +0200
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: resend Re: [PATCH] final merging patch -- significant mozilla speedup.
Message-ID: <20010819030042.T1719@athlon.random>
References: <20010819023548.P1719@athlon.random> <Pine.LNX.4.33L.0108182152410.5646-100000@imladris.rielhome.conectiva>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.33L.0108182152410.5646-100000@imladris.rielhome.conectiva>; from riel@conectiva.com.br on Sat, Aug 18, 2001 at 09:54:21PM -0300
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: Ben LaHaise <bcrl@redhat.com>, torvalds@transmeta.com, alan@redhat.com, linux-mm@kvack.org, Chris Blizzard <blizzard@redhat.com>
List-ID: <linux-mm.kvack.org>

On Sat, Aug 18, 2001 at 09:54:21PM -0300, Rik van Riel wrote:
> On Sun, 19 Aug 2001, Andrea Arcangeli wrote:
> > On Sat, Aug 18, 2001 at 08:10:50PM -0400, Ben LaHaise wrote:
> 
> > > trees to see what kind of an effect it has on performance compared to the
> > > avl tree?
> >
> > I posted some benchmark result a few minutes ago (the numbers says
> > there were no implementation bugs).
> 
> Oh, and now that I think about this ... ;)
> 
> Your numbers show better insert/removal behaviour, but
> isn't LOOKUP the common thing done with the VMAs in the
> tree ?

Every single mmap is doing 1 lookups (and 1 inserction). So it's doing a
flood of lookups as well.

> Doesn't an rb tree give longer lookup paths or is this
> something which should balance out in the real world?

The math complexity of the lookup remains O(lon(N)) and that is the only
thing that matters in the real world as far I can tell.

Andrea
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
