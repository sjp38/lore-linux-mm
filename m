Date: Thu, 11 May 2000 08:15:37 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: [PATCH] Recent VM fiasco - fixed
In-Reply-To: <20000510215301.A322@stormix.com>
Message-ID: <Pine.LNX.4.21.0005110808520.6894-100000@duckman.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; CHARSET=US-ASCII
Content-ID: <Pine.LNX.4.21.0005110808522.6894@duckman.conectiva>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Simon Kirby <sim@stormix.com>
Cc: Linus Torvalds <torvalds@transmeta.com>, linux-mm@kvack.org, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

On Wed, 10 May 2000, Simon Kirby wrote:

> Is Andrea taking a too dangerous approach for the current kernel
> version, or are you trying to get something extremely simple
> working instead?

You may want to read his patch before saying it does any good.

There probably are some good bits in the classzone patch, but
it also backs out bugfixes for bugs which have been proven to
exist and fixed by those fixes. ;(

It would be nice if Andrea could separate the good bits from
the bad bits and make a somewhat cleaner patch...

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
