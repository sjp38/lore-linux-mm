Date: Wed, 16 Oct 2002 16:55:36 -0400 (EDT)
From: Bill Davidsen <davidsen@tmr.com>
Subject: Re: 2.5.42-mm2 on small systems
In-Reply-To: <3DABB8EF.5E00AF4E@digeo.com>
Message-ID: <Pine.LNX.3.96.1021016164613.12145A-100000@gatekeeper.tmr.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: Ed Tomlinson <tomlins@cam.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 14 Oct 2002, Andrew Morton wrote:

> hm.  Works for me.  The default setting are waaay too boring, so
> I used ./resp -m2 -M5 -w5

The problem with reducing the sleep is that it hides a kernel which is
swappy, since there isn't time to build up a big backlog of disk writes,
and the swap doesn't seem to happen right away.

And I often see jackpot cases which are less likely to happen if you
reduce the number of tests. Again it makes the kernel look good, but may
not reflect what's really happening. I agree that it's slow, I've been
debugging it for several weeks now, but every time I think I've got the
corner cases cornered I find another corner.

The next version will add -R to set the retry max count, because some
kernels don't recover from one test and return no resources on fork()
because they haven't cleaned up all terminated processes.

This was intended to be a simple test of how the kernel feels, and it is
that, but some kernels I've tried get to one test or another and shit the
bed every time. It's not a stress test! How can I get my numbers if the
kernel keeps hanging solid? ;-)

-- 
bill davidsen <davidsen@tmr.com>
  CTO, TMR Associates, Inc
Doing interesting things with little computers since 1979.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
