Date: Sun, 26 Mar 2000 23:28:30 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Reply-To: riel@nl.linux.org
Subject: Re: [PATCH] Re: kswapd
In-Reply-To: <200003270121.RAA88890@google.engr.sgi.com>
Message-ID: <Pine.LNX.4.21.0003262327160.1104-100000@duckman.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Kanoj Sarcar <kanoj@google.engr.sgi.com>
Cc: Russell King <rmk@arm.linux.org.uk>, linux-mm@kvack.org, linux-kernel@vger.rutgers.edu, torvalds@transmeta.com
List-ID: <linux-mm.kvack.org>

On Sun, 26 Mar 2000, Kanoj Sarcar wrote:
> > On Sun, 26 Mar 2000, Russell King wrote:
> > 
> > > I think I've solved (very dirtily) my kswapd problem
> > 
> > Your patch is the correct one. I've added an extra reschedule
> > point and cleaned up the code a little bit. I wonder who sent
> > the brown-paper-bag patch with the superfluous while loop to
> > Linus ...        (please raise your hand and/or buy rmk a beer)
> 
> That would be me ...
> 
> What is the problem that your patch is fixing?

Removing the superfluous while loop.

Without my patch kswapd uses between 50 and 70% CPU time
in a particular workload. Now it uses between 3 and 5%.
Oh, and the latency problem probably has been fixed too...

cheers,

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
