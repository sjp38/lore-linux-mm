Date: Wed, 16 Aug 2000 16:09:30 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: new vm - OK but not THAT great
In-Reply-To: <399AD517.656E4279@ucla.edu>
Message-ID: <Pine.LNX.4.21.0008161549370.6164-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Benjamin Redelings <bredelin@ucla.edu>
Cc: linux-mm@kvack.org, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

On Wed, 16 Aug 2000, Benjamin Redelings wrote:

> 	I tested Rik's latest, tuned, VM code on my machine at home.  Sorry
> this isn't more detailed - I have to do some comparisons later.

> 	However, I DO notice some problems: when I run netscape
> and a few other apps, performance is OK, but when I then run
> 'tar -xf linux-2.4.0-pre4.tar' preformance drops.

Indeed, I've seen this here as well. I have some ideas on
fixing this and once I figure out all the details I'll
implement and tune them.

(but first, I have to fix the SMP bug where __alloc_pages
hands out a page that has one of the PG_(in)active_* bits
set...)

> 	Secondly, programs like xfs, which are NOT RUNNING AT ALL,
> do not get swapped out as much as vanilla pre7-4.
> 	So, the page aging code does not appear to be helping as
> much as it should.  Swapping seems, in some sense, to not as
> good as pre7-4...

This is also something which needs to be tuned more. Remember
that you're working with a VM patch that received only about
4 hours of tuning ;)

I hope any of the other VM hackers will use the quiet period
around the vger problems to help tune this VM patch a bit ;)

regards,

Rik
--
"What you're running that piece of shit Gnome?!?!"
       -- Miguel de Icaza, UKUUG 2000

http://www.conectiva.com/		http://www.surriel.com/


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
