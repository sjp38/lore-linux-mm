Date: Wed, 4 Feb 2004 14:33:09 -0500 (EST)
From: "Richard B. Johnson" <root@chaos.analogic.com>
Reply-To: root@chaos.analogic.com
Subject: Re: Active Memory Defragmentation: Our implementation & problems
In-Reply-To: <20040204191829.57468.qmail@web9704.mail.yahoo.com>
Message-ID: <Pine.LNX.4.53.0402041427270.2947@chaos>
References: <20040204191829.57468.qmail@web9704.mail.yahoo.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alok Mooley <rangdi@yahoo.com>
Cc: linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Dave Hansen <haveblue@us.ibm.com>
List-ID: <linux-mm.kvack.org>

On Wed, 4 Feb 2004, Alok Mooley wrote:

> --- "Richard B. Johnson" <root@chaos.analogic.com> >
> If this is an Intel x86 machine, it is impossible
> > for pages
> > to get fragmented in the first place. The hardware
> > allows any
> > page, from anywhere in memory, to be concatenated
> > into linear
> > virtual address space. Even the kernel address space
> > is virtual.
> > The only time you need physically-adjacent pages is
> > if you
> > are doing DMA that is more than a page-length at a
> > time. The
> > kernel keeps a bunch of those pages around for just
> > that
> > purpose.
> >
> > So, if you are making a "memory defragmenter", it is
> > a CPU time-sink.
> > That's all.
>
> What if the external fragmentation increases so much
> that it is not possible to find a large sized block?
> Then, is it not better to defragment rather than swap
> or fail?
>
> -Alok

All "blocks" are the same size, i.e., PAGE_SIZE. When RAM
is tight the content of a page is written to the swap-file
according to a least-recently-used protocol. This frees
a page. Pages are allocated to a process only one page at
a time. This prevents some hog from grabbing all the memory
in the machine. Memory allocation and physical page allocation
are two different things, I can malloc() a gigabyte of RAM on
a machine. It only gets allocated when an attempt is made
to access a page.

Cheers,
Dick Johnson
Penguin : Linux version 2.4.24 on an i686 machine (797.90 BogoMips).
            Note 96.31% of all statistics are fiction.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
