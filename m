Date: Sun, 20 May 2001 05:29:49 +0200 (CEST)
From: Mike Galbraith <mikeg@wen-online.de>
Subject: Re: [RFC][PATCH] Re: Linux 2.4.4-ac10
In-Reply-To: <Pine.LNX.4.21.0105191840250.5531-100000@imladris.rielhome.conectiva>
Message-ID: <Pine.LNX.4.33.0105200509130.488-100000@mikeg.weiden.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, Ingo Oeser <ingo.oeser@informatik.tu-chemnitz.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, 19 May 2001, Rik van Riel wrote:

> On Sat, 19 May 2001, Mike Galbraith wrote:
> > On Fri, 18 May 2001, Stephen C. Tweedie wrote:
> >
> > > That's the main problem with static parameters.  The problem you are
> > > trying to solve is fundamentally dynamic in most cases (which is also
> > > why magic numbers tend to suck in the VM.)
> >
> > Magic numbers might be sucking some performance right now ;-)
>
> ... so you replace them with some others ... ;)

I reused one of our base numbers to classify the severity of the
situation.. not the same as inventing new ones.  (well, not quite
the same anyway.. half did come from the south fourty;)

> > Three back to back make -j 30 runs for three different kernels.
> > Swap cache numbers are taken immediately after last completion.
>
> The performance increase is nice, though.  Do you see similar
> changes in different kinds of workloads ?

I don't have much to test with here, but I'll see if I can find
something. I'd rather see someone with a server load try it.

> > (yes, the last hunk looks out of place wrt my text.
>
> It also looks kind of bogus and geared completely towards this
> particular workload ;)

I'm not sure why that helps.  I didn't put it in as a trick or
anything though.  I put it in because it didn't seem like a
good idea to ever have more cleaned pages than free pages at a
time when we're yammering for help.. so I did that and it helped.

	-Mike

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
