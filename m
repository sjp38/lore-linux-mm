Date: Thu, 13 Jan 2000 20:22:42 +0100 (CET)
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: [RFC] 2.3.39 zone balancing
In-Reply-To: <200001131830.KAA72001@google.engr.sgi.com>
Message-ID: <Pine.LNX.4.21.0001131941580.382-100000@alpha.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Kanoj Sarcar <kanoj@google.engr.sgi.com>
Cc: Linus Torvalds <torvalds@transmeta.com>, Alan Cox <alan@lxorguk.ukuu.org.uk>, linux-mm@kvack.org, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

On Thu, 13 Jan 2000, Kanoj Sarcar wrote:

>[..] For example, I was 
>looking at replace_with_highmem() which makes __GFP_HIGHMEM|__GFP_HIGH
>requests, although I _think_ it can do __GFP_WAIT|__GFP_IO without
>any problems. I just assumed that whoever coded it (you/Mingo?) had

I coded it.

>some logic, like not wanting to waste time scanning for stealable pages
>or incur disk swap to implement this performance optimization (that
>would defeat the optimization).

replace_with_higmem is a _memory-usage_ optimization (not a performance
optimization).

The reason of my GFP_ATOMIC choice is that I don't want to steal pages at
all. Not to go faster but because if the system is just low in memory it
means the high memory is been used completly as well so there's no point
in trying to put the anonymous data into highmem in such case.

Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.nl.linux.org/Linux-MM/
