From: kanoj@google.engr.sgi.com (Kanoj Sarcar)
Message-Id: <199906181703.KAA15995@google.engr.sgi.com>
Subject: Re: filecache/swapcache questions
Date: Fri, 18 Jun 1999 10:03:50 -0700 (PDT)
In-Reply-To: <14186.31507.833263.846717@dukat.scot.redhat.com> from "Stephen C. Tweedie" at Jun 18, 99 06:00:03 pm
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: riel@nl.linux.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> > While I have your attention, I think I found a bug in the
> > sys_swapoff algorithm ... basically, it needs to also look 
> > at swap_lockmap. Say an exitting process fired off some async
> > swap ins just before it exitted, and a bunch of these are in
> > flight (swap_lockmaps are set, as are swap_map, from swapcache).
> > The swap device gets deleted (with a printk warning message due
> > to non zero swap_map count). Finally, the old async swap in's 
> > start terminating, invoking swap_after_unlock_page. Interesting
> > things could happen, depending on whether the swap id has been
> > reallocated or not ... Is there any protection against this
> > scenario?
> 
> Yes --- try_to_unuse calls read_swap_cache() with wait==1, so we always
> wait for the IO to complete before swapoff can complete.  At least,
> that's the theory. :)
>

I just figured that one out all by myself :-) Duuh ...

Note to myself : read the code, stupid, before spouting off ...

Thanks, Stephen.

Kanoj 
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
