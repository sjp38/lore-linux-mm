Date: Thu, 24 Feb 2000 16:03:35 +0100 (MET)
From: Richard Guenther <richard.guenther@student.uni-tuebingen.de>
Subject: Re: mmap/munmap semantics
In-Reply-To: <Pine.LNX.3.96.1000224100022.13614A-100000@kanga.kvack.org>
Message-ID: <Pine.LNX.4.10.10002241601460.27227-100000@linux14.zdv.uni-tuebingen.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: kernel@kvack.org
Cc: Richard Guenther <richard.guenther@student.uni-tuebingen.de>, "Stephen C. Tweedie" <sct@redhat.com>, Jamie Lokier <lk@tantalophile.demon.co.uk>, Linux Kernel List <linux-kernel@vger.rutgers.edu>, glame-devel@lists.sourceforge.net, Linux-MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, 24 Feb 2000 kernel@kvack.org wrote:

> On Thu, 24 Feb 2000, Richard Guenther wrote:
> 
> > Cool, too. So for now we will stay with zeroing by reading from /dev/zero
> > which does vm tricks in linux already.
> 
> It does not do tricks when you are dealing with a shared mapping.

Oops, so I misread the code in drivers/char/mem.c ... well, so how can I
get the same effect as for the private mapping? Not at the moment, I
think? So memset should be faster than reading from /dev/zero?

Richard.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
