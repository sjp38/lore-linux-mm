From: Al Boldi <a1426z@gawab.com>
Subject: Re: vm/fs meetup in september?
Date: Sat, 30 Jun 2007 17:58:16 -0400
References: <20070624042345.GB20033@wotan.suse.de> <20070630093243.GD22354@infradead.org> <87bqexiwu3.wl%peter@chubb.wattle.id.au>
In-Reply-To: <87bqexiwu3.wl%peter@chubb.wattle.id.au>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200706301758.16607.a1426z@gawab.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: peter@chubb.wattle.id.au
Cc: Christoph Hellwig <hch@infradead.org>, Jared Hulbert <jaredeh@gmail.com>, Nick Piggin <npiggin@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

peter@chubb.wattle.id.au wrote:
> >>>>> "Christoph" == Christoph Hellwig <hch@infradead.org> writes:
>
> Christoph> On Tue, Jun 26, 2007 at 10:07:24AM -0700, Jared Hulbert
>
> Christoph> wrote:
> >> If you have a large array of a non-volatile semi-writeable memory
> >> such as a highspeed NOR Flash or some of the similar emerging
> >> technologies in a system.  It would be useful to use that memory as
> >> an extension of RAM.  One of the ways you could do that is allow
> >> pages to be swapped out to this memory.  Once there these pages
> >> could be read directly, but would require a COW procedure on a
> >> write access.  The reason why I think this may be a vm/fs topic is
> >> that the hardware makes writing to this memory efficiently a
> >> non-trivial operation that requires management just like a
> >> filesystem.  Also it seems to me that there are probably overlaps
> >> between this topic and the recent filemap_xip.c discussions.
>
> Christoph> So what you mean is "swap on flash" ?  Defintively sounds
> Christoph> like an interesting topic, although I'm not too sure it's
> Christoph> all that filesystem-related.

I wouldn't want to call it swap, as this carries with it block-io 
connotations.  It's really mmap on flash.

> You need either a block translation layer,

Are you suggesting to go through the block layer to reach the flash?

> or a (swap) filesystem that
> understands flash peculiarities in order to make such a thing work.
> The standard Linux swap format will not work.

Correct.

BTW, you may want to have a look at my "[RFC] VM: I have a dream..." thread.

Here is an excerpt:

"What's more, there is no more swap.
Apps are executed inplace, as if already loaded.
Physical RAM is used to cache slower storage RAM, much the same as the CPU 
cache RAM caches slower physical RAM."

The thread ended with this conclusion:

Alan Cox wrote:
> On Iau, 2006-02-02 at 21:59 +0300, Al Boldi wrote:
> > So w/ 1GB RAM, no swap, and 1TB disk mmap'd, could this mmap'd space be
> > added to the total memory available to the OS, as is done w/ swap?
>
> Yes in theory. It would be harder to manage.
>
> > And if that's possible, why not replace swap w/ mmap'd disk-space?
>
> Swap is just somewhere to stick data that isnt file backed, you could
> build a swapless mmap based OS but it wouldn't be quite the same as
> Unix/Linux are.


Thanks!

--
Al

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
