Message-ID: <3ABCF038.B3162B8B@uow.edu.au>
Date: Sun, 25 Mar 2001 05:06:32 +1000
From: Andrew Morton <andrewm@uow.edu.au>
MIME-Version: 1.0
Subject: Re: Reduce Linux memory requirements for an Embedded PC
References: <20010324133926.A1584@fred.local> <Pine.LNX.4.21.0103241319480.1863-100000@imladris.rielhome.conectiva>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: Andi Kleen <ak@muc.de>, Petr Dusil <pdusil@razdva.cz>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Rik van Riel wrote:
> 
> I'm willing to work on a CONFIG_TINY option for 2.5 which
> does things like this (but I'll have to finish some VM
> things first ;)).

That could be hard, because the amount of tinyness which
can be forced on the VM versus, say, IPV4 will vary from
application to application.

I think this is best solved with documentation, frankly.

Just itemise where the large memory-consumers are, how
much they can be reduced, how to reduce them and what
the consequences of this are.

There's quite a bit of stuff out there - just google
for "linux embedded memory requirements reduce".
It's a matter of pulling it all together.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
