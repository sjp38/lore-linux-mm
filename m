Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id D69E56B003D
	for <linux-mm@kvack.org>; Mon, 11 May 2009 09:36:40 -0400 (EDT)
Date: Mon, 11 May 2009 10:36:51 -0300
From: Mauro Carvalho Chehab <mchehab@infradead.org>
Subject: Re: [PATCH] videobuf-dma-contig: zero copy USERPTR support V3
Message-ID: <20090511103651.49d852f8@pedra.chehab.org>
In-Reply-To: <20090508130658.813e29c1.akpm@linux-foundation.org>
References: <20090508085310.31326.38083.sendpatchset@rx1.opensource.se>
	<20090508130658.813e29c1.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Magnus Damm <magnus.damm@gmail.com>, linux-media@vger.kernel.org, hverkuil@xs4all.nl, linux-mm@kvack.org, lethal@linux-sh.org, hannes@cmpxchg.org
List-ID: <linux-mm.kvack.org>

Em Fri, 8 May 2009 13:06:58 -0700
Andrew Morton <akpm@linux-foundation.org> escreveu:

> On Fri, 08 May 2009 17:53:10 +0900
> Magnus Damm <magnus.damm@gmail.com> wrote:
> 
> > From: Magnus Damm <damm@igel.co.jp>
> > 
> > This is V3 of the V4L2 videobuf-dma-contig USERPTR zero copy patch.
> > 
> > Since videobuf-dma-contig is designed to handle physically contiguous
> > memory, this patch modifies the videobuf-dma-contig code to only accept
> > a user space pointer to physically contiguous memory. For now only
> > VM_PFNMAP vmas are supported, so forget hotplug.
> > 
> > On SuperH Mobile we use this with our sh_mobile_ceu_camera driver
> > together with various multimedia accelerator blocks that are exported to
> > user space using UIO. The UIO kernel code exports physically contiguous
> > memory to user space and lets the user space application mmap() this memory
> > and pass a pointer using the USERPTR interface for V4L2 zero copy operation.
> > 
> > With this approach we support zero copy capture, hardware scaling and
> > various forms of hardware encoding and decoding.
> > 
> > Signed-off-by: Magnus Damm <damm@igel.co.jp>

Acked-by: Mauro Carvalho Chehab <mchehab@redhat.com>

> > ---
> > 
> >  Needs the following patches (Thanks to Johannes Weiner and akpm):
> >  - mm-introduce-follow_pte.patch
> >  - mm-use-generic-follow_pte-in-follow_phys.patch
> >  - mm-introduce-follow_pfn.patch
> 
> I'l plan to merge this and the above three into 2.6.31-rc1 unless it
> all gets shot down.

Andrew,
Due to the the dependencies with the above patches, it seems better if you
could send this patch upstream together with the above patches.

> 
> > +static int videobuf_dma_contig_user_get(struct videobuf_dma_contig_memory *mem,
> > +					struct videobuf_buffer *vb)

> If this function really so obvious and trivial that it is best to merge
> it without any documentation at all?  Has it been made as easy for
> others to maintain as we can possibly make it?
> 
> What does it do, how does it do it and why does it do it?

A good documentation is a really good idea here. There videobuf internals are
very complex. A good documentation for it is very important to keep it updated.

I would also suggest if you could also take a look at videobuf-vmalloc and implement a
similar method to provide USERPTR. The vmalloc flavor can easily be tested with
the virtual (vivi) video driver, so it helps people to better understand how
videobuf works. It will also help the USB drivers that use videobuf to use USERPTR.



Cheers,
Mauro

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
