Date: Tue, 9 Dec 1997 18:53:21 +0100 (MET)
From: Rik van Riel <H.H.vanRiel@fys.ruu.nl>
Reply-To: H.H.vanRiel@fys.ruu.nl
Subject: Re: Ideas for memory management hackers.
In-Reply-To: <Pine.LNX.3.95.971209124434.11334C-100000@as200.spellcast.com>
Message-ID: <Pine.LNX.3.91.971209185056.8620A-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: "Benjamin C.R. LaHaise" <blah@kvack.org>
Cc: Stephen Thomas <stephen.thomas@insignia.co.uk>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, 9 Dec 1997, Benjamin C.R. LaHaise wrote:

> ...
> > I think I'll send it to Linus (together with Zlatko's
> > big-order hack) as a bug-fix (we're on feature-freeze after all:)
> > for inclusion in 2.1.72...
> 
> Hrmpf - what is Zlatko's big-order hack?

You can (at least) get it from my homepage at 
http://www.fys.ruu.nl/~riel, and maybe from Zlatko's
homepage (if he has one).

It is a patch that makes sure that there are at least
min_free_pages/2 pages in 4-page chunks available...
This way kernel functions (network, soundcard) can always
allocate (at least) 16kb chunks of memory. This solves
quite some crashes...

Rik.

--
Send Linux memory-management wishes to me: I'm currently looking
for something to hack...
