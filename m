Date: Wed, 8 Nov 2000 17:36:40 +0100 (CET)
From: Mikulas Patocka <mikulas@artax.karlin.mff.cuni.cz>
Subject: Re: Looking for better VM
In-Reply-To: <Pine.LNX.4.05.10011081450320.3666-100000@humbolt.nl.linux.org>
Message-ID: <Pine.LNX.3.96.1001108172338.7153A-100000@artax.karlin.mff.cuni.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: Szabolcs Szakacsits <szaka@f-secure.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@transmeta.com>, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>

Hi.

> > I also didn't say non-overcommit should be used as default and a
> > patch http://www.cs.helsinki.fi/linux/linux-kernel/2000-13/1208.html,
> > developed for 2.3.99-pre3 by Eduardo Horvath and unfortunately was
> > ignored completely, implemented it this way. 
> 
> OK. This is a lot more reasonable. I'm actually looking
> into putting non-overcommit as a configurable option in
> the kernel.
> 
> However, this does not save you from the fact that the
> system is essentially deadlocked when nothing can get
> more memory and nothing goes away. Non-overcommit won't
> give you any extra reliability unless your applications
> are very well behaved ... in which case you don't need
> non-overcommit.

BTW. Why does your OOM killer in 2.4 try to kill process that mmaped most
memory? mmap is hamrless. mmap on files can't eat memory and swap.

Imagine a case: you have database server that mmaps the whole 2G file but
doesn't have too much anonymous memory. You have an offending process that
does while (1) malloc(1000) and fills up 512M swap. Your OOM killer would
kill the server first...

Mikulas

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
