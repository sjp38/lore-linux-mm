Received: from max.fys.ruu.nl (max.fys.ruu.nl [131.211.32.73])
	by kvack.org (8.8.7/8.8.7) with ESMTP id CAA14051
	for <linux-mm@kvack.org>; Sat, 13 Jun 1998 02:45:51 -0400
Date: Sat, 13 Jun 1998 08:36:52 +0200 (MET DST)
From: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Reply-To: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Subject: Re: TODO list, v0.01
In-Reply-To: <19980613020130.B412@uni-koblenz.de>
Message-ID: <Pine.LNX.3.95.980613083323.3680C-100000@localhost>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: ralf@uni-koblenz.de
Cc: "Stephen C. Tweedie" <sct@dcs.ed.ac.uk>, Linux MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Sat, 13 Jun 1998 ralf@uni-koblenz.de wrote:
> On Thu, Jun 11, 1998 at 11:59:45PM +0200, Rik van Riel wrote:
> 
> > Benjamin C.R. LaHaise <blah@kvack.org>
> > 	Reverse PTE lookup (together with Stephen Tweedie).
> > 
> > Stephen C. Tweedie
> > 	Reverse PTE lookup (together with Benjamin C.R. LaHaise).
> 
> The reverse pte lookup, is this stuff for 2.2?  In the meantime I came to
> the conclusion that the only sane way to fix the virtual cache problems
> on MIPS, so from my point of view this is a must for 2.2.

I don't think Linus will let it in before 2.2 :(

Therefor, our only option would be to work closely
together and push one huge new VM subsystem at Linus
when he's least suspected :)

And if we can't convince him to put it in 2.2, we
should just push for a really short-cycle 2.3...

Oh, if we _do_ want to do this, we'll have to
cooperate more closely and keep each other up to
date on what we're busy with.
As soon as I've installed Stampede Linux and the
devel kernel again, I'll be updating my MM page
at least once a week again...

Rik.
+-------------------------------------------------------------------+
| Linux memory management tour guide.        H.H.vanRiel@phys.uu.nl |
| Scouting Vries cubscout leader.      http://www.phys.uu.nl/~riel/ |
+-------------------------------------------------------------------+
