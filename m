Received: from max.phys.uu.nl (max.phys.uu.nl [131.211.32.73])
	by kvack.org (8.8.7/8.8.7) with ESMTP id PAA22167
	for <linux-mm@kvack.org>; Tue, 24 Nov 1998 15:22:56 -0500
Date: Tue, 24 Nov 1998 20:59:01 +0100 (CET)
From: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Reply-To: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Subject: Re: Linux-2.1.129..
In-Reply-To: <Pine.LNX.3.95.981124092641.10767A-100000@penguin.transmeta.com>
Message-ID: <Pine.LNX.3.96.981124205232.23104B-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@transmeta.com>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, "Eric W. Biederman" <ebiederm+eric@ccr.net>, "Dr. Werner Fink" <werner@suse.de>, Kernel Mailing List <linux-kernel@vger.rutgers.edu>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, 24 Nov 1998, Linus Torvalds wrote:
> On Tue, 24 Nov 1998, Stephen C. Tweedie wrote:

> > > I'd like to see this, although I think it's way too late for 2.2
> > 
> > The mechanism is all there, and we're just tuning policy.  Frankly,
> > the changes we've seen in vm policy since 2.1.125 are pretty major
> > already, and I think it's important to get it right before 2.2.0.
> 
> The VM policy changes weren't stability issues, they were only
> "timing". As such, if they broke something, it was really broken
> before too.

It was quite a bit more than just timing, it shoves the load
more to userland programs and decreases the priority of kswapd,
it removed page aging from swap_out() etc...

IMHO this is hardly any more fundamental than the change Stephen
just proposed.

> And I agree that the mechanism is already there, however as it
> stands we really populate the swap cache at page-in rather than
> page-out, and changing that is fairly fundamental. It would be good,
> no question about it, but it's still fairly fundamental.

But we can easily add some kind of new balancing code later,
wihout having any impact on stability.

2.2 is a _stable_ kernel, not a kernel with unchanging
performance... I think we can go with the new (more stable
because of a larger pool of clean pages around) VM scheme
without impacting stability whatsoever.

> > The patch below is a very simple implementation of this concept.
> 
> I will most probably apply the patch - it just looks fundamentally
> correct. However, what I was thinking of was a bit more ambitious.

>From the discussion we've been having yesterday, I get
the impression that the ambitious stuff can be added
little by little, during the lifetime of 2.2, without
impacting stability or hampering preformance.

It's not going to be as bad as during the 2.1.small days :)

cheers,

Rik -- slowly getting used to dvorak kbd layout...
+-------------------------------------------------------------------+
| Linux memory management tour guide.        H.H.vanRiel@phys.uu.nl |
| Scouting Vries cubscout leader.      http://www.phys.uu.nl/~riel/ |
+-------------------------------------------------------------------+

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
