Date: Mon, 8 May 2000 15:46:09 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: [PATCH] Recent VM fiasco - fixed
In-Reply-To: <dnln1kykkb.fsf@magla.iskon.hr>
Message-ID: <Pine.LNX.4.21.0005081544360.20958-100000@duckman.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Zlatko Calusic <zlatko@iskon.hr>
Cc: linux-mm@kvack.org, linux-kernel@vger.rutgers.edu, Linus Torvalds <torvalds@transmeta.com>
List-ID: <linux-mm.kvack.org>

On 8 May 2000, Zlatko Calusic wrote:
> Rik van Riel <riel@conectiva.com.br> writes:
> > On 8 May 2000, Zlatko Calusic wrote:
> > 
> > > BTW, this patch mostly *removes* cruft recently added, and
> > > returns to the known state of operation.
> > 
> > Which doesn't work.
> > 
> > Think of a 1GB machine which has a 16MB DMA zone,
> > a 950MB normal zone and a very small HIGHMEM zone.
> > 
> > With the old VM code the HIGHMEM zone would be
> > swapping like mad while the other two zones are
> > idle.
> > 
> > It's Not That Kind Of Party(tm)
> 
> OK, I see now what you have in mind, and I'll try to test it when I
> get home (yes, late worker... my only connection to the Net :))
> If only I could buy 1GB to test in the real setup. ;)
> 
> But still, optimizing for 1GB, while at the same time completely
> killing performances even *usability* for the 99% of users doesn't
> look like a good solution, does it?

20MB and 24MB machines will be in the same situation, if
that's of any help to you ;)

> But after few hours spent dealing with the horrible VM that is
> in the pre6, I'm not scared anymore. And I think that solution
> to all our problems with zone balancing must be very simple.

It is. Linus is working on a conservative & simple solution
while I'm trying a bit more "far-out" code (active and inactive
list a'la BSD, etc...). We should have at least one good VM
subsystem within the next few weeks ;)

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
