Date: Thu, 19 Apr 2001 17:58:38 +0200 (MEST)
From: Simon Derr <Simon.Derr@imag.fr>
Subject: Re: Want to allocate almost all the memory with no swap
In-Reply-To: <nl1udt010qnhu78ccoc2bv286h6r3hfn9r@4ax.com>
Message-ID: <Pine.LNX.4.21.0104191755240.10028-100000@guarani.imag.fr>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
Cc: Simon Derr <Simon.Derr@imag.fr>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 19 Apr 2001, James A. Sutherland wrote:

> On Thu, 19 Apr 2001 17:39:23 +0200 (MEST), you wrote:
> 
> >Hi,
> >
> >I'm currently trying to run a high-performance bench on a cluster of PCs
> >under Linux. This bench is the Linpack test, and needs a lot of memory to
> >store a matrix of numbers. Linpack needs to allocate as much as 240 Megs
> >on a machine that has 256 Megs of RAM, but I have to be sure that the
> >memory used by linpack will never be swapped on the disk.
> 
> Call mlockall() to lock all your memory into physical RAM - there's a
> flag to set which ensures all your future allocations are locked as
> well. You should be left with 16 Mb of physical RAM free, plus swap,
> so you should be able to do this as long as the machine isn't too
> heavily loaded at the time - no running Netscape during benchmarks :-)

Well, I have removed as many processes deamons as I could, and there are
not many left.
But under both 2.4.2 and 2.2.17 (with swap on)I get, when I run my
program:

mlockall: Cannot allocate memory

	Simon.
     

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
