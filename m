Date: Thu, 4 May 2000 15:21:22 -0700 (PDT)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: Oops in __free_pages_ok (pre7-1) (Long) (backtrace)
In-Reply-To: <3911E8CB.AD90A518@sgi.com>
Message-ID: <Pine.LNX.4.10.10005041517310.878-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rajagopal Ananthanarayanan <ananth@sgi.com>
Cc: riel@nl.linux.org, Kanoj Sarcar <kanoj@google.engr.sgi.com>, linux-mm@kvack.org, "David S. Miller" <davem@redhat.com>
List-ID: <linux-mm.kvack.org>


On Thu, 4 May 2000, Rajagopal Ananthanarayanan wrote:
> 
> One clarification: In the case I reported only
> dbench was running, presumably doing a lot of read/write. So, why
> isn't shrink_mmap able to find freeable pages? Is it because
> the shrink_mmap() is too conservative about implementing LRU?

Probably. One of the things that has changed is exactly _which_ pages are
on the LRU list, so the old heuristics from shrink_mmap() may need some
tweaking too. In fact, as with vmscan, we should probably scan the LRU
list at least _twice_ when the priority level reaches zero (in order to
defeat the aging).

This is also an area where the secondary effects of the vmscan page
lockedness changes could start showing up - the page being locked on the
LRU list makes a difference to the shrink_mmap() algorithm..

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
