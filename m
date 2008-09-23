Date: Tue, 23 Sep 2008 20:29:40 +0200
From: Jerome Glisse <glisse@freedesktop.org>
Subject: Re: [patch] mm: pageable memory allocator (for DRM-GEM?)
Message-Id: <20080923202940.a9ce8943.glisse@freedesktop.org>
In-Reply-To: <1222185029.4873.157.camel@koto.keithp.com>
References: <20080923091017.GB29718@wotan.suse.de>
	<1222185029.4873.157.camel@koto.keithp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Keith Packard <keithp@keithp.com>
Cc: Nick Piggin <npiggin@suse.de>, eric@anholt.net, hugh@veritas.com, hch@infradead.org, airlied@linux.ie, jbarnes@virtuousgeek.org, thomas@tungstengraphics.com, dri-devel@lists.sourceforge.net, Linux Memory Management List <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Tue, 23 Sep 2008 08:50:29 -0700
Keith Packard <keithp@keithp.com> wrote:

> On Tue, 2008-09-23 at 11:10 +0200, Nick Piggin wrote:
> > If my cursory reading is correct, then my allocator won't work so well as a
> > drop in replacement because one isn't allowed to know about the filp behind
> > the pageable object. It would also indicate some serious crack smoking by
> > anyone who thinks open(2), pread(2), mmap(2), etc is ugly in comparison...
> 
> Yes, we'd like to be able to use regular system calls for our API, right
> now we haven't figured out how to do that.
> 
> > So please, nobody who worked on that code is allowed to use ugly as an
> > argument. Technical arguments are fine, so let's try to cover them.
> 
> I think we're looking for a mechanism that we know how to use and which
> will allow us to provide compatibility with user space going forward.
> Hiding the precise semantics of the object storage behind our
> ioctl-based API means that we can completely replace in the future
> without affecting user space.
> 

I am starting to ponder if driver specific ioctl for memory object is a
better plan. On intel you have your GTT mapping trick (whether you want
to access an object through GTT or directly map ram page iirc), on radeon
i can think of similar but bit different use case where we can ask to
map some vram with special properties on it so we can access some tiled
surface transparently.

Of course the underlying implementation will share quite bit of code.
I just think that each hw have its own specificity and that trying to
hamer out all this in a common userspace API is not the best thing to do.
I am pretty sure nvidia hw offer some nice trick that won't fit in any
common userspace interface.

So the point is that Nick proposal does make lot of sense and i think
we should let each driver design their own memory object API to fit their
need. We don't have the need for a common interface anymore in DRI2.

Cheers,
Jerome Glisse <glisse@freedesktop.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
