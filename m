Date: Thu, 18 May 2000 10:41:05 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: PATCH: Possible solution to VM problems (take 2)
In-Reply-To: <20000518125921.A1570@gondor.com>
Message-ID: <Pine.LNX.4.21.0005181038230.14198-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jan Niehusmann <jan@gondor.com>
Cc: Craig Kulesa <ckulesa@loke.as.arizona.edu>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 18 May 2000, Jan Niehusmann wrote:
> On Thu, May 18, 2000 at 03:17:25AM -0700, Craig Kulesa wrote:
> > A stubborn problem that remains is the behavior when lots of
> > dirty pages pile up quickly.  Doing a giant 'dd' from /dev/zero to a
> > file on disk still causes gaps of unresponsiveness.  Here's a short vmstat
> > session on a 128 MB PIII system performing a 'dd if=/dev/zero of=dummy.dat
> > bs=1024k count=256':
> 
> While 'dd if=/dev/zero of=file' can, of course, generate dirty pages at
> an insane rate, I see the same unresponsiveness when doing cp -a from 
> one filesystem to another. (and even from a slow harddisk to a faster one).

I think I have this mostly figured out. I'll work on
making some small improvements over Quintela's patch
that will make the system behave decently in this
situation too.

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
