Date: Mon, 25 Sep 2000 15:02:58 +0200
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: the new VM
Message-ID: <20000925150258.B13011@athlon.random>
References: <Pine.LNX.4.21.0009242143040.2029-100000@freak.distro.conectiva> <Pine.LNX.4.21.0009251229110.1459-100000@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.21.0009251229110.1459-100000@elte.hu>; from mingo@elte.hu on Mon, Sep 25, 2000 at 12:42:09PM +0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: Marcelo Tosatti <marcelo@conectiva.com.br>, Linus Torvalds <torvalds@transmeta.com>, Rik van Riel <riel@conectiva.com.br>, Roger Larsson <roger.larsson@norran.net>, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, Sep 25, 2000 at 12:42:09PM +0200, Ingo Molnar wrote:
> believe could simplify unrelated kernel code significantly. Eg. no need to
> check for NULL pointers on most allocations, a GFP_KERNEL allocation
> always succeeds, end of story. This behavior also has the 'nice'

Sorry I totally disagree. If GFP_KERNEL are garanteeded to succeed that is a
showstopper bug. We also have another showstopper bug in getblk that will be
hard to fix because people was used to rely on it and they wrote dealdock prone
code.

You should know that people not running benchmarks and and using the machine
power for simulations runs out of memory all the time. If you put this kind of
obvious deadlock into the main kernel allocator you'll screwup the hard work to
fix all the other deadlock problems during OOM that is been done so far. Please
fix raid1 instead of making things worse.

Andrea
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
