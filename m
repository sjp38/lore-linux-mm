Date: Sat, 6 May 2000 18:46:11 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Reply-To: riel@nl.linux.org
Subject: Re: [DATAPOINT] pre7-6 will not swap
In-Reply-To: <3913AF3E.470F26E@ucla.edu>
Message-ID: <Pine.LNX.4.21.0005061844560.4627-100000@duckman.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Benjamin Redelings I <bredelin@ucla.edu>
Cc: Linus Torvalds <torvalds@transmeta.com>, Rajagopal Ananthanarayanan <ananth@sgi.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 5 May 2000, Benjamin Redelings I wrote:

> 	It looks like some processes (my unused daemons) are
> scanned only once, and then get stuck at the end of some list?  
> Is that a possible explanation? <guessing> Perhaps Rik's moving
> list-head idea is needed? </guessing>.

I'm busy implementing Davem's active/inactive list proposal
to replace the current page/swapcache. I don't know if it'll
work really well though, so research into other directions
is very much welcome ;)

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
