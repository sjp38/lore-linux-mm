Received: from max.phys.uu.nl (max.phys.uu.nl [131.211.32.73])
	by kvack.org (8.8.7/8.8.7) with ESMTP id LAA12565
	for <linux-mm@kvack.org>; Fri, 4 Dec 1998 11:51:58 -0500
Date: Fri, 4 Dec 1998 16:23:44 +0100 (CET)
From: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Reply-To: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Subject: Re: SWAP: Linux far behind Solaris or I missed something (fwd)
In-Reply-To: <199812041449.OAA04573@dax.scot.redhat.com>
Message-ID: <Pine.LNX.3.96.981204162132.21578A-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: Neil Conway <nconway.list@ukaea.org.uk>, Linux MM <linux-mm@kvack.org>, Jean-Michel.Vansteene@bull.net, "linux-kernel@vger.rutgers.edu" <linux-kernel@vger.rutgers.edu>
List-ID: <linux-mm.kvack.org>

On Fri, 4 Dec 1998, Stephen C. Tweedie wrote:
> On Fri, 4 Dec 1998 10:41:15 +0000, Neil Conway
> <nconway.list@ukaea.org.uk> said:
> 
> >> (although the 2.1.130+my patch seems to work very well
> >> with extremely high swap throughput)
> 
> > Since the poster didn't say otherwise, perhaps this test was performed
> > with buffermem/pagecache.min_percent set to their default values, which
> > IIRC add up to 13% of physical RAM (in fact that's PHYSICAL ram, not 13%
> 
> I know.  That's why relying on fixed margins to ensure good
> performance is wrong: the system really ought to be self-tuning.
> We may yet get it right for 2.2: there are people working on this.

It appears that 2.1.130 + my little patches only needs the
borrow percentage (otherwise kswapd doesn't have enough
reason to switch from the always-succesful swap_out()),
and that only needs to be set to a high value...
(ie. /not/ the braindead values that went into 2.1.131)

cheers,

Rik -- the flu hits, the flu hits, the flu hits -- MORE
+-------------------------------------------------------------------+
| Linux memory management tour guide.        H.H.vanRiel@phys.uu.nl |
| Scouting Vries cubscout leader.      http://www.phys.uu.nl/~riel/ |
+-------------------------------------------------------------------+

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
