Date: Thu, 24 Feb 2000 16:15:30 +0100
From: Jamie Lokier <lk@tantalophile.demon.co.uk>
Subject: Re: mmap/munmap semantics
Message-ID: <20000224161530.G7129@pcep-jamie.cern.ch>
References: <Pine.LNX.3.96.1000224100022.13614A-100000@kanga.kvack.org> <Pine.LNX.4.10.10002241601460.27227-100000@linux14.zdv.uni-tuebingen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <Pine.LNX.4.10.10002241601460.27227-100000@linux14.zdv.uni-tuebingen.de>; from Richard Guenther on Thu, Feb 24, 2000 at 04:03:35PM +0100
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Richard Guenther <richard.guenther@student.uni-tuebingen.de>
Cc: kernel@kvack.org, "Stephen C. Tweedie" <sct@redhat.com>, Linux Kernel List <linux-kernel@vger.rutgers.edu>, glame-devel@lists.sourceforge.net, Linux-MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Richard Guenther wrote:
> Oops, so I misread the code in drivers/char/mem.c ... well, so how can I
> get the same effect as for the private mapping? Not at the moment, I
> think? So memset should be faster than reading from /dev/zero?

Try them both.  /dev/zero may be faster eventually, once kiobufs do
clever things.  For the moment they should be about the same speed apart
from syscall entry cost, so zeroing a large region would be fine with
/dev/zero, and for a small region even when kiobufs are working, you
probably don't want the overhead of messing with page tables for a small
region.

enjoy,
-- Jamie
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
