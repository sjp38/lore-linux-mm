Received: by py-out-1112.google.com with SMTP id d32so2298502pye
        for <linux-mm@kvack.org>; Fri, 07 Sep 2007 22:12:25 -0700 (PDT)
Message-ID: <170fa0d20709072212m4563ce76sa83092640491e4f3@mail.gmail.com>
Date: Sat, 8 Sep 2007 01:12:24 -0400
From: "Mike Snitzer" <snitzer@gmail.com>
Subject: Re: [RFC 0/3] Recursive reclaim (on __PF_MEMALLOC)
In-Reply-To: <200709050916.04477.phillips@phunq.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20070814142103.204771292@sgi.com>
	 <200709050220.53801.phillips@phunq.net>
	 <Pine.LNX.4.64.0709050334020.8127@schroedinger.engr.sgi.com>
	 <200709050916.04477.phillips@phunq.net>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Daniel Phillips <phillips@phunq.net>
Cc: Christoph Lameter <clameter@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, dkegel@google.com, Peter Zijlstra <a.p.zijlstra@chello.nl>, David Miller <davem@davemloft.net>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

On 9/5/07, Daniel Phillips <phillips@phunq.net> wrote:
> On Wednesday 05 September 2007 03:42, Christoph Lameter wrote:
> > On Wed, 5 Sep 2007, Daniel Phillips wrote:
> > > If we remove our anti-deadlock measures, including the
> > > ddsnap.vm.fixes (a roll-up of Peter's patch set) and the request
> > > throttling code in dm-ddsnap.c, and apply your patch set instead,
> > > we hit deadlock on the socket write path after a few hours
> > > (traceback tomorrow).  So your patch set by itself is a stability
> > > regression.
> >
> > Na, that cannot be the case since it only activates when an OOM
> > condition would otherwise result.
>
> I did not express myself clearly then.  Compared to our current
> anti-deadlock patch set, you patch set is a regression.  Because
> without help from some of our other patches, it does deadlock.
> Obviously, we cannot have that.

Can you be specific about which changes to existing mainline code were
needed to make recursive reclaim "work" in your tests (albeit less
ideally than peterz's patchset in your view)?

Also, in a previous post you stated:

>   Just to recap, we have identified two essential ingredients in the
> recipe for writeout deadlock prevention:
>
>  1) Throttle block IO traffic to a bounded maximum memory use.
>
>  2) Guarantee availability of the required amount of memory.

Which changes allowed you to address 1?  I had a look at the various
patches you provided (via svn) and it wasn't clear which subset
fulfilled 1 for you.  Does it work for all Block IO and not just
specially tuned drivers like ddsnap et al?

regards,
Mike

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
