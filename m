Date: Thu, 9 Nov 2000 01:08:19 +0100 (CET)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: Looking for better VM
In-Reply-To: <Pine.LNX.3.96.1001108172338.7153A-100000@artax.karlin.mff.cuni.cz>
Message-ID: <Pine.LNX.4.05.10011090106520.23541-100000@humbolt.nl.linux.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mikulas Patocka <mikulas@artax.karlin.mff.cuni.cz>
Cc: Szabolcs Szakacsits <szaka@f-secure.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@transmeta.com>, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>

On Wed, 8 Nov 2000, Mikulas Patocka wrote:

> BTW. Why does your OOM killer in 2.4 try to kill process that mmaped
> most memory? mmap is hamrless. mmap on files can't eat memory and
> swap.

Because the thing is too stupid to take that into
consideration? :)

Btw, if your mmap()ed file still takes 1GB of memory,
you have 1GB of freeable memory left and you shouldn't
be out of memory ... or should you??

regards,

Rik
--
The Internet is not a network of computers. It is a network
of people. That is its real strength.

http://www.conectiva.com/		http://www.surriel.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
