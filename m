Date: Wed, 7 Jun 2000 18:20:53 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: journaling & VM  (was: Re: reiserfs being part of the kernel:
 it'snot just the code)
In-Reply-To: <393EADB0.54FB3633@reiser.to>
Message-ID: <Pine.LNX.4.21.0006071818580.14304-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hans Reiser <hans@reiser.to>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, "Quintela Carreira Juan J." <quintela@fi.udc.es>, linux-kernel@vger.rutgers.edu, Chris Mason <mason@suse.com>, linux-mm@kvack.org, Alexander Zarochentcev <zam@odintsovo.comcor.ru>
List-ID: <linux-mm.kvack.org>

On Wed, 7 Jun 2000, Hans Reiser wrote:

> The new age one 64th of your objects scheme causes pressure to
> be proportional.....

Which is wrong, unless the oldest pages from each zone happen
to be the same age ;)

Suppose a 5MB SHM segment gets deattached and not used for a
long time. In this situation it makes little sense to round-robin
free from the different caches if the other caches are under more
pressure.

> I am looking forward to reading the new 2.4 mm code during my
> next aeroflot experience this sunday....

I'm working on it, but I can't promise to have all of the
active/inactive/scavenge list framework ready by then ;)

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
