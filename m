Date: Thu, 26 Feb 1998 00:43:55 -0500 (U)
From: "Benjamin C.R. LaHaise" <blah@kvack.org>
Subject: Re: memory fragmentation / pte-list
In-Reply-To: <Pine.LNX.3.91.980225232238.1846A-100000@mirkwood.dummy.home>
Message-ID: <Pine.LNX.3.95.980226003625.29543A-100000@as200.spellcast.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <H.H.vanRiel@fys.ruu.nl>
Cc: "Stephen C. Tweedie" <sct@dcs.ed.ac.uk>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, 25 Feb 1998, Rik van Riel wrote:

> Hi Ben (and Stephen),
> 
> Since memory defragmentation is rather high on my list,
> I wonder how far Ben's patch is from integration in the
> kernel...

Right now I'm hoping to have a mid-alpha version by the end of the weekend
(mid-alpha == my machine runs with it, so other people should be able to
test it).  Right now I'm just trying to get everything done (at least I
know what I need to write and how... ;-). 

		-ben (who's finally realized *just* how bad a big kernel
spinlock is)
