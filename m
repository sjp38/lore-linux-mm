Date: Mon, 27 Mar 2000 14:54:02 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Reply-To: riel@nl.linux.org
Subject: Re: [PATCH] Re: kswapd
In-Reply-To: <Pine.LNX.4.10.10003271152350.2650-100000@coffee.psychology.mcmaster.ca>
Message-ID: <Pine.LNX.4.21.0003271452170.1104-100000@duckman.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mark Hahn <hahn@coffee.psychology.mcmaster.ca>
Cc: Kanoj Sarcar <kanoj@google.engr.sgi.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 27 Mar 2000, Mark Hahn wrote:

> > So think of the bug as "kswapd will waste the final part of its timeslice
> > doing nothing useful".
> 
> yes!  should it not look at the return from try_to_free_pages 
> to find out whether further looping is needed? 
> or something based on the current free pages level, hopefully
> with hysteresis like Rik mentioned?

It is looking at the current free page levels, on a zone-by-zone
basis. Looking at the return value of try_to_free_pages() doesn't
make much sense IMHO because that just means that normal processes
will be doing the heavy work instead of kswapd (leading to poor
interactive response and other trouble).

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
