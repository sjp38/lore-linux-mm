Date: Mon, 25 Sep 2000 10:47:07 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: test9-pre5+t9p2-vmpatch VM deadlock during write-intensive
 workload
In-Reply-To: <Pine.LNX.4.10.10009221037560.1647-100000@penguin.transmeta.com>
Message-ID: <Pine.LNX.4.21.0009251040270.14614-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: Molnar Ingo <mingo@debella.ikk.sztaki.hu>, "David S. Miller" <davem@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 22 Sep 2000, Linus Torvalds wrote:
> On Fri, 22 Sep 2000, Molnar Ingo wrote:
> > 
> > i'm still getting VM related lockups during heavy write load, in
> > test9-pre5 + your 2.4.0-t9p2-vmpatch (which i understand as being your
> > last VM related fix-patch, correct?). Here is a histogram of such a
> > lockup:
> 
>  those VM patches are going away RSN if these issues do not get
> fixed. I'm really disappointed, and suspect that it would be
> easier to go back to the old VM with just page aging added, not
> your new code that seems to be full of deadlocks everywhere.

I've been away on a conference last week, so I haven't
had much chance to take a look at the code after you
integrated it and the test base got increased ;(

One thing I discovered are some UP-only deadlocks and
the page ping-pong thing, which I am fixing right now.

If I had a choice, I'd have chosen /next/ week as the
time to integrate the code ... doing this while I'm 
away at a conference was really inconvenient ;)

I'm looking into the email backlog and the bug reports
right now (today, tuesday and wednesday I'm at /another/
conferenc and thursday will be the next opportunity).

It looks like ther are no fundamental issues left, just
a bunch of small thinkos that can be fixed in a (few?)
week(s).

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
