Date: Mon, 27 Mar 2000 11:54:11 -0500 (EST)
From: Mark Hahn <hahn@coffee.psychology.mcmaster.ca>
Subject: Re: [PATCH] Re: kswapd
In-Reply-To: <Pine.LNX.4.10.10003270807260.1745-100000@penguin.transmeta.com>
Message-ID: <Pine.LNX.4.10.10003271152350.2650-100000@coffee.psychology.mcmaster.ca>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: Kanoj Sarcar <kanoj@google.engr.sgi.com>, riel@nl.linux.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> So think of the bug as "kswapd will waste the final part of its timeslice
> doing nothing useful".

yes!  should it not look at the return from try_to_free_pages 
to find out whether further looping is needed?  or something based
on the current free pages level, hopefully with hysteresis like 
Rik mentioned?

regards, mark hahn.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
