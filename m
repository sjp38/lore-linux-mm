Date: Tue, 9 May 2000 02:56:10 -0500 (CDT)
From: Daniel Stone <tamriel@ductape.net>
Subject: Re: [PATCH] Recent VM fiasco - fixed
In-Reply-To: <Pine.LNX.4.21.0005081442030.20790-100000@duckman.conectiva>
Message-ID: <Pine.LNX.4.21.0005090254360.12487-100000@ductape.net>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: riel@nl.linux.org
Cc: Zlatko Calusic <zlatko@iskon.hr>, linux-mm@kvack.org, linux-kernel@vger.rutgers.edu, Linus Torvalds <torvalds@transmeta.com>
List-ID: <linux-mm.kvack.org>

Rik,
That's astonishing, I'm sure, but think of us poor bastards who DON'T have
an SMP machine with >1gig of RAM.

This is a P120, 32meg. Lately, fine has degenerated into bad into worse
into absolutely obscene. It even kills my PGSQL compiles.
And I killed *EVERYTHING* there was to kill.
The only processes were init, bash and gcc/cc1. VM still wiped it out.

d

On Mon, 8 May 2000, Rik van Riel wrote:

> On 8 May 2000, Zlatko Calusic wrote:
> 
> > BTW, this patch mostly *removes* cruft recently added, and
> > returns to the known state of operation.
> 
> Which doesn't work.
> 
> Think of a 1GB machine which has a 16MB DMA zone,
> a 950MB normal zone and a very small HIGHMEM zone.
> 
> With the old VM code the HIGHMEM zone would be
> swapping like mad while the other two zones are
> idle.
> 
> It's Not That Kind Of Party(tm)
> 
> cheers,
> 
> Rik
> --
> The Internet is not a network of computers. It is a network
> of people. That is its real strength.
> 
> Wanna talk about the kernel?  irc.openprojects.net / #kernelnewbies
> http://www.conectiva.com/		http://www.surriel.com/
> 
> 
> -
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.rutgers.edu
> Please read the FAQ at http://www.tux.org/lkml/
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
