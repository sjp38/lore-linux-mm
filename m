Message-ID: <20040204191829.57468.qmail@web9704.mail.yahoo.com>
Date: Wed, 4 Feb 2004 11:18:29 -0800 (PST)
From: Alok Mooley <rangdi@yahoo.com>
Subject: Re: Active Memory Defragmentation: Our implementation & problems
In-Reply-To: <Pine.LNX.4.53.0402041402310.2722@chaos>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: root@chaos.analogic.com
Cc: linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Dave Hansen <haveblue@us.ibm.com>
List-ID: <linux-mm.kvack.org>

--- "Richard B. Johnson" <root@chaos.analogic.com> >
If this is an Intel x86 machine, it is impossible
> for pages
> to get fragmented in the first place. The hardware
> allows any
> page, from anywhere in memory, to be concatenated
> into linear
> virtual address space. Even the kernel address space
> is virtual.
> The only time you need physically-adjacent pages is
> if you
> are doing DMA that is more than a page-length at a
> time. The
> kernel keeps a bunch of those pages around for just
> that
> purpose.
> 
> So, if you are making a "memory defragmenter", it is
> a CPU time-sink.
> That's all.

What if the external fragmentation increases so much
that it is not possible to find a large sized block?
Then, is it not better to defragment rather than swap
or fail?

-Alok

__________________________________
Do you Yahoo!?
Yahoo! SiteBuilder - Free web site building tool. Try it!
http://webhosting.yahoo.com/ps/sb/
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
