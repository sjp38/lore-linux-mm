Date: Tue, 9 May 2000 07:21:05 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: [PATCH] Recent VM fiasco - fixed
In-Reply-To: <Pine.LNX.4.21.0005090254360.12487-100000@ductape.net>
Message-ID: <Pine.LNX.4.21.0005090720260.25637-100000@duckman.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Daniel Stone <tamriel@ductape.net>
Cc: Zlatko Calusic <zlatko@iskon.hr>, linux-mm@kvack.org, linux-kernel@vger.rutgers.edu, Linus Torvalds <torvalds@transmeta.com>
List-ID: <linux-mm.kvack.org>

On Tue, 9 May 2000, Daniel Stone wrote:

> That's astonishing, I'm sure, but think of us poor bastards who
> DON'T have an SMP machine with >1gig of RAM.
> 
> This is a P120, 32meg.

The old zoned VM code will run that machine as efficiently
as if it had 16MB of ram. See my point now?

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
