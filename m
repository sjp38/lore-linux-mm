Date: Tue, 2 May 2000 14:40:34 -0700 (PDT)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: Oops in __free_pages_ok (pre7-1) (Long)
In-Reply-To: <ytt4s8g1vx0.fsf@vexeta.dc.fi.udc.es>
Message-ID: <Pine.LNX.4.10.10005021439320.12403-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Juan J. Quintela" <quintela@fi.udc.es>
Cc: linux-mm@kvack.org, Andrea Arcangeli <andrea@suse.de>, Kanoj Sarcar <kanoj@google.engr.sgi.com>
List-ID: <linux-mm.kvack.org>


On 2 May 2000, Juan J. Quintela wrote:
> 
> <self package advertising> 
> I can reproduce this BUGs easily with the mmap002 program from the
> memtest-0.0.3 suite (http://carpanta.dc.fi.udc.es/~quintela/memtest/).
> You need to change the #define RAMSIZE to reflect your memory size in
> include file misc_lib.h and you run it in one while(true); do
> ./mmap002; done and in the 8th, 9th execution it Oops here also.
> </self package advertising>

Ok, I'll try that..

> If you want the patch for get rid of PG_swap_entry, I can do it and send it to
> you.

I'd rather get rid of it entirely, yes, as I hate having "crud" around
that nobody realizes isn't really even active any more (and your one-liner
de-activates the whole thing as far as I can tell).

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
