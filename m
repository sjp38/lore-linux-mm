Date: Mon, 25 Sep 2000 16:39:09 +0200
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: the new VM
Message-ID: <20000925163909.O22882@athlon.random>
References: <20000925162311.L22882@athlon.random> <Pine.LNX.4.21.0009251625090.9122-100000@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.21.0009251625090.9122-100000@elte.hu>; from mingo@elte.hu on Mon, Sep 25, 2000 at 04:27:24PM +0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: Marcelo Tosatti <marcelo@conectiva.com.br>, Linus Torvalds <torvalds@transmeta.com>, Rik van Riel <riel@conectiva.com.br>, Roger Larsson <roger.larsson@norran.net>, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, Sep 25, 2000 at 04:27:24PM +0200, Ingo Molnar wrote:
> i think an application should not fail due to other applications
> allocating too much RAM. OOM behavior should be a central thing and based

At least Linus's point is that doing perfect accounting (at least on the
userspace allocation side) may cause you to waste resources, failing even if
you could still run and I tend to agree with him. We're lazy on that
side and that's global win in most cases.

We are finegrined with page granularity, not with the mmap granularity.

The point is that not all the mmapped regions are going to be pagedin.  Think a
program that only after 1 hour did all the calculations that allocated all
the memory it requested with malloc.  Before the hour passes the unused memory
can still be used for other things and that's what the user also expects
when he runs `free`.

Andrea
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
