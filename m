Date: Wed, 4 Oct 2000 10:13:52 -0400 (EDT)
From: Eric Lowe <elowe@myrile.madriver.k12.oh.us>
Subject: Re: SMP VM race in 2.[0-4]
In-Reply-To: <Pine.LNX.3.96.1001004154920.27909C-100000@artax.karlin.mff.cuni.cz>
Message-ID: <Pine.BSF.4.10.10010041008540.70794-100000@myrile.madriver.k12.oh.us>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mikulas Patocka <mikulas@artax.karlin.mff.cuni.cz>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hello,

> I found a possible problem on SMP. In vmscan.c / try_to_swap_out you do
> not use atomic operations for manipulating with ptes. You read the pte,
> modify it and write it nonatomically. When the second CPU is running
> process that turns on 'D' bit of pte while the first CPU is in
> try_to_swap_out, 'D' bit is lost. Because anonymous pages have always 'D'
> bit set, the bug can only affect pages mapped with MAP_SHAREAD,
> PROT_WRITE. Sometimes updates are not written back to file. 
> 

You're correct.  A discussion about this occurred on Linux-MM
1-2 weeks ago, and a patch followed.  (Unfortunately, it's not
very efficient, but I'm not sure if anyone has found a really
good solution yet to this problem on any other x86 OS)

Check out:
http://mail.nl.linux.org/linux-mm/2000-09/

Thread: [PATCH] workaround for lost dirty bits on x86 SMP -and-
Thread: [PATCH] 2.2.18pre5 version of pte dirty bit psmp race atch

--
Eric Lowe
FibreChannel Software Engineer, Systran Corporation
elowe@systran.com


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
