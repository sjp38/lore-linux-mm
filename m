Date: Tue, 25 Jul 2000 17:46:10 -0400 (EDT)
From: Mark Hahn <hahn@coffee.psychology.mcmaster.ca>
Subject: Re: Inter-zone swapping
In-Reply-To: <20000725143833.E1396@redhat.com>
Message-ID: <Pine.LNX.4.10.10007251743530.11616-100000@coffee.psychology.mcmaster.ca>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: Cesar Eduardo Barros <cesarb@nitnet.com.br>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> > Then would it be useful to "swap" a page from the DMA zone into the normal zone
> > (and of course after that ending up swapping from the normal zone to the disk)?
> 
> Yes.  There are _lots_ of other possible applications for that sort of
> non-IO-consuming relocation-style swapping, including memory
> defragmentation (we really need that if we want to support things like
> large page stuff on Intel boxes for user space).

doesn't good page coloring need this ability, as well, 
to move around which physical page is backing a virtual one?
guess it depends on whether the arch does cache lookups based
on p or v addresses...

thanks, mark hahn.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
