Date: Sat, 8 Apr 2000 01:26:48 +0200 (CEST)
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: [patch] take 2 Re: PG_swap_entry bug in recent kernels
In-Reply-To: <200004072012.NAA10407@google.engr.sgi.com>
Message-ID: <Pine.LNX.4.21.0004080120330.2088-100000@alpha.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Kanoj Sarcar <kanoj@google.engr.sgi.com>
Cc: Ben LaHaise <bcrl@redhat.com>, riel@nl.linux.org, Linus Torvalds <torvalds@transmeta.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 7 Apr 2000, Kanoj Sarcar wrote:

>[..] you should try stress
>testing with swapdevice removal with a large number of runnable
>processes.[..]

swapdevice removal during swapin activity is broken right now as far I can
see. I'm trying to fix that stuff right now.

>Also, did you have a good reason to want to make lookup_swap_cache()
>invoke find_get_page(), and not find_lock_page()? I coded some of the 

Using find_lock_page and then unlocking the page is meaningless. If you
are going to unconditionally unlock the page then you shouldn't lock it in
first place.

Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
