Date: Sun, 14 May 2000 18:37:28 -0700 (PDT)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: pre8: where has the anti-hog code gone?
In-Reply-To: <Pine.LNX.4.05.10005141023530.2330-100000@fenrus.demon.nl>
Message-ID: <Pine.LNX.4.10.10005141834450.3158-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Arjan van de Ven <arjan@fenrus.demon.nl>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


On Sun, 14 May 2000, Arjan van de Ven wrote:
> 
> > How does it feel performance-wise?
> 
> This is a bit hard to say, as my testbox is headless. However, I started
> Netscape on it (over a 100Mbit network) and did a "make -j2 bzImage" at
> the same time. Netscape didn't seem to suffer, but there was usually about
> 30 megabytes[1] ram free (according to "top"), so maybe it is to agressive
> in freeing memory.

No, it's probably not too aggressive in freeing up memory, it's just that
a kernel make is a very "wellbehaved" benchmark MM-wise.

Why? Because the kernel make will start up a lot of processes that are
short-lived in comparison to the whole build (I bet this is the first time
anybody called gcc "short-lived" - it's one slow compiler - but
comparatiely it is).

So the kernel make will actually keep noticeable amounts of memory free
"on average", simply because of processes exiting..

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
