Date: Fri, 19 May 2000 14:05:41 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: [patch] balanced highmem subsystem under pre7-9
In-Reply-To: <Pine.LNX.4.21.0005190905200.1099-100000@inspiron.random>
Message-ID: <Pine.LNX.4.21.0005191354500.20142-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: Ingo Molnar <mingo@elte.hu>, Linus Torvalds <torvalds@transmeta.com>, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

On Fri, 19 May 2000, Andrea Arcangeli wrote:
> On Fri, 19 May 2000, Rik van Riel wrote:
> 
> >I'm curious what would be so "very broken" about this?
> 
> You start eating from ZONE_DMA before you made empty ZONE_NORMAL.

What's wrong with this?  We'll never go below zone->pages_low
in ZONE_DMA, so you don't have to worry about running out of
DMA pages.

> >AFAICS it does most of what the classzone patch would achieve,
> >at lower complexity and better readability.
> 
> I disagree.

The classzone patches look like a bunch of magic to most of the
people who've read it and with whom I've spoken. There has been
almost no explanation of what the patch tries to achieve or why
it would work better than the normal code (nor is it visible in
the code).

Juan Quintela's patch, on the other hand, has received continuous
feedback from 7 kernel hackers, all of whom now understand how the
code works. This provides a lot more long-term maintainability of
the code.

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
