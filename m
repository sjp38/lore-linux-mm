Date: Wed, 4 Aug 1999 13:50:28 +0200 (CEST)
From: Ingo Molnar <mingo@chiara.csoma.elte.hu>
Subject: Re: [patch] minimal page-LRU
In-Reply-To: <Pine.LNX.4.10.9908041310460.2739-100000@laser.random>
Message-ID: <Pine.LNX.3.96.990804134203.21581B-100000@chiara.csoma.elte.hu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: Linus Torvalds <torvalds@transmeta.com>, MOLNAR Ingo <mingo@redhat.com>, "David S. Miller" <davem@redhat.com>, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 4 Aug 1999, Andrea Arcangeli wrote:

> I did only a little not interesting benchmark. I compiled the kernel with
> 2.3.12 and 2.3.12-LRU and these are the numbers:
> 
> 2.3.12:
> real    3m0.974s
> user    3m22.400s
> sys     0m16.350s
> 
> 2.3.12-lru:
> real    2m58.483s
> user    3m23.350s
> sys     0m15.920s
> 
> NOTE: I have 128mbyte of ram so the kernel almost fit in cache during the
> compile and there isn't high I/O activity so I didn't ever expected such
> two seconds improvement...

even two seconds can be statistical noise (eg. look at the user-time
numbers, those increased by one second.). But it's not so hard to test
high-intensity VM with kernel compiles. This method is from Davem: compile
the kernel with 'make -jN', where N = 1,2,3... increasingly. [also put
'make -jN' into the top Makefile.] Sometimes at N=6 or so you'll fall out
of core 128M RAM. This is both a good stability and a good performance
test. You can even automate it. This way you'll see both the effect on
'normal' (cached) and 'high load' (swapping) situations. Such a list of
numbers is a much more reliable measurement of performance than just one
arbitrary number.

-- mingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
