Date: Mon, 27 Mar 2000 09:36:26 -0800 (PST)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: [PATCH] Re: kswapd
In-Reply-To: <Pine.LNX.4.10.10003271152350.2650-100000@coffee.psychology.mcmaster.ca>
Message-ID: <Pine.LNX.4.10.10003270935480.1949-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mark Hahn <hahn@coffee.psychology.mcmaster.ca>
Cc: Kanoj Sarcar <kanoj@google.engr.sgi.com>, riel@nl.linux.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


On Mon, 27 Mar 2000, Mark Hahn wrote:
> 
> yes!  should it not look at the return from try_to_free_pages 
> to find out whether further looping is needed?  or something based
> on the current free pages level, hopefully with hysteresis like 
> Rik mentioned?

It does do that - that's what the "kswapd_wake_up" flag does for the loop.
The problem was that the loop termination logic was a bit topsy-turvy.

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
