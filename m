Date: Sun, 11 Jun 2000 15:20:24 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: Linux crash, probably memory-problem on Alladin V
In-Reply-To: <00061119335700.01115@Poseidon.OPCO.de>
Message-ID: <Pine.LNX.4.21.0006111513000.16932-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dieter Schuster <didischuster@gmx.de>
Cc: linux-kernel@vger.rutgers.edu, Alan.Cox@linux.org, Linus Torvalds <torvalds@transmeta.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, 11 Jun 2000, Dieter Schuster wrote:

> I tried to compile (make -j zImage) linux-2.2.16 and the
> folowing message appears in /var/log/message:
> 
> Poseidon kernel: Whoops: end_buffer_io_async: async io complete
> on unlocked page
> Poseidon last message repeated 47 times
> Poseidon exiting on signal 15

Hummm, that doesn't look good...

Somebody unlocking a page when IO on its buffers is going
on, is this actually something allowed in 2.2 or??

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
