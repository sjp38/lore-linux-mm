Message-ID: <393EC40A.376BB072@reiser.to>
Date: Wed, 07 Jun 2000 14:52:10 -0700
From: Hans Reiser <hans@reiser.to>
MIME-Version: 1.0
Subject: Re: journaling & VM  
References: <Pine.LNX.4.21.0006071818580.14304-100000@duckman.distro.conectiva>
Content-Type: text/plain; charset=koi8-r
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, "Quintela Carreira Juan J." <quintela@fi.udc.es>, linux-kernel@vger.rutgers.edu, Chris Mason <mason@suse.com>, linux-mm@kvack.org, Alexander Zarochentcev <zam@odintsovo.comcor.ru>
List-ID: <linux-mm.kvack.org>

Let me convey an aspect of its rightness.

Caches have a declining marginal utility.  It is a good idea to keep at least a
little bit of each cache around.  The classic problem is when you switch usage
patterns back and forth, and one of the caches has been completely flushed by,
say, a large file read.  If just 3% of the amount of cache remained from when it
was being used that 3% might give you a lot of speedup when the usage pattern
flipped back.

Hans

Rik van Riel wrote:
> 
> On Wed, 7 Jun 2000, Hans Reiser wrote:
> 
> > The new age one 64th of your objects scheme causes pressure to
> > be proportional.....
> 
> Which is wrong, unless the oldest pages from each zone happen
> to be the same age ;)
> 
> Suppose a 5MB SHM segment gets deattached and not used for a
> long time. In this situation it makes little sense to round-robin
> free from the different caches if the other caches are under more
> pressure.
> 
> > I am looking forward to reading the new 2.4 mm code during my
> > next aeroflot experience this sunday....
> 
> I'm working on it, but I can't promise to have all of the
> active/inactive/scavenge list framework ready by then ;)
> 
> regards,
> 
> Rik
> --
> The Internet is not a network of computers. It is a network
> of people. That is its real strength.
> 
> Wanna talk about the kernel?  irc.openprojects.net / #kernelnewbies
> http://www.conectiva.com/               http://www.surriel.com/
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
