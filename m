Received: from chiara.csoma.elte.hu (chiara.csoma.elte.hu [157.181.71.18])
	by kvack.org (8.8.7/8.8.7) with ESMTP id CAA16823
	for <linux-mm@kvack.org>; Sat, 5 Dec 1998 02:51:34 -0500
Date: Sat, 5 Dec 1998 08:51:13 +0100 (CET)
From: MOLNAR Ingo <mingo@chiara.csoma.elte.hu>
Subject: Re: SWAP: Linux far behind Solaris or I missed something (fwd)
In-Reply-To: <Pine.LNX.3.96.981204162132.21578A-100000@mirkwood.dummy.home>
Message-ID: <Pine.LNX.3.96.981205083722.23557B-100000@chiara.csoma.elte.hu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, Neil Conway <nconway.list@ukaea.org.uk>, Linux MM <linux-mm@kvack.org>, Jean-Michel.Vansteene@bull.net, "linux-kernel@vger.rutgers.edu" <linux-kernel@vger.rutgers.edu>
List-ID: <linux-mm.kvack.org>


On Fri, 4 Dec 1998, Rik van Riel wrote:

> > I know.  That's why relying on fixed margins to ensure good
> > performance is wrong: the system really ought to be self-tuning.
> > We may yet get it right for 2.2: there are people working on this.
> 
> It appears that 2.1.130 + my little patches only needs the
> borrow percentage (otherwise kswapd doesn't have enough
> reason to switch from the always-succesful swap_out()),
> and that only needs to be set to a high value...

'borrow percentage' is just yet another arbitrary parameter (*). The
solution is not to increase the number of parameters and tweak them until
there is more or less ok fit on all testcases! (i know that borrow
percentage was there originally) The task is to _decrease_ the number of
parameters as much as possible. (preferably no 'number' parameters at all,
just one basic self-tuning framework) [Unfortunately this is much much
harder than adding parameters, it needs a thorough understanding of all
issues involved.]

-- mingo

(*) parameter: degree of freedom in an algorithm, both kernel-source
    compiled-in constants/tweaks/rules and user-supplied (possibly
    runtime) parameters.

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
