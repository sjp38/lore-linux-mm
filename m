Date: Mon, 25 Sep 2000 17:48:15 +0200
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: the new VM
Message-ID: <20000925174815.E25814@athlon.random>
References: <E13dZX7-00055f-00@the-village.bc.nu> <Pine.LNX.4.21.0009251714480.9122-100000@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.21.0009251714480.9122-100000@elte.hu>; from mingo@elte.hu on Mon, Sep 25, 2000 at 05:16:06PM +0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, Marcelo Tosatti <marcelo@conectiva.com.br>, Linus Torvalds <torvalds@transmeta.com>, Rik van Riel <riel@conectiva.com.br>, Roger Larsson <roger.larsson@norran.net>, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, Sep 25, 2000 at 05:16:06PM +0200, Ingo Molnar wrote:
> situation is just 1% RAM away from the 'root cannot log in', situation.

The root cannot log in is a little different. Just think that in the "root
cannot log in" you only need to press SYSRQ+E (or as worse +I).

If all tasks in the systems are hanging into the GFP loop SYSRQ+I won't solve
the deadlock.

Ok you can add a signal check in the memory balancing code but that looks an
ugly hack that shows the difference between the two cases (the one Alan pointed
out is real deadlock, the current one is kind of live lock that can go away any
time, while the deadlock can reach the point where it can't be recovered
without an hack from an irq somewhere).

Andrea
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
