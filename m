From: kanoj@google.engr.sgi.com (Kanoj Sarcar)
Message-Id: <200004080011.RAA21305@google.engr.sgi.com>
Subject: Re: [patch] take 2 Re: PG_swap_entry bug in recent kernels
Date: Fri, 7 Apr 2000 17:11:15 -0700 (PDT)
In-Reply-To: <Pine.LNX.4.21.0004080120330.2088-100000@alpha.random> from "Andrea Arcangeli" at Apr 08, 2000 01:26:48 AM
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: Ben LaHaise <bcrl@redhat.com>, riel@nl.linux.org, Linus Torvalds <torvalds@transmeta.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> 
> On Fri, 7 Apr 2000, Kanoj Sarcar wrote:
> 
> >[..] you should try stress
> >testing with swapdevice removal with a large number of runnable
> >processes.[..]
> 
> swapdevice removal during swapin activity is broken right now as far I can
> see. I'm trying to fix that stuff right now.

Be aware that I already have a patch for this. I have been meaning to 
clean it up against latest 2.3 and submit it to Linus ... FWIW, it 
has been broken since 2.2.

> 
> >Also, did you have a good reason to want to make lookup_swap_cache()
> >invoke find_get_page(), and not find_lock_page()? I coded some of the 
> 
> Using find_lock_page and then unlocking the page is meaningless. If you
> are going to unconditionally unlock the page then you shouldn't lock it in
> first place.

I will have to think a little bit about why the code does what it does
currently. I will let you know ...

Kanoj

> 
> Andrea
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
