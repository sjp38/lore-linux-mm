Message-ID: <3917C33F.1FA1BAD4@sgi.com>
Date: Tue, 09 May 2000 00:50:23 -0700
From: Rajagopal Ananthanarayanan <ananth@sgi.com>
MIME-Version: 1.0
Subject: A possible winner in pre7-8
References: <Pine.LNX.4.10.10005082332560.773-100000@penguin.transmeta.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Linus Torvalds wrote:
> 
> On Mon, 8 May 2000, Rajagopal Ananthanarayanan wrote:
> >
> > Not sure entirely what effect this has, except for freeing underlying
> > buffer_head's. The page itself is still skipped. Anyway, brief examination
> > shows that you've changed several things here (in 7-7), so I'll have to go
> > at it some more time to get a full picture.
> 
> Actually, look at pre7-8 instead.
> 
> pre7-7 was rather useful to me - I tested the exact same kernel with the
> only difference being the order of the "zone free" and the
> "try_to_free_buffers()" tests, and that's what I then released as pre7-7.
> But pre7-8 has what I believe to be a saner order when it comes to the
> other tests.


Interesting! This stuff is coming out faster than I can patch.
In any case, good news about pre7-8: not only does dbench run without
errors, but it runs well. Let's hope that others (Juan & Benjamin to name two)
see similar results.

> 
> > Unfortunately my dbench test really runs bad with pre 7-7.
> > Quantitively, the amount of memory in "cache" of vmstat
> > is higher than before. write()'s start failing.
> 
> Can you tell me how they fail? Is it with a ENOMEM, or is there something
> more insidious going on?
> 
> I tested pre7-7 with 20MB of RAM, and it was fine. But I didn't run
> dbench: instead I tested it with X and netscape and a kernel recursive
> diff - really more to test that it works ok under real load. Something
> which previous pre7's definitely did not do well on at all. pre7-8 should
> be better, because it has the LRU enabled on the buffer cache too,
> something that pre7-7 lost due to the ordering changes.
> 

pre7-8 is definitely better; 7-7 was really bad. I don't know for
sure but the write failure was similar to what I've seen earlier with ENOMEM.

More after looking at your changes in 7-6 -> 7-7 and  7-7 ->7-8 ...

-- 
--------------------------------------------------------------------------
Rajagopal Ananthanarayanan ("ananth")
Member Technical Staff, SGI.
--------------------------------------------------------------------------
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
