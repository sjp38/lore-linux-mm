Message-ID: <38DB1772.5665EFA2@intermec.com>
Date: Fri, 24 Mar 2000 08:21:22 +0100
From: lars brinkhoff <lars.brinkhoff@intermec.com>
MIME-Version: 1.0
Subject: Re: madvise (MADV_FREE)
References: <20000322233147.A31795@pcep-jamie.cern.ch> <Pine.BSO.4.10.10003231332080.20600-100000@funky.monkey.org> <20000324012149.C20140@pcep-jamie.cern.ch>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jamie Lokier <lk@tantalophile.demon.co.uk>
Cc: Chuck Lever <cel@monkey.org>, linux-mm@kvack.org, jdike@karaya.com
List-ID: <linux-mm.kvack.org>

Jamie Lokier wrote:
> Well, I guess we will never know until it has been tried, but it looks
> like it should be experimented with by someone writing a garbage
> collector before it becomes a standard kernel feature.  I really don't
> like the way mprotect breaks syscalls though, even if it performs well.

And please remember that not only garbage collectors can benefit from dirty
and accessed bits.  There are a number of applications doing paging in user
space.  For example, the Brown Simulator
(http://www.cs.brown.edu/software/brownsim/)
and a386 (http://a386.nocrew.org/) both provide virtual CPUs with MMUs which
can run operating system kernels.  Per-page accessed and dirty information
from the hosting kernel would ease the implementation of a simulated MMU.

Perhaps also the user-mode Linux kernel would benefit, but I'm not sure.
Jeff?
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
