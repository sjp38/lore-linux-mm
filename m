Date: Sun, 21 May 2000 16:11:21 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: Basic testing shows 2.3.99-pre9-3 bad, pre9-2 good
In-Reply-To: <Pine.LNX.4.10.10005211837310.627-100000@aslak.demon.co.uk>
Message-ID: <Pine.LNX.4.21.0005211609170.9939-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lawrence Manning <lawrence@aslak.demon.co.uk>
Cc: Linux Kernel <linux-kernel@vger.rutgers.edu>, linux-mm@kvack.org, Linus Torvalds <torvalds@transmeta.com>
List-ID: <linux-mm.kvack.org>

On Sun, 21 May 2000, Lawrence Manning wrote:

> That's my observation anyway.  I did some dd and bonnie tests
> and got abismal results :-( Machine unusable during dd write
> etc.  pre9-2 on the other hand is close to being as smooth as,
> say, 2.3.51.  What happened? ;)

OK, I guess this means shrink_mmap() should not wait on
*every* locked buffer it runs into ;)

This will destroy both latency (we end up waiting for a
*lot* of buffers) and throughput (waiting on buffers could
interfere with request sorting if we're unlucky).

> I also should chip in to say that 2.2.15 is abit sick IO wise
> for me too.

I'm working on it :)

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
