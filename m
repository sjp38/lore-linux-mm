Subject: Re: nice vmm test case
References: <39636E66.CE21C296@ucla.edu>
From: "John Fremlin" <vii@penguinpowered.com>
Date: 06 Jul 2000 17:37:21 +0100
In-Reply-To: Benjamin Redelings's message of "Wed, 05 Jul 2000 10:20:38 -0700"
Message-ID: <m2sntn1agu.fsf@boreas.southchinaseas>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Roman Zippel <roman@augan.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Benjamin Redelings <bredelin@ucla.edu> writes:

> > Anyway, the swap_cnt in vmscan.c looks suspicious, maybe it's
> > initiliazed too high?

Perhaps, but I think the cause of the problem might well the priority
argument to the swap_out function. For me, it is always set to around
62, so that the swap out loop is executed a ridiculous number of
times, i.e. until all memory that can be is swapped out (which seems
to be the behaviour described). You might like to force the counter to
a sensible number (say 100) by editing the source. If you're not
confortable with that, I can try to run off my current patch. (I'm not
sure if I posted it or not).

[...]

-- 

	http://web.onetel.net.uk/~elephant/john
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
