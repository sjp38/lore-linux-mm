Message-ID: <3AE3400B.80B2F1BF@club-internet.fr>
Date: Sun, 22 Apr 2001 22:33:15 +0200
From: Jean Francois Martinez <jfm2@club-internet.fr>
MIME-Version: 1.0
Subject: Re: suspend processes at load (was Re: a simple OOM ...)
References: <l03130312b708cf8a37bf@[192.168.239.105]> <Pine.LNX.4.21.0104221555090.1685-100000@imladris.rielhome.conectiva> <usc6etgvdlapakkeh57lcr8qu5ji7ca142@4ax.com>
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "James A. Sutherland" <jas88@cam.ac.uk>
Cc: Rik van Riel <riel@conectiva.com.br>, Jonathan Morton <chromi@cyberspace.org>, "Joseph A. Knapka" <jknapka@earthlink.net>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

"James A. Sutherland" a ecrit :

> On Sun, 22 Apr 2001 15:57:32 -0300 (BRST), you wrote:
>
> >On Sun, 22 Apr 2001, Jonathan Morton wrote:
> >
> >> I think we're approaching the problem from opposite viewpoints.
> >> Don't get me wrong here - I think process suspension could be a
> >> valuable "feature" under extreme load, but I think that the
> >> working-set idea will perform better and more consistently under "mild
> >> overloads", which the current system handles extremely poorly.
> >
> >Could this mean that we might want _both_ ?
>
> Absolutely, as I said elsewhere.
>
> >1) a minimal guaranteed working set for small processes, so root
> >   can login and large hogs don't penalize good guys
> >   (simpler than the working set idea, should work just as good)
>
> Yep - this will help us under heavy load conditions, when the system
> starts getting "sluggish"...
>
> >2) load control through process suspension when the load gets
> >   too high to handle, this is also good to let the hogs (which
> >   would thrash with the working set idea) make some progress
> >   in turns
>
> Exactly!
>
>

I find this funny because I suggested that idea in 1996 after 2.0 release.
I even gave an example (with an 8 megs box, how time change :-) from
a situation who could be handled only by stopping a process.  That is
two processes who peek 5 Megs of memory in 1 ms (they are scaning
an array).  Since your average disk needs some 20 ms to retrieve a
page that means both processes will spend nearly 100% of time waiting
for pages who have been stolen by the other so the only way is to stop
or swap one of them and let the other run alone for some time.  But at that
time I was told Linux this was feature for high loads and Linux was not
being used there.

BTW this idea has been implemented in mainframes since the 60s.

Another idea in mainframes is that some processes can be swapped out
because you know they will be sleeping for a long time.    The 3270
interface only interacts with the mainframe when user hits the enter key
and in whole screen mode this is when he has filled a whole page of text.
That means that when a process enters keyboard sleep it will probably
remain in that state for  several minutes so in
case MVS needs memory it looks for TSO (interactive) process on keyboard
sleep, swaps them first and ask questions later.
Of course Unix has a differnt UI and I don't see a sleep class where
we can assume programs on it will be sleeping for minutes.


                                    JFM


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
