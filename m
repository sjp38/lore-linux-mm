Date: Fri, 5 May 2000 07:23:15 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Reply-To: riel@nl.linux.org
Subject: Re: 7-4 VM killing (A solution)
In-Reply-To: <Pine.LNX.4.10.10005042348560.870-100000@penguin.transmeta.com>
Message-ID: <Pine.LNX.4.21.0005050722140.30843-100000@duckman.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: Rajagopal Ananthanarayanan <ananth@sgi.com>, Kanoj Sarcar <kanoj@google.engr.sgi.com>, linux-mm@kvack.org, "David S. Miller" <davem@redhat.com>
List-ID: <linux-mm.kvack.org>

On Thu, 4 May 2000, Linus Torvalds wrote:
> On Thu, 4 May 2000, Rajagopal Ananthanarayanan wrote:
> > On another note, noticed your change to shrink_mmap in 7-5:
> > 
> > -------
> > -       count = nr_lru_pages >> priority;
> > +       count = (nr_lru_pages << 1) >> priority;
> > -------
> > 
> > Is this to defeat aging? If so, I think its overly cautious:
> > if all an iteration of shrink_mmap did was to flip the referenced bit,
> > then that iteration shouldn't be included in count (and in the
> > current code it isn't). So why double the effort?
> 
> It was indeed because I thought we should defeat aging. But
> you're right, the reference bit flip doesn't get counted.

Also, we'll be holding the pages on our local &young list, so
we won't be able to see them again (but that's ok since the
next call to shrink_mmap() can easily free them all).

regards,

Rik
--
The Internet is not a network of computers. It is a network
of people. That is its real strength.

Wanna talk about the kernel?  irc.openprojects.net / #kernelnewbies
http://www.conectiva.com/		http://www.surriel.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
