From: kanoj@google.engr.sgi.com (Kanoj Sarcar)
Message-Id: <200003270239.SAA97539@google.engr.sgi.com>
Subject: Re: [PATCH] Re: kswapd
Date: Sun, 26 Mar 2000 18:39:14 -0800 (PST)
In-Reply-To: <Pine.LNX.4.21.0003262327160.1104-100000@duckman.conectiva> from "Rik van Riel" at Mar 26, 2000 11:28:30 PM
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: riel@nl.linux.org
Cc: Russell King <rmk@arm.linux.org.uk>, linux-mm@kvack.org, linux-kernel@vger.rutgers.edu, torvalds@transmeta.com
List-ID: <linux-mm.kvack.org>

> 
> On Sun, 26 Mar 2000, Kanoj Sarcar wrote:
> > > On Sun, 26 Mar 2000, Russell King wrote:
> > > 
> > > > I think I've solved (very dirtily) my kswapd problem
> > > 
> > > Your patch is the correct one. I've added an extra reschedule
> > > point and cleaned up the code a little bit. I wonder who sent
> > > the brown-paper-bag patch with the superfluous while loop to
> > > Linus ...        (please raise your hand and/or buy rmk a beer)
> > 
> > That would be me ...
> > 
> > What is the problem that your patch is fixing?
> 
> Removing the superfluous while loop.
> 

Maybe I am being stupid, but where is the superfluous loop? Remember,
as I just pointed out, 2.3.43 had the same loop, are you claiming it 
was buggy even then?

> Without my patch kswapd uses between 50 and 70% CPU time
> in a particular workload. Now it uses between 3 and 5%.

Can you explain how this is happening? I can see that in your patch,
kswapd does not go thru the loop if need_resched is set, but with
a single node, 3 zones, I would find it hard to explain such a 
difference.

> Oh, and the latency problem probably has been fixed too...

What latency problem? I still believe that the pre3 code is doing
the right thing, assuming 2.3.43 was doing the right thing.

Kanoj

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

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
