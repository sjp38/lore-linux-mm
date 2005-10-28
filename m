Received: by zproxy.gmail.com with SMTP id n29so402143nzf
        for <linux-mm@kvack.org>; Fri, 28 Oct 2005 00:59:08 -0700 (PDT)
Message-ID: <6934efce0510280059i4c7483areee8432b62533cab@mail.gmail.com>
Date: Fri, 28 Oct 2005 00:59:08 -0700
From: Jared Hulbert <jaredeh@gmail.com>
Subject: Re: VM_XIP Request for comments
In-Reply-To: <20051027190933.GC16211@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT
Content-Disposition: inline
References: <6934efce0510251542j66c0a738qe3c37fe56aaaaf2d@mail.gmail.com>
	 <20051027190933.GC16211@infradead.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 10/27/05, Christoph Hellwig <hch@infradead.org> wrote:
> On Tue, Oct 25, 2005 at 03:42:25PM -0700, Jared Hulbert wrote:
> > What would it take to get this first patch in the kernel?
> >
> > The reason for the first patch is in the second patch, which I will
> > try to get into the kernel list.  With this mmap()'ed files can be
> > used directly from flash when possible and COW's it when necessary..
>
> Can't you use the XIP infrastructure we already have?  Grep for
> CONFIG_XIP and CONFIG_EXT2_FS_XIP

I can't find CONFIG_XIP.  But I assume you are talking about
filemap_xip.c and Documentation/filesystems/xip.txt.

Hmm.

I don't know. The code and discussions about it looked very big-iron
DSCC specific but now on second pass it was meant to more generic.  If
I can learn this infrastructure then maybe this will work.

So I'm supposed to create a function in the target fs that gets
plugged into get_xip_page().  Then I call that function to create an
proper XIP'ed page in my mmap() and fread() calls.  I could use the
first arg of get_xip_page() to pass in the start address of the cramfs
volume and the second the offset of the page in the file I want to
map.

Is that about right?

This is a lot more overhead than the current XIP Linear CRAMFS patches
but it would allow me choose a page-by-page compression/XIP scheme
rather than the file-by-file compression/XIP currently used in cramfs.
 Hmm.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
