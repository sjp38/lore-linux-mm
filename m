Date: Wed, 4 Feb 2004 14:07:52 -0500 (EST)
From: "Richard B. Johnson" <root@chaos.analogic.com>
Reply-To: root@chaos.analogic.com
Subject: Re: Active Memory Defragmentation: Our implementation & problems
In-Reply-To: <20040204185446.91810.qmail@web9705.mail.yahoo.com>
Message-ID: <Pine.LNX.4.53.0402041402310.2722@chaos>
References: <20040204185446.91810.qmail@web9705.mail.yahoo.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alok Mooley <rangdi@yahoo.com>
Cc: Dave Hansen <haveblue@us.ibm.com>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, 4 Feb 2004, Alok Mooley wrote:

>
> --- Dave Hansen <haveblue@us.ibm.com> wrote:
>
> > The "work until we get interrupted and restart if
> > something changes
> > state" approach is very, very common.  Can you give
> > some more examples
> > of just how a page fault would ruin the defrag
> > process?
> >
>
> What I mean to say is that if we have identified some
> pages for movement, & we get preempted, the pages
> identified as movable may not remain movable any more
> when we are rescheduled. We are left with the task of
> identifying new movable pages.
>
> -Alok
>

If this is an Intel x86 machine, it is impossible for pages
to get fragmented in the first place. The hardware allows any
page, from anywhere in memory, to be concatenated into linear
virtual address space. Even the kernel address space is virtual.
The only time you need physically-adjacent pages is if you
are doing DMA that is more than a page-length at a time. The
kernel keeps a bunch of those pages around for just that
purpose.

So, if you are making a "memory defragmenter", it is a CPU time-sink.
That's all.

Cheers,
Dick Johnson
Penguin : Linux version 2.4.24 on an i686 machine (797.90 BogoMips).
            Note 96.31% of all statistics are fiction.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
