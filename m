Date: Fri, 7 Apr 2000 14:00:11 +0200 (CEST)
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: [patch] take 2 Re: PG_swap_entry bug in recent kernels
In-Reply-To: <Pine.LNX.4.21.0004070826350.23401-100000@duckman.conectiva>
Message-ID: <Pine.LNX.4.21.0004071356590.325-100000@alpha.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: riel@nl.linux.org
Cc: Ben LaHaise <bcrl@redhat.com>, Linus Torvalds <torvalds@transmeta.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 7 Apr 2000, Rik van Riel wrote:

>Please use the clear_bit() macro for this, the code is
>unreadable enough in its current state...

I didn't used the ClearPageSwapEntry macro to avoid executing locked asm
instructions where not necessary.

Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
