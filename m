Date: Wed, 04 Feb 2004 07:57:37 -0800
From: "Martin J. Bligh" <mbligh@aracnet.com>
Subject: Re: VM benchmarks
Message-ID: <31020000.1075910255@[10.10.2.4]>
In-Reply-To: <1075908453.6795.149.camel@localhost.localdomain>
References: <401D8D64.8010605@cyberone.com.au> <1075908453.6795.149.camel@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Koni <koni@sgn.cornell.edu>, Nick Piggin <piggin@cyberone.com.au>
Cc: Andrew Morton <akpm@osdl.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> It seems to me that increasing -jX doesn't necessarily result in a
> linear increase in load since the kernel build process has all kinds of
> dependencies and source files distributed in different nested
> subdirectories. Thus, it may not be possible for make to spawn X gcc
> instances say unless there are at least X independent files to compile
> in the directory it's working in. Maybe something about kbuild that I
> don't know, I just use make bzImage.

A full -j on the kernel spawns about 1300 processes constantly on a 16-way,
so there's not too much of a problem there. Make sure you do "make vmlinux"
not "make bzImage" though, as the compression phase is all single-threaded.
There's also a pretty much single-threaded linker phase at the end, which
is unavoidable, but on the whole it scales pretty well.

M.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
