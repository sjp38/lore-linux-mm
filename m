Date: Mon, 8 Jan 2001 11:11:32 -0200 (BRST)
From: Marcelo Tosatti <marcelo@conectiva.com.br>
Subject: Re: Subtle MM bug
In-Reply-To: <Pine.LNX.4.10.10101072223160.29065-100000@penguin.transmeta.com>
Message-ID: <Pine.LNX.4.21.0101081101430.5599-100000@freak.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: "David S. Miller" <davem@redhat.com>, Rik van Riel <riel@conectiva.com.br>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, 7 Jan 2001, Linus Torvalds wrote:

> and just get rid of all the logic to try to "find the best mm". It's bogus
> anyway: we should get perfectly fair access patterns by just doing
> everything in round-robin, and each "swap_out_mm(mm)" would just try to
> walk some fixed percentage of the RSS size (say, something like
> 
> 	count = (mm->rss >> 4)
> 
> and be done with it.

I have the impression that a fixed percentage of the RSS will be a problem
when you have a memory hog (or hogs) running.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
