Date: Mon, 19 Aug 2002 03:55:21 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: [BUG] 2.5.30 swaps with no swap device mounted!!
Message-ID: <20020819105520.GK18350@holomorphy.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Description: brief message
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Due to the natural slab shootdown laziness issues, I turned off swap.
The kernel reported that it had successfully unmounted the swap device,
and for several days ran without it. Tonight, it went 91MB into swap
on the supposedly unmounted swap device!

Yeah, it's 2.5.30, but this wasn't a crashbox that did it, and no one's
touched swap for a while anyway.

I'm about to hit the sack, so hopefully someone else can look into it
while I'm resting. This one will probably be a PITA to reproduce and I
already shot down one bad bug tonight anyway.


Cheers,
Bill
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
