Date: Fri, 12 May 2000 20:37:44 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: pre8: where has the anti-hog code gone?
Message-ID: <Pine.LNX.4.21.0005122031500.28943-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Linus Torvalds <torvalds@transmeta.com>
List-ID: <linux-mm.kvack.org>

Hi Linus,

I'm reading the pre8 code now and I see that the anti-hog
code is gone. I'm still busy developing the active/inactive
list thing, but was just doing a short test with pre8 and
noticed a *sharp* increase in the amount of filesystem IO
when a big memory hog is swapping ...

In addition, I'm seeing smaller processes blocked on disk;
this didn't happen as often when the anti-hog code was still
in and drastically reduces throughput for the memory hog
(who now has to wait in line for disk accesses).

I'm curious ... why was the anti-hog code taken out?

It helps quite a bit on systems which are more or less
low on memory (ie. not your normal working environment,
but common in universities and lots of countries all
around the world).

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
