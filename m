Date: Thu, 4 May 2000 18:51:41 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Reply-To: riel@nl.linux.org
Subject: Re: Oops in __free_pages_ok (pre7-1) (Long) (backtrace)
In-Reply-To: <3911E8CB.AD90A518@sgi.com>
Message-ID: <Pine.LNX.4.21.0005041843120.23740-100000@duckman.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rajagopal Ananthanarayanan <ananth@sgi.com>
Cc: Linus Torvalds <torvalds@transmeta.com>, Kanoj Sarcar <kanoj@google.engr.sgi.com>, linux-mm@kvack.org, "David S. Miller" <davem@redhat.com>
List-ID: <linux-mm.kvack.org>

On Thu, 4 May 2000, Rajagopal Ananthanarayanan wrote:

> One clarification: In the case I reported only
> dbench was running, presumably doing a lot of read/write. So, why
> isn't shrink_mmap able to find freeable pages? Is it because
> the shrink_mmap() is too conservative about implementing LRU?
> I mean, it doesn't make sense to swap pages just to keep others
> in cache ... if the demand is too high, start shooting down
> pages regardless.

Indeed, we've seen kswapd fail to get us free pages even
when the total RSS was small...

> Or, is shrink_mmap bailing not because of referenced bit,
> but because bdflush is too slow, for example? That is,
> are the pages having active I/O so can't be freed?
> 
> Do you guys think a profile using gcc-style mcount
> would be useful?

This could be very useful indeed. To be honest I'm not sure
what is happening (though I have some suspicions).

regards,

Rik
--
The Internet is not a network of computers. It is a network
of people. That is its real strength.

Wanna talk about the kernel?  irc.openprojects.net / #kernelnewbies
http://www.conectiva.com/		http://www.surriel.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
