Date: Mon, 8 May 2000 16:04:55 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: [PATCH] Recent VM fiasco - fixed
In-Reply-To: <dnhfc8yitw.fsf@magla.iskon.hr>
Message-ID: <Pine.LNX.4.21.0005081604080.20958-100000@duckman.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Zlatko Calusic <zlatko@iskon.hr>
Cc: linux-mm@kvack.org, linux-kernel@vger.rutgers.edu, Linus Torvalds <torvalds@transmeta.com>
List-ID: <linux-mm.kvack.org>

On 8 May 2000, Zlatko Calusic wrote:
> Rik van Riel <riel@conectiva.com.br> writes:
> 
> > > But after few hours spent dealing with the horrible VM that is
> > > in the pre6, I'm not scared anymore. And I think that solution
> > > to all our problems with zone balancing must be very simple.
> > 
> > It is. Linus is working on a conservative & simple solution
> > while I'm trying a bit more "far-out" code (active and inactive
> > list a'la BSD, etc...). We should have at least one good VM
> > subsystem within the next few weeks ;)
> 
> Nice. I'm also in favour of some kind of active/inactive list
> solution (looks promising), but that is probably 2.5.x stuff.

I have it booting (against pre7-4) and it seems almost
stable ;)  (with _low_ overhead)

> I would be happy to see 2.4 out ASAP. Later, when it stabilizes,
> we will have lots of fun in 2.5, that's for sure.

Of course, this has the highest priority.

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
