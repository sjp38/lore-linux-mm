Date: Wed, 3 May 2000 02:43:48 +0200 (CEST)
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: Oops in __free_pages_ok (pre7-1) (Long)
In-Reply-To: <Pine.LNX.4.21.0005022355140.1677-100000@alpha.random>
Message-ID: <Pine.LNX.4.21.0005030239240.3498-100000@alpha.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Juan J. Quintela" <quintela@fi.udc.es>
Cc: Linus Torvalds <torvalds@transmeta.com>, linux-mm@kvack.org, Kanoj Sarcar <kanoj@google.engr.sgi.com>
List-ID: <linux-mm.kvack.org>

On Wed, 3 May 2000, Andrea Arcangeli wrote:

>On 2 May 2000, Juan J. Quintela wrote:
>
>><self package advertising> 
>>I can reproduce this BUGs easily with the mmap002 program from the
>>memtest-0.0.3 suite (http://carpanta.dc.fi.udc.es/~quintela/memtest/).
>>You need to change the #define RAMSIZE to reflect your memory size in
>>include file misc_lib.h and you run it in one while(true); do
>>./mmap002; done and in the 8th, 9th execution it Oops here also.
>></self package advertising>
>
>I'll try this, thanks.

I reached 23 passes in SMP and nothing happened yet with my latest
lru_cache code plus swap entry patch and classzone stuff. However I can't
exclude it's a timing issue that doesn't allow me to reproduce. As soon as
I'll have finished the rework of the swap entry logic as described in last
email I'll pass you a patch to try out to see if you can reproduce
something weird with it. Thanks.

Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
