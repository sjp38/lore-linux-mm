Date: Sun, 21 May 2000 12:17:25 -0700 (PDT)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: Basic testing shows 2.3.99-pre9-3 bad, pre9-2 good
In-Reply-To: <Pine.LNX.4.21.0005211609170.9939-100000@duckman.distro.conectiva>
Message-ID: <Pine.LNX.4.10.10005211215060.1429-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: Lawrence Manning <lawrence@aslak.demon.co.uk>, Linux Kernel <linux-kernel@vger.rutgers.edu>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


On Sun, 21 May 2000, Rik van Riel wrote:

> On Sun, 21 May 2000, Lawrence Manning wrote:
> 
> > That's my observation anyway.  I did some dd and bonnie tests
> > and got abismal results :-( Machine unusable during dd write
> > etc.  pre9-2 on the other hand is close to being as smooth as,
> > say, 2.3.51.  What happened? ;)

What happened was really that I did a partial integration just to make it
easier to synchronize. I wanted to basically have pre9-2 + quintela's
patch, but I had too many emails to go through and too many changes of my
own in this area, so I made pre9-3 available so that others could help me
synchronize.

So on't despair, pre9-3 is definitely just a temporary mix of patches, and
is lacking the balancing that Quintela did. 

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
